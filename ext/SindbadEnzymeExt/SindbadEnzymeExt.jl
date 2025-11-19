module SindbadEnzymeExt

import Sindbad
import SindbadCore.Types:
    EnzymeGrad
using Enzyme

function Sindbad.ML.gradientSite(::EnzymeGrad, x_vals::AbstractArray, chunk_size::Int, loss_f::F, args...) where {F}
    # does not work with `Enzyme.gradient!` but is kept here as placeholder for future development
    # Ensure x_vals is a mutable array (Vector)
    x_vals = collect(copy(x_vals))  # Convert to a mutable array if necessary
    # x_vals = copy(x_vals)
    loss_tmp(x) = loss_f(x, grads_lib, args...)
    return Enzyme.gradient(Forward, loss_tmp, x_vals)
end

end