using Sindbad.MachineLearning
using Test

@testset "SindbadML.jl" begin
    list = string.('a':'d')
    @test shuffleList(list) == ["a", "d", "b", "c"]
    @test shuffleList(list; seed = 312) == ["c", "b", "d", "a"]
    @test length(partitionBatches(10; batch_size=5)) == 2
    batch_test = shuffleBatches(list, 2; seed=1)
    @test length(batch_test) == 2
    @test length(batch_test[1]) == 2

    # test nn_dense
    m1 = denseNN(5, 2, 1)
    @test length(m1(rand(5))) == 1
    m2 = denseNN(5, 2, 2)
    @test size(m2(rand(Float32, 5))) == (2,)
    dense_flat = denseFlattened(m2)
    @test typeof(dense_flat[1]) <: AbstractArray
    @test typeof(dense_flat[2]) <: SindbadML.Optimisers.Restructure
    @test typeof(dense_flat[3]) <: SindbadML.Optimisers.Leaf

    # ForwardDiff_grads
    f_cost(x, a, b) = a*x[1]^2 + b*x[2]
    args = (; a=2, b = 1)
    @test ForwardDiff_grads(f_loss, [1,0], args...) == [4,1]
end