using PlotsOptim, Tests

function runtests()
    @testset "simplify_stairs" begin
        # several edge cases
        abs = [1, 2, 3, 4, 5]
        ord = [1, 1, 1, 2, 7]
        @test PlotsOptim.simplify_stairs(abs, ord) == ([1, 3, 4, 5], [1, 1, 2, 7])

        abs = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        ord = [1, 1, 1, 2, 7, 6, 4, 4, 4]
        @test PlotsOptim.simplify_stairs(abs, ord) == ([1, 3, 4, 5, 6, 7, 9], [1, 1, 2, 7, 6, 4, 4])

        abs = [1, 2, 3, 4, 5, 6, 7, 8]
        ord = [1, 1, 1, 2, 7, 6, 4, 4]
        @test PlotsOptim.simplify_stairs(abs, ord) == ([1, 3, 4, 5, 6, 7, 8], [1, 1, 2, 7, 6, 4, 4])
    end
end
