module PlotsOptim

using Reexport
@reexport using PGFPlotsX
@reexport using LaTeXStrings
using Contour
using Colors
using LinearAlgebra
using DataStructures
using DocStringExtensions

using Meshes
using Infiltrator


function __init__()
    if isempty(PGFPlotsX.CUSTOM_PREAMBLE)
        # F's colors
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{chartreuse}{HTML}{288800}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{darkgray}{HTML}{111111}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{lightgray}{HTML}{555555}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{tomato}{HTML}{FF6347}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{snow}{HTML}{F1F1F1}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{whiteee}{HTML}{EEEEEC}")

        # Paul Tol's vibrant colour scheme (fig 3, https://personal.sron.nl/~pault/#fig:scheme_vibrant)
        # for lines and labels
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{vibrant1}{HTML}{EE7733}") # orange
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{vibrant2}{HTML}{0077BB}") # blue
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{vibrant3}{HTML}{33BBEE}") # cyan
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{vibrant4}{HTML}{EE3377}") # magenta
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{vibrant5}{HTML}{CC3311}") # red
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{vibrant6}{HTML}{009988}") # teal
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{vibrant7}{HTML}{BBBBBB}") # grey

        # Paul Tol's bright colour scheme (fig 3, https://personal.sron.nl/~pault/#fig:scheme_bright)
        # same as above, somewhat print friendly
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{bright1}{HTML}{4477AA}") # blue
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{bright2}{HTML}{EE6677}") # red
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{bright3}{HTML}{228833}") # green
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{bright4}{HTML}{CCBB44}") # yellow
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{bright5}{HTML}{66CCEE}") # cyan
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{bright6}{HTML}{AA3377}") # purple
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{bright7}{HTML}{BBBBBB}") # grey

        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{bright_blue}{HTML}{4477AA}") # blue
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{bright_red}{HTML}{EE6677}") # red
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{bright_green}{228833}") # green
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{bright_yellow}{HTML}{CCBB44}") # yellow
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{bright_cyan}{HTML}{66CCEE}") # cyan
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{bright_purple}{HTML}{AA3377}") # purple
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{bright_grey}{HTML}{BBBBBB}") # grey

        # Paul Tol's light color scheme
        for coldef in [
            raw"\definecolor{light_blue}{HTML}{77AADD}",
            raw"\definecolor{orange}{HTML}{EE8866}",
            raw"\definecolor{light_yellow}{HTML}{EEDD88}",
            raw"\definecolor{pink}{HTML}{FFAABB}",
            raw"\definecolor{light_cyan}{HTML}{99DDFF}",
            raw"\definecolor{mint}{HTML}{44BB99}",
            raw"\definecolor{pear}{HTML}{BBCC33}",
            raw"\definecolor{olive}{HTML}{AAAA00}",
            raw"\definecolor{pale_grey}{HTML}{DDDDDD}",
            raw"\definecolor{black}{HTML}{000000}",
            ]
            push!(PGFPlotsX.CUSTOM_PREAMBLE, coldef)
        end

        # old color scheme
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c1}{RGB}{238,102,119}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c2}{RGB}{68, 119, 170}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c3}{RGB}{102, 204, 238}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c4}{RGB}{34, 136, 51}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c5}{RGB}{204, 187, 68}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c6}{RGB}{238, 102, 119}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c7}{RGB}{170, 51, 119}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\definecolor{c8}{RGB}{187, 187, 187}")
        #
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\newcommand{\prox}{\textrm{prox}}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\newcommand{\Hess}{\textrm{Hess}}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\newcommand{\grad}{\textrm{grad}}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\newcommand{\M}{\mathcal{M}}")
        push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\newcommand{\R}{\mathoperator{R}}")
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
export get_abscisses, get_ordinates
export get_legendname, get_curveparams
export savefig

include("plots_plane.jl")
include("plots_line.jl")
export baseaxis, get_axesdiscretization, add_point!, onlyvisible!, add_surface!, add_text!, add_arrow!

export COLORS_light

export plot_perfprofile

end # module

