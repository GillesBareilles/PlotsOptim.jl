function get_curve_params(optimizer, COLORS, algoid, markrepeat)
    return Dict{Any,Any}(
        "mark" => MARKERS[mod(algoid, 7) + 1],
        "color" => COLORS[algoid],
        "mark repeat" => markrepeat,
        # "mark phase" => 7,
        # "mark options" => "draw=black",
    )
end


"""
    $SIGNATURES

Produce the default style of the curve for the given object.
"""
function get_curveparams(object, objid, nobjs, COLORS, MARKERS)
    return OrderedDict(
        "mark" => MARKERS[mod(objid, length(MARKERS)) + 1],
        "color" => COLORS[mod(objid, length(COLORS)) + 1],
    )
end

"""
    $SIGNATURES

Return the legend entry as a `String` for given `object`.
"""
function get_legendname(object)
    return string(object)
end

"""
    $SIGNATURES

Extract a `Vector` of abscisses from the `trace` corresponding to `object`.
"""
function get_abscisses(object, trace)
    return trace[1]
end

"""
    $SIGNATURES

Extract a `Vector` of ordinates from the `trace` corresponding to `object`.
"""
function get_ordinates(object, trace)
    return trace[2]
end

"""
    $TYPEDSIGNATURES

The base function for plotting positive stuff. The data plotted for each trace
is extracted by the functions `get_abscisses` and `get_ordinates`. See
[`get_legendname`](@ref) and [`get_curveparams`](@ref) for examples.

To customize the styling and legend of each curve, define your implementations
of:
- [`get_abscisses`](@ref),
- [`get_ordinates`](@ref).

## Arguments:
- `simplifystairs`: call the function `simplify_stairs` on every curve;
- `callback!: (plotdata, obj, trace, abs, ord)->nothing`: allows one to add more information to the figure;
"""
function plot_curves(
    object_to_trace::AbstractDict,
    get_abscisses::Function,
    get_ordinates::Function;
    xlabel = "time (s)",
    ylabel = "",
    xmode = "normal",
    ymode = "log",
    nmarks = 20,
    includelegend = true,
    title = nothing,
    simplifylines = false,
    simplificationfactor = 1e-2,
    width = "8cm",
    height = "6cm",
    callback! = (wargs...) -> nothing,
    horizontallines = [],
)
    ntraces = length(object_to_trace)
    COLORS = (ntraces <= 7 ? COLORS_7 : COLORS_10)

    maxnpoints = maximum(length(get_abscisses(obj, tr)) for (obj, tr) in object_to_trace)
    markrepeat = floor(maxnpoints / nmarks)

    plotdata = []

    algoid = 1
    for (obj, trace) in object_to_trace
        abs = get_abscisses(obj, trace)
        ord = get_ordinates(obj, trace)
        curvestyle = get_curveparams(obj, algoid, ntraces, COLORS, MARKERS)

        points = [(abs[i], ord[i]) for i in 1:length(abs)]
        if simplifylines
            points = simplifyline(points, simplificationfactor; xmode, ymode)
        end

        lineoptions = get_curveparams(obj, algoid, ntraces, COLORS, MARKERS)
        !isinf(markrepeat) && push!(lineoptions, "mark repeat" => markrepeat)

        push!(
            plotdata,
            PlotInc(
                PGFPlotsX.Options(lineoptions...),
                Coordinates(points),
            ),
        )
        includelegend && push!(plotdata, LegendEntry(get_legendname(obj)))

        callback!(plotdata, obj, trace, abs, ord, curvestyle)
        algoid += 1
    end

    for hlevel in horizontallines
        push!(plotdata, @pgf HLine({ dashed, black }, hlevel))
    end

    return TikzPicture(@pgf Axis(
        {
            xmode = xmode,
            ymode = ymode,
            xlabel = xlabel,
            ylabel = ylabel,
            legend_pos = "outer north east",
            legend_style = "font=\\footnotesize",
            legend_cell_align = "left",
            unbounded_coords = "jump",
            title = title,
            xmin = 0,
            width = width,
            height = height,
        },
        plotdata...,
    ))
end

