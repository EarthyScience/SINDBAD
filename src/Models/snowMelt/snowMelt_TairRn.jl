export snowMelt_TairRn

#! format: off
@bounds @describe @units @with_kw struct snowMelt_TairRn{T1,T2} <: snowMelt
    melt_T::T1 = 3.0 | (0.01, 10.0) | "melt factor for temperature" | "mm/°C"
    melt_Rn::T2 = 2.0 | (0.01, 3.0) | "melt factor for radiation" | "mm/MJ/m2"
end
#! format: on

function define(p_struct::snowMelt_TairRn, forcing, land, helpers)
    ## unpack land variables
    @unpack_land begin
        WBP ∈ land.states
        𝟘 ∈ helpers.numbers
    end
    # potential snow melt if T > 0.0 deg C
    potential_snow_melt = 𝟘
    snow_melt = 𝟘
    # a Water Balance Pool variable that tracks how much water is still "available"
    WBP = WBP + snow_melt
    ## pack land variables
    @pack_land begin
        snow_melt => land.fluxes
        potential_snow_melt => land.snowMelt
        WBP => land.states
    end
    return land
end

function compute(p_struct::snowMelt_TairRn, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_snowMelt_TairRn p_struct
    @unpack_forcing (Rn, Tair) ∈ forcing

    ## unpack land variables
    @unpack_land begin
        (WBP, frac_snow) ∈ land.states
        snowW ∈ land.pools
        ΔsnowW ∈ land.states
        (𝟘, 𝟙) ∈ helpers.numbers
    end

    # snowmelt [mm/day] is calculated as a simple function of temperature & radiation & scaled with the snow covered fraction
    # @show Tair, melt_T
    tmp_T = Tair * melt_T
    tmp_Rn = max_0(Rn * melt_Rn)
    potential_snow_melt = (tmp_T + tmp_Rn) * frac_snow

    # potential snow melt if T > 0.0 deg C
    potential_snow_melt = Tair > 𝟘 ? potential_snow_melt : zero(potential_snow_melt)
    snow_melt = min(addS(snowW, ΔsnowW), potential_snow_melt)

    # divide snowmelt loss equally from all layers
    ΔsnowW = add_to_each_elem(ΔsnowW, -snow_melt / length(snowW))

    # a Water Balance Pool variable that tracks how much water is still "available"
    WBP = WBP + snow_melt

    ## pack land variables
    @pack_land begin
        snow_melt => land.fluxes
        potential_snow_melt => land.snowMelt
        WBP => land.states
        ΔsnowW => land.states
    end
    return land
end

function update(p_struct::snowMelt_TairRn, forcing, land, helpers)
    @unpack_snowMelt_TairRn p_struct

    ## unpack variables
    @unpack_land begin
        snowW ∈ land.pools
        ΔsnowW ∈ land.states
    end

    # update snow pack
    snowW .= snowW .+ ΔsnowW

    # reset delta storage
    ΔsnowW .= ΔsnowW .- ΔsnowW

    ## pack land variables
    @pack_land begin
        snowW => land.pools
        ΔsnowW => land.states
    end
    return land
end

@doc """
instantiate the potential snow melt based on temperature & net radiation on days with Tair > 0.0°C. instantiate the potential snow melt based on temperature & net radiation on days with Tair > 0.0 °C

# Parameters
$(PARAMFIELDS)

---

# compute:
Calculate snowmelt and update s.w.wsnow using snowMelt_TairRn

*Inputs*
 - forcing.Rn: net radiation [MJ/m2/day]
 - forcing.Tair: temperature [C]
 - info structure
 - land.snowMelt.potential_snow_melt : potential snow melt based on temperature & net radiation [mm/time]
 - land.states.frac_snow : snow cover fraction []

*Outputs*
 - land.fluxes.snowMelt : snow melt [mm/time]
 - land.snowMelt.potential_snow_melt: potential snow melt [mm/time]

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
