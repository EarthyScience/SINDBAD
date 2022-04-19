export gpp_none

struct gpp_none <: gpp
end

function precompute(o::gpp_none, forcing, land, infotem)

	## calculate variables
	gpp = infotem.helpers.zero

	## pack land variables
	@pack_land gpp => land.fluxes
	return land
end

@doc """
sets the actual GPP to zeros

---

# compute:
Combine effects as multiplicative or minimum; if coupled, uses transup using gpp_none

*Inputs*
 - info

*Outputs*
 - land.fluxes.gpp: actual GPP [gC/m2/time]
 -

# precompute:
precompute/instantiate time-invariant variables for gpp_none


---

# Extended help

*References*

*Versions*
 - 1.0 on 22.11.2019 [skoirala]: documentation & clean up [changed the output to nPix, nTix]  

*Created by:*
 - ncarval
"""
gpp_none