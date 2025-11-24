using Sindbad.Simulation
using BenchmarkTools
using Test

@testset verbose=true begin
    include("utilsCore.jl")
    include("Models/models.jl") 
end