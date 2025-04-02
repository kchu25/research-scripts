using Plots, Statistics, Colors

# Simulate data
n = 50  # Number of data points
x = collect(1:n)
y = rand(10:50, n)  # Random y values
true_slope = 0.5
true_intercept = 5.0

# Generate y' with a linear relationship + noise
noise_std = sqrt(var(y) * 0.5)  # Set noise level to make R^2 ~ 0.5
y_prime = true_slope .* y .+ true_intercept .+ randn(n) .* noise_std

# Compute R^2
y_prime_hat = mean(y_prime) .+ true_slope .* (y .- mean(y))  # Predicted y'
ss_total = sum((y_prime .- mean(y_prime)).^2)
ss_res = sum((y_prime .- y_prime_hat).^2)
r_squared = 1 - ss_res / ss_total

println("R^2 of simulated data: ", round(r_squared, digits=3))

# Confidence values (normalized between 0 and 1)
confidence = rand(0.4:0.01:1.0, n)

# Define color gradient based on confidence
cmap = cgrad(:reds, alpha=[0.5, 1.0])  # Create a colormap with transparency

# Plot the scatter with color determined by confidence
scatter(
    x, y_prime,
    marker_z = confidence,  # Use confidence values for the colorbar
    color = cmap,  # Use the colormap
    colorbar_title = "Confidence",  # Title for the colorbar
    markersize = 5,
    title = "Simulated Data (R² ≈ 0.5)",
    xlabel = "x",
    ylabel = "y'",
    grid = :on,
    framestyle = :box,
    legend = false,  # Disable legend since we have a colorbar
    size = (800, 400)
)