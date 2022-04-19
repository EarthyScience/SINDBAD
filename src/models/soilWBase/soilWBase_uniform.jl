export soilWBase_uniform

struct soilWBase_uniform <: soilWBase
end


function precompute(o::soilWBase_uniform, forcing, land, infotem)
	#@needscheck
	## unpack land variables
	@unpack_land begin
		(sp_kFC, sp_kSat, sp_kWP, sp_α, sp_β, sp_θFC, sp_θSat, sp_θWP, sp_ψFC, sp_ψSat, sp_ψWP) ∈ land.soilProperties
		(st_CLAY, st_ORGM, st_SAND, st_SILT) ∈ land.soilTexture
		soilW ∈ land.pools
	end

	## precomputations/check
	# get the soil thickness 
	soilDepths = infotem.pools.water.layerThickness.soilW; 
	p_soilDepths = soilDepths;
	# check if the number of soil layers & number of elements in soil thickness arrays are the same 
	if length(soilDepths) != infotem.pools.water.nZix.soilW 
		error("soilWBase_uniform: the number of soil layers in modelStructure.json does not match with soil depths specified")
	end 

	if length(sp_kFC) != infotem.pools.water.nZix.soilW 
		# println("soilWBase_uniform: the number of soil layers forcing data does not match the layers in in modelStructure.json. Using mean of input over the soil layers.")
		st_CLAY = mean(st_CLAY)
		st_ORGM = mean(st_ORGM)
		st_SAND = mean(st_SAND)
		st_SILT = mean(st_SILT)
		sp_kFC = mean(sp_kFC)
		sp_kSat = mean(sp_kSat)
		sp_kWP = mean(sp_kWP)
		sp_α = mean(sp_α)
		sp_β = mean(sp_β)
		sp_θFC = mean(sp_θFC)
		sp_θSat = mean(sp_θSat)
		sp_θWP = mean(sp_θWP)
		sp_ψFC = mean(sp_ψFC)
		sp_ψSat = mean(sp_ψSat)
		sp_ψWP = mean(sp_ψWP)
	end 
	# @create_arrays (:p_CLAY, :p_SAND, :p_SILT, :p_ORGM, :p_soilDepths, :p_wFC, :p_wWP, :p_wSat, :p_kSat, :p_kFC, :p_kWP, :p_ψSat, :p_ψFC, :p_ψWP, :p_θSat, :p_θFC, :p_θWP, :p_α, :p_β) = (infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	# props = (:p_CLAY, :p_SAND, :p_SILT, :p_ORGM, :p_soilDepths, :p_wFC, :p_wWP, :p_wSat, :p_kSat, :p_kFC, :p_kWP, :p_ψSat, :p_ψFC, :p_ψWP, :p_θSat, :p_θFC, :p_θWP, :p_α, :p_β) 

	## instantiate variables
	p_CLAY = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_SAND = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_SILT = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_ORGM = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_soilDepths = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_wFC = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_wWP = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_wSat = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_kSat = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_kFC = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_kWP = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_ψSat = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_ψFC = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_ψWP = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_θSat = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_θFC = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_θWP = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_α = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_β = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)

	p_CLAY .= st_CLAY
	p_SAND .= st_SAND
	p_SILT .= st_SILT
	p_ORGM .= st_ORGM
	p_kSat .= sp_kSat
	p_kFC .= sp_kFC
	p_kWP .= sp_kWP
	p_ψSat .= sp_ψSat
	p_ψFC .= sp_ψFC
	p_ψWP .= sp_ψWP
	p_θSat .= sp_θSat
	p_θFC .= sp_θFC
	p_θWP .= sp_θWP
	p_α .= sp_α
	p_β .= sp_β

	p_wFC = p_θFC .* soilDepths
	p_wWP = p_θWP .* soilDepths
	p_wSat = p_θSat .* soilDepths
	p_soilDepths = soilDepths

	# get the plant available water capacity
	p_wAWC = p_wFC - p_wWP

	soilW = min.(soilW, p_wSat)
	@pack_land begin
		(p_CLAY, p_ORGM, p_SAND, p_SILT, p_kFC, p_kSat, p_kWP, p_soilDepths, p_wAWC, p_wFC, p_wSat, p_wWP, p_α, p_β, p_θFC, p_θSat, p_θWP, p_ψFC, p_ψSat, p_ψWP) => land.soilWBase
		soilW => land.pools
	end
	return land
end

@doc """
distributes the soil hydraulic properties for different soil layers assuming an uniform vertical distribution of all soil properties

# Parameters
$(PARAMFIELDS)

---

# compute:
Distribution of soil hydraulic properties over depth using soilWBase_uniform

*Inputs*
 - infotem.flags.useLookupK: flag for creating lookup table [modelRun.json]
 - infotem.pools.water.: soil layers & depths
 - land.soilProperties.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.
 - land.soilTexture.p_[SAND/SILT/CLAY/ORGM]: texture properties [nPix, nZix]

*Outputs*
 - all soil hydraulic properties in land.soilWBase.p_[parameterName] (nPix, nTix)
 - makeLookup: to switch on/off the creation of lookup table of  unsaturated hydraulic conductivity

# precompute:
precompute/instantiate time-invariant variables for soilWBase_uniform


---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 18.11.2019 [skoirala]: clean up & consistency
 - 1.1 on 03.12.2019 [skoirala]: handling potentail vertical distribution of soil texture  

*Created by:*
 - ncarval
 - skoirala
"""
soilWBase_uniform