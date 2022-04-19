export interception_fAPAR

@bounds @describe @units @with_kw struct interception_fAPAR{T1} <: interception
	isp::T1 = 1.0 | (0.1, 5.0) | "fapar dependent storage" | ""
end

function compute(o::interception_fAPAR, forcing, land, infotem)
	## unpack parameters
	@unpack_interception_fAPAR o

	## unpack land variables
	@unpack_land begin
		(WBP, fAPAR) ∈ land.states
		rain ∈ land.rainSnow
	end
	# calculate interception loss
	intCap = isp * fAPAR
	interception = min(intCap, rain)
	# update the available water
	WBP = WBP - interception

	## pack land variables
	@pack_land begin
		interception => land.fluxes
		WBP => land.states
	end
	return land
end

@doc """
computes canopy interception evaporation as a fraction of fAPAR

# Parameters
$(PARAMFIELDS)

---

# compute:
Interception evaporation using interception_fAPAR

*Inputs*
 - land.states.fAPAR: fAPAR

*Outputs*
 - land.fluxes.interception: interception loss
 - land.states.WBP: water balance pool [mm]

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code
 - 1.1 on 29.11.2019 [skoirala]: land.states.fAPAR  

*Created by:*
 - mjung
"""
interception_fAPAR