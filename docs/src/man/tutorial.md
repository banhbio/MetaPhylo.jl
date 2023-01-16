# Tutorial

## I/O

### Reading trees

```julia
#read a tree from a newick String
julia> tree = parse_newick("((A:0.1,B:0.2)100:0.3,((C:0.4,D:0.5)77:0.6,E:0.7)98:0.8)100:1.2;", MetaPhylo.Tree{Int, UnRooted, ReRootable})
MetaPhylo.Tree with 5 leaves.
    Rooted: false
    Rerootable: true

#read a tree from a newick file.
julia> tree = Newick.File("/path/to/your_tree") |> Tree{Int, Rooted, NotReRootable}
MetaPhylo.Tree with 5 leaves.
    Rooted: true
    Rerootable: false
```

### Writing trees

MetaPhylo.jl does not yet support writing tree. Sorry!

## Understanding MetaPhylo.Tree data types

The tree structure can be viewed with `print_tree` function.

```julia
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
```

### Get basic informations about trees

```julia
julia> treesize(tree)
10

julia> treebreadth(tree)
6

julia> treeheight(tree)
3
```

Information about a subtree can be obtained using the `IndexNode` type, which is available through the `getindex` function given the node's index and `Colon` (`:`).

```julia
julia> print_tree(tree[5,:])
5: [value:98.0, length:0.8] 
├─ 6: [value:77.0, length:0.6] 
│  ├─ 7: [length:0.4] label:"C"
│  └─ 8: [length:0.5] label:"D"
└─ 9: [length:0.7] label:"E"

julia> treesize(tree[5,:])
5

julia> treebreadth(tree[5,:])
3

julia> treeheight(tree[5,:])
2
```

### Nodes and branches attributes

The attributes of each node and branch of the can be accessed with `getindex`. The attributes are stored in the `Dict`s.

```julia
julia> tree[3]
Dict{Symbol, Any} with 1 entry:
  :label => "A"

julia> tree[5,6]
Dict{Symbol, Any} with 2 entries:
  :value  => 77.0
  :length => 0.6
```

The attributes of each node and branch can be changed or added by using `setindex!`.

```julia
julia> tree[2][:label] = "AB"
"AB"

julia> print_tree(tree)
1: [root] 
├─ 2: [value:100.0, length:0.3] label:"AB"
│  ├─ 3: [length:0.1] label:"A"
│  └─ 4: [length:0.2] label:"B"
├─ 5: [value:98.0, length:0.8] 
│  ├─ 6: [value:77.0, length:0.6] 
│  │  ├─ 7: [length:0.4] label:"C"
│  │  └─ 8: [length:0.5] label:"D"
│  └─ 9: [length:0.7] label:"E"
└─ 10: [length:0.9] label:"F"
```

## Traversing tree

Tree traversing can be done through the `IndexNode` type. `IndexNode` can be used as input for all iterators (PreOderDFS, PostOderDFS, Leaves etc...) provided by [AbstractTrees.jl](https://github.com/JuliaCollections/AbstractTrees.jl)
An IndexNode has a tree and its indexes internally. The index can be accessed through `nodevalue` or `nodevalues` functions.
See [AbstractTrees.jl](https://github.com/JuliaCollections/AbstractTrees.jl) for details.

```julia
julia> [ idx for idx in nodevalues(PreOrderDFS(tree[:]))]
8-element Vector{Int64}:
 1
 2
 3
 4
 5
 6
 7
 8

julia> [ idx for idx in nodevalues(PostOrderDFS(tree[:]))]
8-element Vector{Int64}:
 3
 4
 2
 6
 7
 5
 8
 1

julia> [ tree[idx][:label] for idx in nodevalues(Leaves(tree[:]))]
5-element Vector{String}:
 "A"
 "B"
 "C"
 "D"
 "E"

```

## Tree structure modification

Tree structure modification can be done through bang(!) functions (`reroot!`, `swap!`, `swapchildren!` etc.).
Modified tree can be re-indexed by `reindex!`.
```julia
julia> ladderize!(tree)
true

julia> print_tree(tree)
1: [root] 
├─ 8: [length:0.7] label:"E"
├─ 2: [value:100.0, length:0.3] 
│  ├─ 3: [length:0.1] label:"A"
│  └─ 4: [length:0.2] label:"B"
└─ 5: [value:98.0, length:0.6] 
   ├─ 6: [length:0.4] label:"C"
   └─ 7: [length:0.5] label:"D"

julia> reindex!(tree)
true

julia> print_tree(tree)
1: [root] 
├─ 2: [length:0.7] label:"E"
├─ 3: [value:100.0, length:0.3] 
│  ├─ 4: [length:0.1] label:"A"
│  └─ 5: [length:0.2] label:"B"
└─ 6: [value:98.0, length:0.6] 
   ├─ 7: [length:0.4] label:"C"
   └─ 8: [length:0.5] label:"D"

```


## Find nodes and branches by their attributes

Nodes and branches that match the given criteria can be found with the `findnodes` and `findbranches` functions. These functions return the indices of the matched nodes and branches.

```julia
julia> findnodes(tree, :label => isequal("A"))
1-element Vector{Int64}:
 3

julia> findbranches(tree, :value => x -> x ≥ 90)
1-element Vector{Graphs.SimpleGraphs.SimpleEdge{Int64}}:
 Edge 1 => 2
 Edge 1 => 5
```

## StaticTree (experimental)

You can generate static version of `MetaPhylo.Tree` through `freeze` function. `MetaPhylo.StaticTree` has an `StaticGraph` internally ([StaticGraphs.jl](https://github.com/JuliaGraphs/StaticGraphs.jl)), and the properties of each node and branch are provided in `NamedTuple`s. This allows for type stable access to node and edge properties.