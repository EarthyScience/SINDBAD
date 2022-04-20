export groundWRecharge_fraction

@bounds @describe @units @with_kw struct groundWRecharge_fraction{T1} <: groundWRecharge
	rf::T1 = 0.1 | (0.01, 0.99) | "fraction of land runoff that percolates to groundwater" | ""
end

function compute(o::groundWRecharge_fraction, forcing, land, helpers)
	## unpack parameters
	@unpack_groundWRecharge_fraction o

	## unpack land variables
	@unpack_land begin 
		(groundW, soilW) ∈ land.pools
		(ΔsoilW, ΔgroundW) ∈ land.states
	end

	## calculate variables
	# calculate recharge
	gwRec = rf * (soilW[end] + ΔsoilW[end])
	ΔgroundW .= gwRec / helpers.pools.water.nZix.groundW
	ΔsoilW[end] = ΔsoilW[end] - gwRec

	## pack land variables
	@pack_land begin
		gwRec => land.fluxes
		(ΔsoilW, ΔgroundW) => land.states
	end
	return land
end

function update(o::groundWRecharge_fraction, forcing, land, helpers)
	@unpack_groundWRecharge_fraction o

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
calculates GW recharge as a fraction of soil moisture of the lowermost layer

# Parameters
$(PARAMFIELDS)

---

# compute:
Recharge the groundwater using groundWRecharge_fraction

*Inputs*
 - land.pools.soilW

*Outputs*
 - land.fluxes.gwRec

# update

update pools and states in groundWRecharge_fraction

 - land.pools.groundW[1]

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: clean up  

*Created by:*
 - skoirala
"""
groundWRecharge_fraction