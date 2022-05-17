export groundWRecharge_dos

@bounds @describe @units @with_kw struct groundWRecharge_dos{T1} <: groundWRecharge
	dos_exp::T1 = 1.0 | (1.0, 3.0) | "exponent of non-linearity for dos influence on drainage to groundwater" | ""
end

function compute(o::groundWRecharge_dos, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_groundWRecharge_dos o

	## unpack land variables
	@unpack_land begin
		(p_wSat, p_β) ∈ land.soilWBase
		(groundW, soilW) ∈ land.pools
		(ΔsoilW, ΔgroundW) ∈ land.states
		𝟘 ∈ helpers.numbers
	end
	# calculate recharge
	dosSoilEnd = (soilW[end]) / p_wSat[end]
	groundWRec = max(((dosSoilEnd) ^ (dos_exp * p_β[end])) * (soilW[end] + ΔsoilW[end]), 𝟘)

	ΔgroundW .= ΔgroundW .+ groundWRec / length(groundW)
	ΔsoilW[end] = ΔsoilW[end] - groundWRec

	## pack land variables
	@pack_land begin
		groundWRec => land.fluxes
		(ΔsoilW, ΔgroundW) => land.states
	end
	return land
end

function update(o::groundWRecharge_dos, forcing, land::NamedTuple, helpers::NamedTuple)

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