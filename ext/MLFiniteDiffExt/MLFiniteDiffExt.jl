module MLFiniteDiffExt

import SinbadCore.Types: FiniteDiffGrad
import Sindbad.ML: gradientSite
import FiniteDiff

# function copied from src/ML/mlGradient.jl

function gradientSite(::FiniteDiffGrad, x_vals::AbstractArray, gradient_options::NamedTuple,loss_f::F) where {F}
    return FiniteDiff.finite_difference_gradient(loss_f, x_vals)
end

end