"""
parse a .meme file as pfm Matrix
"""
function file2pfm(file::String; T=Float32)
    f = file |> open
    reads = read(f, String)
    close(f)
    readlines = split(reads, "\n")
    mat = reduce(hcat, split.(readlines[12:end-1], " ", keepempty=false));
    pfm = parse.(T, mat)
    return pfm
end
