export snowMelt_TairRn

@bounds @describe @units @with_kw struct snowMelt_TairRn{T1, T2} <: snowMelt
	melt_T::T1 = 3.0 | (0.01, 10.0) | "melt factor for temperature" | "mm/°C"
	melt_Rn::T2 = 2.0 | (0.01, 3.0) | "melt factor for radiation" | "mm/MJ/m2"
end


function compute(o::snowMelt_TairRn, forcing, land, helpers)
    ## unpack parameters and forcing
    @unpack_snowMelt_TairRn o
    @unpack_forcing (Rn, Tair) ∈ forcing

    ## unpack land variables
    @unpack_land begin
        (WBP, snowFraction) ∈ land.states
        snowW ∈ land.pools
        ΔsnowW ∈ land.states
		(zero, one) ∈ helpers.numbers
    end

    # snowmelt [mm/day] is calculated as a simple function of temperature & radiation & scaled with the snow covered fraction
    tmp_T = Tair * melt_T
    tmp_Rn = max(Rn * melt_Rn, zero)
    potMelt = (tmp_T + tmp_Rn) * snowFraction

    # potential snow melt if T > 0.0 deg C
    potMelt = Tair > zero ? potMelt : zero
    snowMelt = min(sum(snowW + ΔsnowW), potMelt)

	# divide snowmelt loss equally from all layers
    ΔsnowW = ΔsnowW .- snowMelt / length(snowW)

    # a Water Balance Pool variable that tracks how much water is still "available"
    WBP = WBP + snowMelt

    ## pack land variables
    @pack_land begin
        snowMelt => land.fluxes
        potMelt => land.snowMelt
        WBP => land.states
        ΔsnowW => land.states
    end
    return land
end

function update(o::snowMelt_TairRn, forcing, land, helpers)
    @unpack_snowMelt_TairRn o

    ## unpack variables
    @unpack_land begin
        snowW ∈ land.pools
        ΔsnowW ∈ land.states
    end

    # update snow pack
    snowW = snowW + ΔsnowW

    # reset delta storage	
    ΔsnowW = ΔsnowW - ΔsnowW

    ## pack land variables
    @pack_land begin
        snowW => land.pools
        ΔsnowW => land.states
    end
    return land
end

@doc """
precompute the potential snow melt based on temperature & net radiation on days with Tair > 0.0°C. precompute the potential snow melt based on temperature & net radiation on days with Tair > 0.0 °C

# Parameters
$(PARAMFIELDS)

---

# compute:
Calculate snowmelt and update s.w.wsnow using snowMelt_TairRn

*Inputs*
 - forcing.Rn: net radiation [MJ/m2/day]
 - forcing.Tair: temperature [C]
 - info structure
 - land.snowMelt.potMelt : potential snow melt based on temperature & net radiation [mm/time]
 - land.states.snowFraction : snow cover fraction []

*Outputs*
 - land.fluxes.snowMelt : snow melt [mm/time]
 - land.snowMelt.potMelt: potential snow melt [mm/time]

# update

update pools and states in snowMelt_TairRn

 -
 - land.pools.snowW[1] : snowpack [mm]
 - land.states.WBP : water balance pool [mm]

# precompute:
precompute/instantiate time-invariant variables for snowMelt_TairRn


---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - ttraut
"""
snowMelt_TairRn