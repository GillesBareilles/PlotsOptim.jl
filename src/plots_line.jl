"""
    $TYPEDSIGNATURES

Build the base `Axis object`.
"""
function baseaxis_line(axb; width = "8cm", height = "6cm", legend_pos = "outer north east")
    return @pgf Axis({
            xmin = axb.xmin,
            xmax = axb.xmax,
            # ymin = axb.ymin,
            # ymax = axb.ymax,
            "legend pos" = legend_pos,
            legend_cell_align = "left",
            legend_style = "font=\\footnotesize",
            "width" = width,
            "height" = height,
    })
end

function add_curve!(axis, axb, f; color = "black", style = "solid")
    coords = [ (t, f(t)) for t in axb.xmin:0.01:axb.xmax]
    push!(
        axis,
        PlotInc(
            PGFPlotsX.Options(
                # "forget plot" => nothing,
                "no marks" => nothing,
                # "smooth" => nothing,
                # "thick" => nothing,
                style => nothing,
                color => nothing,
            ),
            Coordinates(coords),
        ),
    )
    return
end

export baseaxis_line, add_curve!
