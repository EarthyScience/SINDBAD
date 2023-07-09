export cFlow_simple

struct cFlow_simple <: cFlow end

function compute(p_struct::cFlow_simple, forcing, land, helpers)

    ## unpack land variables
    @unpack_land c_flow_A ∈ land.cCycleBase

    ## calculate variables
    #@nc : this needs to go in the full..
    # Do A matrix..
    p_A = repeat(reshape(c_flow_A, [1 size(c_flow_A)]), 1, 1)
    # transfers
    (c_taker, c_giver) = find(squeeze(sum(p_A > 0.0)) >= 1)
    p_taker = c_taker
    p_giver = c_giver
    # if there is flux order check that is consistent
    if !isfield(land.cCycleBase, :c_flow_order)
        c_flow_order = 1:length(c_taker)
    else
        if length(c_flow_order) != length(c_taker)
            error(["ERR : cFlowAct_simple : " "length(c_flow_order) != length(c_taker)"])
        end
    end

    ## pack land variables
    @pack_land begin
        c_flow_order => land.cCycleBase
        (p_A, p_giver, p_taker) => land.cFlow
    end
    return land
end

@doc """
combine all the effects that change the transfers between carbon pools

---

# compute:
Actual transfers of c between pools (of diagonal components) using cFlow_simple

*Inputs*
 - land.cCycleBase.c_flow_A: transfer matrix for carbon at ecosystem level

*Outputs*
 - land.cFlow.p_A: effect of vegetation & vegetation on actual transfer rates between pools
 - land.cFlow.p_A

---

# Extended help

*References*

*Versions*
 - 1.0 on 13.01.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cFlow_simple
