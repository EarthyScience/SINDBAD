export cCycleConsistency_simple

struct cCycleConsistency_simple <: cCycleConsistency end

function define(p_struct::cCycleConsistency_simple, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        cEco ∈ land.pools
    end
    tmp = ones(length(cEco), length(cEco))
    flagU = flagUpper(tmp)
    flagL = flagLower(tmp)
    flagUL = flagU + flagL
    p_A_tmp = tmp
    @pack_land (flagL, flagU, flagUL, p_A_tmp) => land.cCycleConsistency

    return land
end

function compute(p_struct::cCycleConsistency_simple, forcing, land, helpers)

    ## unpack land variables
    @unpack_land begin
        c_allocation ∈ land.states
        p_A ∈ land.states
        (flagL, flagU, flagUL, p_A_tmp) ∈ land.cCycleConsistency
        tolerance ∈ helpers.numbers
        (z_zero, o_one) ∈ land.wCycleBase
    end

    # check allocation
    if any(c_allocation .> o_one)
        if helpers.run.catch_model_errors
            msg = "cAllocation is greater than 1. Cannot continue"
            push!(Sindbad.error_catcher, land)
            push!(Sindbad.error_catcher, msg)
            error(msg)
        end
    end
    if any(c_allocation .< z_zero)
        if helpers.run.catch_model_errors
            msg = "cAllocation is negative. Cannot continue"
            push!(Sindbad.error_catcher, land)
            push!(Sindbad.error_catcher, msg)
            error(msg)
        end
    end
    if !isapprox(sum(c_allocation), o_one; atol=tolerance)
        if helpers.run.catch_model_errors
            msg = "cAllocation does not sum to 1. Cannot continue"
            push!(Sindbad.error_catcher, land)
            push!(Sindbad.error_catcher, msg)
            error(msg)
        end
    end

    # Check carbon flow matrix
    # check if any of the off-diagonal values of flow matrix is negative
    p_A_tmp .= p_A .* flagUL
    if any(p_A_tmp .< z_zero)
        if helpers.run.catch_model_errors
            msg = "negative values in flow matrix. Cannot continue"
            push!(Sindbad.error_catcher, land)
            push!(Sindbad.error_catcher, msg)
            push!(Sindbad.error_catcher, offDiagA)
            error(msg)
        end
    end

    # check if any of the off-diagonal values of flow matrix is larger than 1.
    if any(p_A_tmp .> o_one)
        if helpers.run.catch_model_errors
            msg = "flow is greater than 1. Cannot continue"
            push!(Sindbad.error_catcher, land)
            push!(Sindbad.error_catcher, msg)
            push!(Sindbad.error_catcher, offDiagA)
            error(msg)
        end
    end

    # check if the flow to different pools add up to 1
    # below the diagonal
    p_A_tmp .= p_A .* flagL
    # the sum of A per column below the diagonals is always < 1. The tolerance allows for small overshoot over 1, but this may result in a negative carbon pool if frequent
    if any((sum(p_A_tmp; dims=1) .- o_one) .> helpers.numbers.tolerance)
        if helpers.run.catch_model_errors
            msg = "sum of cols greater than one in lower cFlow matrix. Cannot continue"
            push!(Sindbad.error_catcher, land)
            push!(Sindbad.error_catcher, msg)
            push!(Sindbad.error_catcher, p_A_L)
            error(msg)
        end
    end
    # above the diagonal
    p_A_tmp .= p_A .* flagU

    # the sum of A per column above the diagonals is always < 1. The tolerance allows for small overshoot over 1, but this may result in a negative carbon pool if frequent
    if any((sum(p_A_tmp; dims=1) .- o_one) .> helpers.numbers.tolerance)
        if helpers.run.catch_model_errors
            msg = "sum of cols greater than one in upper cFlow matrix. Cannot continue"
            push!(Sindbad.error_catcher, land)
            push!(Sindbad.error_catcher, msg)
            push!(Sindbad.error_catcher, p_A_U)
            push!(Sindbad.error_catcher, any(sum(p_A_U; dims=1) .> o_one))
            push!(Sindbad.error_catcher, sum(p_A_U; dims=1))
            error(msg)
        end
    end

    return land
end

@doc """
check consistency in cCycle matrix: c_allocation; cFlow

---

# compute:
Consistency checks on the c allocation and transfers between pools using cCycleConsistency_simple

*Inputs*
 - flow_matrix: carbon flow matrix
 - land.states.c_allocation: carbon allocation matrix

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
