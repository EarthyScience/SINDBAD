export gppDemand_none

struct gppDemand_none <: gppDemand end

function define(params::gppDemand_none, forcing, land, helpers)
    o_one = land.constants.o_one
    z_zero = land.constants.z_zero

    gpp_f_climate = o_one

    # compute demand GPP with no stress. gpp_f_climate is set to ones in the prec; & hence the demand have no stress in GPP.
    gpp_demand = z_zero

    ## pack land variables
    @pack_land (gpp_f_climate, gpp_demand) → land.diagnostics
    return land
end

@doc """
sets the scalar for demand GPP to ones & demand GPP to zero

---

# compute:
Combine effects as multiplicative or minimum using gppDemand_none

*Inputs*
 - helpers

*Outputs*
 - land.diagnostics.gpp_f_climate: effective scalar of demands
 - land.diagnostics.gpp_demand: demand-driven GPP with no stress

# instantiate:
instantiate/instantiate time-invariant variables for gppDemand_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up 

*Created by:*
 - ncarval
"""
gppDemand_none
