
pfm =  [0.02  1.0  0.98  0.0   0.0   0.0   0.98  0.0   0.18  1.0
        0.98  0.0  0.02  0.19  0.0   0.96  0.01  0.89  0.03  0.0
        0.0   0.0  0.0   0.77  0.01  0.0   0.0   0.0   0.56  0.0
        0.0   0.0  0.0   0.04  0.99  0.04  0.01  0.11  0.23  0.0]

function save_as_meme(this_pfm, save_name::String; name="", num_sites=100)
    # write as meme file as well
    io = open(save_name, "w")
    print(io, "MEME version 4\n\n")
    print(io, "ALPHABET= ACGT\n\n")
    print(io, "strands: + -\n\n")
    print(io, "Background letter frequencies\n")
    print(io, "A 0.25 C 0.25 G 0.25 T 0.25\n\n")
    print(io, "MOTIF $name \n")
    print(io, "letter-probability matrix: alength= 4 w= $(size(this_pfm,2)) nsites= $num_sites E= 0\n")
    for i in axes(this_pfm,2)
        print(io, " ")
        for j = 1:4
            print(io, "$(this_pfm[j,i]) ")
        end
        print(io, "\n")
    end
    close(io)
end

save_as_meme(pfm, "save_meme.meme")

