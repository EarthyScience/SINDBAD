export gppAirT_Maekelae2008

@bounds @describe @units @with_kw struct gppAirT_Maekelae2008{T1,T2,T3} <: gppAirT
    TimConst::T1 = 5.0 | (1.0, 20.0) | "time constant for temp delay" | "days"
    X0::T2 = -5.0 | (-15.0, 1.0) | "threshold of delay temperature" | "°C"
    Smax::T3 = 20.0 | (10.0, 30.0) | "temperature at saturation" | "°C"
end


function precompute(o::gppAirT_Maekelae2008, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_forcing TairDay ∈ forcing

    X_prev = TairDay

    ## pack land variables
    @pack_land X_prev => land.gppAirT
    return land
end

function compute(o::gppAirT_Maekelae2008, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_gppAirT_Maekelae2008 o
    @unpack_forcing TairDay ∈ forcing
    @unpack_land begin
        (zero, one) ∈ helpers.numbers
        X_prev ∈ land.gppAirT
    end

    ## calculate variables
    # calculate temperature acclimation
    X = X_prev + (one / TimConst) * (TairDay - X_prev)

    # calculate the stress & saturation
    S = max(X - X0, zero)
    TempScGPP = clamp(S / Smax, zero, one)

    # replace the previous X
    X_prev = X

    ## pack land variables
    @pack_land (TempScGPP, X_prev) => land.gppAirT
    return land
end

@doc """
temperature stress on gppPot based on Maekelae2008 [eqn 3 & 4]

# Parameters
$(PARAMFIELDS)

---

# compute:
Effect of temperature using gppAirT_Maekelae2008

*Inputs*
 - forcing.TairDay: daytime temperature [°C]

*Outputs*
 - land.gppAirT.TempScGPP: effect of temperature on potential GPP

---

# Extended help

*References*
 - Mäkelä, A., Pulkkinen, M., Kolari, P., et al. (2008).  Developing an empirical model of stand GPP with the LUE approachanalysis of eddy covariance data at five contrasting conifer sites in Europe.  Global change biology, 14[1], 92-108.

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up  

*Created by:*
 - ncarval

*Notes*
 - Tmin < Tmax ALWAYS!!!
"""
gppAirT_Maekelae2008