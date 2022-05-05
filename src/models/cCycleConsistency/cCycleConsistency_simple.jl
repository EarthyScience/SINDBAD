export cCycleConsistency_simple

struct cCycleConsistency_simple <: cCycleConsistency
end

function compute(o::cCycleConsistency_simple, forcing, land::NamedTuple, helpers::NamedTuple)

	## unpack land variables
	@unpack_land begin
		cAlloc ∈ land.states
		p_A ∈ land.cFlow
		(𝟘, 𝟙, tolerance) ∈ helpers.numbers
	end

	# check allocation
	if any(cAlloc .> 𝟙)
		@show cAlloc
		error("cAllocation is greater than 1. Cannot continue")
	end
	if any(cAlloc .< 𝟘)
		@show cAlloc
		error("cAllocation is negative. Cannot continue")
	end
	if !isapprox(sum(cAlloc), 𝟙; atol=tolerance)
		@show cAlloc, sum(cAlloc)
		error("cAllocation does not sum to 1. Cannot continue")
	end

	# Check carbon flow matrix
	# the sum of A per column below the diagonals is always < 1
	offDiagA = offDiag(p_A)
	offDiagU = offDiagUpper(p_A)
	offDiagL = offDiagLower(p_A)
	if any(offDiagA .< 𝟘)
		@show offDiagA, p_A
		error("negative values in flow matrix. Cannot continue")
	end
	if any(offDiagA .> 𝟙)
		@show offDiagA, p_A
		error("flow is greater than 1. Cannot continue")
	end

	# if !isapprox(sum(offDiagL), 𝟙; atol=tolerance)
	# 	@show sum(offDiagL), offDiagL, p_A
	# 	error("sum of cols greater than one in lower cFlow matrix")
	# end
	# if !isapprox(sum(offDiagU), 𝟙; atol=tolerance)
	# 	@show sum(offDiagU), offDiagU, p_A
	# 	error("sum of cols greater than one in upper cFlow matrix")
	# end
	return land
end

@doc """
check consistency in cCycle matrix: cAlloc; cFlow

---

# compute:
Consistency checks on the c allocation and transfers between pools using cCycleConsistency_simple

*Inputs*
 - flow_matrix: carbon flow matrix
 - land.states.cAlloc: carbon allocation matrix

*Outputs*

# precompute:
precompute/instantiate time-invariant variables for cCycleConsistency_simple


---

# Extended help

*References*

*Versions*
 - 1.0 on 12.03.2020  

*Created by:*
 - sbesnard
"""
cCycleConsistency_simple