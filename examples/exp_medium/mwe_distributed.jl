using Distributed
using SharedArrays
addprocs()

# n = 2^14
# o = SharedArray{Float64}(n)

# @everywhere function up_elemet!(o, i)
#     o[i] = 1.0/i
# end

# function square_distributed(o)
#     @sync @distributed for i in eachindex(o)
#         up_elemet!(o, i)
#     end
# end

# @time square_distributed(o)

# not everywhere
# using Random
# Random.seed!(123)
# ar = rand(7,5)
# using SindbadML: ForwardDiffGrads
# f_loss(x, a, b, c) = a*x[1]^2 + sum(b[:,c])*x[2]
# args = (; a=2, b = ar, c = 1)

# ForwardDiffGrads(f_loss, [1,0], args...)

# now everywhere


@everywhere using ForwardDiff
@everywhere using SindbadML: ForwardDiffGrads
using Random
Random.seed!(123)
ar = rand(7,5)

@everywhere f_loss(x, a, b, c) = a*x[1]^2 + sum(b[:,c])*x[2]
@everywhere args = (; a=2, b = $ar, c = 1)

ForwardDiffGrads(f_loss, [1,0], args...)

o = SharedArray{Float64}(2, 12)

function GradientsDistributed(o)
    @sync @distributed for i in axes(o,2)
        args = (; a=2, b = rand(7,size(o,2)), c = i)
        o[:,i] = ForwardDiffGrads(f_loss, rand(2), args...)
    end
end


@time GradientsDistributed(o)

o