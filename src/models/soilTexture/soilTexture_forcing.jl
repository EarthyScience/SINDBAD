export soilTexture_forcing, soilTexture_forcing_h
"""
sets the soil texture properties from input

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct soilTexture_forcing{T} <: soilTexture
	noParameter::T = nothing | nothing | nothing | nothing
end

function precompute(o::soilTexture_forcing, forcing, land, infotem)
	@unpack_soilTexture_forcing o

	## instantiate variables
	p_CLAY = ones(size(infotem.pools.water.initValues.soilW))
	p_SAND = ones(size(infotem.pools.water.initValues.soilW))
	p_SILT = ones(size(infotem.pools.water.initValues.soilW))
	p_ORGM = ones(size(infotem.pools.water.initValues.soilW))

	## pack variables
	@pack_land begin
		(p_CLAY, p_SAND, p_SILT, p_ORGM) ∋ land.soilTexture
	end
	return land
end

function compute(o::soilTexture_forcing, forcing, land, infotem)
	@unpack_soilTexture_forcing o

	## unpack variables
	@unpack_land begin
		(p_CLAY, p_SAND, p_SILT, p_ORGM) ∈ land.soilTexture
		(CLAY, ORGM, SAND, SILT) ∈ forcing
	end
	#--> get the number of soil layers from model structure & create arrays for soil
	# texture properties
	#--> set the properties
	vars = (:CLAY, :SAND, :SILT, :ORGM)
	for vn in 1:length(vars)
		vari = vars[vn]
		if size(eval(vari), 2) == infotem.pools.water.nZix.soilW
			dat = eval(vari)
		else
			datTmp = mean(eval(vari), 2)
			dat = repeat(datTmp, 1, infotem.pools.water.nZix.soilW)
		end
		for sl in 1:infotem.pools.water.nZix.soilW
			p_TEXTURE[sl] = dat[sl]; #placeholder for putting the data in sand, silt, clay, orgm feilds
		end
	end

	## pack variables
	@pack_land begin
		(p_CLAY, p_ORGM, p_SAND, p_SILT, p_TEXTURE) ∋ land.soilTexture
	end
	return land
end

function update(o::soilTexture_forcing, forcing, land, infotem)
	# @unpack_soilTexture_forcing o
	return land
end

"""
sets the soil texture properties from input

# precompute:
precompute/instantiate time-invariant variables for soilTexture_forcing

# compute:
Soil texture (sand,silt,clay, and organic matter fraction) using soilTexture_forcing

*Inputs:*
 - forcing.SAND/SILT/CLAY/ORGM

*Outputs:*
 - land.soilTexture.p_SAND/SILT/CLAY/ORGM

# update
update pools and states in soilTexture_forcing
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 21.11.2019  

*Created by:*
 - Sujan Koirala [skoirala]

*Notes:*
 - if not; then sets the average of all as the fixed property of all layers
 - if the input has same number of layers & soilW; then sets the properties per layer
"""
function soilTexture_forcing_h end