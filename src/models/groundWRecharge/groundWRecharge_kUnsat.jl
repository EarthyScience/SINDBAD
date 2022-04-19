export groundWRecharge_kUnsat

struct groundWRecharge_kUnsat <: groundWRecharge
end

function compute(o::groundWRecharge_kUnsat, forcing, land, infotem)

	## unpack land variables
	@unpack_land begin
		p_wSat ∈ land.soilWBase
		unsatK ∈ land.soilProperties
		(groundW, soilW) ∈ land.pools
		(ΔsoilW, ΔgroundW) ∈ land.states
	end
	# index of the last soil layer
	k_unsat = unsatK(land, infotem, infotem.pools.water.nZix.soilW)
	gwRec = min(k_unsat, soilW[end] + ΔsoilW[end])

	ΔgroundW .= gwRec / infotem.pools.water.nZix.groundW
	ΔsoilW[end] = ΔsoilW[end] - gwRec

	## pack land variables
	@pack_land begin
		gwRec => land.fluxes
		(ΔsoilW, ΔgroundW) => land.states
	end
	return land
end

function update(o::groundWRecharge_kUnsat, forcing, land, infotem)

	## unpack variables
	@unpack_land begin
		(soilW, groundW) ∈ land.pools
		(ΔsoilW, ΔgroundW) ∈ land.states
	end

	## update storages pool
	soilW[end] = soilW[end] + ΔsoilW[end]
	groundW = groundW + ΔgroundW

	# reset ΔsoilW[end] to zero
	ΔsoilW[end] = ΔsoilW[end] - ΔsoilW[end]
	ΔgroundW = ΔgroundW - ΔgroundW


	## pack land variables
	@pack_land begin
		(groundW, soilW) => land.pools
		(ΔsoilW, ΔgroundW) => land.states
	end
	return land
end

@doc """
calculates GW recharge as the unsaturated hydraulic conductivity of lowermost soil layer

---

# compute:
Recharge the groundwater using groundWRecharge_kUnsat

*Inputs*
 - land.pools.soilW: soil moisture
 - land.soilProperties.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.
 - land.soilWBase.p_wSat: moisture at saturation

*Outputs*
 - land.fluxes.gwRec

# update

update pools and states in groundWRecharge_kUnsat

 - land.pools.groundW[1]
 - land.pools.soilW

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: clean up  

*Created by:*
 - skoirala
"""
groundWRecharge_kUnsat