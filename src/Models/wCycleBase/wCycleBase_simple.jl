export wCycleBase_simple, adjustPackPoolComponents

struct WCycleBaseSimple end

#! format: off
struct wCycleBase_simple <: wCycleBase end
#! format: on

function define(params::wCycleBase_simple, forcing, land, helpers)
    if hasproperty(land.pools, :TWS)
        @unpack_land TWS ∈ land.pools
        n_TWS = oftype(first(TWS), length(TWS))
        @pack_land n_TWS → land.constants
    end
    if hasproperty(land.pools, :groundW)
        @unpack_land groundW ∈ land.pools
        n_groundW = oftype(first(groundW), length(groundW))
        @pack_land n_groundW → land.constants
    end
    if hasproperty(land.pools, :snowW)
        @unpack_land snowW ∈ land.pools
        n_snowW = oftype(first(snowW), length(snowW))
        @pack_land n_snowW → land.constants
    end
    if hasproperty(land.pools, :soilW)
        @unpack_land soilW ∈ land.pools
        z_zero = oftype(first(soilW), 0.0)
        o_one = oftype(first(soilW), 1.0)
        t_two = oftype(first(soilW), 2.0)
        t_three = oftype(first(soilW), 3.0)
        n_soilW = oftype(first(soilW), length(soilW))
        @pack_land n_soilW → land.constants
    end
    if hasproperty(land.pools, :surfaceW)
        @unpack_land surfaceW ∈ land.pools
        n_surfaceW = oftype(first(surfaceW), length(surfaceW))
        @pack_land n_surfaceW → land.constants
    end
    if hasproperty(land.pools, :cEco)
        @unpack_land cEco ∈ land.pools
        z_zero = oftype(first(cEco), 0.0)
        o_one = oftype(first(cEco), 1.0)
        t_two = oftype(first(cEco), 2.0)
        t_three = oftype(first(cEco), 3.0)
    end

    w_model = WCycleBaseSimple()
    @pack_land begin
        (z_zero, o_one, t_two, t_three) → land.constants
        w_model → land.models
    end
    return land
end


function adjustPackPoolComponents(land, helpers, ::WCycleBaseSimple)
    @unpack_land TWS ∈ land.pools
    zix = helpers.pools.zix
    if hasproperty(land.pools, :groundW)
        @unpack_land groundW ∈ land.pools
        for (lw, l) in enumerate(zix.groundW)
            @rep_elem TWS[l] → (groundW, lw, :groundW)
        end
        @pack_land groundW → land.pools
    end

    if hasproperty(land.pools, :snowW)
        @unpack_land snowW ∈ land.pools
        for (lw, l) in enumerate(zix.snowW)
            @rep_elem TWS[l] → (snowW, lw, :snowW)
        end
        @pack_land snowW → land.pools
    end

    if hasproperty(land.pools, :soilW)
        @unpack_land soilW ∈ land.pools
        for (lw, l) in enumerate(zix.soilW)
            @rep_elem TWS[l] → (soilW, lw, :soilW)
        end
        @pack_land soilW → land.pools
    end

    if hasproperty(land.pools, :surfaceW)
        @unpack_land surfaceW ∈ land.pools
        for (lw, l) in enumerate(zix.surfaceW)
            @rep_elem TWS[l] → (surfaceW, lw, :surfaceW)
        end
        @pack_land surfaceW → land.pools
    end

    return land
end

function adjustPackMainPool(land, helpers, ::WCycleBaseSimple)
    @unpack_land TWS ∈ land.pools
    zix = helpers.pools.zix

    if hasproperty(land.pools, :groundW)
        @unpack_land groundW ∈ land.pools
        for (lw, l) in enumerate(zix.groundW)
            @rep_elem groundW[lw] → (TWS, l, :TWS)
        end
    end

    if hasproperty(land.pools, :snowW)
        @unpack_land snowW ∈ land.pools
        for (lw, l) in enumerate(zix.snowW)
            @rep_elem snowW[lw] → (TWS, l, :TWS)
        end
    end

    if hasproperty(land.pools, :soilW)
        @unpack_land soilW ∈ land.pools
        for (lw, l) in enumerate(zix.soilW)
            @rep_elem soilW[lw] → (TWS, l, :TWS)
        end
    end

    if hasproperty(land.pools, :surfaceW)
        @unpack_land surfaceW ∈ land.pools
        for (lw, l) in enumerate(zix.surfaceW)
            @rep_elem surfaceW[lw] → (TWS, l, :TWS)
        end
    end

    @pack_land TWS → land.pools

    return land
end
@doc """
counts the number of layers in each water storage pools


---


*Inputs*
- land.pools.storages: water storages

*Outputs*
 - land.constants.n_storage: number of layers

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.07.2023 [skoirala]

*Created by:*
 - skoirala
"""
wCycleBase_simple
