export soilTexture_fixed

@bounds @describe @units @with_kw struct soilTexture_fixed{T1, T2, T3, T4} <: soilTexture
	CLAY::T1 = 0.2 | (0.0, 1.0) | "Clay content" | ""
	SILT::T2 = 0.3 | (0.0, 1.0) | "Silt content" | ""
	SAND::T3 = 0.5 | (0.0, 1.0) | "Sand content" | ""
	ORGM::T4 = 0.0 | (0.0, 1.0) | "Organic matter content" | ""
end

function precompute(o::soilTexture_fixed, forcing, land, infotem)
	@unpack_soilTexture_fixed o

	## set parameter variables
	st_CLAY = CLAY
	st_SAND = SAND
	st_SILT = SILT
	st_ORGM = ORGM

	## pack land variables
	@pack_land (st_CLAY, st_SAND, st_SILT, st_ORGM) => land.soilTexture
	return land
end

@doc """
sets the soil texture properties as constant

# Parameters
$(PARAMFIELDS)

---

# compute:
Soil texture (sand,silt,clay, and organic matter fraction) using soilTexture_fixed

*Inputs*

*Outputs*
 - None

# precompute:
precompute/instantiate time-invariant variables for soilTexture_fixed


---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala

*Notes*
 - texture does not change with space & depth
"""
soilTexture_fixed