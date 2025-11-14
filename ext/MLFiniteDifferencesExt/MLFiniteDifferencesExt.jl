module MLFiniteDifferencesExt

import SinbadCore.Types: FiniteDifferencesGrad
import Sindbad.ML: gradientSite
import FiniteDifferences

# function copied from src/ML/mlGradient.jl
function gradientSite(::FiniteDifferencesGrad, x_vals::AbstractArray, gradient_options::NamedTuple,loss_f::F) where {F}
    gr_fds = FiniteDifferences.grad(FiniteDifferences.central_fdm(5, 1), loss_f, x_vals)
    return gr_fds[1]
end

end