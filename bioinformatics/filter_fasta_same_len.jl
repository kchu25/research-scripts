


read_fasta

f = open("bioinformatics/fasta.fa")
reads = read(f, String)
close(f)

read_splits = filter(x->!isempty(x), split(reads, ">"))
read_splits_splits = split.(read_splits, "\n")

filter!(x->length(x[2])==100, read_splits_splits)

"""
Take a fasta file and only keep the reads 
    that are of a predefined length

fasta_path: path to the fasta file
save_as: path and name of the new fasta file
len: the pre-defined length of the reads
"""

function load_fasta_and_keep_len(
        fasta_path::String, 
        save_as::String, 
        len::Int)
    f = open(fasta_path)
    reads = read(f, String)
    close(f)
    read_splits = filter(x->!isempty(x), split(reads, ">"))
    read_splits_splits = split.(read_splits, "\n")
    filter!(x->length(x[2])==len, read_splits_splits)

    open(save_as, "w") do fasta_file
        for (header, seq, _) in read_splits_splits
            println(fasta_file, ">$header")
            println(fasta_file, seq)
        end
    end
end