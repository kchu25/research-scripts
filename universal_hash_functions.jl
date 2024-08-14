
using Primes

#=
K: length of the input vector
M: a prime number
ref: https://www.cs.cmu.edu/~avrim/451f11/lectures/lect1004.pdf 10.6.1


Create a universal hash function 
    h: (Z₊)ⁿ → Z₊ 
    (Z₊ is the set of positive integers)
    that takes a vector x = (x₁, x₂, ..., xₙ) as input
    and returns a hash value h(x) in the range {0,1,...,M-1}
    where M is a prime number    
Input:
    K: size (dimension) of the input (positive integers)
    M: a large enough prime number
        (large enough to avoid collisions)
    upperbdd: upper bound for each random input component xᵢ
        (default: 100)
Output:
    h: a universal hash function
        h(x) = (∑ᵢ rᵢ xᵢ) mod M
        where rᵢ are random numbers in {0,1,...,M-1}
=#

function create_universal_hash(K::Int; upperbdd = 100)
    M = nextprime(upperbdd^K)
    r = [rand(0:M-1) for _ = 1:K]
    h(x) = sum(r .* x) % M
    return h
end

K= 5
h = create_universal_hash(K)

h((1,2,3,4,5))
h((3,4,5,6,7))
