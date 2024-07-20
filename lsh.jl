
abstract type hash_family end

dot_p_t(b, x, t, w) = floor((sum(b .* (x.^2)) + t) / w)

function create_simhash(K::Tuple; w=float_type(25))
    b = randn(float_type, K...)
    t = rand(float_type)*w 
    h(x) = dot_p_t(b, x, t, w) # add epsilon to avoid zero
    return h
end

struct Simhash <: hash_family
    num_AND::Int
    num_OR::Int
    hash_functions::Vector{Function}
    w::float_type
    # shape needs to be a tuple of Ints, i.e. (256, 256)
    function Simhash(num_AND::Int, num_OR::Int, shape::Tuple; 
            num_hash=num_AND*num_OR, w=float_type(25))
        hash_functions = [create_simhash(shape; w=w) for _ = 1:num_hash]
        new(num_AND, num_OR, hash_functions)
    end
end

function (m::Simhash)(feature_vec)
    hash_signitures = Vector{NTuple{m.num_AND, float_type}}(undef, m.num_OR)
    @inbounds for i = 1:m.num_OR
        hash_signitures[i] = Tuple(m.hash_functions[(i-1)*m.num_OR+j](feature_vec)
            for j = 1:m.num_AND)
    end
    return hash_signitures
end

function (m::Simhash)(feature_vec, hashed_vals, seq, _range_::UnitRange)
    @inbounds for (index, i) in enumerate(_range_)
        hashed_vals[i,seq] = m.hash_functions[index](feature_vec)
    end
end

get_num_hash(hash::hash_family) = length(hash.hash_functions)
get_num_ANDs(hash::hash_family) = hash.num_AND
get_num_ORs(hash::hash_family) = hash.num_OR
