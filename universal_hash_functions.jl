
using Primes

#=
K: length of the input vector
M: a prime number
ref: https://www.cs.cmu.edu/~avrim/451f11/lectures/lect1004.pdf 10.6.1


Create a universal hash function 
    h: Z₊ → Z₊ 
    (Z₊ is the set of positive integers)
Input:
    K: upper bound of the input (positive integers)
    M: a large enough prime number
        (large enough to avoid collisions)
Output:
    h: a universal hash function
        h(x) = (∑ᵢ rᵢ xᵢ) mod M
        where rᵢ are random numbers in {0,1,...,M-1}
=#

function create_universal_hash(K::Int, M::Int)
    @assert isprime(M) "M must be a prime number"
    r = [rand(0:M-1) for _ = 1:K]
    h(x) = sum(r .* x) % M
    return h
end

K= 100
h = create_universal_hash(K,991)

for i = 1:K
    println(h(i))
end

[h(i) for i = 1:K] |> unique |> length

Vector


hs = [create_universal_hash(K,59) for _ = 1:5]
