export wCycle_components

struct wCycle_components <: wCycle end

function define(p_struct::wCycle_components, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        (groundW, snowW, soilW, surfaceW, TWS) ∈ land.pools
    end

    # TWS = zero(TWS)

    # @pack_land begin
    #     TWS => land.pools
    # end
    return land
end

function compute(p_struct::wCycle_components, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        (groundW, snowW, soilW, surfaceW, TWS) ∈ land.pools
        (ΔgroundW, ΔsnowW, ΔsoilW, ΔsurfaceW, ΔTWS) ∈ land.states
        zix ∈ helpers.pools

    end
    totalW_prev = addS(soilW) + addS(groundW) + addS(surfaceW) + addS(snowW)

    ## update variables
    groundW = add_vec(groundW, ΔgroundW)
    snowW = add_vec(snowW, ΔsnowW)
    soilW = add_vec(soilW, ΔsoilW)
    surfaceW = add_vec(surfaceW, ΔsurfaceW)

    # set_main_from_component_pool(land, helpers, helpers.pools.vals.self.TWS, helpers.pools.vals.all_components.TWS, helpers.pools.vals.zix.TWS)

    # always pack land tws before calling the adjust method
    @pack_land (groundW, snowW, soilW, surfaceW, TWS) => land.pools

    land = adjust_and_pack_main_pool(land, helpers, land.wCycleBase.w_model)

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

    totalW = addS(soilW) + addS(groundW) + addS(surfaceW) + addS(snowW)

    ## pack land variables
    @pack_land begin
        (ΔgroundW, ΔsnowW, ΔsoilW, ΔsurfaceW, totalW, totalW_prev) => land.states
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
