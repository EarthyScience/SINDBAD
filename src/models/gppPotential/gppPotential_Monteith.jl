export gppPotential_Monteith, gppPotential_Monteith_h
"""
set the potential GPP based on radiation use efficiency

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppPotential_Monteith{T1} <: gppPotential
	maxrue::T1 = 2.0 | (0.1, 5.0) | "Maximum Radiation Use Efficiency" | "gC/MJ"
end

function precompute(o::gppPotential_Monteith, forcing, land, infotem)
	# @unpack_gppPotential_Monteith o
	return land
end

function compute(o::gppPotential_Monteith, forcing, land, infotem)
	@unpack_gppPotential_Monteith o

	## unpack variables
	@unpack_land begin
		PAR ∈ forcing
	end
	#--> set rueGPP to a constant
	gppPot = maxrue * PAR

	## pack variables
	@pack_land begin
		gppPot ∋ land.gppPotential
	end
	return land
end

function update(o::gppPotential_Monteith, forcing, land, infotem)
	# @unpack_gppPotential_Monteith o
	return land
end

"""
set the potential GPP based on radiation use efficiency

# precompute:
precompute/instantiate time-invariant variables for gppPotential_Monteith

# compute:
Maximum instantaneous radiation use efficiency using gppPotential_Monteith

*Inputs:*

*Outputs:*
 - land.gppPotential.rueGPP: potential GPP based on RUE [nPix, nTix]

# update
update pools and states in gppPotential_Monteith
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up [changed the output to nPix, nTix]  

*Created by:*
 - Martin Jung [mjung]
 - Nuno Carvalhais [ncarval]

*Notes:*
 - no crontrols for fPAR | meteo factors
 - set the potential GPP as maxRUE * PAR [gC/m2/dat]
 - usually  GPP = e_max x f[clim] x FAPAR x PAR  here  GPP = GPPpot x f[clim] x FAPAR  GPPpot = e_max x PAR  f[clim] & FAPAR are [maybe] calculated dynamically
"""
function gppPotential_Monteith_h end