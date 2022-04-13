export soilTexture_fixed, soilTexture_fixed_h
"""
sets the soil texture properties as constant

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct soilTexture_fixed{T1, T2, T3, T4} <: soilTexture
	CLAY::T1 = 0.2 | (0.0, 1.0) | "Clay content" | ""
	SILT::T2 = 0.3 | (0.0, 1.0) | "Silt content" | ""
	SAND::T3 = 0.5 | (0.0, 1.0) | "Sand content" | ""
	ORGM::T4 = 0.0 | (0.0, 1.0) | "Organic matter content" | ""
end

function precompute(o::soilTexture_fixed, forcing, land, infotem)
	@unpack_soilTexture_fixed o

	## instantiate variables
	p_CLAY = CLAY * ones(size(infotem.pools.water.initValues.soilW))
	p_SAND = SAND * ones(size(infotem.pools.water.initValues.soilW))
	p_SILT = SILT * ones(size(infotem.pools.water.initValues.soilW))
	p_ORGM = ORGM * ones(size(infotem.pools.water.initValues.soilW))

	## pack variables
	@pack_land begin
		(p_CLAY, p_SAND, p_SILT, p_ORGM) ∋ land.soilTexture
	end
	return land
end

function compute(o::soilTexture_fixed, forcing, land, infotem)
	@unpack_soilTexture_fixed o

	## unpack variables
	@unpack_land begin
		(p_CLAY, p_SAND, p_SILT, p_ORGM) ∈ land.soilTexture
	end

	## pack variables
	@pack_land begin
		(p_CLAY, p_ORGM, p_SAND, p_SILT) ∋ land.soilTexture
	end
	return land
end

function update(o::soilTexture_fixed, forcing, land, infotem)
	# @unpack_soilTexture_fixed o
	return land
end

"""
sets the soil texture properties as constant

# precompute:
precompute/instantiate time-invariant variables for soilTexture_fixed

# compute:
Soil texture (sand,silt,clay, and organic matter fraction) using soilTexture_fixed

*Inputs:*

*Outputs:*

# update
update pools and states in soilTexture_fixed
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 21.11.2019  

*Created by:*
 - Sujan Koirala [skoirala]

*Notes:*
 - texture does not change with space & depth
"""
function soilTexture_fixed_h end