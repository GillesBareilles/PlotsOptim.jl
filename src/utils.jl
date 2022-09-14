COLORS_7 = [
    Colors.RGB(68/255, 119/255, 170/255),
    Colors.RGB(102/255, 204/255, 238/255),
    Colors.RGB(34/255, 136/255, 51/255),
    Colors.RGB(204/255, 187/255, 68/255),
    Colors.RGB(238/255, 102/255, 119/255),
    Colors.RGB(170/255, 51/255, 119/255),
    Colors.RGB(187/255, 187/255, 187/255),
]

COLORS_10 = [
    colorant"#332288",
    colorant"#88CCEE",
    colorant"#44AA99",
    colorant"#117733",
    colorant"#999933",
    colorant"#DDCC77",
    colorant"#CC6677",
    colorant"#882255",
    colorant"#AA4499",
    colorant"#DDDDDD",
]

MARKERS = [
    "x",
    "+",
    "star",
    "oplus",
    "triangle",
    "diamond",
    "pentagon",
]


"""
    $TYPEDSIGNATURES

Save a TikzDocument as tex and pdf, raise an error if pdf compilation fails.
"""
function savefig(fig::TikzDocument, savepath; savetex = true, savepdf = true, FIGFOLDER = ".")
    fullpath = joinpath(FIGFOLDER, savepath)
    if savetex
        pgfsave(fullpath*".tex", fig, include_preamble=false)
    end
    if savepdf
        try
            pgfsave(fullpath*".pdf", fig)
        catch e
            @warn "Could not build $fullpath" e
        end
    end
    @info "wrote $fullpath"
    return
end

function savefig(fig::TikzPicture, savepath)
    savefig(TikzDocument(fig), savepath)
end
function savefig(axis::PGFPlotsX.Axis, savepath; kwargs...)
    savefig(TikzDocument(TikzPicture(axis)), savepath; kwargs...)
end
