"""
    $TYPEDSIGNATURES

Build a logspaced range from 10^`min` to 10^`max`. Default is [1e-15, -1].
"""
function logspaced_range(;npoints = 50, min=-15, max=-1, Tf=Float64)
    return Tf(10) .^ collect(range(min, max, length=npoints))
end

"""
    $TYPEDSIGNATURES

Build the OrderedDict pairing the model name to the tuple of abscisses and
ordinates of the input function. The values are thresholded at `minval`,
and converted to `Float64`.
"""
function build_logcurves(model_to_function::OrderedDict{String, Function}; minval = nothing, npoints=50, Tf)
    isnothing(minval) && (minval = eps(Tf))
    ts = logspaced_range(npoints = npoints; Tf)

    res = OrderedDict( model => (ts, Tf[ max(minval, φ(t)) for t in ts ]) for (model, φ) in model_to_function )
    return res
end

"""
    $TYPEDSIGNATURES

Plot the Taylor development contained in `model_to_curve` (e.g. an output of
 [`build_logcurves`](@ref)).
"""
function plot_taylordev(model_to_curve::OrderedDict{String, Tuple{Vector{T}, Vector{T}}}) where T
    plot_curves(
        model_to_curve,
        (obj, trace) -> trace[1],
        (obj, trace) -> trace[2];
        xmode = "log",
        ymode = "log",
        xlabel = "",
        ylabel = "",
    )
end

"""
    $TYPEDSIGNATURES

Plot the Taylor development contained in `model_to_curve` (e.g. an output of
 [`build_logcurves`](@ref)).
"""
function plot_taylordev(model_to_function::OrderedDict{String, Function}; Tf = Float64, minval = nothing)
    if isnothing(minval)
        minval = eps(Tf)
    end
    curves = build_logcurves(model_to_function; minval)
    return plot_taylordev(curves)
end



"""
    $TYPEDSIGNATURES

Remove the entries `i` of `xs` and `ys` such that `y[i]` has smaller magnitude than `threshold`.
This threshold is set to `1e3 eps(Tf)` by default.

The point of this is to remove functions values that are miscomputed due to numerical errors.
"""
function remove_small_functionvals(xs::Vector{Tf}, ys::Vector{Tf}; threshold=nothing) where Tf
    isnothing(threshold) && (threshold = 1e3 * eps(Tf))

    nnzentries = abs.(ys) .> threshold
    return xs[nnzentries], ys[nnzentries]
end


"""
    $TYPEDSIGNATURES

Fit an affine regressor explaining `ys` in terms of `xs`. Return the slope and residual.

## Fitting the linear regressor
- model : y = βx + c
- explain Y = [log.(y)] by X = [log.(x) 1]
- Y = X β
- β ∈ ℝ^{2x1} - slope and absciss at origin
- X ∈ ℝ^{nx2} - absciss and intercept
- Y ∈ ℝ^{nx1} - ordonate
"""
function build_affinemodel(xs::Vector{Tf}, ys::Vector{Tf}) where Tf
    n = length(xs)

    if length(xs) == 0
        # Ordinates are too small to count
        @info "Linear regression: no data to regress on"
        return Tf[0.0, 0.0], Tf(0.0)
    end

    X = ones(Tf, n, 2)
    X[:, 1] = log.(xs)
    Y = log.(ys)

    F = factorize(X' * X)
    β = F \ X' * Y

    empiricalrisk = (1/(2*n)) * norm((Y - X * β))^2
    return β, empiricalrisk
end

"""
    $TYPEDSIGNATURES

Build the affine models of the input functions.
"""
function build_affinemodels(model_to_function::OrderedDict{String, Function}; Tf=Float64)
    res = OrderedDict()
    for (model, curve) in build_logcurves(model_to_function; Tf)
        xs, ys = curve
        # xs, ys = remove_small_functionvals(xs, ys; threshold = 1e5*eps(Tf))
        xs, ys = remove_small_functionvals(xs, ys)
        res[model] = build_affinemodel(xs, ys)

    end
    return res
end

"""
    $TYPEDSIGNATURES

Check that the given `curve` has at least slope `targetslope`, accounting
for the fact that the curve may be parasited by numerical errors at low values.
"""
function check_curveslope(curve::Tuple{Vector{Tf}, Vector{Tf}}, targetslope) where Tf
    xs, ys = curve
    xs_clean, ys_clean = PlotsOptim.remove_small_functionvals(xs, ys)
    res = build_affinemodel(xs_clean, ys_clean)

    slope, ordorig = res[1]
    residual = res[2]

    # either the slope is as good as predicted, or the function is plain flat
    # when there is no data to regress on, build_affinemodel returns exactly [0, 0]
    ismodelsatisfying = (slope >= targetslope - 0.1) || (slope == ordorig == Tf(0))
    isresidualsatisfying = residual < eps(Tf)
    return ismodelsatisfying && isresidualsatisfying
end
