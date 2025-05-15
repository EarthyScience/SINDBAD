export transpirationSupply_CASA

struct transpirationSupply_CASA <: transpirationSupply end

function compute(params::transpirationSupply_CASA, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt PAW ⇐ land.states

    ## calculate variables
    transpiration_supply = sum(PAW)

    ## pack land variables
    @pack_nt transpiration_supply ⇒ land.diagnostics
    return land
end


purpose(::Type{transpirationSupply_CASA}) = "calculate the supply limited transpiration as function of volumetric soil content & soil properties; as in the CASA model"

@doc """

$(getModelDocString(transpirationSupply_CASA))

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala | @dr-ko]: split the original transpiration_supply of CASA into demand  supply: actual [minimum] is now just demSup approach of transpiration  

*Created by*
 - ncarvalhais
 - skoirala | @dr-ko

*Notes*
 - The supply limit has non-linear relationship with moisture state over the root zone
"""
transpirationSupply_CASA
