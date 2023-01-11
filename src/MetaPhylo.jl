module MetaPhylo

using Graphs
using Graphs.SimpleGraphs:SimpleGraphs, fadj, badj
using AbstractTrees
using AxisArrays

include("types.jl")
include("indexing.jl")
include("trees.jl")
include("distance.jl")
include("show.jl")


#export type utils
export Rooted, UnRooted, ReRootable, NotReRooteble, isrooted, isrerootable

#export basic funtions
export rootindex, parent_edge, leafedges, leaves, isleaf, isinternal,
       reindex!, reroot!, swapchildren!, swap!, ladderize!,
       add_child!, rem_descendant!,
       ancestors, common_ancestor,
       print_tree, treesize, treebreadth, treeheight

#export distance functions
export distance, distance_matrix, treelength

include("newick/newick.jl")
import ..Newick: parse_newick
export Newick, parse_newick

end
