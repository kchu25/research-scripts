s = "cart";
t = "cat";
n = 3;
lambda = 0.6;

# https://github.com/helq/python-ssk/blob/master/main.py

function ssk(s, t, n, lambda, accum)
    len_s = length(s);
    len_t = length(t);

    k_prime = zeros(n, len_s, len_t);
    k_prime[1,:,:] .= 1;

    for i = 2:n
        for sj = i:len_s
            toret = 0;
            for tk = i:len_t
                if s[sj-1] == t[tk-1]
                    toret = lambda * (toret + lambda * (k_prime[i-1, sj-1, tk-1]));
                else
                    toret *= lambda
                end
                k_prime[i, sj, tk] = toret + lambda * k_prime[i, sj-1, tk];
            end
        end
    end

    start = accum ? 1 : n-1;
    k = 0.0;

    for i = start:n
        for sj = i:len_s
            for tk = i:len_t
                if s[sj] == t[tk]
                    k += lambda*lambda*k_prime[i, sj, tk];
                end
            end
        end
    end
    
    return k
end

# check
ssk(s,t,4,lambda, true) - (3*lambda^2 + lambda^4 + lambda^5 + 2*lambda^7) < 1e-6
ssk("science is organized knowledge", "wisdom is organized life", 4, 1, true) == 20538.0

a = [3, 1, 2, 4, 3, 2, 2, 2, 4, 2, 2]
b = [3, 1, 2, 3, 4, 2, 2, 2, 1, 1, 2]
ssk(a, b, 3, 0.7, false)
c = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2]
ssk(a, c, 3, 0.7, false)