export drainage_dos

@bounds @describe @units @with_kw struct drainage_dos{T1} <: drainage
	dos_exp::T1 = 1.1 | (1.1, 3.0) | "exponent of non-linearity for dos influence on drainage in soil" | ""
end

function precompute(o::drainage_dos, forcing, land, helpers)
	## unpack parameters

	## unpack land variables
	@unpack_land begin
		ΔsoilW ∈ land.states
	end
	drain_fraction = zero(ΔsoilW)
	drainage = zero(ΔsoilW)

	## pack land variables
	@pack_land begin
		drainage => land.drainage
	end
	return land
end

function compute(o::drainage_dos, forcing, land, helpers)
	## unpack parameters
	@unpack_drainage_dos o

	## unpack land variables
	@unpack_land begin
		drainage ∈ land.drainage
		(p_wSat, p_β, p_wFC) ∈ land.soilWBase
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
		(𝟘, 𝟙, tolerance) ∈ helpers.numbers
	end
	# drain_fraction .= clamp.(((soilW) ./ p_wSat) .^ (dos_exp .* p_β), 𝟘, 𝟙)
	# drainage .=  drain_fraction .* (soilW +  ΔsoilW)
	## calculate drainage
	for sl in 1:length(land.pools.soilW)-1
		soilW_sl = min(max(soilW[sl] + ΔsoilW[sl], 𝟘), p_wSat[sl])
		drain_fraction = clamp(((soilW_sl) / p_wSat[sl]) ^ (dos_exp * p_β[sl]), 𝟘, 𝟙)
		drainage_tmp =  drain_fraction * (soilW_sl)
		max_drain = p_wSat[sl] - p_wFC[sl]
		lossCap = min(soilW_sl, max_drain)
		holdCap = p_wSat[sl+1] - (soilW[sl+1] + ΔsoilW[sl+1])
		drain = min(drainage_tmp, holdCap, lossCap)
		tmp = drain > tolerance ? drain : 𝟘
		@rep_elem tmp => (drainage, sl, :soilW) 
		@add_to_elem -drainage[sl] => (ΔsoilW, sl, :soilW)
		@add_to_elem drainage[sl] => (ΔsoilW, sl + 1, :soilW)
	end
	@rep_elem 𝟘 => (drainage, lastindex(drainage), :soilW)
	## pack land variables
	@pack_land begin
		drainage => land.drainage
		ΔsoilW => land.states
	end
	return land
end

function update(o::drainage_dos, forcing, land, helpers)

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
	end

	## update variables
	# update soil moisture
	soilW .= soilW .+ ΔsoilW

	# reset soil moisture changes to zero
	ΔsoilW .= ΔsoilW .- ΔsoilW

	## pack land variables
	# @pack_land begin
	# 	soilW => land.pools
	# 	ΔsoilW => land.states
	# end
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