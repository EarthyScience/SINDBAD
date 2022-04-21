export groundWSoilWInteraction_gradient

@bounds @describe @units @with_kw struct groundWSoilWInteraction_gradient{T1, T2} <: groundWSoilWInteraction
	smax_scale::T1 = 0.5 | (0.0, 50.0) | "scale param to yield storage capacity of wGW" | ""
	maxFlux::T2 = 10.0 | (0.0, 20.0) | "maximum flux between wGW and wSoil" | "[mm d]"
end

function compute(o::groundWSoilWInteraction_gradient, forcing, land, helpers)
	## unpack parameters
	@unpack_groundWSoilWInteraction_gradient o
	## unpack land variables
	@unpack_land begin
		p_wSat ∈ land.soilWBase
		(groundW, soilW) ∈ land.pools
		(ΔsoilW, ΔgroundW) ∈ land.states
		zero ∈ helpers.numbers
	end
	# maximum groundwater storage
	p_gwmax = p_wSat[end] * smax_scale

	# gradient between groundW[1] & soilW
	tmp_gradient = sum(groundW + ΔgroundW) / p_gwmax - soilW[end] / p_wSat[end] # the sign of the gradient gives direction of flow: positive = flux to soil; negative = flux to gw from soilW

	# scale gradient with pot flux rate to get pot flux
	potFlux = tmp_gradient * maxFlux; # need to make sure that the flux does not overflow | underflow storages

	# adjust the pot flux to what is there
	tmp = min(potFlux, p_wSat[end] - (soilW[end] + ΔsoilW[end]), sum(groundW + ΔgroundW))
	gwCapFlow = max(tmp, -(soilW[end] + ΔsoilW[end]), -sum(groundW + ΔgroundW));

	# adjust the delta storages
	ΔgroundW = ΔgroundW .- gwCapFlow / length(groundW)
	ΔsoilW[end] = ΔsoilW[end] + gwCapFlow

	## pack land variables
	@pack_land begin
		gwCapFlow => land.fluxes
		(ΔsoilW, ΔgroundW) => land.states
	end
	return land
end

function update(o::groundWSoilWInteraction_gradient, forcing, land, helpers)
	## unpack variables
	@unpack_land begin
		(soilW, groundW) ∈ land.pools
		(ΔsoilW, ΔgroundW) ∈ land.states
	end

	## update storage pools
	soilW[end] = soilW[end] + ΔsoilW[end]
	groundW = groundW + ΔgroundW

	# reset ΔsoilW[end] and ΔgroundW to zero
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
calculates a buffer storage that gives water to the soil when the soil dries up; while the soil gives water to the buffer when the soil is wet but the buffer low

# Parameters
$(PARAMFIELDS)

---

# compute:
Groundwater soil moisture interactions (capilary flux) using groundWSoilWInteraction_gradient

*Inputs*
 - info : helpers.pools.water.nZix.soilW = number of soil layers
 - land.groundWSoilWInteraction.p_gwmax : maximum storage capacity of the groundwater
 - land.soilWBase.p_wSat : maximum storage capacity of soil [mm]

*Outputs*
 - land.fluxes.GW2Soil : flux between groundW & soilW (positive from groundwater to soil, and negative from soil to groundwater)

# update

update pools and states in groundWSoilWInteraction_gradient

 - land.pools.groundW
 - land.pools.soilW

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 04.02.2020 [ttraut]

*Created by:*
 - ttraut
"""
groundWSoilWInteraction_gradient