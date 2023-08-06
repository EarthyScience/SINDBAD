export evaporation_bareFraction

#! format: off
@bounds @describe @units @with_kw struct evaporation_bareFraction{T1} <: evaporation
    ks::T1 = 0.5 | (0.1, 0.95) | "resistance against soil evaporation" | ""
end
#! format: on

function compute(p_struct::evaporation_bareFraction, forcing, land, helpers)
    ## unpack parameters
    @unpack_evaporation_bareFraction p_struct

    ## unpack land variables
    @unpack_land begin
        frac_vegetation ∈ land.states
        ΔsoilW ∈ land.states
        soilW ∈ land.pools
        PET ∈ land.fluxes
        (z_zero, o_one) ∈ land.wCycleBase
    end
    # scale the potential ET with bare soil fraction
    PET_evaporation = PET * (o_one - frac_vegetation)
    # calculate actual ET as a fraction of PET_evaporation
    evaporation = min(PET_evaporation, (soilW[1] + ΔsoilW[1]) * ks)

    # update soil moisture changes
    @add_to_elem -evaporation => (ΔsoilW, 1, :soilW)

    ## pack land variables
    @pack_land begin
        PET_evaporation => land.fluxes
        evaporation => land.fluxes
        ΔsoilW => land.states
    end
    return land
end

function update(p_struct::evaporation_bareFraction, forcing, land, helpers)
    @unpack_evaporation_bareFraction p_struct

    ## unpack variables
    @unpack_land begin
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
    end

    ## update variables
    # update soil moisture of the first layer
    soilW[1] = soilW[1] + ΔsoilW[1]

    # reset soil moisture changes to zero
    ΔsoilW[1] = ΔsoilW[1] - ΔsoilW[1]

    # ## pack land variables
    # @pack_land begin
    # 	soilW => land.pools
    # 	ΔsoilW => land.states
    # end
    return land
end

@doc """
calculates the bare soil evaporation from 1-frac_vegetation of the grid & PET_evaporation

# Parameters
$(SindbadParameters)

---

# compute:
Soil evaporation using evaporation_bareFraction

*Inputs*
 - land.fluxes.PET: forcing data set
 - land.states.frac_vegetation [output of frac_vegetation module]

*Outputs*
 - land.fluxes.PETSoil
 - land.fluxes.evaporation

# update

update pools and states in evaporation_bareFraction

 - land.pools.soilW[1]: bare soil evaporation is only allowed from first soil layer

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: clean up the code & moved from prec to dyna to handle land.states.frac_vegetation  

*Created by:*
 - mjung
 - skoirala
 - ttraut
"""
evaporation_bareFraction
