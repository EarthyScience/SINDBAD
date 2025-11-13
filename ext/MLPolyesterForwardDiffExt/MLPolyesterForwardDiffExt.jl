module MLPolyesterForwardDiffExt

import SinbadCore.Types:
    PolyesterForwardDiffGrad,
    ForwardDiffGrad
import Sindbad.ML:
    getCacheFromOutput,
    getOutputFromCache
import PolyesterForwardDiff
import ForwardDiff

# Extend getCacheFromOutput and getOutputFromCache to handle PolyesterForwardDiffGrad
# Functions copied from src/ML/diffCaches.jl
function getCacheFromOutput(loc_output, ::PolyesterForwardDiffGrad)
    return getCacheFromOutput(loc_output, ForwardDiffGrad())
end

function getOutputFromCache(loc_output, new_params, ::PolyesterForwardDiffGrad)
    return getOutputFromCache(loc_output, new_params, ForwardDiffGrad())
end

# Gradient computation using PolyesterForwardDiff for parallel differentiation
# Functions copied from src/ML/mlGradient.jl
function gradientSite(grads_lib::PolyesterForwardDiffGrad, x_vals, chunk_size::Int, loss_f::F, args...) where {F}
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

function gradientSite(::PolyesterForwardDiffGrad, x_vals, gradient_options::NamedTuple, loss_f::F) where {F}
    ∇x = similar(x_vals) # pre-allocate
    if occursin("arm64-apple-darwin", Sys.MACHINE) # fallback due to closure issues on M1 systems
        # cfg = ForwardDiff.GradientConfig(loss_tmp, x_vals, Chunk{chunk_size}());
        ForwardDiff.gradient!(∇x, loss_f, x_vals) # ?, add `cfg` at the end if further control is needed.
    else
        PolyesterForwardDiff.threaded_gradient!(loss_f, ∇x, x_vals, ForwardDiff.Chunk(chunk_size));
    end
    return ∇x
end

function gradientBatch!(grads_lib::PolyesterForwardDiffGrad, dx_batch, chunk_size::Int,
    loss_f::Function, get_inner_args::Function, input_args...; showprog=false)
    mapfun = showprog ? progress_pmap : pmap
    result = mapfun(CachingPool(workers()), axes(dx_batch, 2)) do idx
        x_vals, inner_args = get_inner_args(idx, grads_lib, input_args...)
        gradientSite(grads_lib, x_vals, chunk_size, loss_f, inner_args...)
    end
    for idx in axes(dx_batch, 2)
        dx_batch[:, idx] = result[idx]
    end
end

function gradientBatch!(grads_lib::PolyesterForwardDiffGrad, dx_batch, gradient_options::NamedTuple, loss_functions, scaled_params_batch, sites_batch; showprog=false)
    mapfun = showprog ? progress_pmap : pmap
    result = mapfun(CachingPool(workers()), axes(dx_batch, 2)) do idx
        site_name = sites_batch[idx]
        loss_f = loss_functions(site=site_name)
        x_vals = scaled_params_batch(site=site_name).data.data
        gradientSite(grads_lib, x_vals, gradient_options, loss_f)    
    end
    for idx in axes(dx_batch, 2)
        dx_batch[:, idx] = result[idx]
    end
end

end