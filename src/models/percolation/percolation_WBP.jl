export percolation_WBP

struct percolation_WBP <: percolation
end

function compute(o::percolation_WBP, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		WBP ∈ land.states
		(soilW, groundW) ∈ land.pools
		ΔsoilW ∈ land.states
		zero ∈ helpers.numbers
		p_wSat ∈ land.soilWBase
	end

	# set WBP as the soil percolation
	percolation = WBP
	holdCapacity = p_wSat - (soilW + ΔsoilW)
	toAllocate = percolation
	if toAllocate > zero
		for sl in 1:length(land.pools.soilW)
			allocated = min(holdCapacity[sl], toAllocate)
			ΔsoilW[sl] = ΔsoilW[sl] + allocated
			toAllocate = toAllocate - allocated
		end
	end

	if abs(toAllocate) > 1e-4
		WBP = toAllocate
	else
		WBP = 0.0
	end

	## pack land variables
	@pack_land begin
		percolation => land.percolation
		(ΔsoilW, WBP) => land.states
	end
	return land
end

function update(o::percolation_WBP, forcing, land, helpers)
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
		ΔsoilW => land.states
	end
	return land

end
@doc """
computes the percolation into the soil after the surface runoff process

---

# compute:
Calculate the soil percolation = wbp at this point using percolation_WBP

*Inputs*
 - land.states.WBP: water budget pool

*Outputs*
 - land.fluxes.percolation: soil percolation

# update

update pools and states in percolation_WBP
 - land.states.WBP

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
percolation_WBP