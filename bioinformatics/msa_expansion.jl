using StaticArrays

"""
nz_components_storage: 
    Dict{seq => (pos, fil)}
ind2fil_use: 
    Dict{ind => fil (in use_indices)}

return pos: 
    Dict{fil => Vector{Tuple{UnitRange{Int}, Int}}}
                (position span, sequence index)
"""

function nz_components_storage_to_pos(nz_components_storage, fil2ind_use, hp)
    # Tuple{UnitRange{Int}, Int} is position span and sequence index
    pos = [Vector{Tuple{UnitRange{Int}, Int}}() for _ = 1:fil2ind_use.count]
    for seq in keys(nz_components_storage)
        for t in nz_components_storage[seq]
            position, fil = t[1], t[2]
            push!(pos[fil2ind_use[fil]], (position:position+hp.pfm_len-1, seq))
        end
    end
    return pos
end

function countvec2ic(countvec; ps=float_type(1e-5), bg=float_type(0.25))
    countvec = countvec .+ ps
    countvec_sum = sum(countvec)
    freqvec = countvec ./ countvec_sum
    ic_here = info_content(freqvec; bg=bg)
    return ic_here
end

get_expand_ind_left(pos_range, delta)  = pos_range[1] - delta
get_expand_ind_right(pos_range, delta) = pos_range[end] + delta

function countvec_at_pos!(countvec, seq, onehotarr, index)
    if 1 ≤ index ≤ size(onehotarr,2)
        countvec .+= (@view onehotarr[:, index, 1, seq])
    end
end

function left_expansion(onehotarr, pos_f, left_dec, ic_threshold; 
        tol=float_type(0.975))
    countvec = @MVector zeros(float_type, 4)
    for (pos_range, seq) in pos_f
        index = get_expand_ind_left(pos_range, left_dec)
        countvec_at_pos!(countvec, seq, onehotarr, index)
    end
    ic_here = countvec2ic(countvec)
    percentage_used = sum(countvec) / length(pos_f)
    return ic_here > ic_threshold && percentage_used > tol
end

function right_expansion(onehotarr, pos_f, right_inc, ic_threshold; 
        tol=float_type(0.975))
    countvec = @MVector zeros(float_type, 4)
    for (pos_range, seq) in pos_f
        ind = pos_range[end] + right_inc
        countvec_at_pos!(countvec, seq, onehotarr, ind)
    end
    ic_here = countvec2ic(countvec)
    percentage_used = sum(countvec) / length(pos_f)
    return ic_here > ic_threshold && percentage_used > tol
end

function expansion_left_right(onehotarr, pos_f, ic_threshold, tol)
    expand_left, expand_right = true, true
    left_dec, right_inc = 1, 1 
    while expand_left
        expand_left = left_expansion(onehotarr, pos_f, left_dec, ic_threshold; tol=tol)
        expand_left ? (left_dec += 1) : (left_dec -= 1)
    end
    while expand_right
        expand_right = right_expansion(onehotarr, pos_f, right_inc, ic_threshold; tol=tol)
        expand_right ? (right_inc += 1) : (right_inc -= 1)
    end
    return left_dec, right_inc
end

function msa_expansion(pos, onehotarr, fil2ind_use; 
        ic_threshold=float_type(1.0), tol=float_type(0.975))
    # Tuple{Int, Int} is (left decrement, right increment)
    # expansions vector is of the size of the number of filters
    expansions = Vector{Tuple{Int, Int}}(undef, fil2ind_use.count)    
    for (ind, pos_f) in enumerate(pos)
        if !isempty(pos_f)
            expansions[ind] = expansion_left_right(onehotarr, pos_f, ic_threshold, tol)
        else
            expansions[ind] = (0, 0)
        end
    end
    return expansions
end

"""
Given:
    nz_components_storage: Dict{seq => (pos, fil)}
    onehotarr: Array{Float32,4}
    fil2ind_use:  Dict{fil => ind (in use_indices)}
    hp: HyperParameter (for pfm_len)
Return:
    expansions: Vector{Tuple{Int, Int}}
                (left decrement, right increment)
            each element corresponds to a filter (use ind2fil_use to map)
"""
function obtain_expansions(nz_components_storage, onehotarr, fil2ind_use, hp;
    ic_threshold=float_type(1.0), tol=float_type(0.975))
    pos = nz_components_storage_to_pos(nz_components_storage, fil2ind_use, hp)
    expansions = msa_expansion(pos, onehotarr, fil2ind_use; 
        ic_threshold=ic_threshold, tol=tol)
    return expansions
end