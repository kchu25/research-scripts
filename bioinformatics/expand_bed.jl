using ProgressMeter

inc = 45
const my_genome_path = "/home/shane/Desktop/genome_files/genomes"

#=
note:  araTha1 corresponds to TAIR10
source: https://davetang.org/muse/2017/08/08/getting-started-arabidopsis-thaliana-genomics/
=#

function get_jaspar_bed_genome_used(bed_here::String)
    f = open(bed_here)
    reads = read(f, String)
    close(f)
    reads_line_1 = split(split(reads, "\n")[1], "\t")
    genome_used_here = split(reads_line_1[4], "_")[1]
    return genome_used_here
end


function get_my_genome(genome_str::AbstractString; fai=true)
    if fai
        genome_path = joinpath(my_genome_path, genome_str, "$genome_str.fa.fai")
    else
        genome_path = joinpath(my_genome_path, genome_str, "$genome_str.fa")
    end
    if isfile(genome_path) "genome file not found"
        return genome_path
    else 
        return ""
    end
end

bed_path = "bed"
# take bed file 
jaspar_beds = readdir(bed_path)

existed_genomes = Set{String}()

@showprogress desc = "expanding beds..." for bed in jaspar_beds
    bed_here = joinpath(bed_path, bed)
    genome_here = get_my_genome(get_jaspar_bed_genome_used(bed_here))    
    if genome_here == ""
        println("genome not found for $bed")
        continue
    end
    push!(existed_genomes, genome_here)
    new_bed_path = joinpath("bed_expanded", "$bed")
    command = "bedtools slop -i $bed_here -g $genome_here -b $inc > $new_bed_path"
    command_wrap = `bash -c $command`
    try 
        run(command_wrap)
    catch
        println("error in $bed")
    end
end

bed_expanded_path = readdir("bed_expanded")
jaspar_beds = readdir(bed_path)
