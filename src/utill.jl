conv_to_minumte(date) = dayofyear.(date).*24.0 .* 60.0 .+ hour.(date) .* 60.0 .+ minute.(date)

contractions = [ 
    "ain't "=> "am not / are not / is not / has not / have not ",
    "aren't "=> "are not / am not ",
    "can't "=> "cannot ",
    "can't've "=> "cannot have ",
    "'cause "=> "because ",
    "could've "=> "could have ",
    "couldn't "=> "could not ",
    "couldn't've "=> "could not have ",
    "didn't "=> "did not ",
    "doesn't "=> "does not ",
    "don't "=> "do not ",
    "Don't "=> "do not ",
    "hadn't "=> "had not ",
    "hadn't've "=> "had not have ",
    "hasn't "=> "has not ",
    "haven't "=> "have not ",
    "he'd "=> "he had / he would ",
    "he'd've "=> "he would have ",
    "he'll "=> "he shall / he will ",
    "he'll've "=> "he shall have / he will have ",
    "he's "=> "he has / he is ",
    "how'd "=> "how did ",
    "how'd'y "=> "how do you ",
    "how'll "=> "how will ",
    "how's "=> "how has / how is / how does ",
    "I'd "=> "I had / I would ",
    "I'd've "=> "I would have ",
    "I'll "=> "I shall / I will ",
    "I'll've "=> "I shall have / I will have ",
    "I'm "=> "I am ",
    "I've "=> "I have ",
    "isn't "=> "is not ",
    "it'd "=> "it had / it would ",
    "it'd've "=> "it would have ",
    "it'll "=> "it shall / it will ",
    "it'll've "=> "it shall have / it will have ",
    "it's "=> "it has / it is ",
    "let's "=> "let us ",
    "ma'am "=> "madam ",
    "mayn't "=> "may not ",
    "might've "=> "might have ",
    "mightn't "=> "might not ",
    "mightn't've "=> "might not have ",
    "must've "=> "must have ",
    "mustn't "=> "must not ",
    "mustn't've "=> "must not have ",
    "needn't "=> "need not ",
    "needn't've "=> "need not have ",
    "o'clock "=> "of the clock ",
    "oughtn't "=> "ought not ",
    "oughtn't've "=> "ought not have ",
    "shan't "=> "shall not ",
    "sha'n't "=> "shall not ",
    "shan't've "=> "shall not have ",
    "she'd "=> "she had / she would ",
    "she'd've "=> "she would have ",
    "she'll "=> "she shall / she will ",
    "she'll've "=> "she shall have / she will have ",
    "she's "=> "she has / she is ",
    "should've "=> "should have ",
    "shouldn't "=> "should not ",
    "shouldn't've "=> "should not have ",
    "so've "=> "so have ",
    "so's "=> "so as / so is ",
    "that'd "=> "that would / that had ",
    "that'd've "=> "that would have ",
    "that's "=> "that has / that is ",
    "there'd "=> "there had / there would ",
    "there'd've "=> "there would have ",
    "there's "=> "there has / there is ",
    "they'd "=> "they had / they would ",
    "they'd've "=> "they would have ",
    "they'll "=> "they shall / they will ",
    "they'll've "=> "they shall have / they will have ",
    "they're "=> "they are ",
    "they've "=> "they have ",
    "to've "=> "to have ",
    "wasn't "=> "was not ",
    "we'd "=> "we had / we would ",
    "we'd've "=> "we would have ",
    "we'll "=> "we will ",
    "we'll've "=> "we will have ",
    "we're "=> "we are ",
    "we've "=> "we have ",
    "weren't "=> "were not ",
    "what'll "=> "what shall / what will ",
    "what'll've "=> "what shall have / what will have ",
    "what're "=> "what are ",
    "what's "=> "what has / what is ",
    "what've "=> "what have ",
    "when's "=> "when has / when is ",
    "when've "=> "when have ",
    "where'd "=> "where did ",
    "where's "=> "where has / where is ",
    "where've "=> "where have ",
    "who'll "=> "who shall / who will ",
    "who'll've "=> "who shall have / who will have ",
    "who's "=> "who has / who is ",
    "who've "=> "who have ",
    "why's "=> "why has / why is ",
    "why've "=> "why have ",
    "will've "=> "will have ",
    "won't "=> "will not ",
    "won't've "=> "will not have ",
    "would've "=> "would have ",
    "wouldn't "=> "would not ",
    "wouldn't've "=> "would not have ",
    "y'all "=> "you all ",
    "y'all'd "=> "you all would ",
    "y'all'd've "=> "you all would have ",
    "y'all're "=> "you all are ",
    "y'all've "=> "you all have ",
    "you'd "=> "you had / you would ",
    "you'd've "=> "you would have ",
    "you'll "=> "you shall / you will ",
    "you'll've "=> "you shall have / you will have ",
    "you're "=> "you are ",
    "you've "=> "you have "];


Base.replace(s::String, oldnews::Pair...) = foldl(replace, oldnews, init=s)


function make_plots(smpls, dtm,  wvect, clustmask,  tmask, eng; size = (10, 5), dims=(1,2,3))
        
    clst_tmp = unique(clustmask)
    n_clusters = length(clst_tmp)
    
    fig = plt.figure(figsize=size)
    fig.subplots_adjust(hspace=0.0, wspace=0.00)
    
    bar_col = []
    cl_size = []
    for clust_id in 1:n_clusters
        cl_mask = clustmask .== clust_id
        push!(cl_size, sum(cl_mask))
        push!(bar_col, mean(eng[cl_mask]))
    end
    bar_col_1 = plt.cm.Oranges.(bar_col ./ (maximum(bar_col)+0.1))
    bar_col_2 = plt.cm.Purples.(bar_col ./ (maximum(bar_col)+0.1))
    

    for (clust_ind, clust_val) in enumerate(sortperm(cl_size, rev=true))
        
        cl_mask = clustmask .== clust_val
        
        ax1 = fig.add_subplot(2, n_clusters, clust_ind, projection="3d")
        ax2 = fig.add_subplot(2, n_clusters, n_clusters + clust_ind)
        ax1.scatter(smpls[dims[1],:], smpls[dims[2],:], smpls[dims[3],:], s=1, color="gray", alpha=0.2, zorder=-5, rasterized=true, ) 
        ax1.scatter(smpls[dims[1],cl_mask], smpls[dims[2],cl_mask], smpls[dims[3],cl_mask], s=5, color="red", alpha=0.8, rasterized=true, zorder=5,) 

        ax1.set_xticks([])
        ax1.set_yticks([])
        ax1.set_zticks([])
#         ax1.set_axis_off()
        ax1.set_xticklabels([])
        ax1.set_yticklabels([])
        ax1.set_zticklabels([])
        
        ax1.w_xaxis.line.set_color((1.0, 1.0, 1.0, 0.0))
        ax1.w_yaxis.line.set_color((1.0, 1.0, 1.0, 0.0))
        ax1.w_zaxis.line.set_color((1.0, 1.0, 1.0, 0.0))
        
        ax1.w_xaxis.gridlines.set_lw(0.1)
        ax1.w_yaxis.gridlines.set_lw(0.1)
        ax1.w_zaxis.gridlines.set_lw(0.1)
        
        top_range = collect(1:7)
        
        freq_all = sum(dtm[:,cl_mask], dims=2)[:,1]
        freq_1 = sum(dtm[:,cl_mask.*tmask], dims=2)[:,1]
        
        sort_ind = sortperm(freq_all, rev=true)[top_range]
        
        all_words = wvect[sort_ind]
        
        freq_all = freq_all[sort_ind]
        freq_1 = freq_1[sort_ind] # Start
        
        ax2.bar(top_range, freq_1,  color=bar_col_1[clust_val], alpha=0.9)  
        ax2.bar(top_range, freq_all .- freq_1,  bottom = freq_1, color=bar_col_2[clust_val], alpha=0.9 ) 
        
        ax2.set_xticks(top_range)
        ax2.set_xticklabels(all_words, rotation = 48, fontsize=9, ha="right")
        ax2.set_yticks([])

        ax2.spines["right"].set_visible(false)
        ax2.spines["top"].set_visible(false)
        ax2.spines["left"].set_visible(false)
        ax2.spines["bottom"].set_visible(false)
        
    end
    
    return fig
end

# function sel_top(dataframe, clustmask)
    
#     clst_tmp = unique(clustmask)
#     n_clusters = length(clst_tmp)
    
#     cl_size = []
    
#     for clust_id in 1:n_clusters
#         cl_mask = clustmask .== clust_id
#         push!(cl_size, sum(cl_mask))
#     end
    
#     sorted_df = DataFrame()

#     for (clust_ind, clust_val) in enumerate(sortperm(cl_size, rev=true))
        
#         cl_mask = clustmask .== clust_val
        
#         data_tmp = dataframe[cl_mask,:]
#         top_ind = sortperm(data_tmp.favorite_count, rev=true)[1:50]
#         data_tmp = data_tmp[top_ind,:]
        
#         sort_edit = (
#             clust_id = repeat([clust_ind], length(top_ind)),
#             favorite_count = data_tmp.favorite_count,
#             created_at = data_tmp.created_at,
#             text = data_tmp.text,
#             retweet_count = data_tmp.retweet_count,
#             id_str = data_tmp.id_str,
#             lang = data_tmp.lang,
#         )
        
#         append!(sorted_df, DataFrame(sort_edit)) 
#     end
    
#     return sorted_df
# end

function sel_top(dataframe, clustmask; nitems=50)
    
    clst_tmp = unique(clustmask)
    n_clusters = length(clst_tmp)
    
    cl_size = []
    
    for clust_id in 1:n_clusters
        cl_mask = clustmask .== clust_id
        push!(cl_size, sum(cl_mask))
    end
    
    sorted_df = DataFrame()
    
    ind_spring = dataframe.tind

    for (clust_ind, clust_val) in enumerate(sortperm(cl_size, rev=true))
        
        cl_mask = clustmask .== clust_val
        
        data_tmp = dataframe[cl_mask .* ind_spring,:]
        
        if size(data_tmp, 1) > nitems
            vnitems = nitems
        else
            vnitems = size(data_tmp, 1)
        end
            
        top_ind = sortperm(data_tmp.favorite_count, rev=true)[1:vnitems]
        data_tmp = data_tmp[top_ind,:]
        
        sort_edit = (
            clust_id = repeat([clust_ind], length(top_ind)),
            favorite_count = data_tmp.favorite_count,
            created_at = data_tmp.created_at,
            text = data_tmp.text,
            retweet_count = data_tmp.retweet_count,
            id_str = data_tmp.id_str,
            lang = data_tmp.lang,
        )
        
        append!(sorted_df, DataFrame(sort_edit)) 
        
        # December: 
        
        data_tmp = dataframe[cl_mask .* (.!ind_spring),:]
        
        if size(data_tmp, 1) > nitems
            vnitems = nitems
        else
            vnitems = size(data_tmp, 1)
        end
            
        top_ind = sortperm(data_tmp.favorite_count, rev=true)[1:vnitems]
        data_tmp = data_tmp[top_ind,:]
        
        sort_edit = (
            clust_id = repeat([clust_ind], length(top_ind)),
            favorite_count = data_tmp.favorite_count,
            created_at = data_tmp.created_at,
            text = data_tmp.text,
            retweet_count = data_tmp.retweet_count,
            id_str = data_tmp.id_str,
            lang = data_tmp.lang,
        )
        
        append!(sorted_df, DataFrame(sort_edit)) 
    end
    
    return sorted_df
end