export treeFraction_forcing

struct treeFraction_forcing <: treeFraction end

function compute(params::treeFraction_forcing, forcing, land, helpers)
    ## unpack forcing
    @unpack_nt f_tree_frac ⇐ forcing

    frac_tree = first(f_tree_frac)
    ## pack land variables
    @pack_nt frac_tree ⇒ land.states
    return land
end

@doc """
sets the value of land.states.frac_tree from the forcing in every time step

---

# compute:
Fractional coverage of trees using treeFraction_forcing

*Inputs*
 - forcing.frac_tree read from the forcing data set

*Outputs*
 - land.states.frac_tree: the value of frac_tree for current time step

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
treeFraction_forcing
