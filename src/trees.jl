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

"""
    reindex!(tree::Tree)
Reindex the `tree` in `PreOderDFS` order from the root. 
"""
function reindex!(tree::Tree{Code, rooted, rerootable}) where {Code, rooted, rerootable}
    counterpart = Dict{Code, Code}()

    edges = Edge{Code}[]
    node_data = Pair{Code, Dict{Symbol, Any}}[]
    branch_data = Pair{Edge{Code}, Dict{Symbol, Any}}[]

    for (new_index, idx_node) in enumerate(PreOrderDFS(IndexNode(tree)))
        old_index = idx_node.index
        counterpart[old_index] = new_index
        push!(node_data, new_index=>tree.node_data[old_index])
        pold_index = parentindex(tree, old_index)
        isnothing(pold_index) && continue 
        pnew_index = counterpart[pold_index]
        old_edge = Edge{Code}(pold_index, old_index)
        new_edge = Edge{Code}(pnew_index, new_index)
        push!(edges, new_edge)
        push!(branch_data, new_edge=>tree.branch_data[old_edge])
    end
    graph = DiGraph(edges)
    tree.graph = graph
    tree.root = 1
    tree.node_data = Dict(node_data)
    tree.branch_data = Dict(branch_data)
    return true
end

#TODO: Is it the best way?
function findpath(tree::Tree{Code}, sidx::Integer, tidx::Integer) where {Code<:Integer}
    nodes = Code[]
    while true
        pidx = parentindex(tree, tidx)
        push!(nodes, tidx)
        tidx == sidx && break
        isnothing(pidx) && return nothing
        tidx = pidx
    end
    reverse!(nodes)
    return nodes
end

"""
    reroot!(tree::Tree, idx::Integer)
Reroot the `tree` at the specified node. Return `true` if rerooting success.
"""
function reroot!(tree::Tree, idx::Integer)
    @assert isrerootable(tree)

    isleaf(tree, idx) && error("Leaf nodes are not allowed to reroot")
    path = findpath(tree, rootindex(tree), idx)
    @assert !isnothing(path)
    #TODO: substitue with better way 
    edges = Edge.(path[1:end-1], path[2:end])
    rev_edges = Edge.(path[2:end], path[1:end-1])
    for (e, re) in zip(edges, rev_edges)
        rem_edge!(tree.graph, e)
        add_edge!(tree.graph, re)
        branch = getindex(tree.branch_data, e)
        pop!(tree.branch_data, e)
        tree.branch_data[re] = branch
    end
    tree.root = idx
    return true
end

"""
    swapchildren!(tree::Tree, idx::Integer, newchildren)
Swap the child indices of the specified `idx` node to the given `newchildren`.
The elements of children and `newchildren` must be match.
Return `false` if swapping fails; true otherwise.
"""
function swapchildren!(tree::Tree, idx::Integer, newchildren::Vector{<:Integer})
    !haskey(tree, idx) && return false
    sort(tree.graph.fadjlist[idx]) != sort(newchildren) && return false
    tree.graph.fadjlist[idx] = newchildren
    return true
end

"""
    swap!(tree::Tree, idx::Integer, old_new::Pair{<:Integer, <:Integer})
Swap the two child elements of the specified `idx` node.
The `old` and `new` in `old_new` must be child of `idx` node.
Return `ture` if swapping fails; true otherwise.
"""
function swap!(tree::Tree, idx::Integer, old_new::Pair{<:Integer, <:Integer})
    !haskey(tree, idx) && return false
    old, new = old_new
    chidx = childindices(tree, idx)
    flag = (old in chidx) && (new in chidx)
    if flag
        oldpos = findfirst(isequal(old), tree.graph.fadjlist[idx])
        newpos = findfirst(isequal(new), tree.graph.fadjlist[idx])
        tree.graph.fadjlist[idx][oldpos] = new
        tree.graph.fadjlist[idx][newpos] = old
    end
    return flag
end

"""
    ladderize!(tree::Tree; left=false)
Ladderize the tree structure. By default, the smallest clade is on the right side; if left=true, on the left side.
"""
function ladderize!(idxnode::IndexNode{<:Tree, Int}; left=false)
    tree = idxnode.tree
    for node in PreOrderDFS(idxnode)
        idx = nodevalue(node)
        sorted = sort(
            childindices(tree, idx),
            by = x -> treebreadth(IndexNode(tree,x)),
            rev = left
            )
        swapchildren!(tree, idx, sorted)
    end
    return true
end
ladderize!(tree::Tree; kwargs...) = ladderize!(IndexNode(tree); kwargs...)
ladderize!(tree::Tree, idx::Int; kwargs...) = ladderize!(IndexNode(tree, idx); kwargs...)

