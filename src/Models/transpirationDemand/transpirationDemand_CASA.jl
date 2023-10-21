export transpirationDemand_CASA

struct transpirationDemand_CASA <: transpirationDemand end

function compute(params::transpirationDemand_CASA, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        PAW ∈ land.states
        (wAWC, soil_α, soil_β) ∈ land.properties
        percolation ∈ land.fluxes
        PET ∈ land.fluxes
    end
    VMC = clampZeroOne(sum(PAW) / sum(wAWC))
    o_one = one(VMC)
    RDR = (o_one + mean(soil_α)) / (o_one + mean(soil_α) * (VMC^mean(soil_β)))
    transpiration_demand = percolation + (PET - percolation) * RDR

    ## pack land variables
    @pack_land transpiration_demand → land.diagnostics
    return land
end

@doc """
calculate the supply limited transpiration as function of volumetric soil content & soil properties; as in the CASA model

---

# compute:
Demand-driven transpiration using transpirationDemand_CASA

*Inputs*
 - land.pools.PAW : plant avaiable water
 - land.properties.p_[α/β]: moisture retention characteristics
 - land.properties.wAWC: total maximum plant available water [FC-WP]
 - land.states.PAW: actual extractable water

*Outputs*
 - land.transpiration_demand.transpirationDemand: supply limited transpiration

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: split the original transpiration_supply of CASA into demand supply: actual [minimum] is now just demandSupply approach of transpiration  

*Created by:*
 - ncarval
 - skoirala

*Notes*
 - The supply limit has non-linear relationship with moisture state over the root zone
"""
transpirationDemand_CASA
