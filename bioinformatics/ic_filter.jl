
#=
IC formula:
IC = sum(pfm .* log2.(pfm ./ bg), dims=1)
=#
function pfms_avg_ic(pfm; bg = float_type(0.25))
    ic = sum(pfm .* log2.(pfm ./ bg), dims = 1)
    return sum(ic) / size(pfm, 2)
end

"""
Given a set of position frequency matrices, 
this function returns the indices of the matrices 
that have an average information content greater than the specified 
IC threshold.
"""
function filter_high_IC_pwms(
    pfms::AbstractArray{Float32,4}; 
    ic_thresh = float_type(1.0)
)::Vector{Int}
    pfms = pfms |> cpu
    pfms_array = [pfms[:, :, 1, i] for i in axes(pfms, 4)]
    pfms_avg_ic_values = pfms_avg_ic.(pfms_array)
    return findall(pfms_avg_ic_values .> ic_thresh)
end

# use case 
filter_high_IC_pwms(pfms; ic_thresh = 1.0)