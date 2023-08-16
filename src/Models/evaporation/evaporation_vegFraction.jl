export evaporation_vegFraction

#! format: off
@bounds @describe @units @with_kw struct evaporation_vegFraction{T1,T2} <: evaporation
    α::T1 = 1.0 | (0.0, 3.0) | "α coefficient of Priestley-Taylor formula for soil" | ""
    k_evaporation::T2 = 0.2 | (0.03, 0.98) | "fraction of soil water that can be used for soil evaporation" | "1/time"
end
#! format: on

function compute(p_struct::evaporation_vegFraction, forcing, land, helpers)
    ## unpack parameters
    @unpack_evaporation_vegFraction p_struct

    ## unpack land variables
    @unpack_land begin
        frac_vegetation ∈ land.states
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
        PET ∈ land.fluxes
        (z_zero, o_one) ∈ land.wCycleBase
    end

    # multiply equilibrium PET with αSoil & [1.0 - frac_vegetation] to get potential soil evap
    tmp = PET * α * (o_one - frac_vegetation)
    PET_evaporation = maxZero(tmp)

    # scale the potential with the a fraction of available water & get the minimum of the current moisture
    evaporation = min(PET_evaporation, k_evaporation * (soilW[1] + ΔsoilW[1]))

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

function update(p_struct::evaporation_vegFraction, forcing, land, helpers)
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

    ## pack land variables
    @pack_land begin
        soilW => land.pools
        ΔsoilW => land.states
    end
    return land
end

@doc """
calculates the bare soil evaporation from 1-frac_vegetation & PET soil

# Parameters
$(SindbadParameters)

---

# compute:
Soil evaporation using evaporation_vegFraction

*Inputs*
 - land.fluxes.PET: forcing data set
 - land.states.frac_vegetation [output of frac_vegetation module]
 - α

*Outputs*
 - land.fluxes.PETSoil
 - land.fluxes.evaporation

# update

update pools and states in evaporation_vegFraction

 - land.pools.soilW[1]: bare soil evaporation is only allowed from first soil layer

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: clean up the code & moved from prec to dyna to handle land.states.frac_vegetation  

*Created by:*
 - mjung
 - skoirala
"""
evaporation_vegFraction
