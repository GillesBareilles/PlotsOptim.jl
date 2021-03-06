"""
    $TYPEDSIGNATURES

Build the base `Axis object`.
"""
function baseaxis(axb; width = "8cm", height = "6cm")
    return @pgf Axis({
            xmin = axb.xmin,
            xmax = axb.xmax,
            ymin = axb.ymin,
            ymax = axb.ymax,
            legend_pos = "outer north east",
            legend_cell_align = "left",
            legend_style = "font=\\footnotesize",
            "width" = width,
            "height" = height,
    })
end

vec2tikz(x) = (x[1], x[2])

function onlyvisible!(xs, axbounds::NamedTuple)
    filter!(x -> (axbounds.xmin <= x[1] <= axbounds.xmax) && (axbounds.ymin <= x[2] <= axbounds.ymax), xs)
    return xs
end

function get_axesdiscretization(axb, npoints)
    xs = axb.xmin:((axb.xmax - axb.xmin) / npoints):axb.xmax
    ys = axb.ymin:((axb.ymax - axb.ymin) / npoints):axb.ymax
    return xs, ys
end

"""
    $TYPEDSIGNATURES

Add arrow representing vector `d` with foot `x`
"""
function add_arrow!(axis, x::Vector{Float64}, d::Vector{Tf}; color="tomato", style="") where Tf <: Real
    if style == ""
        push!(axis, raw"\draw [thick, "*color*", -stealth]"*string(vec2tikz(x))*" -- "*string(vec2tikz(x+d))*";")
    else
        push!(axis, raw"\draw [thick, "*color*", -stealth, "*style*"]"*string(vec2tikz(x))*" -- "*string(vec2tikz(x+d))*";")
    end
end

"""
    $TYPEDSIGNATURES

Add surface defined by `coords`, a vector of length 2 vectors.
"""
function add_surface!(axis, color, coords)
    coords_simple = PlotsOptim.simplifyline(coords, 0.001)
    push!(
        axis,
        PlotInc(
            PGFPlotsX.Options(
                "forget plot" => nothing,
                "no marks" => nothing,
                "fill" => color,
                "draw" => "none",
                "fill_opacity" => 0.25,
            ),
            Coordinates(vec2tikz.(coords_simple)),
        ),
    )
end

"""
    $TYPEDSIGNATURES

Add point at `x`, with choice of `mark`, `name`, and `pert` for name position.
"""
function add_point!(axis, x; mark = "x", name = "x", pert=[0.2, -0.2], color="black")
    coords = [x]

    push!(
        axis,
        PlotInc(
            PGFPlotsX.Options(
                "forget plot" => nothing,
                "only marks" => nothing,
                "mark" => mark,
                "thick" => nothing,
                "color" => "black",
            ),
            Coordinates(vec2tikz.(coords)),
        ),
    )
    push!(axis, string(
        raw"\node[", color, "] at (axis cs: ",
        x[1] + pert[1],
        ", ",
        x[2] + pert[2],
        raw") {{\small $",
        name,
        raw"$}};"
    ))
    return
end

"""
    $TYPEDSIGNATURES

Add text `text` at position `pos`, possibly shifted by `pert`.
"""
function add_text!(axis, pos, text; pert = [0., 0.], color="black")
    push!(axis, string(
        raw"\node[", color, "] at (axis cs: ",
        pos[1] + pert[1],
        ", ",
        pos[2] + pert[2],
        raw") {{\small ",
        text,
        raw"}};"
    ))
    return
end

"""
    $TYPEDSIGNATURES

Add curve defined by `coords`, with some `color`.
The curve is simplified with `(@simplifyline)`.
"""
function add_curve!(axis, coords; color = "chartreuse")
    coords_simple = PlotsOptim.simplifyline(coords, 0.001)
    push!(
        axis,
        PlotInc(
            PGFPlotsX.Options(
                "forget plot" => nothing,
                "no marks" => nothing,
                "smooth" => nothing,
                "thick" => nothing,
                "solid" => nothing,
                "lightgray" => nothing,
                color => nothing,
                # "mark size" => "1pt"
            ),
            Coordinates(coords_simple),
        ),
    )
end

"""
    $TYPEDSIGNATURES

Add segment defined by `coords`.

See (@add_curve!)
"""
function add_segment!(axis, coords; color="chartreuse", linestyle = "solid", linewidth="0.4pt")
    push!(
        axis,
        PlotInc(
            PGFPlotsX.Options(
                "forget plot" => nothing,
                "no marks" => nothing,
                "semithick" => nothing,
                linestyle => nothing,
                "line width" => linewidth,
                color => nothing,
            ),
            Coordinates(vec2tikz.(coords)),
        ),
    )
    return
end

"""
    $TYPEDSIGNATURES

Add the contour plot of function `F` with bounds `axb`.

Parameters:
- `opacity`
- `levels` either the number of levels, or the vector of level values
"""
function add_contour!(axis::PGFPlotsX.Axis, F::Function, axb::NamedTuple; colormap="hot", opacity=1, levels = 10)
    xs, ys = get_axesdiscretization(axb, 200)
    ??(x, y) = F([x, y])

    push!(
        axis,
        PlotInc(
            PGFPlotsX.Options(
                "forget_plot" => nothing,
                "contour_prepared" => nothing,
                "no marks" => nothing,
                "colormap/$colormap" => nothing,
                "opacity" => opacity,
                "ultra_thin" => nothing,
            ),
            Table(PGFPlotsX.Options(
                    "col sep" => "space",
                ),
                contours(xs, ys, ??.(xs, ys'), levels)
            )
        )
    )
end

export baseaxis
export add_contour!, add_curve!, add_segment!, add_text!
