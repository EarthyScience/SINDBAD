export groundWRecharge_dos

@bounds @describe @units @with_kw struct groundWRecharge_dos{T1} <: groundWRecharge
	dos_exp::T1 = 1.5 | (1.1, 3.0) | "exponent of non-linearity for dos influence on drainage to groundwater" | ""
end

function precompute(o::groundWRecharge_dos, forcing, land, helpers)
	## unpack land variables
	@unpack_land begin
		𝟘 ∈ helpers.numbers
	end

	groundWRec = 𝟘

	## pack land variables
	@pack_land begin
		groundWRec => land.fluxes
	end
	return land
end

function compute(o::groundWRecharge_dos, forcing, land, helpers)
	## unpack parameters
	@unpack_groundWRecharge_dos o

	## unpack land variables
	@unpack_land begin
		(p_wSat, p_β) ∈ land.soilWBase
		(groundW, soilW) ∈ land.pools
		(ΔsoilW, ΔgroundW) ∈ land.states
		(𝟘, 𝟙) ∈ helpers.numbers
	end
	# calculate recharge
	dosSoilEnd = clamp((soilW[end] + ΔsoilW[end]) / p_wSat[end], 𝟘, 𝟙)
	recharge_fraction = clamp((dosSoilEnd) ^ (dos_exp * p_β[end]), 𝟘, 𝟙)
	groundWRec = recharge_fraction * (soilW[end] + ΔsoilW[end])
	nGroundW = length(groundW) * 𝟙

	ΔgroundW = add_to_each_elem(ΔgroundW, groundWRec / nGroundW)
	@add_to_elem -groundWRec => (ΔsoilW, lastindex(ΔsoilW), :soilW)

	## pack land variables
	@pack_land begin
		groundWRec => land.fluxes
		(ΔsoilW, ΔgroundW) => land.states
	end
	return land
end

function update(o::groundWRecharge_dos, forcing, land, helpers)

	## unpack variables
	@unpack_land begin
		(soilW, groundW) ∈ land.pools
		(ΔsoilW, ΔgroundW) ∈ land.states
	end

	## update storage pools
	soilW[end] = soilW[end] + ΔsoilW[end]
	groundW .= groundW .+ ΔgroundW

	# reset ΔsoilW[end] and ΔgroundW to zero
	ΔsoilW[end] = ΔsoilW[end] - ΔsoilW[end]
	ΔgroundW .= ΔgroundW .- ΔgroundW


	## pack land variables
	@pack_land begin
		(groundW, soilW) => land.pools
		(ΔsoilW, ΔgroundW) => land.states
	end
	return land
end

@doc """
GW recharge as a exponential functions of the degree of saturation of the lowermost soil layer

# Parameters
$(PARAMFIELDS)

---

# compute:
Recharge the groundwater using groundWRecharge_dos

*Inputs*
 - land.pools.soilW
 - rf

*Outputs*
 - land.fluxes.groundWRec

# update

update pools and states in groundWRecharge_dos

 - land.pools.groundW[1]

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]: clean up  

*Created by:*
 - skoirala
"""
groundWRecharge_dos