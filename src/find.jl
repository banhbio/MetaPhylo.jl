OneOrVector{T} = Union{T, Vector{T}}

"""
    findnodes(tree::AbstractPhyloTree, args...; ifnot_haskey::Bool=false)
Return indices of tree node which all values proceed by transformation(s) `args` for a given attribute are true.
"""
function findnodes(tree::AbstractPhyloTree, args::Pair{<:OneOrVector{Symbol}, <:Base.Callable}...; kwargs...)
    _find_key(tree.node_data, args...; kwargs...)
end

"""
    findbranches(tree::AbstractPhyloTree, args...; ifnot_haskey::Bool=false)
Return indices of tree branch which all values proceed by transformation(s) `args` for a given attribute are true.
"""
function findbranches(tree::AbstractPhyloTree, args::Pair{<:OneOrVector{Symbol}, <:Base.Callable}...; kwargs...)
    _find_key(tree.branch_data, args...; kwargs...)
end

function _find_key(dict::Dict, args...; ifnot_haskey=false)
    args = map(args) do (key, f)
        if key isa Symbol
            key_vec = [key]
        else
            key_vec = key
        end
        return key_vec => f 
    end
    [ idx for (idx, value) in dict if all([(all(haskey.(Ref(value), key)) ? f(getindex.(Ref(value), key)...) : ifnot_haskey) for (key, f) in args])]
end