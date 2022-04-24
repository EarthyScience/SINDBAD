export PET_forcing

struct PET_forcing <: PET
end

function compute(o::PET_forcing, forcing, land, helpers)
	## unpack forcing
	@unpack_forcing PET ∈ forcing

	## pack land variables
	@pack_land PET => land.PET
	return land
end

@doc """
sets the value of land.PET.PET from the forcing

---

# compute:
Set potential evapotranspiration using PET_forcing

*Inputs*
 - forcing.PET read from the forcing data set

*Outputs*
 - land.PET.PET: the value of PET for current time step

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
PET_forcing