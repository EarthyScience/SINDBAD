module SindbadFiniteDifferencesExt

import FiniteDifferences
import SindbadCore.Types:
    FiniteDifferencesGrad
import Sindbad

# function copied from src/ML/mlGradient.jl
function Sindbad.ML.gradientSite(grads_lib::FiniteDifferencesGrad, x_vals::AbstractArray, chunk_size::Int, loss_f::F, args...) where {F}
    loss_tmp(x) = loss_f(x, grads_lib, args...)
    gr_fds = FiniteDifferences.grad(FiniteDifferences.central_fdm(5, 1), loss_tmp, x_vals)
    return gr_fds[1]
end

end