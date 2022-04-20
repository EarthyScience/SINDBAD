export soilWFlow_simple

struct soilWFlow_simple <: soilWFlow
end

function compute(o::soilWFlow_simple, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		WBP ∈ land.states
		capFlow ∈ land.capillaryFlow
		drainage ∈ land.drainage
		percolation ∈ land.percolation
		p_wSat ∈ land.soilWBase
		(soilW, groundW) ∈ land.pools
		ΔsoilW ∈ land.states
	end


	# reallocate excess moisture of 1st layer to deeper layers
	holdCapacity = p_wSat - soilW + ΔsoilW
	toAllocate = percolation + capFlow[1] - drainage[1]
	ΔsoilW[1] = max(min(toAllocate, holdCapacity[1]), -(soilW[1]  + ΔsoilW[1]))
	toAllocate = toAllocate - ΔsoilW[1]

	for sl in 2:helpers.pools.water.nZix.soilW
		toAllocate = toAllocate + drainage[sl-1] - drainage[sl] + capFlow[sl] - capFlow[sl-1]
		ΔsoilW[sl] = max(min(holdCapacity[sl], toAllocate), -(soilW[sl] + ΔsoilW[sl]))
		toAllocate = toAllocate - ΔsoilW[sl]
	end

	if abs(toAllocate) > 1e-4
		# @show percolation, toAllocate, WBP, soilW
		WBP = toAllocate
	else
		WBP = 0.0
	end
	# error("water could not be allocated to soil layers in soilWFlow_simple")

	## pack land variables
	@pack_land begin
		ΔsoilW => land.states
		WBP => land.states
	end
	return land
end

function update(o::soilWFlow_simple, forcing, land, helpers)

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
	end
	## update variables
	soilW = soilW + ΔsoilW

	# reset soil moisture changes to zero
	ΔsoilW = ΔsoilW - ΔsoilW

	## pack land variables
	@pack_land begin
		soilW => land.pools
		ΔsoilW => land.states
	end
	return land
end

@doc """
computes the percolation into the soil after the surface runoff & evaporation processes are complete

---

# compute:
Calculate the soil percolation = wbp at this point using percolation_WBP

*Inputs*
 - land.states.WBP: water budget pool

*Outputs*
 - land.fluxes.soilWPerc: soil percolation

# update

update pools and states in percolation_WBP

 - land.pools.soilW
 - land.states.WBP

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 18.11.2019 [skoirala]:  

*Created by:*
 - skoirala
"""
soilWFlow_simple