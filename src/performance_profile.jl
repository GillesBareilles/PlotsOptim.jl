using DataStructures

"""
    $TYPEDSIGNATURES

Build a `TikzPicture` showing the performance profile of some solvers on some
problems.

# Arguments:
- `solverxpb_perf`: maps a tuple of solver and problem to a scalar performance indicator;
- `perfdescr`: description of the performance indicator;

# Assumptions:
- performance: lower is better
"""
function plot_perfprofile(solverxpb_perf::OrderedDict{Tuple{String, String}, Tf}; perfdescr = nothing) where {Tf <: Real}
    plotdata = []

    solvers = SortedSet{String}([k[1] for k in keys(solverxpb_perf)])
    problems = SortedSet{String}([k[2] for k in keys(solverxpb_perf)])
    @debug "plot perfprofile" solvers problems

    pb_to_bestperf = SortedDict{String, Float64}([pb => Inf for pb in problems])
    for (solverpb, perf) in solverxpb_perf
        pb_to_bestperf[solverpb[2]] = min(pb_to_bestperf[solverpb[2]], perf)
    end
    @debug "plot perfprofile" pb_to_bestperf

    t̄ = 5
    ts = range(1, t̄, length = 20)
    for (i, solver) in enumerate(solvers)
        pb_to_solverrelperf = [solverxpb_perf[(solver, pb)] / pb_to_bestperf[pb] for pb in problems]
        relperfprofile = [ count(<=(t), pb_to_solverrelperf ) / length(problems) for t in ts ]
        @debug "plot perfprofile" solver pb_to_solverrelperf

        # abs, ord = simplify ? simplify_stairs(collect(ts), relperfprofile) : ts, relperfprofile
        abs, ord = ts, relperfprofile

        push!(
            plotdata,
            PlotInc(
                PGFPlotsX.Options(
                    "mark" => MARKERS[mod(i, 7) + 1],
                    "color" => COLORS_7[i],
                    "mark repeat" => 10,
                ),
                Coordinates(abs, ord),
            ),
        )
        push!(plotdata, LegendEntry(solver))
    end


    return TikzPicture(@pgf Axis(
        {
            # height = "10cm",
            # width = "10cm",
            xlabel = "relative decrease",
            ylabel = "relative performance",
            title = perfdescr,
            xmin = 1,
            xmax = t̄,
            ymin = 0,
            ymax = 1,
            legend_pos = "south east",
            legend_style = "font=\\footnotesize",
            legend_cell_align = "left",
            unbounded_coords = "jump",
        },
        plotdata...,
    ))
end


function perfprofile_toydata()
    return OrderedDict(
        ("s1", "pb1") => 10,
        ("s1", "pb2") => 8,
        ("s1", "pb3") => 4,
        ("s2", "pb1") => 12,
        ("s2", "pb2") => 32,
        ("s2", "pb3") => 2,
    )
end
