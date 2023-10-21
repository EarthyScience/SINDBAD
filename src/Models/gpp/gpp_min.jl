export gpp_min

struct gpp_min <: gpp end

function compute(params::gpp_min, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        gpp_f_climate ∈ land.diagnostics
        fAPAR ∈ land.states
        gpp_potential ∈ land.diagnostics
        gpp_f_soilW ∈ land.diagnostics
    end

    AllScGPP = min(gpp_f_climate, gpp_f_soilW)
    # & multiply
    gpp = fAPAR * gpp_potential * AllScGPP

    ## pack land variables
    @pack_land begin
        gpp → land.fluxes
        AllScGPP → land.gpp
    end
    return land
end

@doc """
compute the actual GPP with potential scaled by minimum stress scalar of demand & supply for uncoupled model structure [no coupling with transpiration]

---

# compute:
Combine effects as multiplicative or minimum; if coupled, uses transup using gpp_min

*Inputs*
 - land.diagnostics.gpp_f_climate: effective demand scalars; between 0-1
 - land.diagnostics.gpp_potential: maximum potential GPP based on radiation use efficiency
 - land.diagnostics.gpp_f_soilW: soil moisture stress scalar; between 0-1
 - land.states.fAPAR: fraction of absorbed photosynthetically active radiation  [-] (equivalent to "canopy cover" in Gash & Miralles)

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
gpp_min
