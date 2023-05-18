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

# Paul Tol's vibrant colour scheme (fig 3, https://personal.sron.nl/~pault/#fig:scheme_vibrant)
# for lines and labels
COLORS_vibrant = [
    colorant"#EE7733", # orange
    colorant"#0077BB", # blue
    colorant"#33BBEE", # cyan
    colorant"#EE3377", # magenta
    colorant"#CC3311", # red
    colorant"#009988", # teal
    colorant"#BBBBBB", # grey
]

# Paul Tol's bright colour scheme (fig 3, https://personal.sron.nl/~pault/#fig:scheme_bright)
# same as above, somewhat print friendly
COLORS_bright = [
        colorant"#4477AA", # blue
        colorant"#EE6677", # red
        colorant"#228833", # green
        colorant"#CCBB44", # yellow
        colorant"#66CCEE", # cyan
        colorant"#AA3377", # purple
        colorant"#BBBBBB", # grey
]

# Paul Tol's bright colour scheme (fig 7, https://personal.sron.nl/~pault/#fig:scheme_light)
# nice for filled areas
COLORS_light = Dict(
    :light_blue   => colorant"#77AADD",
    :orange       => colorant"#EE8866",
    :light_yellow => colorant"#EEDD88",
    :pink         => colorant"#FFAABB",
    :light_cyan   => colorant"#99DDFF",
    :mint         => colorant"#44BB99",
    :pear         => colorant"#BBCC33",
    :olive        => colorant"#AAAA00",
    :pale_grey    => colorant"#DDDDDD",
    :black        => colorant"#000000",
)



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
function savefig(fig::TikzDocument, savepath; savetex = true, savepdf = true, FIGFOLDER = ".", include_preamble = false)
    fullpath = joinpath(FIGFOLDER, savepath)
    if savetex
        pgfsave(fullpath*".tex", fig; include_preamble = include_preamble)
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

function savefig(fig::TikzPicture, savepath; kwargs...)
    savefig(TikzDocument(fig), savepath; kwargs...)
end
function savefig(axis::PGFPlotsX.Axis, savepath; kwargs...)
    savefig(TikzDocument(TikzPicture(axis)), savepath; kwargs...)
end
