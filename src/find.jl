function findnodes(tree::AbstractPhyloTree, args::Pair{Symbol, <:Base.Callable}...; ifnot_haskey = false)
    [ idx for (idx, value) in tree.node_data if all([(haskey(value, key) ? f(value[key]) : ifnot_haskey) for (key, f) in args])]
end

function findbranches(tree::AbstractPhyloTree, args::Pair{Symbol, <:Base.Callable}...; ifnot_haskey = false)
    [ idx for (idx, value) in tree.branch_data if all([(haskey(value, key) ? f(value[key]) : ifnot_haskey) for (key, f) in args])]
end
