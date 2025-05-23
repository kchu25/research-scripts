const float_type = Float32

const dummy = Dict('A'=>Array{float_type}([1, 0, 0, 0]), 
                   'C'=>Array{float_type}([0, 1, 0, 0]),
                   'G'=>Array{float_type}([0, 0, 1, 0]), 
                   'T'=>Array{float_type}([0, 0, 0, 1]),
                   'N'=>Array{float_type}([0, 0, 0, 0]));

function dna2dummy(dna_string::String, dummy::Dict; F=float_type)
    v = Array{F,2}(undef, (4, length(dna_string)));
    found_n = false
    @inbounds for (index, alphabet) in enumerate(dna_string)
        alphabet_here = uppercase(alphabet)
        alphabet_here == 'N' && (found_n = true)
        v[:,index] = dummy[alphabet_here];
    end
    found_n && (@info "contains N in the string!")
    return v
end

function data_2_dummy(dna_reads; F = float_type) 
    how_many_strings = length(dna_reads);
    @assert how_many_strings != 0 "There aren't DNA strings found in the input";
    _len_ = unique(length.(dna_reads))
    @assert length(_len_) == 1 "All DNA reads must be of same length"
    _S_ = Array{F, 4}(undef, (4, _len_[1], 1, how_many_strings));
    @inbounds for i = 1:how_many_strings
        _S_[:, :, 1, i] = dna2dummy(dna_reads[i], dummy; F=F)
    end
    return _S_
end

function fasta2dummy(fastapath; F=float_type)
    f = open(fastapath)
    reads = read(f, String)
    close(f)
    dna_heads = Vector{String}();
    dna_reads = Vector{String}();
    for i in split(reads, ">")
        if !isempty(i)
            splits = split(i, "\n");
            this_read_head= splits[1];
            this_read = join(splits[2:end]);
            push!(dna_heads, this_read_head);
            push!(dna_reads, this_read);
        end 
    end
    return data_2_dummy(dna_reads; F=F)
end

# e.g. 
fastapath = "./fasta.fa"
data_2_dummy(dna_reads)


######################################