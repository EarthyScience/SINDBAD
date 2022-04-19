export cCycleBase_simple

@bounds @describe @units @with_kw struct cCycleBase_simple{T1, T2, T3} <: cCycleBase
	annk::T1 = [1, 0.03, 0.03, 1, 14.8, 3.9, 18.5, 4.8, 0.2424, 0.2424, 6, 7.3, 0.2, 0.0045] | ([0.05, 0.002, 0.002, 0.05, 1.48, 0.39, 1.85, 0.48, 0.02424, 0.02424, 0.6, 0.73, 0.02, 0.0045], [3.3, 0.5, 0.5, 3.3, 148.0, 39.0, 185.0, 48.0, 2.424, 2.424, 60.0, 73.0, 2.0, 0.045]) | "turnover rate of ecosystem carbon pools" | "yr-1"
	cFlowA::T2 = 	[-1  0  0  0  0  0  0  0  0  0  0  0  0  0;
					0  -1  0  0  0  0  0  0  0  0  0  0  0  0;
					0  0  -1  0  0  0  0  0  0  0  0  0  0  0;
					0  0  0  -1  0  0  0  0  0  0  0  0  0  0;
					0  0  0  0.54  -1  0  0  0  0  0  0  0  0  0;
					0  0  0  0.46  0  -1  0  0  0  0  0  0  0  0;
					0.54  0  0  0  0  0  -1  0  0  0  0  0  0  0;
					0.46  0  0  0  0  0  0  -1  0  0  0  0  0  0;
					0  0  1  0  0  0  0  0  -1  0  0  0  0  0;
					0  1  0  0  0  0  0  0  0  -1  0  0  0  0;
					0  0  0  0  0.4  0.15  0  0  0.24  0  -1  0  0  0;
					0  0  0  0  0  0  0.45  0.17  0  0.24  0  -1  0  0;
					0  0  0  0  0  0.43  0  0.43  0.28  0.28  0.4  0.43  -1  0;
					0  0  0  0  0  0  0  0  0  0  0  0.005  0.0026  -1] | nothing | "Transfer matrix for carbon at ecosystem level" | ""
	C2Nveg::T3 = [25, 260, 260, 25] | nothing | "carbon to nitrogen ratio in vegetation pools" | "gC/gN"
end

function precompute(o::cCycleBase_simple, forcing, land, infotem)
	@unpack_cCycleBase_simple o

	## instantiate variables
	p_C2Nveg = repeat(infotem.helpers.azero, infotem.pools.carbon.nZix.cVeg); #sujan

	## pack land variables
	@pack_land p_C2Nveg => land.cCycleBase
	return land
end

function compute(o::cCycleBase_simple, forcing, land, infotem)
	## unpack parameters
	@unpack_cCycleBase_simple o

	## unpack land variables
	@unpack_land p_C2Nveg ∈ land.cCycleBase

	## calculate variables
	#carbon to nitrogen ratio [gC.gN-1]
	for zix in infotem.pools.carbon.zix.cVeg
		p_C2Nveg[zix] = C2Nveg[zix]
	end
	# annual turnover rates
	p_annk = reshape(repelem[annk], infotem.pools.carbon.nZix.cEco); #sujan

	## pack land variables
	@pack_land (p_C2Nveg, p_annk) => land.cCycleBase
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
 -

# precompute:
precompute/instantiate time-invariant variables for cCycleBase_simple


---

# Extended help

*References*
 - Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; & S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite & surface data.  Global Biogeochemical Cycles. 7: 811-841.

*Versions*
 - 1.0 on 28.02.2020 [sbesnard]  

*Created by:*
 - ncarvalhais
"""
cCycleBase_simple