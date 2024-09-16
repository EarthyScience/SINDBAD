export drainage_wFC

struct drainage_wFC <: drainage end

function define(params::drainage_wFC, forcing, land, helpers)
    ## instantiate drainage
    @unpack_nt soilW ⇐ land.pools
    drainage = zero(soilW)
    ## pack land variables
    @pack_nt drainage ⇒ land.fluxes
    return land
end

function compute(params::drainage_wFC, forcing, land, helpers)

    ## unpack land variables
    @unpack_nt begin
        drainage ⇐ land.fluxes
        (p_nsoilLayers, wFC) ⇐ land.properties
        soilW ⇐ land.pools
        ΔsoilW ⇐ land.pools
        z_zero ⇐ land.constants
    end

    ## calculate drainage
    for sl ∈ 1:(length(soilW)-1)
        holdCap = wSat[sl+1] - (soilW[sl+1] + ΔsoilW[sl+1])
        lossCap = soilW[sl] + ΔsoilW[sl]
        drainage[sl] = maxZero(soilW[sl] + ΔsoilW[sl] - wFC[sl])
        drainage[sl] = min(drainage[sl], holdCap, lossCap)
        ΔsoilW[sl] = ΔsoilW[sl] - drainage[sl]
        ΔsoilW[sl+1] = ΔsoilW[sl+1] + drainage[sl]
    end

    ## pack land variables
    # @pack_nt begin
    # 	drainage ⇒ land.fluxes
    # 	# ΔsoilW ⇒ land.pools
    # end
    return land
end

function update(params::drainage_wFC, forcing, land, helpers)
    ## unpack variables
    @unpack_nt begin
        soilW ⇐ land.pools
        ΔsoilW ⇐ land.pools
    end

    ## update variables
    # update soil moisture
    soilW .= soilW .+ ΔsoilW

    # reset soil moisture changes to zero
    ΔsoilW .= ΔsoilW .- ΔsoilW

    ## pack land variables
    @pack_nt begin
        # soilW ⇒ land.pools
        # ΔsoilW ⇒ land.pools
    end
    return land
end

@doc """
downward flow of moisture [drainage] in soil layers based on overflow over field capacity

---

# compute:
Recharge the soil using drainage_wFC

*Inputs*
 - land.pools.soilW: soil moisture in different layers
 - land.properties.wFC: field capacity of soil in mm
 - land.states.WBP amount of water that can potentially drain

*Outputs*
 - drainage from the last layer is saved as groundwater recharge [gw_recharge]
 - land.states.soilWFlow: drainage flux between soil layers (same as nZix, from percolation  into layer 1 & the drainage to the last layer)

# update

update pools and states in drainage_wFC

 - land.pools.soilW
 - land.states.WBP

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [skoirala]: clean up & consistency  

*Created by:*
 - mjung
 - skoirala
"""
drainage_wFC
