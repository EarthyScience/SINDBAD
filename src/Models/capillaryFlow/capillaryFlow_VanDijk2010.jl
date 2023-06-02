export capillaryFlow_VanDijk2010

@bounds @describe @units @with_kw struct capillaryFlow_VanDijk2010{T1} <: capillaryFlow
	max_frac::T1 = 0.95 | (0.02, 0.98) | "max fraction of soil moisture that can be lost as capillary flux" | ""
end

function precompute(o::capillaryFlow_VanDijk2010, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		soilW ∈ land.pools
		numType ∈ helpers.numbers
	end
	capFlow = zero(land.pools.soilW)

	## pack land variables
	@pack_land begin
		capFlow => land.capillaryFlow
	end
	return land
end

function compute(o::capillaryFlow_VanDijk2010, forcing, land, helpers)
	## unpack parameters
	@unpack_capillaryFlow_VanDijk2010 o

	## unpack land variables
	@unpack_land begin
		(p_kFC, p_wSat) ∈ land.soilWBase
		capFlow ∈ land.capillaryFlow
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
		(numType, 𝟘, 𝟙, tolerance) ∈ helpers.numbers
	end
	
	for sl in 1:length(land.pools.soilW)-1
		dos_soilW = clamp((soilW[sl] + ΔsoilW[sl]) ./ p_wSat[sl], 𝟘, 𝟙)
		tmpCapFlow = sqrt(p_kFC[sl+1] * p_kFC[sl]) * (𝟙 - dos_soilW)
		holdCap = max(p_wSat[sl] - (soilW[sl] + ΔsoilW[sl]), 𝟘)
		lossCap = max(max_frac * (soilW[sl+1] + ΔsoilW[sl+1]), 𝟘)
		minFlow = min(tmpCapFlow, holdCap, lossCap)
		tmp = minFlow > tolerance ? minFlow : 𝟘
		capFlow = ups(capFlow, tmp, sl) 
		ΔsoilW = cusp(ΔsoilW, capFlow[sl], helpers.pools.water.zeros.soilW .* 𝟘, sl)
		ΔsoilW = cusp(ΔsoilW, -capFlow[sl], helpers.pools.water.zeros.soilW .* 𝟘, sl+1)
		
	end

	## pack land variables
    @pack_land begin
		capFlow => land.capillaryFlow
		ΔsoilW => land.states
	end
	return land
end

function update(o::capillaryFlow_VanDijk2010, forcing, land, helpers)

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
	end

	## update variables
	# update soil moisture of the first layer
	soilW = soilW + ΔsoilW

	# reset soil moisture changes to zero
	ΔsoilW = ΔsoilW - ΔsoilW

	## pack land variables
	@pack_land begin
		soilW => land.pools
		# ΔsoilW => land.states
	end
	return land
end

@doc """
computes the upward water flow in the soil layers

---

# compute:
Flux of water from lower to upper soil layers (upward soil moisture movement) using capillaryFlow_VanDijk2010

*Inputs*
 - land.pools.soilW: soil moisture in different layers
 - land.soilProperties.unsatK: function handle to calculate unsaturated hydraulic conduct.

*Outputs*

# update

update pools and states in capillaryFlow_VanDijk2010

 - land.pools.soilW
 - land.states.soilWFlow: drainage flux between soil layers [from soilWRec] is adjusted to reflect  upward capillary flux

---

# Extended help

*References*
 - AIJM Van Dijk, 2010, The Australian Water Resources Assessment System Technical Report 3. Landscape Model [version 0.5] Technical Description
 - http://www.clw.csiro.au/publications/waterforahealthycountry/2010/wfhc-aus-water-resources-assessment-system.pdf

*Versions*
 - 1.0 on 18.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
capillaryFlow_VanDijk2010