import Base: ==

abstract type RootState end
struct Rooted <: RootState end
struct UnRooted <: RootState end

abstract type ReRootablilty end
struct ReRootable <: ReRootablilty end
struct NotReRootable <: ReRootablilty end

abstract type AbstractPhyloTree{Code<:Integer, rooted<:RootState} end

mutable struct Tree{Code<:Integer, rooted<:RootState, rerootable<:ReRootablilty} <: AbstractPhyloTree{Code, rooted}
    graph::DiGraph{Code}
    root::Code
    branch_data::Dict{Edge{Code}, Dict{Symbol, Any}}
    node_data::Dict{Code, Dict{Symbol,Any}}
end

Base.copy(t::Tree{Code, rooted, rerootable}) where {Code, rooted, rerootable} = Tree{Code, rooted, rerootable}(copy(t.graph), t.root, deepcopy(t.branch_data), deepcopy(t.node_data))

struct StaticTree{Code<:Integer, rooted<:RootState, BI<:NamedTuple, NI<:NamedTuple} <: AbstractPhyloTree{Code, rooted}
    graph::StaticDiGraph{Code,Code}
    root::Code
    branch_data::Dict{Edge{Code}, BI}
    node_data::Dict{Code, NI}
end

"""
    freeze(tree::MetaPhylo.Tree)
Generate a `StaticTree` from a tree.
`NamedTuple` stores only the keys that are common to all data among the node and branch data of previous tree.
"""
function freeze(tree::Tree{Code, rooted}) where {Code, rooted}
    static_graph = StaticDiGraph(tree.graph)
    NewCode = eltype(static_graph)

    node_pairs = collect(tree.node_data)
    new_node_keys = Code.(first.(node_pairs))
    new_node_values_tmp = namedtuple.(last.(node_pairs))
    new_node_values_fieldnames = intersect(unique(fieldnames.(new_node_values_tmp))...) |> Tuple
    new_node_values = select.(new_node_values_tmp, Ref(new_node_values_fieldnames))

    NI = eltype(new_node_values)
    new_node_data = Dict(Pair.(new_node_keys, new_node_values))
    
    branch_pairs = collect(tree.branch_data)
    new_branch_keys = Edge{Code}.(first.(branch_pairs))
    new_branch_values_tmp = namedtuple.(last.(branch_pairs))
    new_branch_values_fieldnames = intersect(unique(fieldnames.(new_branch_values_tmp))...) |> Tuple
    new_branch_values = select.(new_branch_values_tmp, Ref(new_branch_values_fieldnames))

    BI = eltype(new_branch_values)
    new_branch_data = Dict(Pair.(new_branch_keys, new_branch_values))

    return StaticTree{NewCode, rooted, BI, NI}(static_graph, Code(tree.root), new_branch_data, new_node_data)
end

Base.copy(t::StaticTree{Code, rooted, BI, NI}) where {Code, rooted, BI, NI} = StaticTree{Code, rooted, rerootable, BI, NI}(copy(t.graph), t.root, deepcopy(t.branch_data), deepcopy(t.node_data)) 

"""
    isrooted(tree::AbstractPhyloTree)
Return true if tree is rooted.
"""
isrooted(::Type{<:AbstractPhyloTree{Code, Rooted}}) where {Code} = true
isrooted(::Type{<:AbstractPhyloTree{Code, UnRooted}}) where {Code} = false
isrooted(tree::AbstractPhyloTree) = isrooted(typeof(tree))

"""
    isrerootable(tree::AbstractPhyloTree)
Return true if tree is rerootable.
"""
isrerootable(::Type{<:Tree{Code, rooted, ReRootable}}) where {Code, rooted} = true
isrerootable(::Type{<:Tree{Code, rooted, NotReRootable}}) where {Code, rooted} = false
isrerootable(::Type{<:StaticTree}) = false
isrerootable(tree::AbstractPhyloTree) = isrerootable(typeof(tree))
