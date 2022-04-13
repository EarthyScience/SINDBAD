export evaporation_Snyder2000, evaporation_Snyder2000_h
"""
calculates the bare soil evaporation using relative drying rate of soil. calculates the bare soil evaporation using relative drying rate of soil

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct evaporation_Snyder2000{T1, T2} <: evaporation
	α::T1 = 1.0 | (0.5, 1.5) | "scaling factor for PET to account for maximum bare soil evaporation" | ""
	β::T2 = 3.0 | (1.0, 5.0) | "soil moisture resistance factor for soil evapotranspiration" | "mm^0.5"
end

function precompute(o::evaporation_Snyder2000, forcing, land, infotem)
	# @unpack_evaporation_Snyder2000 o
	return land
end

function compute(o::evaporation_Snyder2000, forcing, land, infotem)
	@unpack_evaporation_Snyder2000 o

	## unpack variables
	@unpack_land begin
		fAPAR ∈ land.states
		soilW ∈ land.pools
		PET ∈ land.PET
	end
	#--> set the PET and ET values as precomputation; because they are needed in the first time step & updated every time
	PET = PET * α * (1.0 - fAPAR)
	PET[PET < 0.0] = 0.0
	p_sPETOld = PET[1]
	p_sET = 0.0
	#--> get the soil moisture available PET scaled by α & a proxy of vegetation cover
	soilWAvail = soilW[1]
	PET = PET * α * (1.0 - fAPAR)
	PET[PET < 0.0] = 0.0
	β2 = β * β
	isdry = soilWAvail < PET; # assume wetting occurs with precip-interception >
	# pet_soil; Snyder argued one should use precip > 3*pet_soil but then it becomes inconsistent here
	sPET = isdry * (p_sPETOld + PET)
	issat = sPET > β2; # same as sqrt(sPET) > β (see paper); issat is a flag for stage 2 evap
	# (name "issat" not correct here)
	ET = isdry * (!issat * sPET + issat * sqrt(sPET) * β - p_sET) + !isdry * PET
	#
	#--> correct for conditions with light rainfall which were considered not as a
	#wetting event; for these conditions we assume soil_evap = min(precip-ECanop, pet_soil-evap soil already used)
	ET2 = min(soilWAvail, PET-ET)
	ETsoil = ET + ET2
	actETsoil = min(ETsoil, soilW[1])
	evaporation = actETsoil
	#--> storing the ET & PET of the current time step
	p_sPETOld = sPET
	p_sET = isdry * (p_sET+ET)

	## pack variables
	@pack_land begin
		(p_sET, p_sPETOld) ∋ land.evaporation
		evaporation ∋ land.fluxes
	end
	return land
end

function update(o::evaporation_Snyder2000, forcing, land, infotem)
	@unpack_evaporation_Snyder2000 o

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		evaporation ∈ land.fluxes
	end

	## update variables
	#--> update soil moisture of the first layer
	soilW[1] = soilW[1] - evaporation

	## pack variables
	@pack_land begin
		soilW ∋ land.pools
	end
	return land
end

"""
calculates the bare soil evaporation using relative drying rate of soil. calculates the bare soil evaporation using relative drying rate of soil

# precompute:
precompute/instantiate time-invariant variables for evaporation_Snyder2000

# compute:
Soil evaporation using evaporation_Snyder2000

*Inputs:*
 - land.PET.PET
 - land.PET.PET:
 - land.states.fAPAR
 - α
 - β

*Outputs:*
 - land.evaporation.p_sPETOld & land.evaporation.p_sET of first time step
 - land.fluxes.evaporation

# update
update pools and states in evaporation_Snyder2000
 -
 - land.pools.soilW[1]: bare soil evaporation is only allowed from first soil layer

# Extended help

*References:*
 - Snyder, R. L., Bali, K., Ventura, F., & Gomez-MacPherson, H. (2000).  Estimating evaporation from bare | nearly bare soil. Journal of irrigation & drainage engineering, 126[6], 399-403.

*Versions:*
 - 1.0 on 11.11.2019 [skoirala]: transfer from to accommodate land.states.fAPAR  

*Created by:*
 - Martin Jung [mjung@]
 - Sujan Koirala [skoirala]
"""
function evaporation_Snyder2000_h end