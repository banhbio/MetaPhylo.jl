# MetaPhylo

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://banhbio.github.io/MetaPhylo.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://banhbio.github.io/MetaPhylo.jl/dev/)
[![Build Status](https://github.com/banhbio/MetaPhylo.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/banhbio/MetaPhylo.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/banhbio/MetaPhylo.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/banhbio/MetaPhylo.jl)

`MetaPhylo.jl` is Julia package for dealing with phylogenetic trees.
This package is in the early stage of development and probably has many bugs (especially around Newick format). Bug reports and any suggestions are welcome🙂!

## Acknowledgements
`MetaPhylo.jl` is inspired by [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl) and implemented with [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl) and [AbstractTrees.jl](https://github.com/JuliaCollections/AbstractTrees.jl).

## Example
```julia
julia> import Pkg; Pkg.add(url="https://github.com/banhbio/MetaPhylo.jl");

julia> using MetaPhylo

julia> tree = parse_newick("((A:0.1,B:0.2)100:0.3,((C:0.4,D:0.5)77:0.6,E:0.7)98:0.8,F:0.9);", MetaPhylo.Tree{Int, UnRooted, ReRootable})
MetaPhylo.Tree with 6 leaves.
    Rooted: false
    Rerootable: true

julia> print_tree(tree)
1: [root] 
├─ 2: [value:100.0, length:0.3] 
│  ├─ 3: [length:0.1] label:"A"
│  └─ 4: [length:0.2] label:"B"
├─ 5: [value:98.0, length:0.8] 
│  ├─ 6: [value:77.0, length:0.6] 
│  │  ├─ 7: [length:0.4] label:"C"
│  │  └─ 8: [length:0.5] label:"D"
│  └─ 9: [length:0.7] label:"E"
└─ 10: [length:0.9] label:"F"

julia> tree[3]
Dict{Symbol, Any} with 1 entry:
  :label => "A"

julia> tree[5,6]
Dict{Symbol, Any} with 2 entries:
  :value  => 77.0
  :length => 0.6

julia> findnodes(tree, :label => isequal("A"))
1-element Vector{Int64}:
 3

julia> findbranches(tree, :value => x -> x ≥ 100)
1-element Vector{Graphs.SimpleGraphs.SimpleEdge{Int64}}:
 Edge 1 => 2

julia> @time big_tree = Newick.File("/path/to/big_tree") |> MetaPhylo.Tree{Int, UnRooted, ReRootable}
  3.394991 seconds (23.63 M allocations: 1.180 GiB, 32.24% gc time)
MetaPhylo.Tree with 54327 leaves.
    Rooted: false
    Rerootable: true

julia> freeze(big_tree)
MetaPhylo.StaticTree with 54327 leaves.
    Rooted: false
    branch_data: NamedTuple{(:length,), Tuple{Float64}}
    node_data: NamedTuple{(), Tuple{}}
```