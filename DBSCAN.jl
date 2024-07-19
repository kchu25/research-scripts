# quick and dirty implementation of DBSCAN clustering algorithm

euc_dist(p1, p2) = sqrt(sum((p1-p2).^2))

function RangeQuery(DB, distFunc, query_ind, eps)
    neighbors = Set{Int}()
    query_pt = @view DB[:, query_ind]
    for (ind, p) in enumerate(eachcol(DB))
        if ind != query_ind && distFunc(p, query_pt) ≤ eps
            push!(neighbors, ind)
        end
    end
    return neighbors
end

function DBSCAN(DB, distFunc; eps=5, minPts=3)
    C = 0           # cluster counter
    N = size(DB, 2) # 
    labels = zeros(Int, N) # labels: 0 - unclassified, -1 - noise, 1, 2, ... - cluster number

    for query_ind = 1:N
        labels[query_ind] != 0 && continue
        neighbors = RangeQuery(DB, distFunc, query_ind, eps)
        if length(neighbors)+1 < minPts  # +1 to include query_ind
            labels[query_ind] = -1 # noise
            continue
        end
        C += 1
        labels[query_ind] = C
        S = neighbors
        while !isempty(S)
            neighbor_ind = pop!(S)
            labels[neighbor_ind] == -1 && (labels[neighbor_ind] = C) # change noise to border point
            labels[neighbor_ind] != 0  && continue # previously processed
            labels[neighbor_ind] = C
            neighbors_there = RangeQuery(DB, distFunc, neighbor_ind, eps)
            if length(neighbors_there)+1 ≥ minPts
                S = union(S, neighbors_there)
            end
        end
    end
    return labels
end
