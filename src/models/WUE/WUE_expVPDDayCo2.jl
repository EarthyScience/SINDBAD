export WUE_expVPDDayCo2, WUE_expVPDDayCo2_h
"""
calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct WUE_expVPDDayCo2{T1, T2, T3, T4} <: WUE
	WUEatOnehPa::T1 = 9.2 | (2.0, 20.0) | "WUE at 1 hpa VPD" | "gC/mmH2O"
	κ::T2 = 0.4 | (0.06, 0.7) | "" | "kPa-1"
	Ca0::T3 = 380.0 | (300.0, 500.0) | "" | "ppm"
	Cm::T4 = 500.0 | (10.0, 2000.0) | "" | "ppm"
end

function precompute(o::WUE_expVPDDayCo2, forcing, land, infotem)
	# @unpack_WUE_expVPDDayCo2 o
	return land
end

function compute(o::WUE_expVPDDayCo2, forcing, land, infotem)
	@unpack_WUE_expVPDDayCo2 o

	## unpack variables
	@unpack_land begin
		VPDDay ∈ forcing
		ambCO2 ∈ land.states
	end
	# "WUEat1hPa"
	AoENoCO2 = WUEatOnehPa * exp(κ * -VPDDay)
	fCO2_CO2 = 1 + (ambCO2 - Ca0) / (ambCO2 - Ca0 + Cm)
	AoE = AoENoCO2 * fCO2_CO2

	## pack variables
	@pack_land begin
		(AoE, AoENoCO2) ∋ land.WUE
	end
	return land
end

function update(o::WUE_expVPDDayCo2, forcing, land, infotem)
	# @unpack_WUE_expVPDDayCo2 o
	return land
end

"""
calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD

# precompute:
precompute/instantiate time-invariant variables for WUE_expVPDDayCo2

# compute:
Estimate wue using WUE_expVPDDayCo2

*Inputs:*
 - WUEat1hPa: the VPD at 1 hpa
 - forcing.VPDDay: daytime mean VPD [kPa]

*Outputs:*
 - land.WUE.AoENoCO2: water use efficiency - ratio of assimilation &  transpiration fluxes [gC/mmH2O] without co2 effect

# update
update pools and states in WUE_expVPDDayCo2
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 31.03.2021 [skoirala]:  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function WUE_expVPDDayCo2_h end