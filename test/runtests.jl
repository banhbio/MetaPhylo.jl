using MetaPhyTrees
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
