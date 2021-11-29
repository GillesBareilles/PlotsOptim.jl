module PlotsOptim

using PGFPlotsX
using Contour
using Colors
using LinearAlgebra
using DataStructures
using DocStringExtensions

include("utils.jl")
include("performance_profile.jl")

function contour(x, y, f; levels=nothing)
    return @pgf Axis(
        {
            contour_prepared,
            legend_cell_align = "left",
            legend_style = "font=\\footnotesize",
        },
        PlotInc(
            PGFPlotsX.Options(
                "forget plot" => nothing,
                "no marks" => nothing,
                "ultra thin" => nothing
            ),
            isnothing(levels) ? Table(contours(x, y, f.(x, y'))) : Table(contours(x, y, f.(x, y'), levels)),
    ))
end


include("model_to_curves.jl")
export build_affinemodel
export plot_taylordev

include("plots_base.jl")
export plot_curves
export get_legendname, get_curveparams
export savefig

export plot_perfprofile

end # module

