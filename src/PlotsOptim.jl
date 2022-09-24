module PlotsOptim

using PGFPlotsX
using Contour
using Colors
using LinearAlgebra
using DataStructures
using DocStringExtensions

using Meshes
using Infiltrator

function __init__()
    if isempty(PGFPlotsX.CUSTOM_PREAMBLE)
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{chartreuse}{HTML}{288800}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{darkgray}{HTML}{111111}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{lightgray}{HTML}{555555}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{tomato}{HTML}{FF6347}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{snow}{HTML}{F1F1F1}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{whiteee}{HTML}{EEEEEC}")
        #
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c1}{RGB}{238,102,119}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c2}{RGB}{68, 119, 170}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c3}{RGB}{102, 204, 238}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c4}{RGB}{34, 136, 51}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c5}{RGB}{204, 187, 68}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c6}{RGB}{238, 102, 119}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c7}{RGB}{170, 51, 119}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c8}{RGB}{187, 187, 187}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\newcommand{\prox}{\textrm{prox}}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\newcommand{\Hess}{\textrm{Hess}}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\newcommand{\grad}{\textrm{grad}}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\newcommand{\M}{\mathcal{M}}")
    end
    return
end

include("utils.jl")
include("performance_profile.jl")
include("simplify.jl")

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
export check_curveslope
export plot_taylordev

include("plots_base.jl")
export plot_curves
export get_legendname, get_curveparams
export savefig

include("plots_plane.jl")
include("plots_line.jl")
export baseaxis, get_axesdiscretization, add_point!, onlyvisible!, add_surface!, add_text!, add_arrow!

export plot_perfprofile

end # module

