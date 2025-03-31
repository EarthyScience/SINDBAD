export transpirationDemand_CASA

struct transpirationDemand_CASA <: transpirationDemand end

function compute(params::transpirationDemand_CASA, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        PAW ⇐ land.states
        (w_awc, soil_α, soil_β) ⇐ land.properties
        percolation ⇐ land.fluxes
        PET ⇐ land.fluxes
    end
    VMC = clampZeroOne(sum(PAW) / sum(w_awc))
    o_one = one(VMC)
    RDR = (o_one + mean(soil_α)) / (o_one + mean(soil_α) * (VMC^mean(soil_β)))
    transpiration_demand = percolation + (PET - percolation) * RDR

    ## pack land variables
    @pack_nt transpiration_demand ⇒ land.diagnostics
    return land
end


purpose(::Type{transpirationDemand_CASA}) = "calculate the supply limited transpiration as function of volumetric soil content & soil properties; as in the CASA model"


@doc """

$(getBaseDocString(transpirationDemand_CASA))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala | @dr-ko]: split the original transpiration_supply of CASA into demand supply: actual [minimum] is now just demandSupply approach of transpiration  

*Created by*
 - ncarvalhais
 - skoirala | @dr-ko

*Notes*
 - The supply limit has non-linear relationship with moisture state over the root zone
"""
transpirationDemand_CASA
