function Base.show(io::IO, tree::Tree)
    print(
        io,
        """
        MetaPhyTrees.Tree with $(length(leaves(tree))) leaves.
            Rooted: $(isrooted(tree))
            Rerootable: $(isrerootable(tree))
        """
    )
end
AbstractTrees.print_tree(tree::Tree; kwargs...) = print_tree(IndexNode(tree); kwargs...)
AbstractTrees.print_tree(io::IO, tree::Tree; kwargs...) = print_tree(io, IndexNode(tree); kwargs...)
AbstractTrees.print_tree(f::Function, io::IO, tree::Tree; kwargs...) = print_tree(f::Function, io, IndexNode(tree); kwargs...)

function _join_namedtuplevalues(dict::Dict{Symbol, Any}, delim::AbstractString)
    entries = map(collect(dict)) do (key,val)
        keystr = String(key)
        valuestr = sprint(show, val)
        keystr * ":" * valuestr
    end
    return join(entries, delim)
end

function AbstractTrees.printnode(io::IO, idxnode::IndexNode)
    tree = idxnode.tree
    node = idxnode.index
    pnode = parentindex(tree, node)
    branch = isnothing(pnode) ? nothing : Edge(pnode, node)
    nodestr = _join_namedtuplevalues(tree[node], ", ")
    branchstr = isnothing(branch) ? "root" : _join_namedtuplevalues(tree[branch], ", ")
    print(IOContext(io, :compact => true, :limit => true), "$node: [$branchstr] $nodestr")
end