export evaporation_fAPAR

#! format: off
@bounds @describe @units @with_kw struct evaporation_fAPAR{T1,T2} <: evaporation
    α::T1 = 1.0 | (0.1, 3.0) | "α coefficient of Priestley-Taylor formula for soil" | ""
    k_evaporation::T2 = 0.2 | (0.05, 0.95) | "fraction of soil water that can be used for soil evaporation" | "1/time"
end
#! format: on

function compute(params::evaporation_fAPAR, forcing, land, helpers)
    ## unpack parameters
    @unpack_evaporation_fAPAR params

    ## unpack land variables
    @unpack_land begin
        fAPAR ∈ land.states
        soilW ∈ land.pools
        ΔsoilW ∈ land.states
        PET ∈ land.fluxes
        (z_zero, o_one) ∈ land.wCycleBase
    end
    # multiply equilibrium PET with αSoil & [1.0 - fAPAR] to get potential soil evap
    tmp = PET * α * (o_one - fAPAR)
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

function update(params::evaporation_fAPAR, forcing, land, helpers)
    @unpack_evaporation_bareFraction params

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
        # ΔsoilW => land.states
    end
    return land
end

@doc """
calculates the bare soil evaporation from 1-fAPAR & PET soil

# Parameters
$(SindbadParameters)

---

# compute:
Soil evaporation using evaporation_fAPAR

*Inputs*
 - land.fluxes.PET: forcing data set
 - land.states.fAPAR [output of fAPAR module]
 - α

*Outputs*
 - land.fluxes.PETSoil
 - land.fluxes.evaporation

# update

update pools and states in evaporation_fAPAR

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
evaporation_fAPAR
