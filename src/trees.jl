# basic index interface
#TODO: Do we need to restrict access to node and branch that do not exist in the graph?
Base.getindex(tree::Tree, idx::Integer) = tree.node_data[idx]
Base.getindex(tree::Tree, edge::Edge) = tree.branch_data[edge]
Base.getindex(tree::Tree, idx1::Integer, idx2::Integer) = getindex(tree, Edge(idx1, idx2))

Base.haskey(tree::Tree, idx::Integer) = haskey(tree.node_data, idx)
Base.haskey(tree::Tree, edge::Edge) = haskey(tree.branch_data, edge)
Base.haskey(tree::Tree, idx1::Integer, idx2::Integer) = haskey(tree, Edge(idx1, idx2))

Base.setindex!(tree::Tree, data, idx::Integer) = setindex!(tree.node_data, data, idx)
Base.setindex!(tree::Tree, data, edge::Edge) = setindex!(tree.branch_data, data, edge)
Base.setindex!(tree::Tree, data, idx1::Integer, idx2::Integer) = setindex!(tree.branch_data, data, Edge(idx1, idx2))

Base.getindex(tree::Tree, idx::Integer, ::Colon) = IndexNode(tree, idx)
Base.getindex(tree::Tree, ::Colon) = IndexNode(tree)