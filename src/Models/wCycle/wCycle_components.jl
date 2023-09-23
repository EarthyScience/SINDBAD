export wCycle_components

struct wCycle_components <: wCycle end


function compute(p_struct::wCycle_components, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        (groundW, snowW, soilW, surfaceW, TWS) ∈ land.pools
        (ΔgroundW, ΔsnowW, ΔsoilW, ΔsurfaceW, ΔTWS) ∈ land.states
        zix ∈ helpers.pools
        (z_zero, o_one) ∈ land.wCycleBase
    end
    total_water_prev = totalS(soilW) + totalS(groundW) + totalS(surfaceW) + totalS(snowW)

    ## update variables
    groundW = addVec(groundW, ΔgroundW)
    snowW = addVec(snowW, ΔsnowW)
    soilW = addVec(soilW, ΔsoilW)
    surfaceW = addVec(surfaceW, ΔsurfaceW)

    # setMainFromComponentPool(land, helpers, helpers.pools.vals.self.TWS, helpers.pools.vals.all_components.TWS, helpers.pools.vals.zix.TWS)

    # always pack land tws before calling the adjust method
    @pack_land (groundW, snowW, soilW, surfaceW, TWS) => land.pools

    land = adjustPackMainPool(land, helpers, land.wCycleBase.w_model)

    # reset moisture changes to zero
    for l in eachindex(ΔsnowW)
        @rep_elem zero(eltype(ΔsnowW)) => (ΔsnowW, l, :snowW)
    end
    for l in eachindex(ΔsoilW)
        @rep_elem zero(eltype(ΔsoilW)) => (ΔsoilW, l, :soilW)
    end
    for l in eachindex(ΔgroundW)
        @rep_elem zero(eltype(ΔgroundW)) => (ΔgroundW, l, :groundW)
    end
    for l in eachindex(ΔsurfaceW)
        @rep_elem zero(eltype(ΔsurfaceW)) => (ΔsurfaceW, l, :surfaceW)
    end

    total_water = totalS(soilW) + totalS(groundW) + totalS(surfaceW) + totalS(snowW)

    ## pack land variables
    @pack_land begin
        (ΔgroundW, ΔsnowW, ΔsoilW, ΔsurfaceW, total_water, total_water_prev) => land.states
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
- land.soilWBase.wSat: water holding capacity

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
