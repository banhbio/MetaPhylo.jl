# basic index interface
#TODO: Do we need to restrict access to node and branch that do not exist in the graph?
Base.getindex(tree::Tree, idx::Integer) = tree.node_data[idx]
Base.getindex(tree::Tree, edge::Edge) = tree.branch_data[edge]
Base.getindex(tree::Tree, idx1::Integer, idx2::Integer) = getindex(tree, Edge(idx1, idx2))

Base.haskey(tree::Tree, idx::Integer) = haskey(tree.node_data, idx)
Base.haskey(tree::Tree, edge::Edge) = haskey(tree.branch_data, edge)
Base.haskey(tree::Tree, idx1::Integer, idx2::Integer) = haskey(tree, Edge(idx1, idx2))

Base.setindex!(tree::Tree, data, idx::Integer) = setindex!(tree.node_data, data, idx)
Base.setindex!(tree::Tree, data, edge::Edge) = setindex!(tree.branch_data, data, edge)
Base.setindex!(tree::Tree, data, idx1::Integer, idx2::Integer) = setindex!(tree.branch_data, data, Edge(idx1, idx2))

Base.getindex(tree::Tree, idx::Integer, ::Colon) = IndexNode(tree, idx)
Base.getindex(tree::Tree, ::Colon) = IndexNode(tree)

"""
    parent_edge(tree::Tree, idx::Integer)
Return the edge between the specified `idx` node and its parent node. If the node is root, this returns `nothing` 
"""
function parent_edge(tree::Tree{Code}, idx::Integer) where {Code}
    pidx = parentindex(tree, idx)
    return isnothing(pidx) ? nothing : Edge{Code}(pidx, idx)
end

"""
    leaves(tree::Tree, [idx::Integer])
Return the indices of all leaves in the `tree`. If the index is specified, this returns the indices of leaves in its subtree.
"""
leaves(tree::Tree, idx::Integer) = nodevalue.(Leaves(IndexNode(tree, idx)))
leaves(tree::Tree) = leaves(tree, rootindex(tree))

"""
    leafedges(tree::Tree, [idx::Integer])
Return the edges of all edges connected to the leaves in the `tree`. If the index is specified, this returns the edges connected to its leaves in the `tree`.
"""
leafedges(tree::Tree{Code}, idx::Integer) where {Code} = Vector{Edge{Code}}([parent_edge(tree, lf) for lf in leaves(tree, idx) if rootindex(tree) != lf])
leafedges(tree::Tree) = leafedges(tree, rootindex(tree))

"""
    isleaf(tree::Tree, idx::Integer)
Return `true` if the `idx` is contained in a leaf node of the `tree`.
"""
isleaf(tree::Tree, idx::Integer) = haskey(tree, idx) && idx in leaves(tree)

"""
    isleaf(tree::Tree, edge::Edge)
Return `true` if the `edge` is connected to a leaf node of the `tree`.
"""
isleaf(tree::Tree, edge::Edge) = haskey(tree, edge) && edge in leafedges(tree)

"""
    isinternal(tree::Tree, idx::Integer)
Return `true` if the `idx` is contained in an internal node of the `tree`.
"""
isinternal(tree::Tree, idx::Integer) = haskey(tree, idx) && !isleaf(tree, idx)

"""
    isinternal(tree::Tree, idx::Integer)
Return `true` if the `edge` is both connected to internal nodes of the `tree`.
"""
isinternal(tree::Tree, edge::Edge) = haskey(tree, edge) && !isleaf(tree, edge)

