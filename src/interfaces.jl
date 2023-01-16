# basic index interface
#TODO: Do we need to restrict access to node and branch that do not exist in the graph?
Base.getindex(tree::AbstractPhyloTree, idx::Integer) = tree.node_data[idx]
Base.getindex(tree::AbstractPhyloTree, edge::Edge) = tree.branch_data[edge]
Base.getindex(tree::AbstractPhyloTree, idx1::Integer, idx2::Integer) = getindex(tree, Edge(idx1, idx2))

Base.haskey(tree::AbstractPhyloTree, idx::Integer) = haskey(tree.node_data, idx)
Base.haskey(tree::AbstractPhyloTree, edge::Edge) = haskey(tree.branch_data, edge)
Base.haskey(tree::AbstractPhyloTree, idx1::Integer, idx2::Integer) = haskey(tree, Edge(idx1, idx2))

Base.getindex(tree::AbstractPhyloTree{Code}, idx::Integer, ::Colon) where {Code} = IndexNode(tree, Code(idx))
Base.getindex(tree::AbstractPhyloTree, ::Colon) = IndexNode(tree)

"""
    parent_branch(tree::AbstractPhyloTree, idx::Integer)
Return the baranch (edge) between the specified `idx` node and its parent node. If the node is root, this returns `nothing` 
"""
function parent_branch(tree::AbstractPhyloTree{Code}, idx::Integer) where {Code}
    pidx = parentindex(tree, idx)
    return isnothing(pidx) ? nothing : Edge{Code}(pidx, idx)
end

"""
    leaves(tree::AbstractPhyloTree, [idx::Integer])
Return the indices of all leaves in the `tree`. If the index is specified, this returns the indices of leaves in its subtree.
"""
leaves(tree::AbstractPhyloTree, idx::Integer) = nodevalue.(Leaves(tree[idx, :]))
leaves(tree::AbstractPhyloTree) = leaves(tree, rootindex(tree))

"""
    leafedges(tree::AbstractPhyloTree, [idx::Integer])
Return the edges of all edges connected to the leaves in the `tree`. If the index is specified, this returns the edges connected to its leaves in the `tree`.
"""
leafedges(tree::AbstractPhyloTree{Code}, idx::Integer) where {Code} = Vector{Edge{Code}}([parent_branch(tree, lf) for lf in leaves(tree, idx) if rootindex(tree) != lf])
leafedges(tree::AbstractPhyloTree) = leafedges(tree, rootindex(tree))

"""
    isleaf(tree::AbstractPhyloTree, idx::Integer)
Return `true` if the `idx` is contained in a leaf node of the `tree`.
"""
isleaf(tree::AbstractPhyloTree, idx::Integer) = haskey(tree, idx) && idx in leaves(tree)

"""
    isleaf(tree::AbstractPhyloTree, edge::Edge)
Return `true` if the `edge` is connected to a leaf node of the `tree`.
"""
isleaf(tree::AbstractPhyloTree, edge::Edge) = haskey(tree, edge) && edge in leafedges(tree)

"""
    isinternal(tree::AbstractPhyloTree, idx::Integer)
Return `true` if the `idx` is contained in an internal node of the `tree`.
"""
isinternal(tree::AbstractPhyloTree, idx::Integer) = haskey(tree, idx) && !isleaf(tree, idx)

"""
    isinternal(tree::AbstractPhyloTree, idx::Integer)
Return `true` if the `edge` is both connected to internal nodes of the `tree`.
"""
isinternal(tree::AbstractPhyloTree, edge::Edge) = haskey(tree, edge) && !isleaf(tree, edge)

#TODO: Is it the best way?
function findpath(tree::AbstractPhyloTree{Code}, sidx::Integer, tidx::Integer) where {Code<:Integer}
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
    AbstractTrees.treebreadth(tree::AbstractPhyloTree)
Return the number of leaves in the `tree`.
"""
AbstractTrees.treebreadth(tree::AbstractPhyloTree) = treebreadth(IndexNode(tree))

"""
    AbstractTrees.treeheight(tree::AbstractPhyloTree)
Return the maximum depth from the root to the leaves in the tree. See also `treelength`.
"""
AbstractTrees.treeheight(tree::AbstractPhyloTree) = treeheight(IndexNode(tree))

"""
    AbstractTrees.treesize(tree::AbstractPhyloTree)
Return the size og the tree.
"""
AbstractTrees.treesize(tree::AbstractPhyloTree) = treesize(IndexNode(tree))

"""
    ancestors(tree::AbstractPhyloTree, idx::Integer)
Return the indices of all ancestor nodes of the specified `idx` node.
"""
function ancestors(tree::AbstractPhyloTree{Code}, idx::Integer) where {Code}
    idx_node = tree[idx, :]
    ancestors_idx = Code[]
    while true
        push!(ancestors_idx, idx_node.index)
        idx_node = AbstractTrees.parent(idx_node)
        isnothing(idx_node) && break
    end
    return reverse(ancestors_idx)
end

"""
    common_ancestor(tree::AbstractPhyloTree, idx1::Integer, idx2::Integer)
Return the common ancestor index of two specified `idx1` and `idx2` nodes.
"""
function common_ancestor(tree::AbstractPhyloTree, idx1::Integer, idx2::Integer)
    intersect(ancestors(tree, idx1), ancestors(tree, idx2))[end]
end

Base.setindex!(tree::Tree, data, idx::Integer) = setindex!(tree.node_data, data, idx)
Base.setindex!(tree::Tree, data, edge::Edge) = setindex!(tree.branch_data, data, edge)
Base.setindex!(tree::Tree, data, idx1::Integer, idx2::Integer) = setindex!(tree.branch_data, data, Edge(idx1, idx2))

"""
    reindex!(tree::Tree)
Reindex the `tree` in `PreOderDFS` order from the root. 
"""
function reindex!(tree::Tree{Code}) where {Code}
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
    tree.branch_data = Dict(branch_data)
    tree.node_data = Dict(node_data)
    return true
end

"""
    reroot!(tree::Tree, idx::Integer)
Reroot the `tree` at the specified node. Return `true` if rerooting success.
"""
reroot!(::Tree{Code, root, NotReRootable}) where {Code, root} = error("The tree is not rerootable")

function reroot!(tree::Tree{Code, root, ReRootable}, idx::Integer) where {Code, root}
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


"""
    add_child!(tree::Tree, idx::Integer, branch_data::Dict{Symbol, Any}, node_data::Dict{Symbol, Any})
Add a child node to the specified node with branch and node data. Return `true` on success. 
"""
function add_child!(tree::Tree, idx::Integer, bi::Dict{Symbol, Any}, ni::Dict{Symbol, Any})
    !haskey(tree, idx) && return false
    added = add_vertex!(tree.graph)
    new_edge = Edge(idx, nv(tree.graph))
    added &= add_edge!(tree.graph, new_edge)
    if added
        tree.node_data[nv(tree.graph)] = ni
        tree.branch_data[new_edge] = bi
    end
    return added
end

"""
    rem_descendants(tree::Tree, idx::Integer)
Remove all descendants of the specified node. Return `true` on success. 
"""
function rem_descendants!(tree::Tree, idx::Integer)
    !haskey(tree, idx) && throw(ArgumentError("The tree does not have the index to be removed"))
    node_indices = nodevalue.(PreOrderDFS(IndexNode(tree, idx)))
    vmap = rem_vertices!(tree.graph, node_indices)

    for (new_idx, old_idx) in enumerate(vmap)
        if new_idx != old_idx
            tree.node_data[new_idx] = tree.node_data[old_idx]
            pop!(tree.node_data, old_idx)

            for edge in keys(tree.branch_data)
                edge_indices = Tuple(edge)
                if old_idx in edge_indices
                    new_edge = first(edge_indices) == old_idx ? Edge(new_idx, last(edge_indices)) : Edge(first(edge_indices), new_idx)
                    tree.branch_data[new_edge] = tree.branch_data[edge]
                end
            end
        end
    end

    pop!.(tree.branch_data |> Ref, edge for edge in keys(tree.branch_data) if !in(edge, edges(tree.graph)))

    return vmap
end