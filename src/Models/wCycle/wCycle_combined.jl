export wCycle_combined

struct wCycle_combined <: wCycle end

function define(p_struct::wCycle_combined, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        ΔTWS ∈ land.states
    end
    zeroΔTWS = zero(ΔTWS)

    @pack_land zeroΔTWS => land.states
    return land
end

function compute(p_struct::wCycle_combined, forcing, land, helpers)
    ## unpack variables
    @unpack_land begin
        TWS ∈ land.pools
        (ΔTWS, zeroΔTWS) ∈ land.states
        tolerance ∈ helpers.numbers
    end
    totalW_prev = sum(TWS)
    #TWS_old = deepcopy(TWS)
    ## update variables
    TWS = add_vec(TWS, ΔTWS)

    # reset soil moisture changes to zero
    if minimum(TWS) < zero(first(TWS))
        if abs(minimum(TWS)) < tolerance
            @error "Numerically small negative TWS ($(TWS)) smaller than tolerance ($(tolerance)) were replaced with absolute value of the storage"
            # @assert(false, "Numerically small negative TWS ($(TWS)) smaller than tolerance ($(tolerance)) were replaced with absolute value of the storage") 
            TWS = abs.(TWS)
        else
            error("TWS is negative. Cannot continue. $(TWS)")
        end
    end
    ΔTWS = zeroΔTWS

    totalW = sum(TWS)

    # pack land variables
    @pack_land begin
        (TWS) => land.pools
        (ΔTWS, totalW, totalW_prev) => land.states
    end
    return land
end

@doc """
computes the algebraic sum of storage and delta storage


---

# compute:
- apply the delta storage changes
- check if there is overflow or over extraction

*Inputs*
- land.pools.storages: water storages
- land.states.Δstorages: water storage changes

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
wCycle_combined
