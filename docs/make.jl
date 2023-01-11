using MetaPhyTrees
using Documenter

DocMeta.setdocmeta!(MetaPhyTrees, :DocTestSetup, :(using MetaPhyTrees); recursive=true)

makedocs(;
    modules=[MetaPhyTrees],
    authors="banhbio <ban@kuicr.kyoto-u.ac.jp> and contributors",
    repo="https://github.com/banhbio/MetaPhyTrees.jl/blob/{commit}{path}#{line}",
    sitename="MetaPhyTrees.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://banhbio.github.io/MetaPhyTrees.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/banhbio/MetaPhyTrees.jl",
    devbranch="main",
)
