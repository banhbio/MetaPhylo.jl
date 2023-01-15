using MetaPhylo
using Documenter

DocMeta.setdocmeta!(MetaPhylo, :DocTestSetup, :(using MetaPhylo); recursive=true)

function readme2index()
    readme_path = "README.md"
    index_path = "docs/src/index.md" 
    f = open(readme_path,"r")
    g = open(index_path, "w")
    try
        readme = read(f,String)
        index = replace(readme,"![](docs/src/img" => "![](img")
        write(g,readme)
    finally
        close(f)
        close(g)
    end
end

readme2index()

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
        "API" => "man/api.md",
    ],
)

deploydocs(;
    repo="github.com/banhbio/MetaPhylo.jl",
    devbranch="main",
)
