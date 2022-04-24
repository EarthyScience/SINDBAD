export gppPotential_Monteith

@bounds @describe @units @with_kw struct gppPotential_Monteith{T1} <: gppPotential
	εmax::T1 = 2.0 | (0.1, 5.0) | "Maximum Radiation Use Efficiency" | "gC/MJ"
end

function compute(o::gppPotential_Monteith, forcing, land, helpers)
	## unpack parameters and forcing
	@unpack_gppPotential_Monteith o
	@unpack_forcing PAR ∈ forcing


	## calculate variables
	# set rueGPP to a constant
	gppPot = εmax * PAR

	## pack land variables
	@pack_land gppPot => land.gppPotential
	return land
end

@doc """
set the potential GPP based on radiation use efficiency

# Parameters
$(PARAMFIELDS)

---

# compute:
Maximum instantaneous radiation use efficiency using gppPotential_Monteith

*Inputs*

*Outputs*
 - land.gppPotential.rueGPP: potential GPP based on RUE [nPix, nTix]

---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up

*Created by:*
 - mjung
 - ncarval

*Notes*
 - no crontrols for fPAR | meteo factors
 - set the potential GPP as maxRUE * PAR [gC/m2/dat]
 - usually  GPP = e_max x f[clim] x FAPAR x PAR  here  GPP = GPPpot x f[clim] x FAPAR  GPPpot = e_max x PAR  f[clim] & FAPAR are [maybe] calculated dynamically
"""
gppPotential_Monteith