module MetaPhylo

using Reexport
@reexport using Graphs
using Graphs.SimpleGraphs:SimpleGraphs, fadj, badj
using StaticGraphs
@reexport using AbstractTrees
using NamedTupleTools
using AxisArrays

include("types.jl")
include("indexing.jl")
include("interfaces.jl")
include("distance.jl")
include("show.jl")

#export type utils
export Rooted, UnRooted, ReRootable, NotReRooteble, freeze, isrooted, isrerootable

#export basic funtions
export rootindex, parent_branch, leafedges, leaves, isleaf, isinternal,
       ancestors, common_ancestor,
       reindex!, reroot!, swapchildren!, swap!, ladderize!,
       add_child!, rem_descendant!

#export distance functions
export distance, distance_matrix, treelength

include("newick/newick.jl")
import ..Newick: parse_newick
export Newick, parse_newick

end
