export percolation_WBP

struct percolation_WBP <: percolation
end

function compute(o::percolation_WBP, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		WBP ∈ land.states
	end

	# set WBP as the soil percolation
	percolation = WBP
	WBP = 0.0

	## pack land variables
	@pack_land begin
		percolation => land.percolation
		WBP => land.states
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
 -

*Versions*
 - 1.0 on 18.11.2019 [skoirala]:  

*Created by:*
 - skoirala
"""
percolation_WBP