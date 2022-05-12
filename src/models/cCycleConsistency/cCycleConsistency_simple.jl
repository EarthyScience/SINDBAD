export cCycleConsistency_simple

struct cCycleConsistency_simple <: cCycleConsistency
end

function precompute(o::cCycleConsistency_simple, forcing, land::NamedTuple, helpers::NamedTuple)

	## unpack land variables
	@unpack_land begin
		cEco ∈ land.pools
		numType ∈ helpers.numbers
	end
	tmp = ones(numType, length(cEco), length(cEco))
	flagU = flagUpper(tmp)
	flagL = flagLower(tmp)
	@pack_land (flagL, flagU) => land.cCycleConsistency

	return land
end

function compute(o::cCycleConsistency_simple, forcing, land::NamedTuple, helpers::NamedTuple)

	## unpack land variables
	@unpack_land begin
		cAlloc ∈ land.states
		p_A ∈ land.cFlow
		(flagL, flagU) ∈ land.cCycleConsistency
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
	# check if any of the off-diagonal values of flow matrix is negative
	offDiagA = offDiag(p_A)
	if any(offDiagA .< 𝟘)
		@show offDiagA, p_A
		error("negative values in flow matrix. Cannot continue")
	end

	# check if any of the off-diagonal values of flow matrix is larger than 1.
	if any(offDiagA .> 𝟙)
		@show offDiagA, p_A
		error("flow is greater than 1. Cannot continue")
	end

	# check if the flow to different pools add up to 1
	# below the diagonal
	p_A_L = p_A .* flagL
	# the sum of A per column below the diagonals is always < 1
	if any(sum(p_A_L, dims=1) .> 𝟙)
		@show p_A
		error("sum of cols greater than one in lower cFlow matrix. Cannot continue")
	end

	# above the diagonal
	p_A_U = p_A .* flagU
	if any(sum(p_A_U, dims=1) .> 𝟙)
		@show p_A
		error("sum of cols greater than one in upper cFlow matrix. Cannot continue")
	end

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
 - 1.0 on 12.05.2022: skoirala: julia implementation  

*Created by:*
 - sbesnard
"""
cCycleConsistency_simple