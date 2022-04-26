export drainage_dos

@bounds @describe @units @with_kw struct drainage_dos{T1} <: drainage
	dos_exp::T1 = 1.0 | (0.1, 3.0) | "exponent of non-linearity for dos influence on drainage in soil" | ""
end

function compute(o::drainage_dos, forcing, land, helpers)
	## unpack parameters
	@unpack_drainage_dos o

	## unpack land variables
	@unpack_land begin
		(p_wSat, p_β) ∈ land.soilWBase
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
		𝟘 ∈ helpers.numbers
	end

	drainage = (((soilW + ΔsoilW) ./ p_wSat) .^ (dos_exp .* p_β)) .* (soilW + ΔsoilW)
	drainage[end] = 𝟘

	## calculate drainage
	for sl in 1:length(land.pools.soilW)-1
		holdCap = p_wSat[sl+1] - (soilW[sl+1] + ΔsoilW[sl+1])
		lossCap = soilW[sl] + ΔsoilW[sl]
		drainage[sl] = min(drainage[sl], holdCap, lossCap)
		ΔsoilW[sl] = ΔsoilW[sl] - drainage[sl]
		ΔsoilW[sl+1] = ΔsoilW[sl+1] + drainage[sl]
	end

	## pack land variables
	@pack_land begin
		drainage => land.drainage
		ΔsoilW => land.states
	end
	return land
end

@doc """
downward flow of moisture [drainage] in soil layers based on exponential function of soil moisture degree of saturation

# Parameters
$(PARAMFIELDS)

---

# compute:
Recharge the soil using drainage_dos

*Inputs*
 - land.pools.soilW: soil moisture in different layers
 - land.soilProperties.unsatK: function handle to calculate unsaturated hydraulic conduct.

*Outputs*
 - drainage from the last layer is saved as groundwater recharge [groundWRec]
 - land.states.soilWFlow: drainage flux between soil layers (same as nZix, from percolation  into layer 1 & the drainage to the last layer)

# update

update pools and states in drainage_dos

 - land.pools.soilW

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
drainage_dos