function is_subsequence_with_indices(short, long)
    i, j = 1, 1
    indices = Int[]  # Store matching indices

    while i ≤ length(short) && j ≤ length(long)
        if short[i] == long[j]
            push!(indices, j)  # Store index of match
            i += 1
        end
        j += 1
    end

    return (i > length(short), indices)
end

function check_subsequence_with_indices(t1, t2)
    if length(t1) ≤ length(t2)
        return is_subsequence_with_indices(t1, t2)
    else
        return is_subsequence_with_indices(t2, t1)
    end
end

# Example Usage
t1 = (1, 3, 5)
t2 = (1, 2, 3, 4, 5)

result, indices = check_subsequence_with_indices(t1, t2)
println("Is subsequence: ", result)  # true
println("Match indices: ", indices)  # [1, 3, 5]

result, indices = check_subsequence_with_indices((2, 4), (1, 2, 3, 4, 5))
println("Is subsequence: ", result)  # true
println("Match indices: ", indices)  # [2, 4]

result, indices = check_subsequence_with_indices((2, 5), (1, 2, 3, 4))
println("Is subsequence: ", result)  # false
println("Match indices: ", indices)  # [2] (only the first match found)
