export snowMelt_TairRn

#! format: off
@bounds @describe @units @with_kw struct snowMelt_TairRn{T1,T2} <: snowMelt
    melt_T::T1 = 3.0 | (0.01, 10.0) | "melt factor for temperature" | "mm/°C"
    melt_Rn::T2 = 2.0 | (0.01, 3.0) | "melt factor for radiation" | "mm/MJ/m2"
end
#! format: on

function compute(params::snowMelt_TairRn, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_snowMelt_TairRn params
    @unpack_forcing (f_rn, f_airT) ∈ forcing

    ## unpack land variables
    @unpack_land begin
        (WBP, frac_snow) ∈ land.states
        snowW ∈ land.pools
        ΔsnowW ∈ land.pools
        (z_zero, o_one) ∈ land.constants
        n_snowW ∈ land.constants
    end

    # snowmelt [mm/day] is calculated as a simple function of temperature & radiation & scaled with the snow covered fraction
    # @show f_airT, melt_T
    tmp_T = f_airT * melt_T
    tmp_Rn = maxZero(f_rn * melt_Rn)
    potential_snow_melt = (tmp_T + tmp_Rn) * frac_snow

    # potential snow melt if T > 0.0 deg C
    potential_snow_melt = f_airT > z_zero ? potential_snow_melt : zero(potential_snow_melt)
    snow_melt = min(totalS(snowW, ΔsnowW), potential_snow_melt)

    # divide snowmelt loss equally from all layers
    ΔsnowW = addToEachElem(ΔsnowW, -snow_melt / n_snowW)

    # a Water Balance Pool variable that tracks how much water is still "available"
    WBP = WBP + snow_melt

    ## pack land variables
    @pack_land begin
        snow_melt → land.fluxes
        potential_snow_melt → land.fluxes
        WBP → land.states
        ΔsnowW → land.pools
    end
    return land
end

function update(params::snowMelt_TairRn, forcing, land, helpers)
    @unpack_snowMelt_TairRn params

    ## unpack variables
    @unpack_land begin
        snowW ∈ land.pools
        ΔsnowW ∈ land.pools
    end

    # update snow pack
    snowW .= snowW .+ ΔsnowW

    # reset delta storage
    ΔsnowW .= ΔsnowW .- ΔsnowW

    ## pack land variables
    @pack_land begin
        snowW → land.pools
        ΔsnowW → land.pools
    end
    return land
end

@doc """
instantiate the potential snow melt based on temperature & net radiation on days with f_airT > 0.0°C. instantiate the potential snow melt based on temperature & net radiation on days with f_airT > 0.0 °C

# Parameters
$(SindbadParameters)

---

# compute:
Calculate snowmelt and update s.w.wsnow using snowMelt_TairRn

*Inputs*
 - forcing.f_rn: net radiation [MJ/m2/day]
 - forcing.f_airT: temperature [C]
 - info structure
 - land.fluxes.potential_snow_melt : potential snow melt based on temperature & net radiation [mm/time]
 - land.states.frac_snow : snow cover fraction []

*Outputs*
 - land.fluxes.snowMelt : snow melt [mm/time]
 - land.fluxes.potential_snow_melt: potential snow melt [mm/time]

# update

update pools and states in snowMelt_TairRn

 -
 - land.pools.snowW[1] : snowpack [mm]
 - land.states.WBP : water balance pool [mm]

# instantiate:
instantiate/instantiate time-invariant variables for snowMelt_TairRn


---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - ttraut
"""
snowMelt_TairRn
