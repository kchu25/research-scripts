
"""
Take an one-hot encoded sequence and convert it to ACGT string
"""
function one_hot_to_seq(one_hot::AbstractArray{T, 2}) where T <: Real
    nucleotides = "ACGT"
    seq = [nucleotides[argmax(@view one_hot[:, j])] for j in axes(one_hot, 2)]
    return join(seq)
end
