import Base: ==

mutable struct Tree{Code<:Integer, <:RootState, <:ReRootablilty}
    graph::DiGraph{Code}
    root::Code
    node_data::Dict{Code, Dict{Symbol,Any}}
    branch_data::Dictionary{Edge{Code}, Dict{Symbol, Any}}
end

abstract type RootState end

struct Rooted <: RootState end
struct UnRooted <: RootState end

isrooted(::Type{<:Tree{Code, Rooted}}) where {Code} = true
isrooted(::Type{<:Tree{Code, UnRooted}}) where {Code} = false
isrooted(tree::Tree) = isrooted(typeof(tree))

abstract type ReRootablilty end
struct ReRootable <: ReRootablilty end
struct NotReRootable <: ReRootablilty end

isrerootable(::Type{<:Tree{Code, rooted, ReRootable}}) where {Code, rooted} = true
isrerootable(::Type{<:Tree{Code, rooted, NotReRootable}}) where {Code, rooted} = false
isrerootable(tree::Tree) = isrerootable(typeof(tree))
