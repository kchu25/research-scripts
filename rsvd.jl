# some rsvd and nystrom sampling examples



using LinearAlgebra
using Random

"""
 X: matrix to perform svd upon
 r: rank-r approximation
 q: number of power iterations
 p: oversampling parameter
"""
function rsvd(X, r, q, p)
    ny = size(X,2)
    P = randn(ny, r+p)
    Z = X * P;
    for _ = 1:q
        Z = X * (X' * Z)
    end
    Q, _ = qr(Z);
    Y = Q' * X;
    U_Y, S, V = svd(Y)
    U = Q * U_Y
    return U, S, V
end

A = randn(300, 90)
U, S, V = rsvd(A, 8, 2, 5)
approximation = U*Diagonal(S)*V'

u,s,v = svd(A)

svd_approx = u * Diagonal(s) * v'
abs.(A -  svd_approx) |> sum
abs.(A - approximation) |> sum

for i = 1:15
    U, S, V = rsvd(A, i, 2, 5)
    println(norm(A - U*Diagonal(S)*V'))
end

Q = A' * A

isposdef(Q[1:35,1:35])

isposdef(Q)

randomly_selected_column_inds = randperm(256)
sample_Q_columns = Q[:, randomly_selected_column_inds]
sampled_columns = sample_Q_columns

function nystrom_sampling_simple(sampled_columns, randomly_selected_column_inds)
    k = size(sampled_columns, 2)
    W = @view sampled_columns[randomly_selected_column_inds,:]
    # isposdef(sampled_columns[randomly_selected_column_inds,:])
    # U, S, _ = rsvd2(W, k, 2, 5)
    U, S, _ = svd(Array(W))
    # abs.(W - U * Diagonal(S) * U')

    W_plus = U * Diagonal(1 ./ S) * U'
end


function nystrom_sampling_simple(sampled_columns, randomly_selected_column_inds)
    k = size(sampled_columns, 2)
    W = @view sampled_columns[randomly_selected_column_inds,:]
    other_row_inds = setdiff(collect(1:size(sampled_columns,1)), randomly_selected_column_inds)
    B = sampled_columns[other_row_inds,:]
    # U, S, _ = rsvd(W, k, 2, 5)
    U, S, _ = svd(W)

    W_sqrt = U * Diagonal(S .^(-0.5)) * U'
    Z = W + W_sqrt * B' * B * W_sqrt
    Us, lambda_s, _ = svd(Z)
    V = sampled_columns * W_sqrt * Us * Diagonal(lambda_s .^ (-0.5))
end

approx = V * Diagonal(lambda_s) * V'
abs.(Q - approx) 
sum(abs.(Q - approx)) / 1000^2



Q_approx = sampled_columns * W_plus * sampled_columns'
abs.(Q - Q_approx) 
(abs.(Q - Q_approx) |> sum ) / 1000^2



using MLDatasets, ImageInTerminal
d = MNIST()

X=reshape(d.features, (28*28, 60000))'
X = X[randperm(60000),:]


X_test = X[1:1000,:]
Q = X_test * X_test'