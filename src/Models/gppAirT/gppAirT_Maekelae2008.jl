export gppAirT_Maekelae2008

#! format: off
@bounds @describe @units @timescale @with_kw struct gppAirT_Maekelae2008{T1,T2,T3} <: gppAirT
    TimConst::T1 = 5.0 | (1.0, 20.0) | "time constant for temp delay" | "days" | ""
    X0::T2 = -5.0 | (-15.0, 1.0) | "threshold of delay temperature" | "°C" | ""
    s_max::T3 = 20.0 | (10.0, 30.0) | "temperature at saturation" | "°C" | ""
end
#! format: on

function define(params::gppAirT_Maekelae2008, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_nt f_airT_day ⇐ forcing

    X_prev = f_airT_day

    ## pack land variables
    @pack_nt X_prev ⇒ land.diagnostics
    return land
end

function compute(params::gppAirT_Maekelae2008, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppAirT_Maekelae2008 params
    @unpack_nt f_airT_day ⇐ forcing
    @unpack_nt begin
        o_one ⇐ land.constants
        X_prev ⇐ land.diagnostics
    end

    ## calculate variables
    # calculate temperature acclimation
    X = X_prev + (o_one / TimConst) * (f_airT_day - X_prev)

    # calculate the stress & saturation
    S = maxZero(X - X0)
    gpp_f_airT = clampZeroOne(S / s_max)

    # replace the previous X
    X_prev = X

    ## pack land variables
    @pack_nt (gpp_f_airT, X_prev) ⇒ land.diagnostics
    return land
end

@doc """
temperature stress on gpp_potential based on Maekelae2008 [eqn 3 & 4]

# Parameters
$(SindbadParameters)

---

# compute:
Effect of temperature using gppAirT_Maekelae2008

*Inputs*
 - forcing.f_airT_day: daytime temperature [°C]

*Outputs*
 - land.diagnostics.gpp_f_airT: effect of temperature on potential GPP

---

# Extended help

*References*
 - Mäkelä, A., Pulkkinen, M., Kolari, P., et al. (2008).  Developing an empirical model of stand GPP with the LUE approachanalysis of eddy covariance data at five contrasting conifer sites in Europe.  Global change biology, 14[1], 92-108.

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarvalhais

*Notes*
 - Tmin < Tmax ALWAYS!!!
"""
gppAirT_Maekelae2008
