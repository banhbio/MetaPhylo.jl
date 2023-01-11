module Newick
    
using MetaPhyTrees
using Graphs
using AbstractTrees
export parse_newick

# define parser
using Lerche

grammer = raw"""
    ?start       : subtree ";"
    node         : leaf
                 | subtree
    
    nodeinfo     : value 
                 | [label]
                 | ":" length
                 | value ":" length
                 | label ":" length
    leaf         : (label)? (":" length)?
    subtree      : "(" descendants ")" nodeinfo
    descendants  : node "," node ("," node)*
    label        : newick_string
    length       : float
    value        : float
    newick_string: /[^\,\:\;\(\)\[\]]+/
    float        : /[-+]?([0-9]*\.)?[0-9]+([eE][-+]?[0-9]+)?/
"""

struct TreeToNewick <: Transformer end

@inline_rule node(t::TreeToNewick, n) = n
@rule nodeinfo(t::TreeToNewick, n) = isempty(n) ? Dict{Symbol, Any}() : Dict{Symbol, Any}(n)
@rule leaf(t::TreeToNewick, l) = Dict{Symbol,Any}([:info => Dict{Symbol,Any}(l)])
@rule subtree(t::TreeToNewick, s) = Dict{Symbol, Any}([:descendants => s[1], :info => Dict(s[2])])
@rule descendants(t::TreeToNewick, d) = d

@inline_rule label(t::TreeToNewick, l) = Pair(:label, l)
@inline_rule length(t::TreeToNewick, l) = Pair(:length, l)
@inline_rule value(t::TreeToNewick, v) = Pair(:value, v)
@inline_rule newick_string(t::TreeToNewick, s) = String(s)
@inline_rule float(t::TreeToNewick, s) = Base.parse(Float64, s)
const parser = Lark(grammer, parser="lalr", lexer="standard", transformer=TreeToNewick())

# traverse tree
AbstractTrees.ChildIndexing(::Type{Dict{Symbol}}) = IndexedChildren()
AbstractTrees.NodeType(::Type{Dict{Symbol}}) = HasNodeType()

AbstractTrees.children(dict::Dict{Symbol}) = get(dict, :descendants, Any[])
AbstractTrees.nodetype(::Type{Dict{Symbol}}) = Dict{Symbol}

function parse_newick(input::AbstractString, T::Type{<:MetaPhyTrees.Tree{Code, rooted, rerootable}}) where {Code, rooted, rerootable}
    parsed_tree = Lerche.parse(parser, input) # return tree in Dict{Symbol, Any}

    #TODO: push!() might be slow.
    edges = Edge{Code}[]
    node_data = Pair{Code, Dict{Symbol, Any}}[]
    branch_data = Pair{Edge{Code}, Dict{Symbol, Any}}[]
    for (i, n) in enumerate(PreOrderDFS(parsed_tree))

        #describe parent id
        for c in children(n)
            c[:info][:parent] = i
        end

        info = n[:info]

        label = get(info, :label, nothing)
        graph_node = Dict{Symbol, Any}()
        haskey(info, :label) ? graph_node[:label] = info[:label] : nothing
        push!(node_data, i=>graph_node)

        pid = get(info, :parent, nothing)
        isnothing(pid) && continue
        edge = Edge{Code}(pid, i)
        push!(edges, edge)
        graph_branch = Dict{Symbol, Any}()
        haskey(info, :value) ? graph_branch[:value] = info[:value] : nothing
        haskey(info, :length) ? graph_branch[:length] = info[:length] : nothing
        push!(branch_data, edge=>graph_branch)
    end

    graph = DiGraph(edges)
    return T(graph, 1, Dict(node_data), Dict(branch_data))
end

end #module