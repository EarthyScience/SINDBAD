export gpp_mult

struct gpp_mult <: gpp end

function define(p_struct::gpp_mult, forcing, land, helpers)
    @unpack_land begin
        z_zero ∈ land.wCycleBase
    end

    AllScGPP = z_zero
    gpp = z_zero
    ## pack land variables
    @pack_land begin
        AllScGPP => land.gpp
        gpp => land.fluxes
    end
    return land
end

function compute(p_struct::gpp_mult, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        gpp_f_climate ∈ land.gppDemand
        fAPAR ∈ land.states
        gpp_potential ∈ land.gppPotential
        gpp_f_soilW ∈ land.gppSoilW
    end

    AllScGPP = gpp_f_climate * gpp_f_soilW #sujan

    gpp = fAPAR * gpp_potential * AllScGPP

    ## pack land variables
    @pack_land begin
        gpp => land.fluxes
        AllScGPP => land.gpp
    end
    return land
end

@doc """
compute the actual GPP with potential scaled by multiplicative stress scalar of demand & supply for uncoupled model structure [no coupling with transpiration]

---

# compute:
Combine effects as multiplicative or minimum; if coupled, uses transup using gpp_mult

*Inputs*
 - land.gppDemand.gpp_f_climate: effective demand scalars; between 0-1
 - land.gppPotential.gpp_potential: maximum potential GPP based on radiation use efficiency
 - land.gppSoilW.gpp_f_soilW: soil moisture stress scalar; between 0-1
 - land.states.fAPAR: fraction of absorbed photosynthetically active radiation (equivalent to "canopy cover" in Gash & Miralles)

*Outputs*
 - land.fluxes.gpp: actual GPP [gC/m2/time]
 - land.gpp.AllScGPP

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval

*Notes*
"""
gpp_mult
