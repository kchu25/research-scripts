const _dummy_ = Dict('A'=>Array{float_type}([1, 0, 0, 0]), 
                'C'=>Array{float_type}([0, 1, 0, 0]),
                'G'=>Array{float_type}([0, 0, 1, 0]), 
                'T'=>Array{float_type}([0, 0, 0, 1]),
                'N'=>Array{float_type}([0, 0, 0, 0]));

function dna2dummy(dna_string::AbstractString; dummy::Dict=_dummy_, F=float_type)
    v = Array{F,2}(undef, (4, length(dna_string)));
    @inbounds for (index, alphabet) in enumerate(dna_string)
        alphabet_here = uppercase(alphabet)
        v[:,index] = dummy[alphabet_here];
    end
    return v
end

cat_dim3(x1, x2) = cat(x1, x2, dims=3)

function strs_2_array(seq_use::Vector{String})
    @assert unique(length.(seq_use)) == 1 "All DNA reads must be of same length"
    reduce(cat_dim3, dna2dummy.(seq_use))
end