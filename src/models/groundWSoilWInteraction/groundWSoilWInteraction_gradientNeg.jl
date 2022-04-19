export groundWSoilWInteraction_gradientNeg

@bounds @describe @units @with_kw struct groundWSoilWInteraction_gradientNeg{T1, T2} <: groundWSoilWInteraction
	smax_scale::T1 = 0.5 | (0.0, 50.0) | "scale param to yield storage capacity of wGW" | ""
	maxFlux::T2 = 10.0 | (0.0, 20.0) | "maximum flux between wGW and wSoil" | "[mm d]"
end

function compute(o::groundWSoilWInteraction_gradientNeg, forcing, land, infotem)
	## unpack parameters
	@unpack_groundWSoilWInteraction_gradientNeg o

	## unpack land variables
	@unpack_land begin
		p_wSat ∈ land.soilWBase
		(groundW, soilW) ∈ land.pools
	end
	# PREC: storage capacity of groundwater
	# index of the last soil layer
	soilWend = infotem.pools.water.nZix.soilW
	p_gwmax = p_wSat[soilWend] * smax_scale
	# zix of last soil layer
	soilWend = infotem.pools.water.nZix.soilW
	# gradient between groundW[1] & soilW
	tmp_gradient = groundW[1] / p_gwmax - soilW[soilWend] / p_wSat[soilWend]; # the sign of the gradient gives direction of flow: positive = flux to soil; negative = flux to gw
	# scale gradient with pot flux rate to get pot flux
	potFlux = tmp_gradient * maxFlux; # need to make sure that the flux does not overflow | underflow storages
	# adjust the pot flux to what is there
	tmp = min(potFlux, min(groundW, p_wSat[soilWend] - soilW[soilWend]))
	tmp = max(tmp, max(-soilW[soilWend], -(p_gwmax - groundW))); # use here the GW2Soil from above!
	# -> set all the positive GW2Soil to zero
	tmp[tmp > 0] = 0.0
	GW2Soil = tmp
	# update water pools

	## pack land variables
	@pack_land begin
		GW2Soil => land.fluxes
		(p_gwmax, potFlux) => land.groundWSoilWInteraction
	end
	return land
end

function update(o::groundWSoilWInteraction_gradientNeg, forcing, land, infotem)
	@unpack_groundWSoilWInteraction_gradientNeg o

	## unpack variables
	@unpack_land begin
		groundW ∈ land.pools
		GW2Soil ∈ land.fluxes
	end

	## update variables
	soilW[soilWend] = soilW[soilWend] + GW2Soil
	groundW[1] = groundW[1] - GW2Soil

	## pack land variables
	@pack_land (groundW, soilW) => land.pools
	return land
end

@doc """
calculates a buffer storage that doesn"t give water to the soil when the soil dries up; while the soil gives water to the buffer when the soil is wet but the buffer low; the buffer is only recharged by soil moisture. calculates a buffer storage that doesn"t give water to the soil when the soil dries up; while the soil gives water to the groundW[1] when the soil is wet but the groundW[1] low; the groundW[1] is only recharged by soil moisture

# Parameters
$(PARAMFIELDS)

---

# compute:
Groundwater soil moisture interactions (e.g. capilary flux, water using groundWSoilWInteraction_gradientNeg

*Inputs*
 - info : infotem.pools.water.nZix.soilW = number of soil layers
 - land.groundWSoilWInteraction.p_gwmax : maximum storage capacity of the groundwater
 - land.soilWBase.p_wSat : maximum storage capacity of soil [mm]

*Outputs*
 - land.fluxes.GW2Soil : flux between groundW[1] & soilW [mm/time], positive to soil, negative to gw

# update

update pools and states in groundWSoilWInteraction_gradientNeg

 - land.pools.groundW[1]
 - land.pools.soilW

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 04.02.2020 [ttraut]:  
 - 1.0 on 23.09.2020 [ttraut]:  

*Created by:*
 - ttraut
"""
groundWSoilWInteraction_gradientNeg