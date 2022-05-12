export cCycleBase_simple

@bounds @describe @units @with_kw struct cCycleBase_simple{T1, T2, T3} <: cCycleBase
	annk::T1 = [1, 0.03, 0.03, 1, 14.8, 3.9, 18.5, 4.8, 0.2424, 0.2424, 6, 7.3, 0.2, 0.0045] | ([0.05, 0.002, 0.002, 0.05, 1.48, 0.39, 1.85, 0.48, 0.02424, 0.02424, 0.6, 0.73, 0.02, 0.0045], [3.3, 0.5, 0.5, 3.3, 148.0, 39.0, 185.0, 48.0, 2.424, 2.424, 60.0, 73.0, 2.0, 0.045]) | "turnover rate of ecosystem carbon pools" | "yr-1"
	cFlowA::T2 = 	[-1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0;
					0.0  -1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0;
					0.0  0.0  -1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0;
					0.0  0.0  0.0  -1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0;
					0.0  0.0  0.0  0.54  -1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0;
					0.0  0.0  0.0  0.46  0.0  -1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0;
					0.54  0.0  0.0  0.0  0.0  0.0  -1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0;
					0.46  0.0  0.0  0.0  0.0  0.0  0.0  -1.0  0.0  0.0  0.0  0.0  0.0  0.0;
					0.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0  -1.0  0.0  0.0  0.0  0.0  0.0;
					0.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  -1.0  0.0  0.0  0.0  0.0;
					0.0  0.0  0.0  0.0  0.4  0.15  0.0  0.0  0.24  0.0  -1.0  0.0  0.0  0.0;
					0.0  0.0  0.0  0.0  0.0  0.0  0.45  0.17  0.0  0.24  0.0  -1.0  0.0  0.0;
					0.0  0.0  0.0  0.0  0.0  0.43  0.0  0.43  0.28  0.28  0.4  0.43  -1.0  0.0;
					0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.005  0.0026  -1.0] | nothing | "Transfer matrix for carbon at ecosystem level" | ""
	C2Nveg::T3 = [25.0, 260.0, 260.0, 25.0] | nothing | "carbon to nitrogen ratio in vegetation pools" | "gC/gN"
end

function precompute(o::cCycleBase_simple, forcing, land::NamedTuple, helpers::NamedTuple)
	@unpack_cCycleBase_simple o

	@unpack_land begin
		numType ∈ helpers.numbers
		cEco ∈ land.pools
	end
    ## instantiate variables
    p_C2Nveg = ones(numType, length(cEco)) #sujan
    cEcoEfflux = zeros(numType, length(land.pools.cEco)) #sujan moved from get states

    ## pack land variables
    @pack_land begin
		(p_C2Nveg, cFlowA) => land.cCycleBase
		cEcoEfflux => land.states
	end
	return land
end

function compute(o::cCycleBase_simple, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_cCycleBase_simple o

	## unpack land variables
    @unpack_land begin
		p_C2Nveg ∈ land.cCycleBase
		𝟙 ∈ helpers.numbers
	end

	## calculate variables
	#carbon to nitrogen ratio [gC.gN-1]
    p_C2Nveg[getzix(land.pools.cVeg)] .= C2Nveg

	# turnover rates
    TSPY = helpers.dates.nStepsYear
    p_k_base = 𝟙 .- (exp.(-𝟙 .* annk).^(𝟙 / TSPY))

	## pack land variables
    @pack_land (p_C2Nveg, p_k_base, cFlowA) => land.cCycleBase

	return land
end

@doc """
Compute carbon to nitrogen ratio & annual turnover rates

# Parameters
$(PARAMFIELDS)

---

# compute:
Pool structure of the carbon cycle using cCycleBase_simple

*Inputs*

*Outputs*

# precompute:
precompute/instantiate time-invariant variables for cCycleBase_simple


---

# Extended help

*References*
 - Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; & S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite & surface data.  Global Biogeochemical Cycles. 7: 811-841.

*Versions*
 - 1.0.0 on 28.02.2020.0 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cCycleBase_simple