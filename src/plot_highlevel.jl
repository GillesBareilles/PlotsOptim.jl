function extract_minF(optimizer_to_trace)
    F_opt = +Inf
    for (optimizer, trace) in optimizer_to_trace
        for state in trace
            F_opt = min(F_opt, state.f_x + state.g_x)
        end
    end
    return F_opt
end


"""
    $(TYPEDSIGNATURES)

Plot suboptimality as a function of iterations. The baseline functional value should be supplied
for computing suboptimality.
"""
function plot_relsubopt_iteration(
    optimizer_to_trace::AbstractDict;
    F_opt = nothing,
    state_absciss = s -> s.it,
    xlabel = "iterations",
)
    isnothing(F_opt) && (F_opt = extract_minF(optimizer_to_trace))

    get_abscisses(states) = [state_absciss(state) for state in states]
    get_ordinates(optimizer, states) = [ get_relsubopt(optimizer, states, i, F_opt=F_opt) for i in 1:length(states)]

    return plot_curves(
        optimizer_to_trace::AbstractDict{Optimizer,Any},
        get_abscisses,
        get_ordinates,
        xlabel = xlabel,
        ylabel = L"$F(x_k)-F^\star / (F(x_1)-F^\star)$",
        ymode = "log",
        nmarks = 15,
    )
end

function plot_relsubopt_time(optimizer_to_trace::AbstractDict; F_opt = nothing)
    return plot_relsubopt_iteration(
        optimizer_to_trace,
        F_opt = F_opt,
        state_absciss = s -> s.time,
        xlabel = "time (s)",
    )
end


function plot_subopt_iteration(
    optimizer_to_trace::AbstractDict{Optimizer,Any};
    F_opt = nothing,
    state_absciss = s -> s.it,
    xlabel = "iterations",
    subopt_levels = []
)
    isnothing(F_opt) && (F_opt = extract_minF(optimizer_to_trace))

    get_abscisses(states) = [state_absciss(state) for state in states]
    get_ordinates(optimizer, states) = [ get_subopt(optimizer, states, i, F_opt=F_opt) for i in 1:length(states)]

    return plot_curves(
        optimizer_to_trace::AbstractDict{Optimizer,Any},
        get_abscisses,
        get_ordinates,
        xlabel = xlabel,
        ylabel = L"$F(x_k)-F(x^\star)$",
        ymode = "log",
        nmarks = 15;
        horizontallines = subopt_levels,
    )
end

function plot_subopt_time(optimizer_to_trace::AbstractDict{Optimizer,Any}; F_opt = nothing, subopt_levels = [])
    return plot_subopt_iteration(
        optimizer_to_trace,
        F_opt = F_opt,
        state_absciss = s -> s.time,
        xlabel = "time (s)",
        subopt_levels = subopt_levels
    )
end

"""
    $(TYPEDSIGNATURES)

Plot suboptimality as a function of iterations.
"""
function plot_step_iteration(
    optimizer_to_trace::AbstractDict{Optimizer,Any};
    state_absciss = s -> s.it,
    xlabel = "iterations",
)
    get_abscisses(states) = [state_absciss(state) for state in states]
    get_ordinates(otpimizer, states) = [state.norm_step for state in states]

    return plot_curves(
        optimizer_to_trace::AbstractDict{Optimizer,Any},
        get_abscisses,
        get_ordinates,
        xlabel = xlabel,
        ylabel = L"$\|x_{k-1}-x_k\|$",
        ymode = "log",
        nmarks = 15,
    )
end
function plot_step_time(optimizer_to_trace::AbstractDict{Optimizer,Any})
    return plot_step_iteration(
        optimizer_to_trace,
        state_absciss = s -> s.time,
        xlabel = "time (s)",
    )
end

"""
    $(TYPEDSIGNATURES)

Plot tangent residual as a function of iterations.
"""
function plot_tangentres_iteration(
    optimizer_to_trace::AbstractDict{Optimizer,Any};
    state_absciss = s -> s.it,
    xlabel = "iterations",
)
    get_abscisses(states) = [state_absciss(state) for state in states]
    function get_ordinates(otpimizer, states)
        return [state.norm_minsubgradient_tangent for state in states]
    end

    return plot_curves(
        optimizer_to_trace::AbstractDict{Optimizer,Any},
        get_abscisses,
        get_ordinates,
        xlabel = xlabel,
        ylabel = L"$\|\nabla_M (f+g)(x_k)\|$",
        ymode = "log",
        nmarks = 15,
    )
end
function plot_tangentres_time(optimizer_to_trace::AbstractDict{Optimizer,Any})
    return plot_tangentres_iteration(
        optimizer_to_trace,
        state_absciss = s -> s.time,
        xlabel = "time (s)",
    )
end

"""
plot_normalres_iteration(optimizer_to_trace)

Plot tangent residual as a function of iterations.
"""
function plot_normalres_iteration(
    optimizer_to_trace::AbstractDict{Optimizer,Any};
    state_absciss = s -> s.it,
    xlabel = "iterations",
)
    get_abscisses(states) = [state_absciss(state) for state in states]
    function get_ordinates(otpimizer, states)
        return [state.norm_minsubgradient_normal for state in states]
    end

    return plot_curves(
        optimizer_to_trace::AbstractDict{Optimizer,Any},
        get_abscisses,
        get_ordinates,
        xlabel = xlabel,
        ylabel = L"normal comp. $\partial (f+g)(x_k)$",
        ymode = "linear",
        nmarks = 15,
    )
end
function plot_normalres_time(optimizer_to_trace::AbstractDict{Optimizer,Any})
    return plot_normalres_iteration(
        optimizer_to_trace,
        state_absciss = s -> s.time,
        xlabel = "time (s)",
    )
end

"""
plot_structure_iteration(optimizer_to_trace, M_opt)

Plot iterate manifold dimension as a function of iterations.
"""
function plot_structure_iteration(
    optimizer_to_trace::AbstractDict{Optimizer,Any},
    M_opt;
    state_absciss = s -> s.it,
    xlabel = "iterations",
)
    M_opt_dim = manifold_dimension(M_opt)
    embedding_dim = embedding_dimension(M_opt)

    get_abscisses(states) = [state_absciss(state)+1 for state in states]
    function get_ordinates(optimizer, states)
        # return [100 * (embedding_dim-manifold_dimension(state.additionalinfo.M)) / (embedding_dim - M_opt_dim) for state in states]
        return [manifold_dimension(state.additionalinfo.M) for state in states]
    end

    return plot_curves(
        optimizer_to_trace::AbstractDict{Optimizer,Any},
        get_abscisses,
        get_ordinates,
        xlabel = xlabel,
        xmode = "log",
        ylabel = latexstring("dim(\$M_k\$)"),
        ymode = "normal",
        nmarks = 15,
    )
end
function plot_structure_time(optimizer_to_trace::AbstractDict{Optimizer,Any}, M_opt;)
    return plot_structure_iteration(
        optimizer_to_trace,
        M_opt,
        state_absciss = s -> s.time,
        xlabel = "time (s)",
    )
end
