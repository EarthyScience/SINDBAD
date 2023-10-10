export wCycleBase_simple, adjustPackPoolComponents

struct WCycleBaseSimple end

#! format: off
@bounds @describe @units @with_kw struct wCycleBase_simple{T1,T2} <: wCycleBase
    o_one::T1 = 1.0 | (-Inf, Inf) | "type stable one" | ""
    z_zero::T2 = 0.0 | (-Inf, Inf) | "type stable zero" | ""
end
#! format: on

function define(p_struct::wCycleBase_simple, forcing, land, helpers)
    @unpack_wCycleBase_simple p_struct
    if hasproperty(land.pools, :TWS)
        @unpack_land TWS ∈ land.pools
        n_TWS = oftype(first(TWS), length(TWS))
        @pack_land n_TWS => land.wCycleBase
    end
    if hasproperty(land.pools, :groundW)
        @unpack_land groundW ∈ land.pools
        n_groundW = oftype(first(groundW), length(groundW))
        @pack_land n_groundW => land.wCycleBase
    end
    if hasproperty(land.pools, :snowW)
        @unpack_land snowW ∈ land.pools
        n_snowW = oftype(first(snowW), length(snowW))
        @pack_land n_snowW => land.wCycleBase
    end
    if hasproperty(land.pools, :soilW)
        @unpack_land soilW ∈ land.pools
        o_one = oftype(first(soilW), 1.0)
        z_zero = oftype(first(soilW), 0.0)
        n_soilW = oftype(first(soilW), length(soilW))
        @pack_land n_soilW => land.wCycleBase
    end
    if hasproperty(land.pools, :surfaceW)
        @unpack_land surfaceW ∈ land.pools
        n_surfaceW = oftype(first(surfaceW), length(surfaceW))
        @pack_land n_surfaceW => land.wCycleBase
    end
    if hasproperty(land.pools, :cEco)
        @unpack_land cEco ∈ land.pools
        o_one = oftype(first(cEco), 1)
        z_zero = oftype(first(cEco), 0)
    end

    w_model = WCycleBaseSimple()
    @pack_land begin
        (w_model, o_one, z_zero) => land.wCycleBase
    end
    return land
end


function adjustPackPoolComponents(land, helpers, ::WCycleBaseSimple)
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

function adjustPackMainPool(land, helpers, ::WCycleBaseSimple)
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
