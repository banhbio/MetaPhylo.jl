import Base: ==

mutable struct Tree{Code<:Integer, rooted, rerootable}
    graph::DiGraph{Code}
    root::Code
    node_data::Dict{Code, Dict{Symbol,Any}}
    branch_data::Dictionary{Edge{Code}, Dict{Symbol, Any}}
end

isrooted(::Type{<:Tree{Code, rooted, rerootable}}) where {Code, rooted, rerootable} = rooted::Bool
isrooted(tree::Tree) = isrooted(typeof(tree))

isrerootable(::Type{<:Tree{Code, rooted, rerootable}}) where {Code, rooted, rerootable} = rerootable::Bool
isrerootable(tree::Tree) = isrerootable(typeof(tree))
