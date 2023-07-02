export wCycle_components

struct wCycle_components <: wCycle end

function define(o::wCycle_components, forcing, land, helpers)
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

function compute(o::wCycle_components, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        (groundW, snowW, soilW, surfaceW, TWS) ∈ land.pools
        (ΔgroundW, ΔsnowW, ΔsoilW, ΔsurfaceW, ΔTWS) ∈ land.states
        𝟘 ∈ helpers.numbers
        zix ∈ helpers.pools

    end
    totalW_prev = addS(soilW) + addS(groundW) + addS(surfaceW) + addS(snowW)

    ## update variables
    groundW = add_vec(groundW, ΔgroundW)
    snowW = add_vec(snowW, ΔsnowW)
    soilW = add_vec(soilW, ΔsoilW)
    surfaceW = add_vec(surfaceW, ΔsurfaceW)

    # set_main_from_component_pool(land, helpers, helpers.pools.vals.self.TWS, helpers.pools.vals.all_components.TWS, helpers.pools.vals.zix.TWS)


    for (lc, l) in enumerate(zix.soilW)
        @rep_elem soilW[lc] => (TWS, l, :TWS)
    end

    for (lc, l) in enumerate(zix.snowW)
        @rep_elem snowW[lc] => (TWS, l, :TWS)
    end

    for (lc, l) in enumerate(zix.surfaceW)
        @rep_elem surfaceW[lc] => (TWS, l, :TWS)
    end

    for (lc, l) in enumerate(zix.groundW)
        @rep_elem groundW[lc] => (TWS, l, :TWS)
    end


    # reset moisture changes to zero
    for l in eachindex(ΔsnowW)
        @rep_elem 𝟘 => (ΔsnowW, l, :snowW)
    end
    for l in eachindex(ΔsoilW)
        @rep_elem 𝟘 => (ΔsoilW, l, :soilW)
    end
    for l in eachindex(ΔgroundW)
        @rep_elem 𝟘 => (ΔgroundW, l, :groundW)
    end
    for l in eachindex(ΔsurfaceW)
        @rep_elem 𝟘 => (ΔsurfaceW, l, :surfaceW)
    end

    # @rep_vec ΔgroundW => ΔgroundW .* 𝟘
    # @rep_vec ΔsnowW => ΔsnowW .* 𝟘
    # @rep_vec ΔsoilW => ΔsoilW .* 𝟘
    # @rep_vec ΔsurfaceW => ΔsurfaceW .* 𝟘

    totalW = addS(soilW) + addS(groundW) + addS(surfaceW) + addS(snowW)

    ## pack land variables
    @pack_land begin
        (groundW, snowW, soilW, surfaceW, TWS) => land.pools
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
