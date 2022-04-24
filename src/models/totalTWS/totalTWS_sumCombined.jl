export totalTWS_sumCombined

struct totalTWS_sumCombined <: totalTWS end

function precompute(o::totalTWS_sumCombined, forcing, land, helpers)
    @unpack_land begin
        numType ∈ helpers.numbers
        TWS ∈ land.pools
    end

    ## calculate variables
    totalW = sum(TWS)

    ## pack land variables
    @pack_land begin
        (totalW) => land.totalTWS
    end
    return land
end

function compute(o::totalTWS_sumCombined, forcing, land, helpers)

    ## unpack land variables
    @unpack_land TWS ∈ land.pools

    ## calculate variables
    totalW = sum(TWS)

    ## pack land variables
    @pack_land (totalW) => land.totalTWS
    return land
end

@doc """
calculates total water storage as a sum of all potential components

---

# compute:
calculates total water storage as a sum of combined water storage

*Inputs*
 - land.totalTWS.totalTWS

*Outputs*
 - land.pools.wTotal: total water storage

# precompute:
precompute/instantiate time-invariant variables for totalTWS_sumCombined


---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 01.04.2022  

*Created by:*
 - skoirala
"""
totalTWS_sumCombined