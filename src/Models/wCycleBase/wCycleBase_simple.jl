export wCycleBase_simple

struct wCycleBase_simple <: wCycleBase end

function define(p_struct::wCycleBase_simple, forcing, land, helpers)
    if hasproperty(land.pools, :TWS)
        n_TWS = helpers.numbers.sNT(length(land.pools.TWS))
        @pack_land n_TWS => land.wCycleBase
    end
    if hasproperty(land.pools, :groundW)
        n_groundW = helpers.numbers.sNT(length(land.pools.groundW))
        @pack_land n_groundW => land.wCycleBase
    end
    if hasproperty(land.pools, :snowW)
        n_snowW = helpers.numbers.sNT(length(land.pools.snowW))
        @pack_land n_snowW=> land.wCycleBase
    end
    if hasproperty(land.pools, :soilW)
        n_soilW = helpers.numbers.sNT(length(land.pools.soilW))
        @pack_land n_soilW => land.wCycleBase
    end
    if hasproperty(land.pools, :surfaceW)
        n_surfaceW = helpers.numbers.sNT(length(land.pools.surfaceW))
        @pack_land n_surfaceW => land.wCycleBase
    end
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
