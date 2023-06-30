export getPools_simple

struct getPools_simple <: getPools end
function define(o::getPools_simple, forcing, land, helpers)
    ## unpack land variables
    @unpack_land rain ∈ land.rainSnow
    WBP = rain
    ## pack land variables
    @pack_land WBP => land.states
    return land
end

function compute(o::getPools_simple, forcing, land, helpers)

    ## unpack land variables
    @unpack_land rain ∈ land.rainSnow

    ## calculate variables
    WBP = rain

    ## pack land variables
    # set_components(land, helpers, Val(:TWS), Val(helpers.pools.all_components.TWS), Val(helpers.pools.zix))
    # TWS = land.pools.TWS
    # soilW = land.pools.soilW
    # soilW = (Sindbad.rep_elem)(soilW, TWS[1], helpers.pools.zeros.soilW, helpers.pools.ones.soilW, helpers.numbers.𝟘, helpers.numbers.𝟙, 1)
    # soilW = (Sindbad.rep_elem)(soilW, TWS[2], helpers.pools.zeros.soilW, helpers.pools.ones.soilW, helpers.numbers.𝟘, helpers.numbers.𝟙, 2)
    # soilW = (Sindbad.rep_elem)(soilW, TWS[3], helpers.pools.zeros.soilW, helpers.pools.ones.soilW, helpers.numbers.𝟘, helpers.numbers.𝟙, 3)
    # soilW = (Sindbad.rep_elem)(soilW, TWS[4], helpers.pools.zeros.soilW, helpers.pools.ones.soilW, helpers.numbers.𝟘, helpers.numbers.𝟙, 4)
    # land = (land..., pools=(; land.pools..., soilW=soilW))
    # groundW = land.pools.groundW
    # groundW = (Sindbad.rep_elem)(groundW, TWS[5], helpers.pools.zeros.groundW, helpers.pools.ones.groundW, helpers.numbers.𝟘, helpers.numbers.𝟙, 1)
    # land = (land..., pools=(; land.pools..., groundW=groundW))
    # snowW = land.pools.snowW
    # snowW = (Sindbad.rep_elem)(snowW, TWS[6], helpers.pools.zeros.snowW, helpers.pools.ones.snowW, helpers.numbers.𝟘, helpers.numbers.𝟙, 1)
    # land = (land..., pools=(; land.pools..., snowW=snowW))
    # surfaceW = land.pools.surfaceW
    # surfaceW = (Sindbad.rep_elem)(surfaceW, TWS[7], helpers.pools.zeros.surfaceW, helpers.pools.ones.surfaceW, helpers.numbers.𝟘, helpers.numbers.𝟙, 1)
    # land = (land..., pools=(; land.pools..., surfaceW=surfaceW))

    @pack_land WBP => land.states
    return land
end

@doc """
gets the amount of water available for the current time step

---

# compute:
Get the amount of water at the beginning of timestep using getPools_simple

*Inputs*
 - amount of rainfall

*Outputs*
 - land.states.WBP: the amount of liquid water input to the system

---

# Extended help

*References*

*Versions*
 - 1.0 on 19.11.2019 [skoirala]: added the documentation & cleaned the code, added json with development stage

*Created by:*
 - mjung
 - ncarval
 - skoirala
"""
getPools_simple
