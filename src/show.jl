function Base.show(io::IO, tree::Tree)
    print(
        io,
        """
        MetaPhylo.Tree with $(length(leaves(tree))) leaves.
            Rooted: $(isrooted(tree))
            Rerootable: $(isrerootable(tree))"""
    )
end

function Base.show(io::IO, tree::StaticTree{Code, rooted, BI, NI}) where{Code, rooted, BI, NI}
    print(
        io,
        """
        MetaPhylo.StaticTree with $(length(leaves(tree))) leaves.
            Rooted: $(isrooted(tree))
            branch_data: $BI
            node_data: $NI"""
    )
end
AbstractTrees.print_tree(tree::AbstractPhyloTree; kwargs...) = print_tree(IndexNode(tree); kwargs...)
AbstractTrees.print_tree(io::IO, tree::AbstractPhyloTree; kwargs...) = print_tree(io, IndexNode(tree); kwargs...)
AbstractTrees.print_tree(f::Function, g::Function, io::IO, tree::AbstractPhyloTree; kwargs...) = print_tree(f, g, io, IndexNode(tree); kwargs...)

function _join_namedtuplevalues(node, delim::AbstractString)
    entries = map(collect(pairs(node))) do (key,val)
        keystr = String(key)
        valuestr = sprint(show, val)
        keystr * ":" * valuestr
    end
    return join(entries, delim)
end

function AbstractTrees.printnode(io::IO, idxnode::IndexNode)
    tree = idxnode.tree
    node = idxnode.index
    branch = parent_branch(tree, node)
    nodestr = _join_namedtuplevalues(tree[node], ", ")
    branchstr = isnothing(branch) ? "root" : _join_namedtuplevalues(tree[branch], ", ")
    print(IOContext(io, :compact => true, :limit => true), "$node: [$branchstr] $nodestr")
end