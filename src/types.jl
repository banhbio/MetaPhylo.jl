import Base: ==

abstract type RootState end
struct Rooted <: RootState end
struct UnRooted <: RootState end

abstract type ReRootablilty end
struct ReRootable <: ReRootablilty end
struct NotReRootable <: ReRootablilty end

mutable struct Tree{Code<:Integer, rooted<:RootState, rerootable<:ReRootablilty}
    graph::DiGraph{Code}
    root::Code
    node_data::Dict{Code, Dict{Symbol,Any}}
    branch_data::Dict{Edge{Code}, Dict{Symbol, Any}}
end

isrooted(::Type{<:Tree{Code, Rooted}}) where {Code} = true
isrooted(::Type{<:Tree{Code, UnRooted}}) where {Code} = false
isrooted(tree::Tree) = isrooted(typeof(tree))

isrerootable(::Type{<:Tree{Code, rooted, ReRootable}}) where {Code, rooted} = true
isrerootable(::Type{<:Tree{Code, rooted, NotReRootable}}) where {Code, rooted} = false
isrerootable(tree::Tree) = isrerootable(typeof(tree))
