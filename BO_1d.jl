using Random, LinearAlgebra, StatsBase, Plots

kernel(x1, x2, λ, σ) = σ^2 * exp(-norm(x1 - x2)^2 / (2λ^2))

function create_covariance_matrix(X, λ, σ, noise)
   n, K = size(X, 1), zeros(n, n)
   for i in 1:n
       for j in 1:i
           K[i, j] = kernel(X[i, :], X[j, :], λ, σ)
           K[j, i] = K[i, j]
       end
       K[i, i] += noise^2
   end
   return K
end

function create_cross_covariance_matrix(X, X_new, λ, σ)
   n, n_new, K = 
    size(X, 1), size(X_new, 1), zeros(n, n_new)
   for i in 1:n
       for j in 1:n_new
           K[i, j] = kernel(X[i, :], X_new[j, :], λ, σ)
       end
   end
   return K
end

#### for zygote
function create_cross_covariance_matrix_wo_mutation(X, x_new, λ, σ)
   size_X = size(X, 1)
   n_new = size(x_new, 1)
   K = zeros(size_X, n_new)
   K += kernel.((@view X[:]), x_new[1,1], λ, σ)
   return K
end

function create_covariance_matrix_wo_mutation(x_new, λ, σ, noise)
   K = zeros(1,1)
   K += kernel.((@view x_new[:]), (@view x_new[:]), λ, σ)
   return K
end
#####

# Set the random seed for reproducibility
Random.seed!(1234)

# Generate random input values
g(x) = -(4sin(x) + 0.00000000001x^8 - 0.3x + cos(7x))
f(X) = g.(X) .+ randn(length(X)) * 0.1

function return_essentials(X, X_test, y, λ, σ, noise)
   K = create_covariance_matrix(X, λ, σ, noise);
   K_starstar = create_covariance_matrix(X_test, λ, σ, 0.0);
   K_star_X = create_cross_covariance_matrix(X, X_test, λ, σ);
   K_inv = inv(K)
   mu(x) = (create_cross_covariance_matrix_wo_mutation(X, x, λ, σ)' * K_inv * y)
   sig(x) = begin
       K_starstar = create_covariance_matrix_wo_mutation(x, λ, σ, 0.0)
       K_star_X = create_cross_covariance_matrix_wo_mutation(X, x, λ, σ)
       return (sqrt.(K_starstar - K_star_X' * K_inv * K_star_X))
   end
   return K, K_starstar, K_star_X, K_inv, mu, sig
end

using Distributions, Flux
const n = Normal(0,1)

function ei(pt, fx_star, n, mu, sig; xi=1.0)
   mu_here = mu(pt) |> sum
   sig_here = sig(pt) |> sum
   diff_term = (mu_here - fx_star - xi)
   diff_term_div_sig = diff_term / sig_here
   ei = diff_term*cdf(n, diff_term_div_sig) + sig_here * pdf(n, diff_term_div_sig)
   return ei
end

function obtain_pt(fx_star, n, mu, sig; xi=1.0)
   pt = randn(1,1) * 3
   ps = Flux.params(pt)
   opt = Flux.AdaBelief()
   for _ = 1:1000
       gs = gradient(ps) do
           # x = sig(pt) |> sum   
           # println("ei_here: ", ei_here)
           -ei(pt, fx_star, n, mu, sig; xi=xi)
       end
       Flux.Optimise.update!(opt, ps, gs) # update parameters
   end
   return pt
end

n_samples = 1
X = randn(n_samples) .* 10
y = f(X)

λ = 5
σ = 16
noise = 48
xi = 1.0

X_test = collect(-30:0.2:30)
X_test_high_res = collect(-30:0.01:30)

anim = Plots.Animation()

for j = 1:250
   @info "Iteration $j"
   K, K_starstar, K_star_X, K_inv, mu, sig =
       return_essentials(X, X_test, y, λ, σ, noise)

   μ = K_star_X' * K_inv * y
   Σ = K_starstar - K_star_X' * K_inv * K_star_X
   plot(X_test_high_res, f(X_test_high_res), label="True function", xlims=(-30, 30), ylims=(-15,15))
   plot!(X_test, μ, ribbon=sqrt.(diag(Σ)), xlims=(-30, 30), ylims=(-15,15),
       fillalpha=0.2, label="Predictive distribution")
   scatter!(X, y, label="Data")
   Plots.frame(anim)

   fx_star = f(X) |> maximum

   pt = obtain_pt(fx_star, n, mu, sig;xi=xi)
   @info "pt: $pt"
   X = vcat(X, pt)
   y = vcat(y, f(pt))
end

gif(anim, fps = 24)
