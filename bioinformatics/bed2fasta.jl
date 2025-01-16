using ProgressMeter

const my_genome_path = "/home/shane/Desktop/genome_files/genomes"

#=
Get the genome used here for this bed files
this is using the beds from https://jaspar.elixir.no/download/data/2024/bed.tar.gz
as an example
=#
function get_jaspar_bed_genome_used(bed_here::String)
    f = open(bed_here)
    reads = read(f, String)
    close(f)
    reads_line_1 = split(split(reads, "\n")[1], "\t")
    genome_used_here = split(reads_line_1[4], "_")[1]
    return genome_used_here
end

function get_my_genome(genome_str::String)
    genome_path = joinpath(my_genome_path, genome_str, "$genome_str.fa")
    @assert isfile(genome_path) "genome file not found"
    return genome_path
end


function get_matrix_id(bed::String)
    bed_sep = split(bed, ".")[1:2]
    matrix_id = join(bed_sep, ".")
    return matrix_id
end

get_fasta_name(matrix_id::String) = "fasta/$matrix_id.fa"


bed_path = "bed"
# take bed file 
jaspar_beds = readdir(bed_path)

@showprogress desc = "making beds to fastas..." for bed in jaspar_beds
    bed_here = joinpath(bed_path, bed)
    matrix_id = get_matrix_id(bed)
    genome_str_here = get_jaspar_bed_genome_used(bed_here)
    genome_path = get_my_genome(genome_str_here)
    fasta_here = get_fasta_name(matrix_id)
    commmand = `fastaFromBed -s -fi $genome_path -bed $bed_path_here -fo $fasta_here`
end
