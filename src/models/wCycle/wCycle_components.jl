export wCycle_components

struct wCycle_components <: wCycle
end

function compute(o::wCycle_components, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        (groundW, snowW, soilW, surfaceW) ∈ land.pools
        (ΔgroundW, ΔsnowW, ΔsoilW, ΔsurfaceW, ΔTWS) ∈ land.states
        p_wSat ∈ land.soilWBase
        zero ∈ helpers.numbers
    end

    ## update variables
    groundW .= groundW .+ ΔgroundW
    snowW .= snowW .+ ΔsnowW
    soilW .= soilW .+ ΔsoilW
    surfaceW .= surfaceW .+ ΔsurfaceW

    # @show ΔgroundW, ΔsnowW, ΔsoilW, ΔsurfaceW, ΔTWS
    # reset soil moisture changes to zero
    ΔgroundW .= ΔgroundW .- ΔgroundW
    ΔsnowW .= ΔsnowW .- ΔsnowW
    ΔsoilW .= ΔsoilW .- ΔsoilW
    ΔsurfaceW .= ΔsurfaceW .- ΔsurfaceW

    if minimum(p_wSat - soilW) < zero
        @show soilW, p_wSat, soilW - p_wSat
        error("soilW is larger than soil water holding capacity (p_wSat)")
    end

    if minimum(groundW) < zero
        @show groundW
        error("groundW is negative. Cannot continue")
    end

    if minimum(snowW) < zero
        @show snowW
        error("snowW is negative. Cannot continue")
    end

    if minimum(soilW) < zero
        @show soilW
        error("soilW is negative. Cannot continue")
    end

    if minimum(surfaceW) < zero
        @show soilW
        error("surfaceW is negative. Cannot continue")
    end

    ## pack land variables
    # @pack_land begin
    # 	(groundW, snowW, soilW, surfaceW) => land.pools
    # 	(ΔgroundW, ΔsnowW, ΔsoilW, ΔsurfaceW)  => land.states
    # end
    return land
end

@doc """
computes the algebraic sum of storage and delta storage using each component separately


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