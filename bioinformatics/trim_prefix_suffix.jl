
# given a list of sequences, i.e. Vector{String}, find the longest common prefix and suffix
# and remove them from each sequence

function longest_common_prefix(sequences)
    prefix = sequences[1]
    for seq in sequences[2:end]
        n = findfirst(i -> prefix[i] ≠ seq[i], 1:min(length(prefix), length(seq)))
        prefix = isnothing(n) ? prefix : prefix[1:n-1]
    end
    return prefix
end

function longest_common_suffix(sequences)
    reversed_seqs = [reverse(seq) for seq in sequences]
    suffix = longest_common_prefix(reversed_seqs)
    return reverse(suffix)
end

function trim_common_ends(sequences)
    prefix = longest_common_prefix(sequences)
    suffix = longest_common_suffix(sequences)
    plen, slen = length(prefix), length(suffix)
    return [seq[plen+1:end-slen] for seq in sequences]
end

longest_common_prefix(df.seq)
longest_common_suffix(df.seq)

df.seq = trim_common_ends(df.seq)

countmap(length.(df.seq))