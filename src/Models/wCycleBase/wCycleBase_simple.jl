export wCycleBase_simple, adjust_and_pack_pool_components

struct wCycleBase_simple <: wCycleBase end

function define(p_struct::wCycleBase_simple, forcing, land, helpers)
    if hasproperty(land.pools, :TWS)
        n_TWS = oftype(first(land.pools.TWS), length(land.pools.TWS))
        @pack_land n_TWS => land.wCycleBase
    end
    if hasproperty(land.pools, :groundW)
        n_groundW = oftype(first(land.pools.groundW), length(land.pools.groundW))
        @pack_land n_groundW => land.wCycleBase
    end
    if hasproperty(land.pools, :snowW)
        n_snowW = oftype(first(land.pools.snowW), length(land.pools.snowW))
        @pack_land n_snowW => land.wCycleBase
    end
    if hasproperty(land.pools, :soilW)
        n_soilW = oftype(first(land.pools.soilW), length(land.pools.soilW))
        @pack_land n_soilW => land.wCycleBase
    end
    if hasproperty(land.pools, :surfaceW)
        n_surfaceW = oftype(first(land.pools.surfaceW), length(land.pools.surfaceW))
        @pack_land n_surfaceW => land.wCycleBase
    end
    w_model = Val(:wCycleBase_simple)
    @pack_land w_model => land.wCycleBase

    return land
end


function adjust_and_pack_pool_components(land, helpers, ::Val{:wCycleBase_simple})
    @unpack_land TWS ∈ land.pools
    zix = helpers.pools.zix
    if hasproperty(land.pools, :groundW)
        @unpack_land groundW ∈ land.pools
        for (lw, l) in enumerate(zix.groundW)
            @rep_elem TWS[l] => (groundW, lw, :groundW)
        end
        @pack_land groundW => land.pools
    end

    if hasproperty(land.pools, :snowW)
        @unpack_land snowW ∈ land.pools
        for (lw, l) in enumerate(zix.snowW)
            @rep_elem TWS[l] => (snowW, lw, :snowW)
        end
        @pack_land snowW => land.pools
    end

    if hasproperty(land.pools, :soilW)
        @unpack_land soilW ∈ land.pools
        for (lw, l) in enumerate(zix.soilW)
            @rep_elem TWS[l] => (soilW, lw, :soilW)
        end
        @pack_land soilW => land.pools
    end

    if hasproperty(land.pools, :surfaceW)
        @unpack_land surfaceW ∈ land.pools
        for (lw, l) in enumerate(zix.surfaceW)
            @rep_elem TWS[l] => (surfaceW, lw, :surfaceW)
        end
        @pack_land surfaceW => land.pools
    end

    return land
end

function adjust_and_pack_main_pool(land, helpers, ::Val{:wCycleBase_simple})
    @unpack_land TWS ∈ land.pools
    zix = helpers.pools.zix

    if hasproperty(land.pools, :groundW)
        @unpack_land groundW ∈ land.pools
        for (lw, l) in enumerate(zix.groundW)
            @rep_elem groundW[lw] => (TWS, l, :TWS)
        end
    end

    if hasproperty(land.pools, :snowW)
        @unpack_land snowW ∈ land.pools
        for (lw, l) in enumerate(zix.snowW)
            @rep_elem snowW[lw] => (TWS, l, :TWS)
        end
    end

    if hasproperty(land.pools, :soilW)
        @unpack_land soilW ∈ land.pools
        for (lw, l) in enumerate(zix.soilW)
            @rep_elem soilW[lw] => (TWS, l, :TWS)
        end
    end

    if hasproperty(land.pools, :surfaceW)
        @unpack_land surfaceW ∈ land.pools
        for (lw, l) in enumerate(zix.surfaceW)
            @rep_elem surfaceW[lw] => (TWS, l, :TWS)
        end
    end

    @pack_land TWS => land.pools

    return land
end
@doc """
counts the number of layers in each water storage pools


---


*Inputs*
- land.pools.storages: water storages

*Outputs*
 - land.wCycleBase.n_storage: number of layers

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.07.2023 [skoirala]

*Created by:*
 - skoirala
"""
wCycleBase_simple
