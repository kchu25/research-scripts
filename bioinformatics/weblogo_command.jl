

pfm =  [0.02  1.0  0.98  0.0   0.0   0.0   0.98  0.0   0.18  1.0
        0.98  0.0  0.02  0.19  0.0   0.96  0.01  0.89  0.03  0.0
        0.0   0.0  0.0   0.77  0.01  0.0   0.0   0.0   0.56  0.0
        0.0   0.0  0.0   0.04  0.99  0.04  0.01  0.11  0.23  0.0]

pfm = [
        0.10  2.60  0.01  0.05  4.15  0.02  0.10  0.02 ;
        0.20  0.05  4.10  0.25  0.05  2.60  2.40  0.02 ;
        1.85  0.30  0.11  2.60  0.05  0.20  0.25  2.25 ;
        0.05  0.05  0.01  0.10  0.05  0.08  0.05  0.11 
    ]

pfm = pfm ./ sum(pfm, dims=1)


function save_pfm_as_transfac(pfm, fp::String; count_default=1000)
    io = open(fp, "w")
    println(io, "ID\t")
    println(io, "XX\t")
    println(io, "BF\t")
    println(io, "XX\t")
    println(io, "P0\tA\tC\tG\tT")
    q = Int.(floor.(pfm .* count_default)); # make it a count matrix
    for j in axes(q, 2)
        cur_rows = j < 10 ? string(Int(floor(j)))*"$j" : string(j);
        println(io, cur_rows*"\t$(q[1,j])\t$(q[2,j])\t$(q[3,j])\t$(q[4,j])")
    end
    println(io, "XX\t")
    close(io)
end

fp = "pfm.transfac"
save_pfm_as_transfac(pfm, fp)

Base.run(`weblogo 
        -D transfac 
        -f $fp 
        -n 40 
        -F png_print 
        -s large 
        --title " "
        --title-fontsize 72
        --fineprint ""
        --errorbars NO 
        --resolution 600 
        --fontsize 48 
        --number-fontsize 42
        --color-scheme classic 
        --aspect-ratio 2.1
        --stack-width 82
        --number-interval 60 
        -o $fp.png`
        );


Base.run(`weblogo 
        -D transfac 
        -f $fp 
        -n 40 
        -F png_print 
        -s large 
        --title " "
        --title-fontsize 12
        --fineprint ""
        --errorbars NO 
        --resolution 600 
        --fontsize 24 
        --number-fontsize 16
        --color-scheme classic 
        --aspect-ratio 3.75
        --stack-width 24
        --number-interval 5 
        --show-yaxis YES
        -o $fp.png`
        );

        
"""
--number-interval 50: so no number in the x-axis
--aspect-ratio: Ratio of stack height to width (default: 5)
--stack-width: Width of a logo stack (default: 10.8)
"""