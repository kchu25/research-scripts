using CairoMakie, Random, ColorSchemes
CairoMakie.activate!(type = "svg")
Random.seed!(123)

using Printf
cmaps = [:cool, :viridis, :plasma, :inferno, :thermal,
    :leonardo, :winter, :spring, :ice]
markers = [:+, :diamond, :star4, :rtriangle, :rect,
    :circle, :pentagon, :cross, :star5]


function generate_simulated_data(num_sets::Int, num_points::Int)
    titles = ["Dataset $i" for i in 1:num_sets]
    r_values = 2 .* rand(num_sets) .- 1  # Random r between -1 and 1
    r2_values = r_values .^ 2  # R^2 is just r squared

    predicted = Vector{Vector{Float64}}(undef, num_sets)
    labeled = Vector{Vector{Float64}}(undef, num_sets)

    for i in 1:num_sets
        x = tanh.(randn(num_points) .* 0.5)  # Random input
        noise = randn(num_points) .* 0.2  # Add some noise
        y = r_values[i] .* x + (1 - abs(r_values[i])) .* noise  # Generate y with correlation
        y = tanh.(y)  # Clamp to [-1, 1]

        predicted[i] = x
        labeled[i] = y
    end

    return predicted, labeled, titles, r_values, r2_values
end
num_sets = 3  # Number of scatter plots
num_points = 100  # Points per scatter plot
predicted, labeled, titles, r_values, r2_values = generate_simulated_data(num_sets, num_points)


function FigGridScatters(
        predicted::Vector{Vector{T}}, labeled::Vector{Vector{T}}, 
        titles::Vector{String}, r_values::Vector{T}, r2_values::Vector{T}) where T <: Real
    len_predicted = length(predicted)
    @assert len_predicted == length(labeled) "Lengths of predicted and labeled must be equal"
    fig = Figure(size = (1200, 400), )
        
        for i in 1:len_predicted
            ax = Axis(fig[1, i], aspect = AxisAspect(1), backgroundcolor=:transparent)
            CairoMakie.scatter!(ax, predicted[i], labeled[i];  
                markersize = 8, marker = :circle, strokewidth = 1, 
                strokecolor = :black, color = :orange)
            limits!(ax, -1.1, 1.1, -1.1, 1.1) # assume tanh output
            ax.xticks = [-1, 0, 1]
            ax.yticks = [-1, 0, 1]

            if i != 1
                ax.yticksvisible = false
                ax.yticklabelsvisible = false
            end

            ax.xticklabelsize = 20
            ax.yticklabelsize = 20
            ax.title = titles[i]
            ax.titlealign = :center
            ax.titlefont = :bold
            ax.titlesize = 20
            ax.titlecolor = :black
            ax.titlegap = 10

            
            # Labels
            ax.xlabel = "Predicted value"
            if i == 1
                ax.ylabel = "Label"  # Only on the leftmost plot
            end
        
            # Corrected text placement with `rich()`
            text!(ax, [0.35], [-0.75], 
                text = rich(rich("r = "), @sprintf("%.2f", r_values[i]), font=:regular), 
                fontsize = 20, align = (:left, :center), color = :black
            )
            text!(ax, [0.35], [-0.9], 
                text = rich(rich("R² = "), @sprintf("%.2f", r2_values[i]), font=:regular), 
                fontsize = 20, align = (:left, :center), color = :black
            )
        end
    fig
end

fig = FigGridScatters(predicted, labeled, titles, r_values, r2_values)