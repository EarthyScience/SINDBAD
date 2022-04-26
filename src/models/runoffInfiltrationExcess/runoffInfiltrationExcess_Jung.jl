export runoffInfiltrationExcess_Jung

struct runoffInfiltrationExcess_Jung <: runoffInfiltrationExcess
end

function compute(o::runoffInfiltrationExcess_Jung, forcing, land, helpers)

	## unpack land variables
	@unpack_land begin
		(WBP, fAPAR) ∈ land.states
		p_kSat ∈ land.soilWBase
		rain ∈ land.rainSnow
		rainInt ∈ land.rainIntensity
		(𝟘, 𝟙, sNT) ∈ helpers.numbers
	end
	# assumes infiltration capacity is unlimited in the vegetated fraction [infiltration flux = P*fpar] the infiltration flux for the unvegetated fraction is given as the minimum of the precip & the min of precip intensity [P] & infiltration capacity [I] scaled with rain duration [P/R]

	# get infiltration capacity of the first layer
	pInfCapacity = p_kSat[1] / sNT(24); # in mm/hr
	InfExcess = rain - (rain * fAPAR + (𝟙 - fAPAR) * min(rain, min(pInfCapacity, rainInt) * rain / rainInt))
	runoffInfExc = rain > 𝟘  ? InfExcess : 𝟘
	WBP = WBP - runoffInfExc

	## pack land variables
	@pack_land begin
		runoffInfExc => land.fluxes
		WBP => land.states
	end
	return land
end

@doc """
infiltration excess runoff as a function of rainintensity and vegetated fraction

---

# compute:
Infiltration excess runoff using runoffInfiltrationExcess_Jung

*Inputs*
 - land.rainIntensity.rainInt: rain intensity [mm/h]
 - land.rainSnow.rain : rainfall [mm/time]
 - land.soilWBase.p_kSat: infiltration capacity [mm/day]
 - land.states.fAPAR: fraction of absorbed photosynthetically active radiation  (equivalent to "canopy cover" in Gash & Miralles)

*Outputs*
 - land.fluxes.runoffInfiltration: infiltration excess runoff [mm/time] - what runs off because  the precipitation intensity is to high for it to inflitrate in  the soil

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code
 - 1.1 on 22.11.2019 [skoirala]: moved from prec to dyna to handle land.states.fAPAR which is nPix, 1  

*Created by:*
 - mjung
"""
runoffInfiltrationExcess_Jung