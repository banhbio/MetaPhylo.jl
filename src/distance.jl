function _distace_from_root(tree::AbstractPhyloTree{Code}, index::Integer; length_key=:length) where Code
    edges = Edge{Code}[]
    current_idx = index
    while true
        pidx = parentindex(tree, current_idx)
        isnothing(pidx) && break
        push!(edges, Edge{Code}(pidx, current_idx))
        current_idx = pidx
    end
    isempty(edges) && return 0.0
    return getindex.(getindex.(Ref(tree), edges), length_key) .|> Float64 |> sum
end

#TODO: fix returned type
"""
    distance(tree::AbstractPhyloTree, idx1::Integer, idx2::Integer)
Return distance between two nodes on a tree. 
"""
function distance(tree::AbstractPhyloTree, idx1::Integer, idx2::Integer; kwargs...)
    ca = common_ancestor(tree, idx1, idx2)
    return _distace_from_root(tree, idx1; kwargs...) + _distace_from_root(tree, idx2; kwargs...) - 2 * _distace_from_root(tree, ca; kwargs...)
end

"""
    distance_matrix(tree::AbstractPhyloTree, [indices::Vector{<:Integer}])
Return pairwise distances between all indices on the `tree` as an `AxisArray`.
If not indices are specified, all leaves are used as input.
"""
function distance_matrix(tree::AbstractPhyloTree; kwargs...)
    return distance_matrix(tree, leaves(tree))
end

function distance_matrix(tree::AbstractPhyloTree, indices::Vector{<:Integer}; kwargs...)
    return AxisArray([distance(tree, idx1, idx2; kwargs...) for idx1 in indices, idx2 in indices], Axis{:x}(indices), Axis{:y}(indices))
end
#TODO: Is it correct terminology?
"""
    treelength(tree::AbstractPhyloTree, [idx::Integer])
Return maximum distance from the root to the leaves in the `tree`. If the index is specified, this returns maximum distance from the specified `idx` to its leaves in the `tree`.
"""
treelength(tree::AbstractPhyloTree) = treelength(tree, rootindex(tree))

function treelength(tree::AbstractPhyloTree, idx::Integer; kwargs...)
    ls = leaves(tree, idx)
    map(ls) do leave
        distance(tree, idx, leave; kwargs...)
    end |> maximum
end