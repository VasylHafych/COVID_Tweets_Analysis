using Flux
using Flux: logitcrossentropy, normalise, onecold, onehotbatch, crossentropy, throttle
using Statistics: mean
using Parameters: @with_kw
using Flux: @epochs

function confusion_matrix(X, y, model)
    ŷ = onehotbatch(onecold(model(X)), 0:1)
    y * transpose(ŷ)
end

accuracy(x, y, model) = mean(onecold(model(x)) .== onecold(y))
loss(x, y, model) = crossentropy(model(x), y) 

function roc_curve(x, y, model; ind_neg = 1, ind_pos = 2, trange = range(0, stop=1, length=350))
    
    fp_rate = Float64[]
    tp_rate = Float64[]
    
    nneg = sum(y[ind_neg,:])
    npos = sum(y[ind_pos,:])
    
    prob = softmax(model(x), dims=1) 
    
    for i in trange
        
        pr_tmp = prob .> i
        pred_pos = pr_tmp[ind_pos,:]
        
        fpr = sum( y[ind_neg,:] .* pred_pos ) / nneg
        tpr = sum( y[ind_pos,:] .* pred_pos) / npos
        
        push!(fp_rate, fpr)
        push!(tp_rate, tpr)
        
    end
    
    s_ind = sortperm(fp_rate)
    x_int = diff(fp_rate[s_ind])
    y_int = tp_rate[s_ind]
    
    auc = sum(y_int[1:end-1] .* x_int + 0.5 .* x_int .* diff(y_int))
    
    return (fpr= fp_rate , tpr = tp_rate, auc = auc)
end

function train(x, y; split_f = 0.75 )
    
    n_params, n_vectors = size(x)
    train_ind = zeros(Bool, n_vectors)
    train_ind[1:round(Int64, split_f*n_vectors)] .= one(Bool)
    shuffle!(train_ind)
    
    x_train, y_train = x[:, train_ind], y[:, train_ind]
    x_test, y_test = x[:, .!train_ind], y[:, .!train_ind]
    
    dat_load = Flux.Data.DataLoader(x_train, y_train, batchsize=100, shuffle=true) #batchsize=500, 
    
    model = Chain(
        Flux.Dense(n_params, 200, sigmoid), 
        Flux.Dense(200, 2, sigmoid), 
        softmax)
    
    accuracy_local(xd, yd) = accuracy(xd, yd, model)
    loss_local(xd, yd) = loss(xd, yd, model)
    
    loss_train_vec = Float64[]
    loss_test_vec = Float64[]
    accuracy_train_vec = Float64[]
    accuracy_test_vec = Float64[]
    
    evalcb = () -> begin 
        loss_train = loss_local(x_train, y_train)
        loss_test = loss_local(x_test, y_test)
        accur_train = accuracy_local(x_train, y_train)
        accur_test = accuracy_local(x_test, y_test)
        push!(loss_test_vec, loss_test)
        push!(loss_train_vec, loss_train)
        push!(accuracy_train_vec, accur_train)
        push!(accuracy_test_vec, accur_test)
        @info(loss_train, loss_test)
    end
    
    optimiser = ADAM()
    # Eng = 6 ep, Rus = 10
    @time @epochs 5 Flux.train!(loss_local, Flux.params(model), dat_load, optimiser, cb = throttle(evalcb, 20, leading=true,))
    
    return (
        model=model, 
        loss = (loss_train_vec, loss_test_vec), 
        acc = (accuracy_train_vec, accuracy_test_vec),
        trdata = (x_train, y_train), 
        tstdata=(x_test, y_test)
    )
end

function params_importance(x, y, par_ind)
    auc_test = Float64[]
    auc_train = Float64[]
    
    for i in par_ind
        
        @show i
        x_tmp = deepcopy(x)
        x_tmp[i,:] .= shuffle(x[i,:])
        
        result_tmp = train(x_tmp, y)

        tr_tmp = roc_curve(result_tmp.trdata..., result_tmp.model).auc
        ts_tmp = roc_curve(result_tmp.tstdata..., result_tmp.model).auc
        
        push!(auc_test, ts_tmp)
        push!(auc_train, tr_tmp)
    end
    
    return (test=auc_test, train=auc_train)
end