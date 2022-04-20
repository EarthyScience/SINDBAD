export cCycleConsistency_simple

struct cCycleConsistency_simple <: cCycleConsistency
end

function precompute(o::cCycleConsistency_simple, forcing, land, helpers)

	## instantiate variables
		flagUp = triu(ones(size(flow_matrix)), 1)
		flagLo = tril(ones(size(flow_matrix)), -1)

	## pack land variables
	@pack_land (flagUp, flagLo) => land.cCycleConsistency
	return land
end

function compute(o::cCycleConsistency_simple, forcing, land, helpers)

	## unpack land variables
	@unpack_land (flagUp, flagLo) ∈ land.cCycleConsistency

	## unpack land variables
	@unpack_land begin
		cAlloc ∈ land.states
		p_A ∈ land.cFlow
	end
	# check allocation
	tmp0 = cAlloc; #sujan
	tmp1 = sum(cAlloc)
	if any(tmp0 > 1) || any(tmp0 < helpers.numbers.zero)
		error("SINDBAD TEM: cAlloc lt 0 | gt 1")
	end
	if any(abs(sum(tmp1) - 1) > 1E-6)
		error("SINDBAD TEM: sum(cAlloc) ne1")
	end
	# Check carbon flow matrix
	# the sum of A per column below the diagonals is always < 1
	# sujan: 22/03/2021: the flow_matrix reshape here is extremely slow..Also; it will not work when there is more than 1 pixel.
	for pix in 1:info.tem.helpers.sizes.nPix
		flow_matrix = squeeze(p_A[pix])
		# of diagonal values of 0 must be between 0 & 1
		anyBad = any(flow_matrix * (flagLo + flagUp) < helpers.numbers.zero)
		if anyBad
			error("negative values in the p_cFlow_A matrix!")
		end
		anyBad = any(flow_matrix * (flagLo + flagUp) > 1 + 1E-6)
		if anyBad
			error("values in the p_cFlow_A matrix greater than 1!")
		end
		# in the lower & upper part of the matrix A the sums have to be lower than 1
		anyBad = any(sum(flow_matrix * flagLo) > 1 + 1E-6)
		if anyBad
			error("sum of cols higher than one in lower in p_cFlow_A matrix")
		end
		anyBad = any(sum(flow_matrix * flagUp) > 1 + 1E-6)
		if anyBad
			error("sum of cols higher than one in upper in p_cFlow_A matrix")
		end
	end
	# flow_matrix = reshape(p_A, helpers.pools.carbon.nZix.cEco, helpers.pools.carbon.nZix.cEco)
	# flagUp = triu(ones(size(flow_matrix)), 1)
	# flagLo = tril(ones(size(flow_matrix)), -1)
	# # of diagonal values of 0 must be between 0 & 1
	# anyBad = any(flow_matrix * (flagLo+flagUp) < helpers.numbers.zero)
	# if anyBad
	# error("negative values in the p_cFlow_A matrix!")
	# end
	# anyBad = any(flow_matrix * (flagLo+flagUp) > 1 + 1E-6)
	# if anyBad
	# error("values in the p_cFlow_A matrix greater than 1!")
	# end
	# # in the lower & upper part of the matrix A the sums have to be lower than 1
	# anyBad = any(sum(flow_matrix * flagLo) > 1 + 1E-6)
	# if anyBad
	# error("sum of cols higher than one in lower in p_cFlow_A matrix")
	# end
	# anyBad = any(sum(flow_matrix * flagUp) > 1 + 1E-6)
	# if anyBad
	# error("sum of cols higher than one in upper in p_cFlow_A matrix")
	# end

	## pack land variables
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
 -

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