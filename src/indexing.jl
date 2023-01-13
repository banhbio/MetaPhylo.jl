AbstractTrees.nodevalue(::AbstractPhyloTree{Code}, idx) where Code = Code(idx)

AbstractTrees.ParentLinks(::Type{<:AbstractPhyloTree}) = StoredParents()
AbstractTrees.ChildIndexing(::Type{<:AbstractPhyloTree}) = IndexedChildren()
AbstractTrees.NodeType(::Type{<:AbstractPhyloTree}) = HasNodeType()
AbstractTrees.nodetype(::Type{<:AbstractPhyloTree{T}}) where T = T
AbstractTrees.NodeType(::Type{<:IndexNode{N,T}}) where {N<:AbstractPhyloTree,T} = HasNodeType()
AbstractTrees.nodetype(::Type{<:IndexNode{N,T}}) where {N<:AbstractPhyloTree,T} = IndexNode{N,T}
AbstractTrees.SiblingLinks(::Type{<:AbstractPhyloTree}) = StoredSiblings()

AbstractTrees.childindices(tree::AbstractPhyloTree, idx) = outneighbors(tree.graph, idx)
function AbstractTrees.parentindex(tree::AbstractPhyloTree, idx)
    inne = inneighbors(tree.graph, idx)
    isempty(inne) ? nothing : first(inne)
end

function AbstractTrees.nextsiblingindex(tree::AbstractPhyloTree, idx)
    pidx = parentindex(tree, idx)
    isnothing(pidx) && return nothing
    sibilings = outneighbors(tree.graph, pidx)
    pos = findfirst(isequal(idx), sibilings)
    return pos == length(sibilings) ? nothing : sibilings[pos+1]
end

function AbstractTrees.prevsiblingindex(tree::AbstractPhyloTree, idx)
    pidx = parentindex(tree, idx)
    isnothing(pidx) && return nothing
    sibilings = outneighbors(tree.graph, pidx)
    pos = findfirst(isequal(idx), sibilings)
    return pos == 1 ? nothing : sibilings[pos-1]
end

AbstractTrees.rootindex(tree::AbstractPhyloTree) = tree.root