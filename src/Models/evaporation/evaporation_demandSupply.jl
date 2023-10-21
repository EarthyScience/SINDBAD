export evaporation_demandSupply

#! format: off
@bounds @describe @units @with_kw struct evaporation_demandSupply{T1,T2} <: evaporation
    α::T1 = 1.0 | (0.1, 3.0) | "α coefficient of Priestley-Taylor formula for soil" | ""
    k_evaporation::T2 = 0.2 | (0.05, 0.98) | "fraction of soil water that can be used for soil evaporation" | "1/time"
end
#! format: on

function compute(params::evaporation_demandSupply, forcing, land, helpers)
    ## unpack parameters
    @unpack_evaporation_demandSupply params

    ## unpack land variables
    @unpack_land begin
        soilW ∈ land.pools
        ΔsoilW ∈ land.pools
        PET ∈ land.fluxes
        z_zero ∈ land.constants
    end
    # calculate potential soil evaporation
    PET_evaporation = maxZero(PET * α)
    evaporationSupply = maxZero(k_evaporation * (soilW[1] + ΔsoilW[1]))

    # calculate the soil evaporation as a fraction of scaling parameter & PET
    evaporation = min(PET_evaporation, evaporationSupply)

    # update soil moisture changes
    @add_to_elem -evaporation → (ΔsoilW, 1, :soilW)
    ## pack land variables
    @pack_land begin
        (PET_evaporation, evaporationSupply) → land.fluxes
        evaporation → land.fluxes
        ΔsoilW → land.pools
    end
    return land
end

function update(params::evaporation_demandSupply, forcing, land, helpers)
    @unpack_evaporation_demandSupply params

    ## unpack variables
    @unpack_land begin
        soilW ∈ land.pools
        ΔsoilW ∈ land.pools
    end

    ## update variables
    # update soil moisture of the first layer
    soilW[1] = soilW[1] + ΔsoilW[1]

    # reset soil moisture changes to zero
    ΔsoilW[1] = ΔsoilW[1] - ΔsoilW[1]

    ## pack land variables
    @pack_land begin
        soilW → land.pools
        # ΔsoilW → land.pools
    end
    return land
end

@doc """
calculates the bare soil evaporation from demand-supply limited approach. 

# Parameters
$(SindbadParameters)

---

# compute:
Soil evaporation using evaporation_demandSupply

*Inputs*
 - land.fluxes.PET: extra forcing from prec
 - land.fluxes.PET_evaporation: extra forcing from prec
 - α:

*Outputs*
 - land.fluxes.PETSoil
 - land.fluxes.evaporation

# update

update pools and states in evaporation_demandSupply

 - land.pools.soilW[1]: bare soil evaporation is only allowed from first soil layer

---

# Extended help

*References*
 - Teuling et al.

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: clean up the code
 - 1.0 on 11.11.2019 [skoirala]: clean up the code  

*Created by:*
 - mjung
 - skoirala
 - ttraut

*Notes*
 - considers that the soil evaporation can occur from the whole grid & not only the  non-vegetated fraction of the grid cell  
"""
evaporation_demandSupply
