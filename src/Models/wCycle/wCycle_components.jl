export wCycle_components

struct wCycle_components <: wCycle
end

function compute(o::wCycle_components, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        (groundW, snowW, soilW, surfaceW, TWS) ∈ land.pools
        (ΔgroundW, ΔsnowW, ΔsoilW, ΔsurfaceW, ΔTWS) ∈ land.states
        𝟘  ∈ helpers.numbers
    end

    ## update variables
    groundW = add_vec(groundW, ΔgroundW)
    snowW = add_vec(snowW, ΔsnowW)
    soilW = add_vec(soilW, ΔsoilW)
    surfaceW = add_vec(surfaceW, ΔsurfaceW)
    TWS = add_vec(TWS, ΔTWS)
    
    # @show ΔgroundW, ΔsnowW, ΔsoilW, ΔsurfaceW, ΔTWS
    # reset moisture changes to zero
    ΔgroundW = ΔgroundW .* 𝟘
    ΔsnowW = ΔsnowW .* 𝟘
    ΔsoilW = ΔsoilW .* 𝟘
    ΔsurfaceW = ΔsurfaceW .* 𝟘
    ΔTWS = ΔTWS .* 𝟘

    ## pack land variables
    @pack_land begin
    	(groundW, snowW, soilW, surfaceW, TWS) => land.pools
    	(ΔgroundW, ΔsnowW, ΔsoilW, ΔsurfaceW, ΔTWS)  => land.states
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