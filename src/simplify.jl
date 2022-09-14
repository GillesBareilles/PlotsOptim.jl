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



"""
    $TYPEDSIGNATURES

Simplify the input line `inpoints` with the `DouglasPeucker` algorithm set with
ε=`precision`.

Note: the simplification is done with the coordinate frame of the plot, thus
converting coordinates to `log10` and back when needed.

The implemented algorithm relies on `Meshes.simplify`.
"""
function simplifyline(inpoints::Vector{Tuple{Tf, Tf}}, precision::Tf; xmode="normal", ymode="normal") where Tf
    @assert xmode in ["normal", "log"]
    @assert ymode in ["normal", "log"]

    points = copy(inpoints)

    # Remove negative ordinates if log coordinates
    if xmode == "log"
        points = filter(t -> t[1] > 0, points)
    end
    if ymode == "log"
        points = filter(t -> t[2] > 0, points)
    end

    xmode == "log" && map!(p -> (log10(p[1]), p[2]), points, points)
    ymode == "log" && map!(p -> (p[1], log10(p[2])), points, points)

    polyarea = Chain(points)
    simplline = simplify(polyarea, DouglasPeucker(precision))
    points = [(v.coords[1], v.coords[2]) for v in simplline.vertices]

    xmode == "log" && map!(p -> (10^p[1], p[2]), points, points)
    ymode == "log" && map!(p -> (p[1], 10^p[2]), points, points)

    @info "Simplified curve" length(inpoints) length(points)
    return points
end
