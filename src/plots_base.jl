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
        "mark" => MARKERS[mod(objid, nobjs) + 1],
        "color" => COLORS[objid],
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
    simplifystairs = false,
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
        abscisses = get_abscisses(obj, trace)
        ordinates = get_ordinates(obj, trace)
        curvestyle = get_curveparams(obj, algoid, ntraces, COLORS, MARKERS)

        if simplifystairs
            abscisses, ordinates = simplify_stairs(abscisses, ordinates)
        end

        push!(
            plotdata,
            PlotInc(
                PGFPlotsX.Options(
                    get_curveparams(obj, algoid, ntraces, COLORS, MARKERS)...,
                    "mark repeat" => markrepeat,
                ),
                Coordinates(
                    abscisses,
                    ordinates
                ),
            ),
        )
        includelegend && push!(plotdata, LegendEntry(get_legendname(obj)))

        callback!(plotdata, obj, trace, abscisses, ordinates, curvestyle)
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
        },
        plotdata...,
    ))
end


"""
    $SIGNATURES

This function simplifies data that will be plotted. This function assumes the
data forms a stairway and does not change the final figure.
"""
function simplify_stairs(abs::Vector{Tf}, ord::Vector{Tf}) where Tf
    if !issorted(abs)
        @warn "simplify_stairs() assumes sorted abscisses as input. No simplification."
        return(abs, ord)
    end

    xs = Tf[]
    ys = Tf[]
    indadd = 1

    i_beg = 1
    i_end = 1
    while i_beg <= length(abs)
        while i_end <= length(abs) && ord[i_end] == ord[i_beg]
            i_end += 1
        end

        # simplify if need be
        push!(xs, abs[i_beg])
        push!(ys, ord[i_beg])

        if i_beg < i_end-1
            push!(xs, abs[i_end-1])
            push!(ys, ord[i_end-1])
        end

        i_beg = i_end
    end

    return xs, ys
end
