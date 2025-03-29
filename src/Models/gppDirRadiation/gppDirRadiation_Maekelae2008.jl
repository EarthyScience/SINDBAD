export gppDirRadiation_Maekelae2008

#! format: off
@bounds @describe @units @timescale @with_kw struct gppDirRadiation_Maekelae2008{T1} <: gppDirRadiation
    γ::T1 = 0.04 | (0.001, 0.1) | "empirical light response parameter" | "" | ""
end
#! format: on

function compute(params::gppDirRadiation_Maekelae2008, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppDirRadiation_Maekelae2008 params
    @unpack_nt f_PAR ⇐ forcing

    ## unpack land variables
    @unpack_nt begin
        fAPAR ⇐ land.states
    end

    o_one = one(γ)
    ## calculate variables
    gpp_f_light =  o_one / (o_one * f_PAR * fAPAR + o_one)

    ## pack land variables
    @pack_nt gpp_f_light ⇒ land.diagnostics
    return land
end

purpose(::Type{gppDirRadiation_Maekelae2008}) = "light saturation scalar [light effect] on gpp_potential based on Maekelae2008"

@doc """

$(getBaseDocString())

---

# Extended help

*References*
 - Mäkelä, A., Pulkkinen, M., Kolari, P., et al. (2008).  Developing an empirical model of stand GPP with the LUE approachanalysis of eddy covariance data at five contrasting conifer sites in Europe.  Global change biology, 14[1], 92-108.

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up 

*Created by:*
 - mjung
 - ncarvalhais

*Notes*
 - γ is between [0.007 0.05], median !0.04 [m2/mol] in Maekelae  et al 2008.
"""
gppDirRadiation_Maekelae2008
