module SindbadMLEnzymeExt

using SindbadML
import SindbadML: gradientSite
import SindbadML: EnzymeGrad
using Enzyme

function gradientSite(::EnzymeGrad, x_vals::AbstractArray, gradient_options::NamedTuple,loss_f::F) where {F}
    # does not work with `Enzyme.gradient!` but is kept here as placeholder for future development
    # Ensure x_vals is a mutable array (Vector)
    x_vals = collect(copy(x_vals))  # Convert to a mutable array if necessary
    # x_vals = copy(x_vals)
    return Enzyme.gradient(Forward, loss_f, x_vals)
end

end