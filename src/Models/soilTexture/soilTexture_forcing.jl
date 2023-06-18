export soilTexture_forcing

struct soilTexture_forcing <: soilTexture
end

function precompute(o::soilTexture_forcing, forcing, land, helpers)
	#@needscheck
	## unpack forcing
	@unpack_forcing (CLAY, ORGM, SAND, SILT) ∈ forcing

	## unpack land variables
	@unpack_land (𝟘, 𝟙) ∈ helpers.numbers
	
	st_CLAY = CLAY  |> Tuple
	st_SAND = SAND  |> Tuple
	st_SILT = SILT |> Tuple
	st_ORGM = 𝟘# * ORGM

	n_soilW = length(land.pools.soilW)
    ## precomputations/check
    # get the soil thickness 

    if length(st_CLAY) != n_soilW
        println("soilTexture_forcing: the number of soil layers in forcing data does not match the layers in modelStructure.json. Using mean of input over the soil layers.")
        st_CLAY = fill(mean(st_CLAY), n_soilW)
        st_ORGM = fill(mean(st_ORGM), n_soilW)
        st_SAND = fill(mean(st_SAND), n_soilW)
        st_SILT = fill(mean(st_SILT), n_soilW)
    end
	st_CLAY = Tuple(st_CLAY)
	st_ORGM = Tuple(st_ORGM)
	st_SAND = Tuple(st_SAND)
	st_SILT = Tuple(st_SILT)

	## pack land variables
	@pack_land (st_CLAY, st_ORGM, st_SAND, st_SILT) => land.soilTexture
	return land
end

@doc """
sets the soil texture properties from input

---

# compute:
Soil texture (sand,silt,clay, and organic matter fraction) using soilTexture_forcing

*Inputs*
 - forcing.SAND/SILT/CLAY/ORGM

*Outputs*
 - land.soilTexture.st_SAND/SILT/CLAY/ORGM

# precompute:
precompute/instantiate time-invariant variables for soilTexture_forcing


---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala

*Notes*
 - if not; then sets the average of all as the fixed property of all layers
 - if the input has same number of layers & soilW; then sets the properties per layer
"""
soilTexture_forcing