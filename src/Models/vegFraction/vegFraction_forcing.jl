export vegFraction_forcing

struct vegFraction_forcing <: vegFraction end

function compute(p_struct::vegFraction_forcing, forcing, land, helpers)
    @unpack_forcing f_frac_vegetation ∈ forcing

    frac_vegetation = f_frac_vegetation

    ## pack land variables
    @pack_land frac_vegetation => land.states
    return land
end

@doc """
sets the value of land.states.frac_vegetation from the forcing in every time step

---

# compute:
Fractional coverage of vegetation using vegFraction_forcing

*Inputs*
 - forcing.frac_vegetation read from the forcing data set

*Outputs*
 - land.states.frac_vegetation: the value of frac_vegetation for current time step

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
vegFraction_forcing
