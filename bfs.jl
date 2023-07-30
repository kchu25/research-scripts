
"""
get connected compomnents from an adjacency matrix
"""

function get_connected_components(adj_matrix)
    n = size(adj_matrix,1)
    visited = falses(n)
    ccs = Vector{Vector{Int}}()
    visited[1] = true
    q = [1]
    while !all(visited)
        next_unvisited_node = findall(visited .== 0)[1] 
        visited[next_unvisited_node] = true
        q = [next_unvisited_node]
        cc_here = [next_unvisited_node]
        while length(q) > 0
            v_popped = popfirst!(q)
            neighbors = findall((@view adj_matrix[v_popped,:]) .> 0)
            for neighbor in neighbors
                if !visited[neighbor]
                    visited[neighbor] = true
                    push!(cc_here, neighbor)
                    push!(q, neighbor)
                end
            end
        end
        push!(ccs, cc_here)
    end
    return ccs
end