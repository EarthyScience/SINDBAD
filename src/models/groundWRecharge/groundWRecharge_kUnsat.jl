export groundWRecharge_kUnsat

struct groundWRecharge_kUnsat <: groundWRecharge
end

function compute(o::groundWRecharge_kUnsat, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		p_wSat ∈ land.soilWBase
		unsatK ∈ land.soilProperties
		(groundW, soilW) ∈ land.pools
		(ΔsoilW, ΔgroundW) ∈ land.states
	end

	# calculate recharge
	k_unsat = unsatK(land, helpers, length(land.pools.soilW))
	groundWRec = min(k_unsat, soilW[end] + ΔsoilW[end])

	ΔgroundW .= ΔgroundW .+ groundWRec / length(groundW)
	ΔsoilW[end] = ΔsoilW[end] - groundWRec

	## pack land variables
	@pack_land begin
		groundWRec => land.fluxes
		(ΔsoilW, ΔgroundW) => land.states
	end
	return land
end

function update(o::groundWRecharge_kUnsat, forcing, land, helpers)

	## unpack variables
	@unpack_land begin
		(soilW, groundW) ∈ land.pools
		(ΔsoilW, ΔgroundW) ∈ land.states
	end

	## update storage pools
	soilW[end] = soilW[end] + ΔsoilW[end]
	groundW .= groundW .+ ΔgroundW

	# reset ΔsoilW[end] and ΔgroundW to zero
	ΔsoilW[end] = ΔsoilW[end] - ΔsoilW[end]
	ΔgroundW .= ΔgroundW .- ΔgroundW


	## pack land variables
	@pack_land begin
		(groundW, soilW) => land.pools
		(ΔsoilW, ΔgroundW) => land.states
	end
	return land
end

@doc """
GW recharge as the unsaturated hydraulic conductivity of the lowermost soil layer

---

# compute:
Recharge the groundwater using groundWRecharge_kUnsat

*Inputs*
 - land.pools.soilW: soil moisture
 - land.soilProperties.unsatK: function handle to calculate unsaturated hydraulic conduct.
 - land.soilWBase.p_wSat: moisture at saturation

*Outputs*
 - land.fluxes.groundWRec

# update

update pools and states in groundWRecharge_kUnsat

 - land.pools.groundW[1]
 - land.pools.soilW

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: clean up  

*Created by:*
 - skoirala
"""
groundWRecharge_kUnsat