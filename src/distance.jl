function distance(tree::Tree, edge::Edge)
    branch = tree[edge]
    return convert(Float64, branch[:length])
end

"""
    distance(tree::Tree, idx1::Integer, idx2::Integer)
Return distance between two nodes on a tree. 
The `Tree` branch types must have the `Length` trait.
"""
function distance(tree::Tree{Code, rooted, rerootable}, idx1::Integer, idx2::Integer) where {Code, rooted, rerootable}
    idx1 == idx2 && return 0.0
    ca = common_ancestor(tree, idx1, idx2)
    map([idx1, idx2]) do idx
        path = findpath(tree, ca, idx)
        edges = Edge.(path[1:end-1], path[2:end])
        distances = distance.(Ref(tree), edges)
    end |> Iterators.flatten |> sum
end

"""
    distance_matrix(tree::Tree)
Return pairwise distances between all leaves on the `tree` in a `AxisArray`.
The `Tree` branch types must have the `Length` trait.
"""
function distance_matrix(tree::Tree)
    ls = leaves(tree)
    return AxisArray([distance(tree, idx1, idx2) for idx1 in ls, idx2 in ls], Axis{:x}(ls), Axis{:y}(ls))
end

#TODO: Is it correct terminology?
"""
    treelength(tree::Tree, [idx::Integer])
Return maximum distance from the root to the leaves in the `tree`. If the index is specified, this returns maximum distance from the specified `idx` to its leaves in the `tree`.
The `Tree` branch types must have the `Length` trait. See also `treeheight`.
"""
treelength(tree::Tree) = treelength(tree, rootindex(tree))

function treelength(tree::Tree, idx::Integer)
    ls = leaves(tree, idx)
    map(ls) do leave
        distance(tree, idx, leave)
    end |> maximum
end