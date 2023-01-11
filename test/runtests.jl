using MetaPhyTrees
using MetaPhyTrees.AbstractTrees
using MetaPhyTrees.Graphs
using Test

#TODO: Think more
@testset "newick/newick.jl" begin
    function try_parse(tree, type)
        try
            parse_newick(tree, type)
            return true
        catch e
            return false
        end
    end

    newicks= [
        "((,),,);",
        "((A,B),C,D);",
        "((A,B)E,C,D)F;",
        "((:0.1,:0.2):0.3,:0.4,:0.5);",
        "((:0.1,:0.2):0.3,:0.4,:0.5):0.0;",
        "((A:0.1,B:0.2):0.3,C:0.4,D:0.5);",
        "((A:0.1,B:0.2)E:0.3,C:0.4,D:0.5);",
        "((A:0.1,B:0.2)100:0.3,C:0.4,D:0.5);",
        "(((one, two),three),(four, five), six);",
        "(((one:10, two:20):70,three:30):80,(four:40, five:50):90, six:60);",
        "(((one:10, two:20)seven:70,three:30)eight:80,(four:40, five:50)nine:90, six:60);",
        "(((one:10, two:20)80:70,three:30)90:80,(four:40, five:50)100:90, six:60);",
    ]

    err_newicks = [
#        "(((o ne:10, two:20):70,three:30):80,(four:40, five:50):90, six:60);", #TODO:Is it ok?
        "((((one:10, two:20):70,three:30):80,(four:40, five:50):90, six:60);",
        "((()one:10, two:20):70,three:30):80,(four:40, five:50):90, six:60);",
        "(((o:ne:10, two:20):70,three:30):80,(four:40, five:50):90, six:60);",
        "(((o(ne:10, two:20):70,three:30):80,(four:40, five:50):90, six:60);",
        "(((o)ne:10, two:20):70,three:30):80,(four:40, five:50):90, six:60);",
        "(((one:1 0, two:20):70,three:30):80,(four:40, five:50):90, six:60);",
        "(((one:10:100, two:20):70,three:30):80,(four:40, five:50):90, six:60);",
    ]

    for newick in newicks
        @test try_parse(newick, MetaPhyTrees.Tree{Int, UnRooted, ReRootable})
    end

    for newick in err_newicks
        @test !try_parse(newick, MetaPhyTrees.Tree{Int, UnRooted, ReRootable})
    end
end

@testset "indexing" begin
    tree = parse_newick("(((,),(,)),(,),);", MetaPhyTrees.Tree{Int, UnRooted, ReRootable})

    @test AbstractTrees.childindices(tree, 1) == [2,9,12]
    @test AbstractTrees.childindices(tree, 4) == []
    @test isnothing(AbstractTrees.parentindex(tree, 1))
    @test AbstractTrees.parentindex(tree, 2) == 1
    @test isnothing(AbstractTrees.nextsiblingindex(tree, 1))
    @test AbstractTrees.nextsiblingindex(tree, 2) == 9
    @test isnothing(AbstractTrees.nextsiblingindex(tree, 11))
    @test isnothing(AbstractTrees.prevsiblingindex(tree, 2))
    @test AbstractTrees.prevsiblingindex(tree, 11) == 10
    @test AbstractTrees.rootindex(tree) == 1
end

@testset "trees.jl" begin

    tree = parse_newick("((A:0.1,B:0.2)100:0.3,((C:0.4, D:0.5)77:0.6,E:0.7)98:0.8,F:0.9);", MetaPhyTrees.Tree{Int, UnRooted, ReRootable})

    @test tree[1] == Dict{Symbol, Any}()
    @test tree[3] == Dict{Symbol, Any}(:label => "A")
    @test tree[1,2] == tree[Edge(1,2)] == Dict{Symbol, Any}(:length => 0.3, :value => 100)
    @test tree[1,10] == tree[Edge(1,10)] == Dict{Symbol, Any}(:length => 0.9)

    @test tree[:] == IndexNode(tree)
    @test tree[4, :] == IndexNode(tree, 4)

    @test haskey(tree, 1)
    @test haskey(tree, 7)
    @test !haskey(tree, 99)
    @test haskey(tree, 1, 2)
    @test !haskey(tree, 1, 3)
    @test haskey(tree, Edge(1,2))

    tree[3] = Dict(:label =>"a")
    tree[1,2] = Dict(:length => 0.7, :value => 90)
    tree[Edge(1,10)] = Dict(:length => 1.9)
    @test tree[3] == Dict(:label => "a")
    @test tree[1,2] == Dict(:length => 0.7, :value => 90)
    @test tree[Edge(1,10)] == Dict(:length => 1.9)

    @test @inferred(Nothing, parent_edge(tree, 2)) == Edge(1,2)
    @test @inferred(isnothing(parent_edge(tree, 1)))

    @test @inferred(leaves(tree)) == [3, 4, 7, 8, 9, 10]
    @test @inferred(leaves(tree, 2)) == [3, 4]
    @test @inferred(leaves(tree, 3)) == [3]
    @test @inferred(!isleaf(tree, 1))
    @test @inferred(!isleaf(tree, 99))
    @test @inferred(isinternal(tree, 1))
    @test @inferred(!isinternal(tree, 3))
    @test @inferred(!isinternal(tree, 99))

    # Julia v1.6.7 can not infer type correctly, but v1.7.2 can.
    @test leafedges(tree) == [Edge(2,3), Edge(2,4), Edge(6,7), Edge(6,8), Edge(5,9), Edge(1,10)]
    @test leafedges(tree, 5) == [Edge(6,7), Edge(6,8), Edge(5,9)]
    @test !isleaf(tree, Edge(1,2))
    @test !isleaf(tree, Edge(99, 100))
    @test isinternal(tree, Edge(1,2))
    @test !isinternal(tree, Edge(2,3))
    @test !isinternal(tree, Edge(99, 100))

    @test MetaPhyTrees.findpath(tree, 1, 4) == [1, 2, 4]
    @test isnothing(MetaPhyTrees.findpath(tree, 5, 4))

    #TODO: Add function to validate tree
    t = copy(tree)
    @test_throws ErrorException @inferred(reroot!(t, 3))
    @test @inferred(reroot!(t, 2))

    t = copy(tree)
    @test @inferred(!swapchildren!(t, 99, [4, 1]))
    @test @inferred(!swapchildren!(t, 2, [4, 1]))
    @test @inferred(swapchildren!(t, 2, [4, 3]))
    @test AbstractTrees.childindices(t, 2) == [4, 3]

    t = copy(tree)
    @test @inferred(!swap!(t, 99, 1=>4))
    @test @inferred(!swap!(t, 2, 1=>4))
    @test @inferred(swap!(t, 2, 3=>4))
    @test AbstractTrees.childindices(t, 2) == [4, 3]

    t = copy(tree)
    @test @inferred(ladderize!(t))
    @test AbstractTrees.childindices(t, 1) == [10, 2, 5]
    @test @inferred(reindex!(t))
    @test AbstractTrees.childindices(t, 1) == [2, 3, 6]

    t = copy(tree)
    @test @inferred(ladderize!(t; left=true))
    @test AbstractTrees.childindices(t, 1) == [5, 2, 10]

    @test @inferred(treesize(tree)) == 10
    @test @inferred(treesize(tree[2,:])) == 3
    @test @inferred(treebreadth(tree)) == 6
    @test @inferred(treebreadth(tree[2,:])) == 2
    @test @inferred(treebreadth(tree[5,:])) == 3
    @test @inferred(treeheight(tree)) == 3
    @test @inferred(treeheight(tree[2,:])) == 1
    @test @inferred(treeheight(tree[5,:])) == 2

    @test @inferred(ancestors(tree, 4)) == [1, 2, 4]
    @test @inferred(common_ancestor(tree, 8, 9)) == 5
end

