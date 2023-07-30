"""
very simple GP
"""

using Random

# Define the number of input features
n_features = 3

# Set the random seed for reproducibility
Random.seed!(1234)

# Generate random input values
n_samples = 125
n_test_samples = 150
X = randn(n_samples, n_features)
X_test = randn(n_test_samples, n_features)

# Define the true regression coefficients
β = [1.0, 2.0, 3.0, 0.5, 0.8, -0.4]

# Compute the response variable with some interaction terms
make_y(X, β, n) = X * β[1:n_features] .+ X[:, 1] .* X[:, 2] .* β[4] .+ X[:, 1] .* X[:, 3] .* β[5] .+ X[:, 2] .* X[:, 3] .* β[6] .+ randn(n) * 0.5
y = make_y(X, β, n_samples)
y_test = make_y(X_test, β, n_test_samples)

function kernel(x1, x2, λ, σ)
    return σ^2 * exp(-norm(x1 - x2)^2 / (2λ^2))
end

function pkernel(x1,x2,d)
    # polynomial kernel of degree d
    return (dot(x1,x2)+ 1)^d
end


function create_covariance_matrix(X, λ, σ, noise)
    n = size(X, 1)
    K = zeros(n, n)
    for i in 1:n
        for j in 1:i
            # K[i, j] = kernel(X[i, :], X[j, :], λ, σ)
            K[i, j] = pkernel(X[i, :], X[j, :], 3)
            K[j, i] = K[i, j]
        end
        K[i, i] += noise^2
    end
    return K
end

function create_cross_covariance_matrix(X, X_new, λ, σ)
    n = size(X, 1)
    n_new = size(X_new, 1)
    K = zeros(n, n_new)
    for i in 1:n
        for j in 1:n_new
            # K[i, j] = kernel(X[i, :], X_new[j, :], λ, σ)
            K[i, j] = pkernel(X[i, :], X_new[j, :], 3)
        end
    end
    return K
end

λ = 0.1
σ = 10.0
noise = 0.1

K = create_covariance_matrix(X, λ, σ, noise);
K_starstar = create_covariance_matrix(X_test, λ, σ, 0.0);
K_star_X = create_cross_covariance_matrix(X, X_test, λ, σ);

K_inv = inv(K)
μ = K_star_X' * K_inv * y
Σ = K_starstar - K_star_X' * K_inv * K_star_X

# Evaluate the performance of the model using the mean absolute error (MAE)
y_test[1:10]
μ[1:10]
mae = mean(abs.(μ - y_test))
println("Mean Absolute Error: $mae")


# Visualize the results
scatter(y_test, μ, xlabel="True Values", ylabel="Predicted Values", legend=false)
plot!([minimum(y_test), maximum(y_test)], [minimum(y_test), maximum(y_test)], linestyle=:dash, color=:black, xlabel="True Values", ylabel="Predicted Values")