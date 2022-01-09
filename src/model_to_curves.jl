"""
    $TYPEDSIGNATURES

Build a logspaced range from 10^`min` to 10^`max`. Default is [1e-15, -1].
"""
function logspaced_range(;npoints = 50, min=-15, max=-1)
    return 10 .^ collect(range(min, max, length=npoints))
end

"""
    $TYPEDSIGNATURES

Build the OrderedDict pairing the model name to the tuple of abscisses and
ordinates of the input function. The values are thresholded at `minval`,
and converted to `Float64`.
"""
function build_logcurves(model_to_function::OrderedDict{String, Function}; minval = eps(Float64), npoints=50)
    ts = logspaced_range(npoints = npoints)

    res = OrderedDict( model => (ts, Float64[ max(minval, φ(t)) for t in ts ]) for (model, φ) in model_to_function )
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
"""
function remove_small_functionvals(xs, ys; threshold=1e-12)
    nnzentries = count(y->abs(y)> threshold, ys)
    xs_clean = zeros(nnzentries)
    ys_clean = zeros(nnzentries)
    ind_clean = 1
    for i in 1:length(xs)
        if abs(ys[i]) > 1e-12
            xs_clean[ind_clean] = xs[i]
            ys_clean[ind_clean] = ys[i]
            ind_clean += 1
        end
    end
    return xs_clean, ys_clean
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
function build_affinemodel(xs, ys)
    n = length(xs)

    if length(xs) == 0
        # Ordinates are too small to count
        return [0.0, 0.0], 0.0
    end

    X = ones(n, 2)
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
    for (model, curve) in build_logcurves(model_to_function; minval = 10*eps(Tf))
        xs, ys = curve
        xs, ys = remove_small_functionvals(xs, ys)
        res[model] = build_affinemodel(xs, ys)
    end
    return res
end
