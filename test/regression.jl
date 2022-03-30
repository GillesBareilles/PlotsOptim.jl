using DataStructures
using Test
using PlotsOptim

@testset "Affine models regression - $Tf" for Tf in [
    Float64,
    BigFloat
    ]

    model_to_functions = OrderedDict{String, Function}(
        "t1" => t -> t,
        "t2" => t -> t^2,
        "t3" => t -> t^3,
        "f null" => t -> 1e3 * eps(Tf), # second order expansion of quadratic model
        "f reaching eps" => t -> max(t^2, 1e3 * eps(Tf)), # reaching numerical precision for Float64
    )
    model_to_pred = Dict(
        "t1" => 1,
        "t2" => 2,
        "t3" => 3,
        "f null" => 3, # Could be other thing
        "f reaching eps" => 2,
    )

    @testset "build_logcurves" begin

        logcurves = PlotsOptim.build_logcurves(model_to_functions; Tf)

        @testset "$model" for (model, curve) in logcurves
            @test curve isa Tuple{Vector{Tf}, Vector{Tf}}

            xs, ys = curve
            xs_clean, ys_clean = PlotsOptim.remove_small_functionvals(xs, ys)
            @test xs_clean isa Vector{Tf}
            @test ys_clean isa Vector{Tf}

            res = build_affinemodel(xs_clean, ys_clean)
            @test res isa Tuple{Vector{Tf}, Tf}

            slope, ordorig = res[1]
            residual = res[2]
            targetslope = model_to_pred[model]

            # either the slope is as good as predicted, or the function is plain flat
            # when there is no data to regress on, build_affinemodel returns exactly [0, 0]
            @test (slope >= targetslope - 0.1) || (res[1] == Tf[0.0, 0.0])
            @test residual < eps(Tf)

            # All the above, wrapped in one function.
            @test check_curveslope(curve, targetslope)
        end
    end
end
