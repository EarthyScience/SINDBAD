module SindbadPolyesterForwardDiffExt

import SindbadCore.Types:
    PolyesterForwardDiffGrad,
    ForwardDiffGrad
import Sindbad.ML:
    getCacheFromOutput,
    getOutputFromCache,
    gradientSite,
    gradientBatch!
import Sindbad
import PolyesterForwardDiff
import ForwardDiff
using Distributed:
        pmap,
        workers,
        CachingPool
import ProgressMeter:
    progress_pmap,
    progress_map

# Extend getCacheFromOutput and getOutputFromCache to handle PolyesterForwardDiffGrad
# Functions copied from src/ML/diffCaches.jl
function Sindbad.ML.getCacheFromOutput(loc_output, ::PolyesterForwardDiffGrad)
    return getCacheFromOutput(loc_output, ForwardDiffGrad())
end

function Sindbad.ML.getOutputFromCache(loc_output, new_params, ::PolyesterForwardDiffGrad)
    return getOutputFromCache(loc_output, new_params, ForwardDiffGrad())
end

# Gradient computation using PolyesterForwardDiff for parallel differentiation
# Functions copied from src/ML/mlGradient.jl
function Sindbad.ML.gradientSite(grads_lib::PolyesterForwardDiffGrad, x_vals::AbstractArray, chunk_size::Int, loss_f::F, args...) where {F}
    loss_tmp(x) = loss_f(x, grads_lib, args...)
    ∇x = similar(x_vals) # pre-allocate
    if occursin("arm64-apple-darwin", Sys.MACHINE) # fallback due to closure issues on M1 systems
        # cfg = ForwardDiff.GradientConfig(loss_tmp, x_vals, Chunk{chunk_size}());
        ForwardDiff.gradient!(∇x, loss_tmp, x_vals) # ?, add `cfg` at the end if further control is needed.
    else
        PolyesterForwardDiff.threaded_gradient!(loss_tmp, ∇x, x_vals, ForwardDiff.Chunk(chunk_size));
    end
    return ∇x
end

function Sindbad.ML.gradientBatch!(grads_lib::PolyesterForwardDiffGrad, dx_batch, chunk_size::Int, loss_f::Function, get_inner_args::Function, input_args...; showprog=false)
    mapfun = showprog ? progress_pmap : pmap
    result = mapfun(CachingPool(workers()), axes(dx_batch, 2)) do idx
        x_vals, inner_args = get_inner_args(idx, grads_lib, input_args...)
        gradientSite(grads_lib, x_vals, chunk_size, loss_f, inner_args...)
    end
    for idx in axes(dx_batch, 2)
        dx_batch[:, idx] = result[idx]
    end
end

end