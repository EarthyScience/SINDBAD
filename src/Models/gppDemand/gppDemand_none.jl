export gppDemand_none

struct gppDemand_none <: gppDemand end

function define(p_struct::gppDemand_none, forcing, land, helpers)
    ## calculate variables
    # set scalar to a constant one [no effect on potential GPP]
    gpp_f_climate = helpers.numbers.𝟙

    # compute demand GPP with no stress. gpp_f_climate is set to ones in the prec; & hence the demand have no stress in GPP.
    gpp_demand = helpers.numbers.𝟘

    ## pack land variables
    @pack_land (gpp_f_climate, gpp_demand) => land.gppDemand
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
 - land.gppDemand.gpp_f_climate: effective scalar of demands
 - land.gppDemand.gpp_demand: demand-driven GPP with no stress

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
