#=
Given a list of intervals in the form Vector{UnitRange{Int}},
union_intervals returns a list of merged intervals;
i.e. each interval in the result is mutually non-overlapping
=#
function union_intervals(intervals)
    # Sort intervals by their start point
    sorted_intervals = sort(intervals, by=x->first(x))
    # Initialize the merged intervals with the first one
    merged = [sorted_intervals[1]]    
    for interval in sorted_intervals[2:end]
        last_merged = merged[end]
        if last_merged.stop ≥ interval.start - 1  # Check if intervals overlap or are adjacent
            # Merge the intervals by updating the stop point
            merged[end] = last_merged.stop > interval.stop ? last_merged : last_merged.start:interval.stop
        else
            push!(merged, interval)  # If no overlap, add the interval to the result
        end
    end    
    return merged
end
