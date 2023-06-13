export rootWaterUptake_proportion

struct rootWaterUptake_proportion <: rootWaterUptake
end


function precompute(o::rootWaterUptake_proportion, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        soilW ∈ land.pools
        numType ∈ helpers.numbers
    end
    wRootUptake = zero(soilW)

    ## pack land variables
    @pack_land begin
        wRootUptake => land.states
    end
    return land
end

function compute(o::rootWaterUptake_proportion, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        PAW ∈ land.vegAvailableWater
        soilW ∈ land.pools
        transpiration ∈ land.fluxes
        (wRootUptake, ΔsoilW) ∈ land.states
        (𝟘, tolerance) ∈ helpers.numbers
    end
    # get the transpiration
    toUptake = transpiration
    PAWTotal = sum(PAW)
    wRootUptake = wRootUptake .* 𝟘
    # extract from top to bottom
    if PAWTotal > 𝟘
        for sl in 1:length(land.pools.soilW)
            uptakeProportion = max(𝟘, PAW[sl] / (PAWTotal))

            wRootUptake = rep_elem(wRootUptake, toUptake * uptakeProportion, helpers.pools.zeros.soilW, helpers.pools.ones.soilW, helpers.numbers.𝟘, helpers.numbers.𝟙, sl)
            ΔsoilW = cusp(ΔsoilW, -wRootUptake[sl], helpers.pools.zeros.soilW, 𝟘, sl) 
        end
    end
    # pack land variables
    @pack_land begin
        wRootUptake => land.states
        ΔsoilW => land.states
    end
    return land
end

function update(o::rootWaterUptake_proportion, forcing, land, helpers)

	## unpack variables
	@unpack_land begin
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
	end

	## update variables
	# update soil moisture
	soilW .= soilW .+ ΔsoilW

	# reset soil moisture changes to zero
	ΔsoilW .= ΔsoilW .- ΔsoilW

	## pack land variables
	@pack_land begin
		soilW => land.pools
		# ΔsoilW => land.states
	end
	return land
end

@doc """
rootUptake from each soil layer proportional to the relative plant water availability in the layer

---

# compute:
Root water uptake (extract water from soil) using rootWaterUptake_proportion

*Inputs*
 - land.fluxes.transpiration: actual transpiration
 - land.pools.soilW: soil moisture
 - land.states.PAW: plant available water [pix, zix]

*Outputs*
 - land.states.wRootUptake: moisture uptake from each soil layer [nPix, nZix of soilW]

# update

update pools and states in rootWaterUptake_proportion

 - land.pools.soilW

---

# Extended help

*References*

*Versions*
 - 1.0 on 13.03.2020 [ttraut]

*Created by:*
 - ttraut

*Notes*
 - assumes that the uptake from each layer remains proportional to the root fraction
"""
rootWaterUptake_proportion