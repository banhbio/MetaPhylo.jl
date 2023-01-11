AbstractTrees.nodevalue(::Tree, idx::T) where T<:Integer = idx

AbstractTrees.ParentLinks(::Type{<:Tree}) = StoredParents()
AbstractTrees.ChildIndexing(::Type{<:Tree}) = IndexedChildren()
AbstractTrees.NodeType(::Type{<:Tree}) = HasNodeType()
AbstractTrees.nodetype(::Type{<:Tree{T}}) where T = T
AbstractTrees.NodeType(::Type{<:IndexNode{N,T}}) where {N<:Tree,T} = HasNodeType()
AbstractTrees.nodetype(::Type{<:IndexNode{N,T}}) where {N<:Tree,T} = IndexNode{N,T}
AbstractTrees.SiblingLinks(::Type{<:Tree}) = StoredSiblings()

AbstractTrees.childindices(tree::Tree, idx) = outneighbors(tree.graph, idx)
function AbstractTrees.parentindex(tree::Tree, idx)
    inne = inneighbors(tree.graph, idx)
    isempty(inne) ? nothing : first(inne)
end

function AbstractTrees.nextsiblingindex(tree::Tree, idx)
    pidx = parentindex(tree, idx)
    isnothing(pidx) && return nothing
    sibilings = outneighbors(tree.graph, pidx)
    pos = findfirst(isequal(idx), sibilings)
    return pos == length(sibilings) ? nothing : sibilings[pos+1]
end

function AbstractTrees.prevsiblingindex(tree::Tree, idx)
    pidx = parentindex(tree, idx)
    isnothing(pidx) && return nothing
    sibilings = outneighbors(tree.graph, pidx)
    pos = findfirst(isequal(idx), sibilings)
    return pos == 1 ? nothing : sibilings[pos-1]
end

AbstractTrees.rootindex(tree::Tree) = tree.root