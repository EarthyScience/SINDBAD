export cCycleConsistency_simple

struct cCycleConsistency_simple <: cCycleConsistency end

function define(p_struct::cCycleConsistency_simple, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        cEco ∈ land.pools
        (c_giver, c_flow_A) ∈ land.cCycleBase
    end
    # make list of indices which give carbon to other pools during the flow, and separate them if 
    # they are above or below the diagonal in flow vector
    giver_upper = Tuple([ind[2] for ind ∈ findall(>(0), flagUpper(c_flow_A) .* c_flow_A)])
    giver_lower = Tuple([ind[2] for ind ∈ findall(>(0), flagUpper(c_flow_A) .* c_flow_A)])
    giver_upper_unique = unique(giver_upper)
    giver_lower_unique = unique(giver_lower)
    giver_upper_indices = []
    for giv in giver_upper_unique
        giver_pos = findall(==(giv), c_giver)
        push!(giver_upper_indices, Tuple(giver_pos))
    end
    giver_lower_indices = []
    for giv in giver_lower_unique
        giver_pos = findall(==(giv), c_giver)
        push!(giver_lower_indices, Tuple(giver_pos))
    end
    giver_lower_indices = Tuple(giver_lower_indices)
    giver_upper_indices = Tuple(giver_upper_indices)
    @pack_land (giver_lower_unique, giver_lower_indices, giver_upper_unique, giver_upper_indices) => land.cCycleConsistency
    return land
end

"""
cry_and_die(land, msg)
display and error msg and stop when there is inconsistency
"""
function cry_and_die(land, msg)
    tcprint(land)
    if hasproperty(Sindbad, :error_catcher)
        push!(Sindbad.error_catcher, land)
    end
    error(msg)
end

function compute(p_struct::cCycleConsistency_simple, forcing, land, helpers)
    ## unpack land variables
    @unpack_land begin
        c_allocation ∈ land.states
        p_A ∈ land.states
        (giver_lower_unique, giver_lower_indices, giver_upper_unique, giver_upper_indices) ∈ land.cCycleConsistency
        tolerance ∈ helpers.numbers
        (z_zero, o_one) ∈ land.wCycleBase
    end

    # check allocation
    if helpers.run.catch_model_errors
        for i in eachindex(c_allocation) 
            if c_allocation[i] < z_zero
                cry_and_die(land, "negative values in carbon_allocation at index $(i). Cannot continue")
            end
        end

        for i in eachindex(c_allocation) 
            if c_allocation[i] > o_one
                cry_and_die(land, "carbon_allocation larger than one at index $(i). Cannot continue")
            end
        end

        if !isapprox(sum(c_allocation), o_one; atol=tolerance)
            cry_and_die(land, "cAllocation does not sum to 1. Cannot continue")
        end

        # Check carbon flow vector
        # check if any of the off-diagonal values of flow vector is negative
        for i in eachindex(p_A) 
            if p_A[i] < z_zero
                cry_and_die(land, "negative value in flow vector at index $(i). Cannot continue")
            end
        end

        # check if any of the off-diagonal values of flow vector is larger than 1.
        for i in eachindex(p_A) 
            if p_A[i] > o_one
                cry_and_die(land, "flow is greater than one in flow vector at index $(i). Cannot continue")
            end
        end

        # check if the flow to different pools add up to 1
        # below the diagonal
        # the sum of A per column below the diagonals is always < 1. The tolerance allows for small overshoot over 1, but this may result in a negative carbon pool if frequent

        for (i, giv) in enumerate(giver_upper_unique)
            s = z_zero
            for ind in giver_upper_indices[i]
                s = s + p_A[ind]
            end
            if (s - o_one) > helpers.numbers.tolerance
                cry_and_die(land, "sum of giver flow greater than one in upper cFlow vector for $(info.tem.helpers.pools.components.cEco[giv]) pool. Cannot continue.")
            end
        end
    
        for (i, giv) in enumerate(giver_lower_unique)
            s = z_zero
            for ind in giver_lower_indices[i]
                s = s + p_A[ind]
            end
            if (s - o_one) > helpers.numbers.tolerance
                cry_and_die(land, "sum of giver flow greater than one in lower cFlow vector for $(info.tem.helpers.pools.components.cEco[giv]) pool. Cannot continue.")
            end
        end

    end

    return land
end

@doc """
check consistency in cCycle vector: c_allocation; cFlow

---

# compute:
Consistency checks on the c allocation and transfers between pools using cCycleConsistency_simple

*Inputs*
 - flow_vector: carbon flow vector
 - land.states.c_allocation: carbon allocation vector

*Outputs*

# instantiate:
instantiate/instantiate time-invariant variables for cCycleConsistency_simple


---

# Extended help

*References*

*Versions*
 - 1.0 on 12.05.2022: skoirala: julia implementation  

*Created by:*
 - sbesnard
"""
cCycleConsistency_simple
