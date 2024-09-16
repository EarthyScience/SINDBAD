export runoffInterflow_residual

#! format: off
@bounds @describe @units @with_kw struct runoffInterflow_residual{T1} <: runoffInterflow
    rc::T1 = 0.3 | (0.0, 0.9) | "fraction of the available water that flows out as interflow" | ""
end
#! format: on

function compute(params::runoffInterflow_residual, forcing, land, helpers)
    ## unpack parameters
    @unpack_runoffInterflow_residual params

    ## unpack land variables
    @unpack_nt WBP ⇐ land.states

    ## calculate variables
    # simply assume that a fraction of the still available water runs off
    interflow_runoff = rc * WBP
    # update the WBP
    WBP = WBP - interflow_runoff

    ## pack land variables
    @pack_nt begin
        interflow_runoff ⇒ land.fluxes
        WBP ⇒ land.states
    end
    return land
end

@doc """
interflow as a fraction of the available water balance pool

# Parameters
$(SindbadParameters)

---

# compute:
Interflow using runoffInterflow_residual

*Inputs*

*Outputs*
 - land.fluxes.interflow_runoff: interflow [mm/time]
 - land.states.WBP: water balance pool [mm]

---

# Extended help

*References*

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - mjung
"""
runoffInterflow_residual
