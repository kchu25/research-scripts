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


# Set the random seed for reproducibility
Random.seed!(1234)

# Generate random input values
g(x) = 6sin.(x) .+ 0.0001 * x .^ 6 .- x
f(X) = g.(X) .+ randn(length(X)) * 0.1

n_samples = 55
n_test_samples = 150
X = randn(n_samples) .* 3
y = f(X)

λ = 2
σ = 25.0
noise = 12

X_test = collect(-8:0.01:8)

K = create_covariance_matrix(X, λ, σ, noise);
K_starstar = create_covariance_matrix(X_test, λ, σ, 0.0);
K_star_X = create_cross_covariance_matrix(X, X_test, λ, σ);

K_inv = inv(K)
μ = K_star_X' * K_inv * y
Σ = K_starstar - K_star_X' * K_inv * K_star_X


plot(X_test, f(X_test), label="True function")
plot!(X_test, μ, ribbon=sqrt.(diag(Σ)), fillalpha=0.2, label="Predictive distribution")
scatter!(X, y, label="Data")