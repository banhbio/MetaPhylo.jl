function distance(tree::AbstractPhyloTree, edge::Edge; length_key=:length)
    branch = tree[edge]
    return branch[length_key]
end

#TODO: fix returned type
"""
    distance(tree::AbstractPhyloTree, idx1::Integer, idx2::Integer)
Return distance between two nodes on a tree. 
"""
function distance(tree::AbstractPhyloTree, idx1::Integer, idx2::Integer; kwargs...)
    idx1 == idx2 && return 0.0
    ca = common_ancestor(tree, idx1, idx2)
    map([idx1, idx2]) do idx
        path = findpath(tree, ca, idx)
        edges = Edge.(path[1:end-1], path[2:end])
        distances = distance.(Ref(tree), edges; kwargs...)
    end |> Iterators.flatten |> sum
end

"""
    distance_matrix(tree::AbstractPhyloTree, [indices::Vector{<:Integer}])
Return pairwise distances between all indices on the `tree` as an `AxisArray`.
If not indices are specified, all leaves are used as input.
"""
function distance_matrix(tree::AbstractPhyloTree; kwargs...)
    return distance_matrix(tree, leaves(tree))
end

function distance_matrix(tree::AbstractPhyloTree, idices::Vector{<:Integer})
    return AxisArray([distance(tree, idx1, idx2; kwargs...) for idx1 in indices, idx2 in indices], Axis{:x}(idices), Axis{:y}(indices))
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