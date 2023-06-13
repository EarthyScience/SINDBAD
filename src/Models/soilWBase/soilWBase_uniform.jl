export soilWBase_uniform

struct soilWBase_uniform <: soilWBase
end


function precompute(o::soilWBase_uniform, forcing, land, helpers)
    #@needscheck
    ## unpack land variables
    @unpack_land begin
        (sp_kFC, sp_kSat, sp_kWP, sp_α, sp_β, sp_θFC, sp_θSat, sp_θWP, sp_ψFC, sp_ψSat, sp_ψWP) ∈ land.soilProperties
        (st_CLAY, st_ORGM, st_SAND, st_SILT) ∈ land.soilTexture
        soilW ∈ land.pools
        numType ∈ helpers.numbers
    end
    n_soilW = length(soilW)
    ## precomputations/check
    # get the soil thickness 
    soilDepths = helpers.numbers.sNT.(helpers.pools.layerThickness.soilW)
    # soilDepths = helpers.pools.layerThickness.soilW
    soilLayerThickness = soilDepths

    if length(sp_kFC) != n_soilW
        println("soilWBase_uniform: the number of soil layers forcing data does not match the layers in in modelStructure.json. Using mean of input over the soil layers.")
        st_CLAY = fill(mean(st_CLAY), n_soilW)
        st_ORGM = fill(mean(st_ORGM), n_soilW)
        st_SAND = fill(mean(st_SAND), n_soilW)
        st_SILT = fill(mean(st_SILT), n_soilW)
        sp_kFC = fill(mean(sp_kFC), n_soilW)
        sp_kSat = fill(mean(sp_kSat), n_soilW)
        sp_kWP = fill(mean(sp_kWP), n_soilW)
        sp_α = fill(mean(sp_α), n_soilW)
        sp_β = fill(mean(sp_β), n_soilW)
        sp_θFC = fill(mean(sp_θFC), n_soilW)
        sp_θSat = fill(mean(sp_θSat), n_soilW)
        sp_θWP = fill(mean(sp_θWP), n_soilW)
        sp_ψFC = fill(mean(sp_ψFC), n_soilW)
        sp_ψSat = fill(mean(sp_ψSat), n_soilW)
        sp_ψWP = fill(mean(sp_ψWP), n_soilW)
    end
    # @create_arrays (:p_CLAY, :p_SAND, :p_SILT, :p_ORGM, :soilLayerThickness, :p_wFC, :p_wWP, :p_wSat, :p_kSat, :p_kFC, :p_kWP, :p_ψSat, :p_ψFC, :p_ψWP, :p_θSat, :p_θFC, :p_θWP, :p_α, :p_β) = (helpers.numbers.aone, n_soilW)
    # props = (:p_CLAY, :p_SAND, :p_SILT, :p_ORGM, :soilLayerThickness, :p_wFC, :p_wWP, :p_wSat, :p_kSat, :p_kFC, :p_kWP, :p_ψSat, :p_ψFC, :p_ψWP, :p_θSat, :p_θFC, :p_θWP, :p_α, :p_β) 

    ## instantiate variables
    # p_CLAY = zero(st_CLAY)
    # p_SAND = zero(st_SAND)
    # p_SILT = zero(st_SILT)
    # p_ORGM = zero(st_ORGM)
    # p_wFC = zero(st_CLAY)
    # p_wWP = zero(st_CLAY)
    # p_wSat = zero(st_CLAY)
    # p_kSat = zero(st_CLAY)
    # p_kFC = zero(st_CLAY)
    # p_kWP = zero(st_CLAY)
    # p_ψSat = zero(st_CLAY)
    # p_ψFC = zero(st_CLAY)
    # p_ψWP = zero(st_CLAY)
    # p_θSat = zero(st_CLAY)
    # p_θFC = zero(st_CLAY)
    # p_θWP = zero(st_CLAY)
    # p_α = zero(st_CLAY)
    # p_β = zero(st_CLAY)

    p_CLAY = helpers.numbers.𝟙 .* st_CLAY
    p_SAND = helpers.numbers.𝟙 .* st_SAND
    p_SILT = helpers.numbers.𝟙 .* st_SILT
    p_ORGM = helpers.numbers.𝟙 .* st_ORGM
    p_kSat = helpers.numbers.𝟙 .* sp_kSat
    p_kFC = helpers.numbers.𝟙 .* sp_kFC
    p_kWP = helpers.numbers.𝟙 .* sp_kWP
    p_ψSat = helpers.numbers.𝟙 .* sp_ψSat
    p_ψFC = helpers.numbers.𝟙 .* sp_ψFC
    p_ψWP = helpers.numbers.𝟙 .* sp_ψWP
    p_θSat = helpers.numbers.𝟙 .* sp_θSat
    p_θFC = helpers.numbers.𝟙 .* sp_θFC
    p_θWP = helpers.numbers.𝟙 .* sp_θWP
    p_α = helpers.numbers.𝟙 .* sp_α
    p_β = helpers.numbers.𝟙 .* sp_β

    p_wFC = p_θFC .* soilDepths
    p_wWP = p_θWP .* soilDepths
    p_wSat = p_θSat .* soilDepths
    soilLayerThickness = soilDepths

    # get the plant available water capacity
    p_wAWC = p_wFC - p_wWP

    # save the sums of selected variables
    s_wFC = sum(p_wFC)
    s_wWP = sum(p_wWP)
    s_wSat = sum(p_wSat)
    s_wAWC = sum(p_wAWC)

    soilW = soilW .* helpers.numbers.𝟘 + min.(soilW, p_wSat) # =. is necessary to maintain the subarray data type
    @pack_land begin
        (p_CLAY, p_ORGM, p_SAND, p_SILT, p_kFC, p_kSat, p_kWP, soilLayerThickness, p_wAWC, p_wFC, p_wSat, p_wWP, s_wAWC, s_wFC, s_wSat, s_wWP, p_α, p_β, p_θFC, p_θSat, p_θWP, p_ψFC, p_ψSat, p_ψWP, n_soilW) => land.soilWBase
        # soilW => land.pools
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
 - helpers.pools.: soil layers & depths
 - land.soilProperties.unsatK: function handle to calculate unsaturated hydraulic conduct.
 - land.soilTexture.p_[SAND/SILT/CLAY/ORGM]: texture properties [nPix, nZix]

*Outputs*
 - all soil hydraulic properties in land.soilWBase.p_[parameterName] (nPix, nTix)
 - makeLookup: to switch on/off the creation of lookup table of  unsaturated hydraulic conductivity

# precompute:
precompute/instantiate time-invariant variables for soilWBase_uniform


---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]: clean up & consistency
 - 1.1 on 03.12.2019 [skoirala]: handling potentail vertical distribution of soil texture  

*Created by:*
 - ncarval
 - skoirala
"""
soilWBase_uniform