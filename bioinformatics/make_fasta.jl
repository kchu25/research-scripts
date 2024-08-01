"""
Take in a vector of (vector of two strings)
    1st string: header
    2nd string: sequence
and then make a fasta file
"""
function make_fasta_file(reads::Vector{Vector{T}}; 
    save_path="processed_data/chaolin_psi_1", save_name="seqs.fa"
    ) where T <: AbstractString
    mkpath(save_path)
    open(joinpath(save_path, save_name), "w") do fasta_file
        for (header, seq) in reads
            println(fasta_file, ">$header")
            println(fasta_file, seq)
        end
    end
end

make_fasta_file(reads; save_path="processed_data/chaolin_psi_1", save_name="seqs.fa")