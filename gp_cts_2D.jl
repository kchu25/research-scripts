using Random, LinearAlgebra, StatsBase, Plots

function kernel(x1, x2, λ, σ)
    return σ^2 * exp(-norm(x1 - x2)^2 / (2λ^2))
end

function create_covariance_matrix(X, λ, σ, noise)
    n = size(X, 1)
    K = zeros(n, n)
    for i in 1:n
        for j in 1:i
            K[i, j] = kernel(X[i, :], X[j, :], λ, σ)
            # K[i, j] = pkernel(X[i, :], X[j, :], 3)
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
            K[i, j] = kernel(X[i, :], X_new[j, :], λ, σ)
            # K[i, j] = pkernel(X[i, :], X_new[j, :], 3)
        end
    end
    return K
end

# Define the number of input features
n_features = 2

# Set the random seed for reproducibility
Random.seed!(1234)

f(x,y) = -sin(x)*cos(y) + (x^2 + y^2)/20 - 4 + 0.2*randn()

n_samples = 55
n_test_samples = 150
X = randn(n_samples, n_features) .* 3
y = f.(X[:,1],X[:,2])

λ = 2
σ = 25.0
noise = 12

X_test = randn(1000, n_features) .* 3

K = create_covariance_matrix(X, λ, σ, noise);
K_starstar = create_covariance_matrix(X_test, λ, σ, 0.0);
K_star_X = create_cross_covariance_matrix(X, X_test, λ, σ);

K_inv = inv(K)
μ = K_star_X' * K_inv * y
Σ = K_starstar - K_star_X' * K_inv * K_star_X

y_test = f.(X_test[:,1],X_test[:,2])
# Visualize the results
scatter(y_test, μ, xlabel="True Values", ylabel="Predicted Values", legend=false)