export wCycle_components

struct wCycle_components <: wCycle end

function define(o::wCycle_components, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        (groundW, snowW, soilW, surfaceW, TWS) ∈ land.pools
    end

    TWS = zero(TWS)

    @pack_land begin
        TWS => land.pools
    end
    return land
end

function compute(o::wCycle_components, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        (groundW, snowW, soilW, surfaceW, TWS) ∈ land.pools
        (ΔgroundW, ΔsnowW, ΔsoilW, ΔsurfaceW, ΔTWS) ∈ land.states
        𝟘 ∈ helpers.numbers
    end

    totalW_prev = sum(soilW) + sum(groundW) + sum(surfaceW) + sum(snowW)


    ## update variables
    groundW = add_vec(groundW, ΔgroundW)
    snowW = add_vec(snowW, ΔsnowW)
    soilW = add_vec(soilW, ΔsoilW)
    surfaceW = add_vec(surfaceW, ΔsurfaceW)
    p_zix = 1
    for zix in helpers.pools.zix.soilW
        @rep_elem soilW[p_zix] => (TWS, zix, :TWS)
        p_zix += 1
    end

    p_zix = 1
    for zix in helpers.pools.zix.snowW
        @rep_elem snowW[p_zix] => (TWS, zix, :TWS)
        p_zix += 1
    end

    p_zix = 1
    for zix in helpers.pools.zix.surfaceW
        @rep_elem surfaceW[p_zix] => (TWS, zix, :TWS)
        p_zix += 1
    end

    p_zix = 1
    for zix in helpers.pools.zix.groundW
        @rep_elem groundW[p_zix] => (TWS, zix, :TWS)
        p_zix += 1
    end


    # reset moisture changes to zero
    ΔgroundW = ΔgroundW .* 𝟘
    ΔsnowW = ΔsnowW .* 𝟘
    ΔsoilW = ΔsoilW .* 𝟘
    ΔsurfaceW = ΔsurfaceW .* 𝟘

    totalW = sum(soilW) + sum(groundW) + sum(surfaceW) + sum(snowW)

    ## pack land variables
    @pack_land begin
        (groundW, snowW, soilW, surfaceW, TWS) => land.pools
        (ΔgroundW, ΔsnowW, ΔsoilW, ΔsurfaceW) => land.states
        (totalW, totalW_prev) => land.states
    end
    return land
end

@doc """
update the water cycle pools per component


---

# compute:
- apply the delta storage changes
- check if there is overflow or over extraction

*Inputs*
- land.pools.storages: water storages
- land.states.Δstorages: water storage changes
- land.soilWBase.p_wSat: water holding capacity

*Outputs*
 - land.states.Δstorages: soil percolation

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]

*Created by:*
 - skoirala
"""
wCycle_components
