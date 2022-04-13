export interception_Miralles2010, interception_Miralles2010_h
"""
computes canopy interception evaporation according to the Gash model

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct interception_Miralles2010{T1, T2, T3, T4, T5} <: interception
	CanopyStorage::T1 = 1.2 | (0.4, 2.0) | "Canopy storage" | "mm"
	fte::T2 = 0.02 | (0.02, 0.02) | "fraction of trunk evaporation" | ""
	evapRate::T3 = 0.3 | (0.1, 0.5) | "mean evaporation rate" | "mm/hr"
	St::T4 = 0.02 | (0.02, 0.02) | "trunk capacity" | "mm"
	pd::T5 = 0.02 | (0.02, 0.02) | "fraction rain to trunks" | ""
end

function precompute(o::interception_Miralles2010, forcing, land, infotem)
	# @unpack_interception_Miralles2010 o
	return land
end

function compute(o::interception_Miralles2010, forcing, land, infotem)
	@unpack_interception_Miralles2010 o

	## unpack variables
	@unpack_land begin
		(WBP, fAPAR) ∈ land.states
		rain ∈ land.rainSnow
		rainInt ∈ land.rainIntensity
	end
	tmp = 1.0
	CanopyStorage = CanopyStorage * tmp
	fte = fte * tmp
	evapRate = evapRate * tmp
	St = St * tmp
	pd = pd * tmp
	#catch for division by zero
	valids = rainInt > 0.0 & fAPAR > 0.0;
	Pgc = 0.0
	Pgt = 0.0
	Ic = 0.0
	Ic1 = 0.0
	Ic2 = 0.0
	It2 = 0.0
	It = 0.0
	#Rain intensity must be larger than evap rate
	#adjusting evap rate:
	v = rainInt < evapRate & valids == 1
	evapRate[v] = rainInt[v]
	#Pgc: amount of gross rainfall necessary to saturate the canopy
	Pgc = -1 * (rainInt * CanopyStorage / ((1.0 - fte) * evapRate)) * log(1.0 - ((1.0 - fte) * evapRate / rainInt))
	#Pgt: amount of gross rainfall necessary to saturate the trunks
	Pgt = Pgc + rainInt * St / (pd * fAPAR * (rainInt - evapRate * (1.0 - fte)))
	#Ic: interception loss from canopy
	Ic1 = fAPAR * rain; #Pg < Pgc
	Ic2 = fAPAR * (Pgc+((1.0 - fte) * evapRate / rainInt) * (rain - Pgc)); #Pg > Pgc
	v = rain <= Pgc & valids == 1
	Ic[v] = Ic1[v]
	Ic[v == 0] = Ic2[v == 0]
	#It: interception loss from trunks
	#It1 = St;# Pg < Pgt
	It2 = pd * fAPAR * (1.0 - (1.0 - fte) * evapRate / rainInt) * (rain - Pgc);#Pg > Pgt
	v = rain <= Pgt
	It[v] = St[v]
	It[v == 0] = It2[v == 0]
	tmp = Ic+It
	tmp[rain == 0.0] = 0.0
	v = tmp > rain
	tmp[v] = rain[v]
	interception = tmp
	# update the water budget pool
	WBP = WBP - interception

	## pack variables
	@pack_land begin
		interception ∋ land.fluxes
		WBP ∋ land.states
	end
	return land
end

function update(o::interception_Miralles2010, forcing, land, infotem)
	# @unpack_interception_Miralles2010 o
	return land
end

"""
computes canopy interception evaporation according to the Gash model

# precompute:
precompute/instantiate time-invariant variables for interception_Miralles2010

# compute:
Interception evaporation using interception_Miralles2010

*Inputs:*
 - info; tix
 - land.states.fAPAR: fraction of absorbed photosynthetically active  radiation [equivalent to "canopy cover" in Gash & Miralles]
 - rain: rainfall [mm/time]
 - rainInt: rainfall intensity [mm/hr]  (1.5, or, 5.6, for, synoptic, |, convective)

*Outputs:*
 - land.fluxes.interception: canopy interception evaporation [mm/time]

# update
update pools and states in interception_Miralles2010
 - land.states.WBP: water balance pool [mm]

# Extended help

*References:*
 - Miralles, D. G., Gash, J. H., Holmes, T. R., de Jeu, R. A., & Dolman, A. J. (2010).  Global canopy interception from satellite observations. Journal of Geophysical Research:  Atmospheres, 115[D16].

*Versions:*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code
 - 1.1 on 22.11.2019 [skoirala]: handle land.states.fAPAR, rainfall intensity & rainfall  

*Created by:*
 - Martin Jung [mjung]

*Notes:*
"""
function interception_Miralles2010_h end