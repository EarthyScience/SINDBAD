export wCycleBase_simple, adjustPackPoolComponents

#! format: off
struct wCycleBase_simple <: wCycleBase end
#! format: on

function define(params::wCycleBase_simple, forcing, land, helpers)
    if hasproperty(land.pools, :TWS)
        @unpack_nt TWS ⇐ land.pools
        n_TWS = oftype(first(TWS), length(TWS))
        @pack_nt n_TWS ⇒ land.constants
    end
    if hasproperty(land.pools, :groundW)
        @unpack_nt groundW ⇐ land.pools
        n_groundW = oftype(first(groundW), length(groundW))
        @pack_nt n_groundW ⇒ land.constants
    end
    if hasproperty(land.pools, :snowW)
        @unpack_nt snowW ⇐ land.pools
        n_snowW = oftype(first(snowW), length(snowW))
        @pack_nt n_snowW ⇒ land.constants
    end
    if hasproperty(land.pools, :soilW)
        @unpack_nt soilW ⇐ land.pools
        z_zero = oftype(first(soilW), 0.0)
        o_one = oftype(first(soilW), 1.0)
        t_two = oftype(first(soilW), 2.0)
        t_three = oftype(first(soilW), 3.0)
        n_soilW = oftype(first(soilW), length(soilW))
        @pack_nt n_soilW ⇒ land.constants
    end
    if hasproperty(land.pools, :surfaceW)
        @unpack_nt surfaceW ⇐ land.pools
        n_surfaceW = oftype(first(surfaceW), length(surfaceW))
        @pack_nt n_surfaceW ⇒ land.constants
    end
    if hasproperty(land.pools, :cEco)
        @unpack_nt cEco ⇐ land.pools
        z_zero = oftype(first(cEco), 0.0)
        o_one = oftype(first(cEco), 1.0)
        t_two = oftype(first(cEco), 2.0)
        t_three = oftype(first(cEco), 3.0)
    end

    w_model = params
    @pack_nt begin
        (z_zero, o_one, t_two, t_three) ⇒ land.constants
        w_model ⇒ land.models
    end
    return land
end


function adjustPackPoolComponents(land, helpers, ::wCycleBase_simple)
    @unpack_nt TWS ⇐ land.pools
    zix = helpers.pools.zix
    if hasproperty(land.pools, :groundW)
        @unpack_nt groundW ⇐ land.pools
        for (lw, l) in enumerate(zix.groundW)
            @rep_elem TWS[l] ⇒ (groundW, lw, :groundW)
        end
        @pack_nt groundW ⇒ land.pools
    end

    if hasproperty(land.pools, :snowW)
        @unpack_nt snowW ⇐ land.pools
        for (lw, l) in enumerate(zix.snowW)
            @rep_elem TWS[l] ⇒ (snowW, lw, :snowW)
        end
        @pack_nt snowW ⇒ land.pools
    end

    if hasproperty(land.pools, :soilW)
        @unpack_nt soilW ⇐ land.pools
        for (lw, l) in enumerate(zix.soilW)
            @rep_elem TWS[l] ⇒ (soilW, lw, :soilW)
        end
        @pack_nt soilW ⇒ land.pools
    end

    if hasproperty(land.pools, :surfaceW)
        @unpack_nt surfaceW ⇐ land.pools
        for (lw, l) in enumerate(zix.surfaceW)
            @rep_elem TWS[l] ⇒ (surfaceW, lw, :surfaceW)
        end
        @pack_nt surfaceW ⇒ land.pools
    end

    return land
end

function adjustPackMainPool(land, helpers, ::wCycleBase_simple)
    @unpack_nt TWS ⇐ land.pools
    zix = helpers.pools.zix

    if hasproperty(land.pools, :groundW)
        @unpack_nt groundW ⇐ land.pools
        for (lw, l) in enumerate(zix.groundW)
            @rep_elem groundW[lw] ⇒ (TWS, l, :TWS)
        end
    end

    if hasproperty(land.pools, :snowW)
        @unpack_nt snowW ⇐ land.pools
        for (lw, l) in enumerate(zix.snowW)
            @rep_elem snowW[lw] ⇒ (TWS, l, :TWS)
        end
    end

    if hasproperty(land.pools, :soilW)
        @unpack_nt soilW ⇐ land.pools
        for (lw, l) in enumerate(zix.soilW)
            @rep_elem soilW[lw] ⇒ (TWS, l, :TWS)
        end
    end

    if hasproperty(land.pools, :surfaceW)
        @unpack_nt surfaceW ⇐ land.pools
        for (lw, l) in enumerate(zix.surfaceW)
            @rep_elem surfaceW[lw] ⇒ (TWS, l, :TWS)
        end
    end

    @pack_nt TWS ⇒ land.pools

    return land
end

purpose(::Type{wCycleBase_simple}) = "counts the number of layers in each water storage pools"

@doc """

$(getModelDocString(wCycleBase_simple))

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.07.2023 [skoirala | @dr-ko]

*Created by*
 - skoirala | @dr-ko
"""
wCycleBase_simple
