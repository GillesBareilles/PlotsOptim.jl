using LinearAlgebra
using PlotsOptim

## function F = f + g
A = Matrix{Float64}([1. 1.; 0. 1.]) .* 0.5
x0 = Vector([-0.25, 1.2])
b = A * x0

f(A, b, x) = 0.5 * norm(A * x - b)^2
g(x) = 0.2 * norm(x, 1)
F(A, b, x) = f(A, b, x) + g(x)

function main()
    ## Plotting in intermediate space
    xmin, xmax = -1, 2
    ymin, ymax = -0.5, 1.5

    ## Base plot
    axisbounds = (; xmin, xmax, ymin, ymax)
    axis = baseaxis(axisbounds)

    ## Plot smooth function f
    axisf = copy(axis)
    add_segment!(axisf, [[0, ymin], [0, ymax]]; color = "black")
    add_segment!(axisf, [[xmin, 0], [xmax, 0]]; color = "black")

    add_contour!(axisf, x -> f(A, b, x), axisbounds; levels = 0.1:0.1:1.0)
    savefig(axisf, "./Lasso_f")

    ## Plot nonsmooth function F
    axisF = copy(axis)
    add_contour!(axisF, x -> F(A, b, x), axisbounds; levels = [ 0.2, 0.28, 0.4, 0.55, 0.67, 0.79, 0.91, 1.0, 1.16, 1.28, 1.40])

    add_segment!(axisF, [[0, ymin], [0, ymax]])
    add_text!(axisF, [1.8, 0.2], raw"$\mathcal M_1$"; color = "chartreuse")
    add_segment!(axisF, [[xmin, 0], [xmax, 0]])
    add_text!(axisF, [0.2, 1.3], raw"$\mathcal M_2$"; color = "chartreuse")
    savefig(axisF, "./Lasso_F")
    return
end

main()
