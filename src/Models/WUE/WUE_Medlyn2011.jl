export WUE_Medlyn2011

#! format: off
@bounds @describe @units @timescale @with_kw struct WUE_Medlyn2011{T1,T2,T3} <: WUE
    g1::T1 = 3.0 | (0.5, 12.0) | "stomatal conductance parameter" | "kPa^0.5" | ""
    ζ::T2 = 1.0 | (0.85, 3.5) | "sensitivity of WUE to ambient co2" | "" | ""
    diffusivity_ratio::T3 = 1.6 | (-Inf, Inf) | "Ratio of the molecular diffusivities for water vapor and CO2" | "" | ""
end
#! format: on

function define(params::WUE_Medlyn2011, forcing, land, helpers)
    @unpack_WUE_Medlyn2011 params

    # umol_to_gC = 1e-06 * 0.012011 * 1000 * 86400 / (86400 * 0.018015); #/(86400 = s to day * .018015 = molecular weight of water) for a guessed fix of the units of water not sure what it should be because the unit of A/E is not clearif A is converted to gCm-2d-1 E should be converted from kg to g?
    umol_to_gC = oftype(diffusivity_ratio, 6.6667e-004)
    ## pack land variables
    @pack_nt umol_to_gC ⇒ land.WUE
    return land
end

function compute(params::WUE_Medlyn2011, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_WUE_Medlyn2011 params
    @unpack_nt (f_psurf_day, f_VPD_day) ⇐ forcing

    ## unpack land variables
    @unpack_nt begin
        ambient_CO2 ⇐ land.states
        tolerance ⇐ helpers.numbers
        umol_to_gC ⇐ land.WUE
    end

    ## calculate variables
    f_VPD_day = max(f_VPD_day, tolerance)
    # umol_to_gC = 1e-06 * 0.012011 * 1000 * 86400 / (86400 * 0.018015); #/(86400 = s to day * .018015 = molecular weight of water) for a guessed fix of the units of water not sure what it should be because the unit of A/E is not clearif A is converted to gCm-2d-1 E should be converted from kg to g?
    # umol_to_gC = 12 * 100/(18 * 1000)
    ciNoCO2 = g1 / (g1 + sqrt(f_VPD_day)) # RHS eqn 13 in corrigendum
    WUENoCO2 = umol_to_gC * f_psurf_day / (diffusivity_ratio * (f_VPD_day + g1 * sqrt(f_VPD_day))) # eqn 14 #? gC/mol of H2o?
    WUE = WUENoCO2 * ζ * ambient_CO2
    ci = ciNoCO2 * ambient_CO2

    ## pack land variables
    @pack_nt (ci, ciNoCO2) ⇒ land.states
    @pack_nt (WUENoCO2, WUE) ⇒ land.diagnostics
    return land
end


purpose(::Type{WUE_Medlyn2011}) = "calculates the WUE/AOE ci/ca as a function of daytime mean VPD. calculates the WUE/AOE ci/ca as a function of daytime mean VPD & ambient co2"

@doc """

$(getBaseDocString(WUE_Medlyn2011))

---

# Extended help

*References*
 - Knauer J, El-Madany TS, Zaehle S, Migliavacca M [2018] Bigleaf—An R  package for the calculation of physical & physiological ecosystem  properties from eddy covariance data. PLoS ONE 13[8]: e0201114. https://doi.org/10.1371/journal.pone.0201114
 - MEDLYN; B.E.; DUURSMA; R.A.; EAMUS; D.; ELLSWORTH; D.S.; PRENTICE; I.C.  BARTON; C.V.M.; CROUS; K.Y.; DE ANGELIS; P.; FREEMAN; M. & WINGATE  L. (2011), Reconciling the optimal & empirical approaches to  modelling stomatal conductance. Global Change Biology; 17: 2134-2144.  doi:10.1111/j.1365-2486.2010.02375.x
 - Medlyn; B.E.; Duursma; R.A.; Eamus; D.; Ellsworth; D.S.; Colin Prentice  I.; Barton; C.V.M.; Crous; K.Y.; de Angelis; P.; Freeman; M. &  Wingate, L. (2012), Reconciling the optimal & empirical approaches to  modelling stomatal conductance. Glob Change Biol; 18: 3476-3476.  doi:10.1111/j.1365-2486.2012.02790.

*Versions*
 - 1.0 on 11.11.2020 [`skoirala | @dr-ko`]

*Created by*
 - `skoirala | @dr-ko`

*Notes*
 - unit conversion: C_flux[gC m-2 d-1] < - CO2_flux[(umol CO2 m-2 s-1)] *  1e-06 [umol2mol] * 0.012011 [Cmol] * 1000 [kg2g] * 86400 [days2seconds]  from Knauer; 2019
 - water: mmol m-2 s-1: /1000 [mol m-2 s-1] * .018015 [Wmol in kg/mol] * 84600
"""
WUE_Medlyn2011
