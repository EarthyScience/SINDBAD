export soilWBase_uniform, soilWBase_uniform_h
"""
distributes the soil hydraulic properties for different soil layers assuming an uniform vertical distribution of all soil properties

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct soilWBase_uniform{T1} <: soilWBase
	nLookup::T1 = 100.0 | (10.0, 1000.0) | "number of values for lookup table of unsaturated hydraulic conductivity" | ""
end

function precompute(o::soilWBase_uniform, forcing, land, infotem)
	@unpack_soilWBase_uniform o

	## precomputations/check
	#--> get the soil thickness 
	soilDepths = infotem.pools.water.layerThickness.soilW; 
	p_soilDepths = soilDepths;
	#--> check if the number of soil layers & number of elements in soil thickness arrays are the same 
	if length(soilDepths) != infotem.pools.water.nZix.soilW 
		error(["soilWBase_uniform: the number of soil layers in modelStructure.json does not match with soil depths specified"])
	end 

	## instantiate variables
	p_CLAY = ones(size(infotem.pools.water.initValues.soilW))
	p_SAND = ones(size(infotem.pools.water.initValues.soilW))
	p_SILT = ones(size(infotem.pools.water.initValues.soilW))
	p_ORGM = ones(size(infotem.pools.water.initValues.soilW))
	p_soilDepths = ones(size(infotem.pools.water.initValues.soilW))
	p_wFC = ones(size(infotem.pools.water.initValues.soilW))
	p_wWP = ones(size(infotem.pools.water.initValues.soilW))
	p_wSat = ones(size(infotem.pools.water.initValues.soilW))
	p_kSat = ones(size(infotem.pools.water.initValues.soilW))
	p_logkSat = ones(size(infotem.pools.water.initValues.soilW))
	p_kFC = ones(size(infotem.pools.water.initValues.soilW))
	p_kWP = ones(size(infotem.pools.water.initValues.soilW))
	p_kPow = ones(size(infotem.pools.water.initValues.soilW))
	p_ψSat = ones(size(infotem.pools.water.initValues.soilW))
	p_ψFC = ones(size(infotem.pools.water.initValues.soilW))
	p_ψWP = ones(size(infotem.pools.water.initValues.soilW))
	p_θSat = ones(size(infotem.pools.water.initValues.soilW))
	p_θFC = ones(size(infotem.pools.water.initValues.soilW))
	p_θWP = ones(size(infotem.pools.water.initValues.soilW))
	p_α = ones(size(infotem.pools.water.initValues.soilW))
	p_β = ones(size(infotem.pools.water.initValues.soilW))

	## pack variables
	@pack_land begin
		(soilDepths, p_soilDepths, p_CLAY, p_SAND, p_SILT, p_ORGM, p_soilDepths, p_wFC, p_wWP, p_wSat, p_kSat, p_logkSat, p_kFC, p_kWP, p_kPow, p_ψSat, p_ψFC, p_ψWP, p_θSat, p_θFC, p_θWP, p_α, p_β) ∋ land.soilWBase
	end
	return land
end

function compute(o::soilWBase_uniform, forcing, land, infotem)
	@unpack_soilWBase_uniform o

	## unpack variables
	@unpack_land begin
		(soilDepths, p_soilDepths, p_CLAY, p_SAND, p_SILT, p_ORGM, p_soilDepths, p_wFC, p_wWP, p_wSat, p_kSat, p_logkSat, p_kFC, p_kWP, p_kPow, p_ψSat, p_ψFC, p_ψWP, p_θSat, p_θFC, p_θWP, p_α, p_β) ∈ land.soilWBase
		(p_CLAY, p_ORGM, p_SAND, p_SILT) ∈ land.soilTexture
		(p_kFC, p_kSat, p_kWP, p_α, p_β, p_θFC, p_θSat, p_θWP, p_ψFC, p_ψSat, p_ψWP) ∈ land.soilProperties
	end
	#--> create the arrays to fill in the soil properties
	p_nsoilLayers = infotem.pools.water.nZix.soilW
	# storages
	# hydraulic conductivities
	# matric potentials
	# moisture contents
	# retention coefficients
	#--> set the properties for each soil layer
	for sl in 1:infotem.pools.water.nZix.soilW
		p_wFC[sl] = p_θFC[sl] * soilDepths[sl]
		p_wWP[sl] = p_θWP[sl] * soilDepths[sl]
		p_wSat[sl] = p_θSat[sl] * soilDepths[sl]
		p_soilDepths[sl] = soilDepths[sl]
		β = p_β[sl]
		λ = 1 / β
		p_kPow[sl] = 3 + (2 / λ)
		p_logkSat[sl] = log(p_logkSat[sl])
	end
	#--> get the plant available water capacity
	p_wAWC = p_wFC - p_wWP
	#--> set the make lookUp flag to false after creating the table
	if infotem.flags.useLookupK
		makeLookup = 0
	end

	## pack variables
	@pack_land begin
		(p_CLAY, p_ORGM, p_SAND, p_SILT, p_kFC, p_kPow, p_kSat, p_kWP, p_logkSat, p_nsoilLayers, p_soilDepths, p_wAWC, p_wFC, p_wSat, p_wWP, p_α, p_β, p_θFC, p_θSat, p_θWP, p_ψFC, p_ψSat, p_ψWP) ∋ land.soilWBase
	end
	return land
end

function update(o::soilWBase_uniform, forcing, land, infotem)
	# @unpack_soilWBase_uniform o
	return land
end

"""
distributes the soil hydraulic properties for different soil layers assuming an uniform vertical distribution of all soil properties

# precompute:
precompute/instantiate time-invariant variables for soilWBase_uniform

# compute:
Distribution of soil hydraulic properties over depth using soilWBase_uniform

*Inputs:*
 - infotem.flags.useLookupK: flag for creating lookup table [modelRun.json]
 - infotem.pools.water.: soil layers & depths
 - land.soilProperties.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.
 - land.soilTexture.p_[SAND/SILT/CLAY/ORGM]: texture properties [nPix, nZix]

*Outputs:*
 - all soil hydraulic properties in land.soilWBase.p_[parameterName] (nPix, nTix)

# update
update pools and states in soilWBase_uniform
 - makeLookup: to switch on/off the creation of lookup table of  unsaturated hydraulic conductivity

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 18.11.2019 [skoirala]: clean up & consistency
 - 1.1 on 03.12.2019 [skoirala]: handling potentail vertical distribution of soil texture  

*Created by:*
 - Nuno Carvalhais [ncarval]
 - Sujan Koirala [skoirala]
"""
function soilWBase_uniform_h end