# Ting Wang's average log likelihood ratio

pfm2pwm(pfm) = log2.(pfm ./ eltype(pfm)(0.25));

function allr(p, q, p_count, q_count)
    allr_score = eltype(p)[];
    for i = 1:size(p,2)
        view_p_col = Base.view(p, :, i);
        view_q_col = Base.view(q, :, i);
        nb_p = p_count .* view_p_col;
        nb_q = q_count .* view_q_col;
        a1=sum(nb_p .* pfm2pwm(view_q_col)); 
        a2=sum(nb_q .* pfm2pwm(view_p_col));
        push!(allr_score, (a1+a2)/(sum(nb_p)+sum(nb_q)))
    end
    return sum(allr_score)
end

"""

"""
function convolve_allr(pfm_c2, pfm,
                       counts_pfm_c2,
                       counts_pfm,
                       len_pfm_c2,
                       len_pfm,
                       ; min_col = 5 # at least how many columns in len_pfm_c2 is being compared
                       )
    #= len_pfm_c2 will always be smaller since we've select the ones
        with smaller length
    =#
    allrs = eltype(pfm_c2)[];
    # start and end indices for pwms
    # s1e2 for pfm_c2, s2e2 for pfm
    s1e1s = UnitRange{Int}[];
    s2e2s = UnitRange{Int}[];
    l_dec_1 = Int[]; l_dec_2 = Int[]; 
    r_inc_1 = Int[]; r_inc_2 = Int[];

    for i = 1:(len_pfm_c2+len_pfm-1)
        # slide the pfm wrt pfm_c2 from right to the left with at least one column overlap
        s1 = max(1, len_pfm_c2-i+1); e1 = min(len_pfm_c2, len_pfm_c2-(i-len_pfm));
        s2 = max(1, i-len_pfm_c2+1); e2 = min(i, len_pfm);
        overlap_count = e1-s1+1;
        push!(s1e1s, s1:e1); push!(s2e2s, s2:e2);
        #=  
            Note that:
            1) no need to calculate if the number of columns of the 
            pfm is less than min_col as specified
            2) no need to calculate the placements for which
            maximal value of the score is below the threshold
        =#
        if overlap_count ≥ min_col
            push!(allrs, allr(Base.view(pfm_c2,:,s1:e1), Base.view(pfm,:,s2:e2), 
                            counts_pfm_c2, counts_pfm));
        else
            push!(allrs, -Inf);
        end        
        push!(l_dec_1, max(s2-1,0)); push!(l_dec_2, max(s1-1,0));
        push!(r_inc_1, max(0,len_pfm-i)); push!(r_inc_2, max(i-e2,0));
    end
    argmax_ind = argmax(allrs);
    return allrs[argmax_ind], 
           l_dec_1[argmax_ind], 
           r_inc_1[argmax_ind], 
           l_dec_2[argmax_ind], 
           r_inc_2[argmax_ind]
end