using MetaPhylo
using Documenter

DocMeta.setdocmeta!(MetaPhylo, :DocTestSetup, :(using MetaPhylo); recursive=true)

makedocs(;
    modules=[MetaPhylo],
    authors="banhbio <ban@kuicr.kyoto-u.ac.jp> and contributors",
    repo="https://github.com/banhbio/MetaPhylo.jl/blob/{commit}{path}#{line}",
    sitename="MetaPhylo.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://banhbio.github.io/MetaPhylo.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/banhbio/MetaPhylo.jl",
    devbranch="main",
)
