export WUE_fVPDDayCo2, WUE_fVPDDayCo2_h
"""
calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct WUE_fVPDDayCo2{T1, T2, T3} <: WUE
	WUEatOnehPa::T1 = 9.2 | (4.0, 17.0) | "WUE at 1 hpa VPD" | "gC/mmH2O"
	Ca0::T2 = 380.0 | (300.0, 500.0) | "" | "ppm"
	Cm::T3 = 500.0 | (100.0, 2000.0) | "" | "ppm"
end

function precompute(o::WUE_fVPDDayCo2, forcing, land, infotem)
	# @unpack_WUE_fVPDDayCo2 o
	return land
end

function compute(o::WUE_fVPDDayCo2, forcing, land, infotem)
	@unpack_WUE_fVPDDayCo2 o

	## unpack variables
	@unpack_land begin
		VPDDay ∈ forcing
		ambCO2 ∈ land.states
	end
	# "WUEat1hPa"
	kpa_to_hpa = 10
	AoENoCO2 = WUEatOnehPa * 1 / sqrt(kpa_to_hpa * (VPDDay +0.05))
	fCO2_CO2 = 1 + (ambCO2 - Ca0) / (ambCO2 - Ca0 + Cm)
	AoE = AoENoCO2 * fCO2_CO2

	## pack variables
	@pack_land begin
		(AoE, AoENoCO2) ∋ land.WUE
	end
	return land
end

function update(o::WUE_fVPDDayCo2, forcing, land, infotem)
	# @unpack_WUE_fVPDDayCo2 o
	return land
end

"""
calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD

# precompute:
precompute/instantiate time-invariant variables for WUE_fVPDDayCo2

# compute:
Estimate wue using WUE_fVPDDayCo2

*Inputs:*
 - WUEat1hPa: the VPD at 1 hpa
 - forcing.VPDDay: daytime mean VPD [kPa]

*Outputs:*
 - land.WUE.AoENoCO2: water use efficiency - ratio of assimilation &  transpiration fluxes [gC/mmH2O] without co2 effect

# update
update pools and states in WUE_fVPDDayCo2
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]:  

*Created by:*
 - Jake Nelson [jnelson]: for the typical values & ranges of WUEat1hPa  across fluxNet sites
 - Sujan Koirala [skoirala]
"""
function WUE_fVPDDayCo2_h end