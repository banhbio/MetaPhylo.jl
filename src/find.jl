"""
    findnodes(tree::AbstractPhyloTree, args...; ifnot_haskey::Bool=false)
Return indices of tree node which all values proceed by transformation(s) `args` for a given attribute are true.
"""
function findnodes(tree::AbstractPhyloTree, args::Pair{Symbol, <:Base.Callable}...; ifnot_haskey::Bool = false)
    [ idx for (idx, value) in tree.node_data if all([(haskey(value, key) ? f(value[key]) : ifnot_haskey) for (key, f) in args])]
end

"""
    findbranches(tree::AbstractPhyloTree, args...; ifnot_haskey::Bool=false)
Return indices of tree branch which all values proceed by transformation(s) `args` for a given attribute are true.
"""
function findbranches(tree::AbstractPhyloTree, args::Pair{Symbol, <:Base.Callable}...; ifnot_haskey::Bool = false)
    [ idx for (idx, value) in tree.branch_data if all([(haskey(value, key) ? f(value[key]) : ifnot_haskey) for (key, f) in args])]
end
