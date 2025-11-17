module SindbadFiniteDiffExt

import SindbadCore.Types:
    FiniteDiffGrad
import Sindbad
import FiniteDiff

# function copied from src/ML/mlGradient.jl
function Sindbad.ML.gradientSite(::FiniteDiffGrad, x_vals::AbstractArray, chunk_size::Int, loss_f::F, args...) where {F}
    loss_tmp(x) = loss_f(x, grads_lib, args...)
    return FiniteDiff.finite_difference_gradient(loss_tmp, x_vals)
end

end