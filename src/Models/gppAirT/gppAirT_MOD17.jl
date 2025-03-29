export gppAirT_MOD17

#! format: off
@bounds @describe @units @timescale @with_kw struct gppAirT_MOD17{T1,T2} <: gppAirT
    Tmax::T1 = 20.0 | (10.0, 35.0) | "temperature for max GPP" | "°C" | ""
    Tmin::T2 = 5.0 | (0.0, 15.0) | "temperature for min GPP" | "°C" | ""
end
#! format: on

function compute(params::gppAirT_MOD17, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppAirT_MOD17 params
    @unpack_nt f_airT_day ⇐ forcing
    @unpack_nt o_one ⇐ land.constants

    ## calculate variables
    tsc = f_airT_day / ((o_one - Tmin) * (Tmax - Tmin)) #@needscheck: if the equation reflects the original implementation
    gpp_f_airT = clampZeroOne(tsc)

    ## pack land variables
    @pack_nt gpp_f_airT ⇒ land.diagnostics
    return land
end

purpose(::Type{gppAirT_MOD17}) = "temperature stress on gpp_potential based on GPP - MOD17 model"

@doc """

$(getBaseDocString(gppAirT_MOD17))

---

# Extended help

*References*
 - MOD17 User guide: https://lpdaac.usgs.gov/documents/495/MOD17_User_Guide_V6.pdf
 - Running; S. W.; Nemani; R. R.; Heinsch; F. A.; Zhao; M.; Reeves; M.  & Hashimoto, H. (2004). A continuous satellite-derived measure of global terrestrial  primary production. Bioscience, 54[6], 547-560.
 - Zhao, M., Heinsch, F. A., Nemani, R. R., & Running, S. W. (2005). Improvements  of the MODIS terrestrial gross & net primary production global data set. Remote  sensing of Environment, 95[2], 164-176.

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarvalhais

*Notes*
"""
gppAirT_MOD17
