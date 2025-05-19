<details class='jldocstring custom-block' open>
<summary><a id='Sindbad' href='#Sindbad'><span class="jlbinding">Sindbad</span></a> <Badge type="info" class="jlObjectType jlModule" text="Module" /></summary>



```julia
Sindbad
```


A Julia package for the terrestrial ecosystem models within **S**trategies to **IN**tegrate **D**ata and **B**iogeochemic**A**l mo**D**els `(SINDBAD)` framework.

The `Sindbad` package serves as the core of the SINDBAD framework, providing foundational types, utilities, and tools for building and managing SINDBAD models.

**Purpose:**

This package defines the `LandEcosystem` supertype, which serves as the base for all SINDBAD models. It also provides utilities for managing model variables, tools for model operations, and a catalog of variables used in SINDBAD workflows.

**Dependencies:**
- `Reexport`: Simplifies re-exporting functionality from other packages, ensuring a clean and modular design.
  
- `CodeTracking`: Enables tracking of code definitions, useful for debugging and development workflows.
  
- `DataStructures`: Provides advanced data structures (e.g., `OrderedDict`, `Deque`) for efficient data handling in SINDBAD models.
  
- `Dates`: Handles date and time operations, useful for managing temporal data in SINDBAD experiments.
  
- `Flatten`: Supplies tools for flattening nested data structures, simplifying the handling of hierarchical model variables.
  
- `InteractiveUtils`: Enables interactive exploration and debugging during development.
  
- `Parameters`: Provides macros for defining and managing model parameters in a concise and readable manner.
  
- `StaticArraysCore`: Supports efficient, fixed-size arrays (e.g., `SVector`, `MArray`) for performance-critical operations in SINDBAD models.
  
- `TypedTables`: Provides lightweight, type-stable tables for structured data manipulation.
  
- `Accessors`: Enables efficient access and modification of nested data structures, simplifying the handling of SINDBAD configurations.
  
- `StatsBase`: Supplies statistical functions such as `mean`, `percentile`, `cor`, and `corspearman` for computing metrics like correlation and distribution-based statistics.
  
- `NaNStatistics`: Extends statistical operations to handle missing values (`NaN`), ensuring robust data analysis.
  

**Included Files:**
1. **`coreTypes.jl`**:
  - Defines the core types used in SINDBAD, including the `LandEcosystem` supertype and other fundamental types.
    
  
2. **`utilsCore.jl`**:
  - Contains core utility functions for SINDBAD, including helper methods for array operations and code generation macros for NamedTuple packing and unpacking.
    
  
3. **`sindbadVariableCatalog.jl`**:
  - Defines a catalog of variables used in SINDBAD models, ensuring consistency and standardization across workflows. Note that every new variable would need a manual entry in the catalog so that the output files are written with correct information.
    
  
4. **`modelTools.jl`**:
  - Provides tools for extracting information from SINDBAD models, including mode code, variables, and parameters.
    
  
5. **`Models/models.jl`**:
  - Implements the core SINDBAD models, inheriting from the `LandEcosystem` supertype. Also, introduces the fallback function for compute, precompute, etc. so that they are optional in every model.
    
  
6. **`generateCode.jl`**:
  - Contains code generation utilities for SINDBAD models and workflows.
    
  

**Notes:**
- The `LandEcosystem` supertype serves as the foundation for all SINDBAD models, enabling extensibility and modularity.
  
- The package re-exports key functionality from other packages (e.g., `Flatten`, `StaticArraysCore`, `DataStructures`) to simplify usage and integration.
  
- Designed to be lightweight and modular, allowing seamless integration with other SINDBAD packages.
  

**Examples:**
1. **Defining a new SINDBAD model**:
  

```julia
struct MyModel <: LandEcosystem
    # Define model-specific fields
end
```

1. **Using utilities from the package**:
  

```julia
using Sindbad
# Access utilities or models
flattened_data = flatten(nested_data)
```

1. **Querying the variable catalog**:
  

```julia
using Sindbad
catalog = getVariableCatalog()
```


</details>


## Exported {#Exported}


<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.sindbad_variables' href='#Sindbad.sindbad_variables'><span class="jlbinding">Sindbad.sindbad_variables</span></a> <Badge type="info" class="jlObjectType jlConstant" text="Constant" /></summary>



`sindbad_variables`

A dictionary of dictionaries that contains information about the variables in the SINDBAD models. The keys of the outer dictionary are the variable names and the inner dictionaries contain the following keys:
- `standard_name`: the standard name of the variable
  
- `long_name`: a longer description of the variable
  
- `units`: the units of the variable
  
- `land_field`: the field in the SINDBAD model where the variable is used
  
- `description`: a description of the variable
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Types.LandEcosystem' href='#Sindbad.Types.LandEcosystem'><span class="jlbinding">Sindbad.Types.LandEcosystem</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



LandEcosystem

Abstract type for all SINDBAD land ecosystem models/approaches

**Methods**

All subtypes of `LandEcosystem` must implement at least one of the following methods:
- `define`: Initialize arrays and variables
  
- `precompute`: Update variables with new realizations
  
- `compute`: Update model state in time
  
- `update`: Update pools within a single time step
  

**Example**

```julia
# Define a new model type
struct MyModel <: LandEcosystem end

# Implement required methods
function define(params::MyModel, forcing, land, helpers)
# Initialize arrays and variables
return land
end

function precompute(params::MyModel, forcing, land, helpers)
# Update variables with new realizations
return land
end

function compute(params::MyModel, forcing, land, helpers)
# Update model state in time
return land
end

function update(params::MyModel, forcing, land, helpers)
# Update pools within a single time step
return land
end
```



---


**Extended help**

**LandEcosystem**

Abstract type for all SINDBAD land ecosystem models/approaches

**Available methods/subtypes:**
- `EVI`: Enhanced vegetation index 
  - `EVI_constant`: sets EVI as a constant 
    
  - `EVI_forcing`: sets land.states.EVI from forcing 
    
  
- `LAI`: Leaf area index 
  - `LAI_cVegLeaf`: sets land.states.LAI from the carbon in the leaves of the previous time step 
    
  - `LAI_constant`: sets LAI as a constant 
    
  - `LAI_forcing`: sets land.states.LAI from forcing 
    
  
- `NDVI`: Normalized difference vegetation index 
  - `NDVI_constant`: sets NDVI as a constant 
    
  - `NDVI_forcing`: sets land.states.NDVI from forcing 
    
  
- `NDWI`: Normalized difference water index 
  - `NDWI_constant`: sets NDWI as a constant 
    
  - `NDWI_forcing`: sets land.states.NDWI from forcing 
    
  
- `NIRv`: Near-infrared reflectance of terrestrial vegetation 
  - `NIRv_constant`: sets NIRv as a constant 
    
  - `NIRv_forcing`: sets land.states.NIRv from forcing 
    
  
- `PET`: Set/get potential evapotranspiration 
  - `PET_Lu2005`: Calculates land.fluxes.PET from the forcing variables 
    
  - `PET_PriestleyTaylor1972`: Calculates land.fluxes.PET from the forcing variables 
    
  - `PET_forcing`: sets land.fluxes.PET from the forcing 
    
  
- `PFT`: Vegetation PFT 
  - `PFT_constant`: sets a uniform PFT class 
    
  
- `WUE`: Estimate wue 
  - `WUE_Medlyn2011`: calculates the WUE/AOE ci/ca as a function of daytime mean VPD. calculates the WUE/AOE ci/ca as a function of daytime mean VPD &amp; ambient co2 
    
  - `WUE_VPDDay`: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD 
    
  - `WUE_VPDDayCo2`: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD 
    
  - `WUE_constant`: calculates the WUE/AOE as a constant in space &amp; time 
    
  - `WUE_expVPDDayCo2`: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD 
    
  
- `ambientCO2`: sets/gets ambient CO2 concentration 
  - `ambientCO2_constant`: sets ambient_CO2 to a constant value 
    
  - `ambientCO2_forcing`: sets ambient_CO2 from forcing 
    
  
- `autoRespiration`: estimates autotrophic respiration for growth and maintenance 
  - `autoRespiration_Thornley2000A`: estimates autotrophic respiration as maintenance + growth respiration according to Thornley &amp; Cannell [2000]: MODEL A - maintenance respiration is given priority. 
    
  - `autoRespiration_Thornley2000B`: estimates autotrophic respiration as maintenance + growth respiration according to Thornley &amp; Cannell [2000]: MODEL B - growth respiration is given priority. 
    
  - `autoRespiration_Thornley2000C`: estimates autotrophic respiration as maintenance + growth respiration according to Thornley &amp; Cannell [2000]: MODEL C - growth, degradation &amp; resynthesis view of respiration. Computes the km [maintenance [respiration] coefficient]. 
    
  - `autoRespiration_none`: sets the autotrophic respiration flux from all vegetation pools to zero. 
    
  
- `autoRespirationAirT`: temperature effect on autotrophic respiration 
  - `autoRespirationAirT_Q10`: temperature effect on autotrophic maintenance respiration following a Q10 response model 
    
  - `autoRespirationAirT_none`: sets the temperature effect on autotrophic respiration to one (i.e. no effect) 
    
  
- `cAllocation`: Compute the allocation of C fixed by photosynthesis to the different vegetation pools (fraction of the net carbon fixation received by each vegetation carbon pool on every times step). 
  - `cAllocation_Friedlingstein1999`: Compute the fraction of fixed C that is allocated to the different plant organs following the scheme of Friedlingstein et al., 1999 (section `Allocation response to multiple stresses``). 
    
  - `cAllocation_GSI`: Compute the fraction of fixated C that is allocated to the different plant organs. The allocation is dynamic in time according to temperature, water &amp; radiation stressors estimated following the GSI approach. Inspired by the work of Friedlingstein et al., 1999, based on Sharpe and Rykiel 1991, but here following the growing season index (GSI) as stress diagnostics, following Forkel et al 2014 and 2015, based on Jolly et al., 2005. 
    
  - `cAllocation_fixed`: Compute the fraction of net primary production (NPP) allocated to different plant organs with fixed allocation parameters. 
    
  

The allocation is adjusted based on the TreeFrac fraction (land.states.frac_tree).  Root allocation is further divided into fine (cf2Root) and coarse roots (cf2RootCoarse) according to the frac_fine_to_coarse parameter.

```
 -  `cAllocation_none`: sets the carbon allocation to zero (nothing to allocated)
```

- `cAllocationLAI`: Estimates allocation to the leaf pool given light limitation constraints to photosynthesis. Estimation via dynamics in leaf area index (LAI). Dynamic allocation approach. 
  - `cAllocationLAI_Friedlingstein1999`: Estimate the effect of light limitation on carbon allocation via leaf area index (LAI) based on Friedlingstein et al., 1999. 
    
  - `cAllocationLAI_none`: sets the LAI effect on allocation to one (no effect) 
    
  
- `cAllocationNutrients`: (pseudo)effect of nutrients on carbon allocation 
  - `cAllocationNutrients_Friedlingstein1999`: pseudo-nutrient limitation calculation based on Friedlingstein1999 
    
  - `cAllocationNutrients_none`: sets the pseudo-nutrient limitation to one (no effect) 
    
  
- `cAllocationRadiation`: Effect of radiation on carbon allocation 
  - `cAllocationRadiation_GSI`: radiation effect on allocation using GSI method 
    
  - `cAllocationRadiation_RgPot`: radiation effect on allocation using potential radiation instead of actual one 
    
  - `cAllocationRadiation_gpp`: radiation effect on allocation = the same for GPP 
    
  - `cAllocationRadiation_none`: sets the radiation effect on allocation to one (no effect) 
    
  
- `cAllocationSoilT`: Effect of soil temperature on carbon allocation 
  - `cAllocationSoilT_Friedlingstein1999`: partial temperature effect on decomposition/mineralization based on Friedlingstein1999 
    
  - `cAllocationSoilT_gpp`: temperature effect on allocation = the same as gpp 
    
  - `cAllocationSoilT_gppGSI`: temperature effect on allocation from same for GPP based on GSI approach 
    
  - `cAllocationSoilT_none`: sets the temperature effect on allocation to one (no effect) 
    
  
- `cAllocationSoilW`: Effect of soil moisture on carbon allocation 
  - `cAllocationSoilW_Friedlingstein1999`: partial moisture effect on decomposition/mineralization based on Friedlingstein1999 
    
  - `cAllocationSoilW_gpp`: moisture effect on allocation = the same as gpp 
    
  - `cAllocationSoilW_gppGSI`: moisture effect on allocation from same for GPP based on GSI approach 
    
  - `cAllocationSoilW_none`: sets the moisture effect on allocation to one (no effect) 
    
  
- `cAllocationTreeFraction`: Adjustment of carbon allocation according to tree cover 
  - `cAllocationTreeFraction_Friedlingstein1999`: adjust the allocation coefficients according to the fraction of trees to herbaceous &amp; fine to coarse root partitioning 
    
  
- `cBiomass`: Compute aboveground_biomass 
  - `cBiomass_simple`: calculates aboveground biomass as a sum of wood and leaf carbon pools. 
    
  - `cBiomass_treeGrass`: This serves the in situ optimization of eddy covariance sites when using AGB as a constraint. In locations where tree cover is not zero, AGB = leaf + wood. In locations where is only grass, there are no observational constraints for AGB. AGB from EO mostly refers to forested locations. To ensure that the parameter set that emerges from optimization does not generate wood, while not assuming any prior on mass of leafs, the aboveground biomass of grasses is set to the wood value, that will be constrained against a pseudo-observational value close to 0. One expects that after optimization, cVegWood_sum will be close to 0 in locations where frac_tree = 0. 
    
  - `cBiomass_treeGrass_cVegReserveScaling`: same as treeGrass, but includes scaling for relative fraction of cVegReserve pool 
    
  
- `cCycle`: Allocate carbon to vegetation components 
  - `cCycle_CASA`: Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools 
    
  - `cCycle_GSI`: Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools 
    
  - `cCycle_simple`: Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools 
    
  
- `cCycleBase`: Pool structure of the carbon cycle 
  - `cCycleBase_CASA`: Compute carbon to nitrogen ratio &amp; base turnover rates 
    
  - `cCycleBase_GSI`: sets the basics for carbon cycle in the GSI approach 
    
  - `cCycleBase_GSI_PlantForm`: sets the basics for carbon cycle  pools as in the GSI, but allows for scaling of turnover parameters based on plant forms 
    
  - `cCycleBase_GSI_PlantForm_LargeKReserve`: same as cCycleBase_GSI_PlantForm but with a larger turnover of reserve so that it respires and flows 
    
  - `cCycleBase_simple`: Compute carbon to nitrogen ratio &amp; annual turnover rates 
    
  
- `cCycleConsistency`: Consistency checks on the c allocation and transfers between pools 
  - `cCycleConsistency_simple`: check consistency in cCycle vector: c_allocation; cFlow 
    
  
- `cCycleDisturbance`: Disturb the carbon cycle pools 
  - `cCycleDisturbance_WROASTED`: move all vegetation carbon pools except reserve to respective flow target when there is disturbance 
    
  - `cCycleDisturbance_cFlow`: move all vegetation carbon pools except reserve to respective flow target when there is disturbance 
    
  
- `cFlow`: Actual transfers of c between pools (of diagonal components) 
  - `cFlow_CASA`: combine all the effects that change the transfers between carbon pools 
    
  - `cFlow_GSI`: compute the flow rates between the different pools. The flow rates are based on the GSI approach. The flow rates are computed based on the stressors (soil moisture, temperature, and light) and the slope of the stressors. The flow rates are computed for the following pools: leaf, root, reserve, and litter. The flow rates are computed for the following processes: leaf to reserve, root to reserve, reserve to leaf, reserve to root, shedding from leaf, and shedding from root. 
    
  - `cFlow_none`: set transfer between pools to 0 [i.e. nothing is transfered] set c_giver &amp; c_taker matrices to [] get the transfer matrix transfers 
    
  - `cFlow_simple`: combine all the effects that change the transfers between carbon pools 
    
  
- `cFlowSoilProperties`: Effect of soil properties on the c transfers between pools 
  - `cFlowSoilProperties_CASA`: effects of soil that change the transfers between carbon pools 
    
  - `cFlowSoilProperties_none`: set transfer between pools to 0 [i.e. nothing is transfered] 
    
  
- `cFlowVegProperties`: Effect of vegetation properties on the c transfers between pools 
  - `cFlowVegProperties_CASA`: effects of vegetation that change the transfers between carbon pools 
    
  - `cFlowVegProperties_none`: set transfer between pools to 0 [i.e. nothing is transfered] 
    
  
- `cTau`: Combine effects of different factors on decomposition rates 
  - `cTau_mult`: multiply all effects that change the turnover rates [k] 
    
  - `cTau_none`: set the actual τ to ones 
    
  
- `cTauLAI`: Calculate litterfall scalars (that affect the changes in the vegetation k) 
  - `cTauLAI_CASA`: calc LAI stressor on τ. Compute the seasonal cycle of litter fall &amp; root litterfall based on LAI variations. Necessarily in precomputation mode 
    
  - `cTauLAI_none`: set values to ones 
    
  
- `cTauSoilProperties`: Effect of soil texture on soil decomposition rates 
  - `cTauSoilProperties_CASA`: Compute soil texture effects on turnover rates [k] of cMicSoil 
    
  - `cTauSoilProperties_none`: Set soil texture effects to ones (ineficient, should be pix zix_mic) 
    
  
- `cTauSoilT`: Effect of soil temperature on decomposition rates 
  - `cTauSoilT_Q10`: Compute effect of temperature on psoil carbon fluxes 
    
  - `cTauSoilT_none`: set the outputs to ones 
    
  
- `cTauSoilW`: Effect of soil moisture on decomposition rates 
  - `cTauSoilW_CASA`: Compute effect of soil moisture on soil decomposition as modelled in CASA [BGME - below grounf moisture effect]. The below ground moisture effect; taken directly from the century model; uses soil moisture from the previous month to determine a scalar that is then used to determine the moisture effect on below ground carbon fluxes. BGME is dependent on PET; Rainfall. This approach is designed to work for Rainfall &amp; PET values at the monthly time step &amp; it is necessary to scale it to meet that criterion. 
    
  - `cTauSoilW_GSI`: calculate the moisture stress for cTau based on temperature stressor function of CASA &amp; Potter 
    
  - `cTauSoilW_none`: set the moisture stress for all carbon pools to ones 
    
  
- `cTauVegProperties`: Effect of vegetation properties on soil decomposition rates 
  - `cTauVegProperties_CASA`: Compute effect of vegetation type on turnover rates [k] 
    
  - `cTauVegProperties_none`: set the outputs to ones 
    
  
- `cVegetationDieOff`: Disturb the carbon cycle pools 
  - `cVegetationDieOff_forcing`: reads and passes along to the land diagnostics the fraction of vegetation pools that die off  
    
  
- `capillaryFlow`: Flux of water from lower to upper soil layers (upward soil moisture movement) 
  - `capillaryFlow_VanDijk2010`: computes the upward water flow in the soil layers 
    
  
- `constants`: define the constants/variables that are independent of model structure 
  - `constants_numbers`: constants of numbers such as 1 to 10 
    
  
- `deriveVariables`: Derive extra variables 
  - `deriveVariables_simple`: derives variables from other sindbad models and saves them into land.deriveVariables 
    
  
- `drainage`: Recharge the soil 
  - `drainage_dos`: downward flow of moisture [drainage] in soil layers based on exponential function of soil moisture degree of saturation 
    
  - `drainage_kUnsat`: downward flow of moisture [drainage] in soil layers based on unsaturated hydraulic conductivity 
    
  - `drainage_wFC`: downward flow of moisture [drainage] in soil layers based on overflow over field capacity 
    
  
- `evaporation`: Soil evaporation 
  - `evaporation_Snyder2000`: calculates the bare soil evaporation using relative drying rate of soil 
    
  - `evaporation_bareFraction`: calculates the bare soil evaporation from 1-frac_vegetation of the grid &amp; PET_evaporation 
    
  - `evaporation_demandSupply`: calculates the bare soil evaporation from demand-supply limited approach.  
    
  - `evaporation_fAPAR`: calculates the bare soil evaporation from 1-fAPAR &amp; PET soil 
    
  - `evaporation_none`: sets the soil evaporation to zero 
    
  - `evaporation_vegFraction`: calculates the bare soil evaporation from 1-frac_vegetation &amp; PET soil 
    
  
- `evapotranspiration`: Calculate the evapotranspiration as a sum of components 
  - `evapotranspiration_sum`: calculates evapotranspiration as a sum of all potential components 
    
  
- `fAPAR`: Fraction of absorbed photosynthetically active radiation 
  - `fAPAR_EVI`: calculates fAPAR as a linear function of EVI 
    
  - `fAPAR_LAI`: sets fAPAR as a function of LAI 
    
  - `fAPAR_cVegLeaf`: Compute FAPAR based on carbon pool of the leave; SLA; kLAI 
    
  - `fAPAR_cVegLeafBareFrac`: Compute FAPAR based on carbon pool of the leaf, but only for the vegetation fraction 
    
  - `fAPAR_constant`: sets fAPAR as a constant 
    
  - `fAPAR_forcing`: sets land.states.fAPAR from forcing 
    
  - `fAPAR_vegFraction`: sets fAPAR as a linear function of vegetation fraction 
    
  
- `getPools`: Get the amount of water at the beginning of timestep 
  - `getPools_simple`: gets the amount of water available for the current time step 
    
  
- `gpp`: Combine effects as multiplicative or minimum; if coupled, uses transup 
  - `gpp_coupled`: calculate GPP based on transpiration supply &amp; water use efficiency [coupled] 
    
  - `gpp_min`: compute the actual GPP with potential scaled by minimum stress scalar of demand &amp; supply for uncoupled model structure [no coupling with transpiration] 
    
  - `gpp_mult`: compute the actual GPP with potential scaled by multiplicative stress scalar of demand &amp; supply for uncoupled model structure [no coupling with transpiration] 
    
  - `gpp_none`: sets the actual GPP to zero 
    
  - `gpp_transpirationWUE`: calculate GPP based on transpiration &amp; water use efficiency 
    
  
- `gppAirT`: Effect of temperature 
  - `gppAirT_CASA`: temperature stress for gpp_potential based on CASA &amp; Potter 
    
  - `gppAirT_GSI`: temperature stress on gpp_potential based on GSI implementation of LPJ 
    
  - `gppAirT_MOD17`: temperature stress on gpp_potential based on GPP - MOD17 model 
    
  - `gppAirT_Maekelae2008`: temperature stress on gpp_potential based on Maekelae2008 [eqn 3 &amp; 4] 
    
  - `gppAirT_TEM`: temperature stress for gpp_potential based on TEM 
    
  - `gppAirT_Wang2014`: temperature stress on gpp_potential based on Wang2014 
    
  - `gppAirT_none`: sets the temperature stress on gpp_potential to one (no stress) 
    
  
- `gppDemand`: Combine effects as multiplicative or minimum 
  - `gppDemand_min`: compute the demand GPP as minimum of all stress scalars [most limited] 
    
  - `gppDemand_mult`: compute the demand GPP as multipicative stress scalars 
    
  - `gppDemand_none`: sets the scalar for demand GPP to ones &amp; demand GPP to zero 
    
  
- `gppDiffRadiation`: Effect of diffuse radiation 
  - `gppDiffRadiation_GSI`: cloudiness scalar [radiation diffusion] on gpp_potential based on GSI implementation of LPJ 
    
  - `gppDiffRadiation_Turner2006`: cloudiness scalar [radiation diffusion] on gpp_potential based on Turner2006 
    
  - `gppDiffRadiation_Wang2015`: cloudiness scalar [radiation diffusion] on gpp_potential based on Wang2015 
    
  - `gppDiffRadiation_none`: sets the cloudiness scalar [radiation diffusion] for gpp_potential to one 
    
  
- `gppDirRadiation`: Effect of direct radiation 
  - `gppDirRadiation_Maekelae2008`: light saturation scalar [light effect] on gpp_potential based on Maekelae2008 
    
  - `gppDirRadiation_none`: sets the light saturation scalar [light effect] on gpp_potential to one 
    
  
- `gppPotential`: Maximum instantaneous radiation use efficiency 
  - `gppPotential_Monteith`: set the potential GPP based on radiation use efficiency 
    
  
- `gppSoilW`: soil moisture stress on GPP 
  - `gppSoilW_CASA`: soil moisture stress on gpp_potential based on base stress and relative ratio of PET and PAW (CASA) 
    
  - `gppSoilW_GSI`: soil moisture stress on gpp_potential based on GSI implementation of LPJ 
    
  - `gppSoilW_Keenan2009`: soil moisture stress on gpp_potential based on Keenan2009 
    
  - `gppSoilW_Stocker2020`: soil moisture stress on gpp_potential based on Stocker2020 
    
  - `gppSoilW_none`: sets the soil moisture stress on gpp_potential to one (no stress) 
    
  
- `gppVPD`: Vpd effect 
  - `gppVPD_MOD17`: VPD stress on gpp_potential based on MOD17 model 
    
  - `gppVPD_Maekelae2008`: calculate the VPD stress on gpp_potential based on Maekelae2008 [eqn 5] 
    
  - `gppVPD_PRELES`: VPD stress on gpp_potential based on Maekelae2008 and with co2 effect based on PRELES model 
    
  - `gppVPD_expco2`: VPD stress on gpp_potential based on Maekelae2008 and with co2 effect 
    
  - `gppVPD_none`: sets the VPD stress on gpp_potential to one (no stress) 
    
  
- `groundWRecharge`: Recharge to the groundwater storage 
  - `groundWRecharge_dos`: GW recharge as a exponential functions of the degree of saturation of the lowermost soil layer 
    
  - `groundWRecharge_fraction`: GW recharge as a fraction of moisture of the lowermost soil layer 
    
  - `groundWRecharge_kUnsat`: GW recharge as the unsaturated hydraulic conductivity of the lowermost soil layer 
    
  - `groundWRecharge_none`: sets the GW recharge to zero 
    
  
- `groundWSoilWInteraction`: Groundwater soil moisture interactions (e.g. capilary flux, water 
  - `groundWSoilWInteraction_VanDijk2010`: calculates the upward flow of water from groundwater to lowermost soil layer using VanDijk method 
    
  - `groundWSoilWInteraction_gradient`: calculates a buffer storage that gives water to the soil when the soil dries up; while the soil gives water to the buffer when the soil is wet but the buffer low 
    
  - `groundWSoilWInteraction_gradientNeg`: calculates a buffer storage that doesn&#39;t give water to the soil when the soil dries up; while the soil gives water to the groundW when the soil is wet but the groundW low; the groundW is only recharged by soil moisture 
    
  - `groundWSoilWInteraction_none`: sets the groundwater capillary flux to zero 
    
  
- `groundWSurfaceWInteraction`: Water exchange between surface and groundwater 
  - `groundWSurfaceWInteraction_fracGradient`: calculates the moisture exchange between groundwater &amp; surface water as a fraction of difference between the storages 
    
  - `groundWSurfaceWInteraction_fracGroundW`: calculates the depletion of groundwater to the surface water as a fraction of groundwater storage 
    
  
- `interception`: Interception evaporation 
  - `interception_Miralles2010`: computes canopy interception evaporation according to the Gash model 
    
  - `interception_fAPAR`: computes canopy interception evaporation as a fraction of fAPAR 
    
  - `interception_none`: sets the interception evaporation to zero 
    
  - `interception_vegFraction`: computes canopy interception evaporation as a fraction of vegetation cover 
    
  
- `percolation`: Calculate the soil percolation = wbp at this point 
  - `percolation_WBP`: computes the percolation into the soil after the surface runoff process 
    
  
- `plantForm`: define the plant form of the ecosystem 
  - `plantForm_PFT`: get the plant form based on PFT 
    
  - `plantForm_fixed`: use a fixed plant form with 1: tree, 2: shrub, 3:herb 
    
  
- `rainIntensity`: Set rainfall intensity 
  - `rainIntensity_forcing`: stores the time series of rainfall &amp; snowfall from forcing 
    
  - `rainIntensity_simple`: stores the time series of rainfall intensity 
    
  
- `rainSnow`: Set/get rain and snow 
  - `rainSnow_Tair`: separates the rain &amp; snow based on temperature threshold 
    
  - `rainSnow_forcing`: stores the time series of rainfall and snowfall from forcing &amp; scale snowfall if snowfall_scalar parameter is optimized 
    
  - `rainSnow_rain`: set all precip to rain 
    
  
- `rootMaximumDepth`: Maximum rooting depth 
  - `rootMaximumDepth_fracSoilD`: sets the maximum rooting depth as a fraction of total soil depth. rootMaximumDepth_fracSoilD 
    
  
- `rootWaterEfficiency`: Distribution of water uptake fraction/efficiency by root per soil layer 
  - `rootWaterEfficiency_constant`: sets the maximum fraction of water that root can uptake from soil layers as constant 
    
  - `rootWaterEfficiency_expCvegRoot`: maximum root water fraction that plants can uptake from soil layers according to total carbon in root [cVegRoot]. sets the maximum fraction of water that root can uptake from soil layers according to total carbon in root [cVegRoot] 
    
  - `rootWaterEfficiency_k2Layer`: sets the maximum fraction of water that root can uptake from soil layers as calibration parameter; hard coded for 2 soil layers 
    
  - `rootWaterEfficiency_k2fRD`: sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction; &amp; for the second soil layer additional as function of RD 
    
  - `rootWaterEfficiency_k2fvegFraction`: sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction 
    
  
- `rootWaterUptake`: Root water uptake (extract water from soil) 
  - `rootWaterUptake_proportion`: rootUptake from each soil layer proportional to the relative plant water availability in the layer 
    
  - `rootWaterUptake_topBottom`: rootUptake from each of the soil layer from top to bottom using all water in each layer 
    
  
- `runoff`: Calculate the total runoff as a sum of components 
  - `runoff_sum`: calculates runoff as a sum of all potential components 
    
  
- `runoffBase`: Baseflow 
  - `runoffBase_Zhang2008`: computes baseflow from a linear ground water storage 
    
  - `runoffBase_none`: sets the base runoff to zero 
    
  
- `runoffInfiltrationExcess`: Infiltration excess runoff 
  - `runoffInfiltrationExcess_Jung`: infiltration excess runoff as a function of rainintensity and vegetated fraction 
    
  - `runoffInfiltrationExcess_kUnsat`: infiltration excess runoff based on unsaτurated hydraulic conductivity 
    
  - `runoffInfiltrationExcess_none`: sets infiltration excess runoff to zero 
    
  
- `runoffInterflow`: Interflow 
  - `runoffInterflow_none`: sets interflow runoff to zero 
    
  - `runoffInterflow_residual`: interflow as a fraction of the available water balance pool 
    
  
- `runoffOverland`: calculates total overland runoff that passes to the surface storage 
  - `runoffOverland_Inf`: ## assumes overland flow to be infiltration excess runoff 
    
  - `runoffOverland_InfIntSat`: assumes overland flow to be sum of infiltration excess, interflow, and saturation excess runoffs 
    
  - `runoffOverland_Sat`: assumes overland flow to be saturation excess runoff 
    
  - `runoffOverland_none`: sets overland runoff to zero 
    
  
- `runoffSaturationExcess`: Saturation runoff 
  - `runoffSaturationExcess_Bergstroem1992`: saturation excess runoff using original Bergström method 
    
  - `runoffSaturationExcess_Bergstroem1992MixedVegFraction`: saturation excess runoff using Bergström method with separate berg parameters for vegetated and non-vegetated fractions 
    
  - `runoffSaturationExcess_Bergstroem1992VegFraction`: saturation excess runoff using Bergström method with parameter scaled by vegetation fraction 
    
  - `runoffSaturationExcess_Bergstroem1992VegFractionFroSoil`: saturation excess runoff using Bergström method with parameter scaled by vegetation fraction and frozen soil fraction 
    
  - `runoffSaturationExcess_Bergstroem1992VegFractionPFT`: saturation excess runoff using Bergström method with parameter scaled by vegetation fraction and PFT 
    
  - `runoffSaturationExcess_Zhang2008`: saturation excess runoff as a function of incoming water and PET 
    
  - `runoffSaturationExcess_none`: set the saturation excess runoff to zero 
    
  - `runoffSaturationExcess_satFraction`: saturation excess runoff as a fraction of saturated fraction of land 
    
  
- `runoffSurface`: Surface runoff generation process 
  - `runoffSurface_Orth2013`: calculates the delay coefficient of first 60 days as a precomputation. calculates the base runoff 
    
  - `runoffSurface_Trautmann2018`: calculates the delay coefficient of first 60 days as a precomputation based on Orth et al. 2013 &amp; as it is used in Trautmannet al. 2018. calculates the base runoff based on Orth et al. 2013 &amp; as it is used in Trautmannet al. 2018 
    
  - `runoffSurface_all`: assumes all overland runoff is lost as surface runoff 
    
  - `runoffSurface_directIndirect`: assumes surface runoff is the sum of direct fraction of overland runoff and indirect fraction of surface water storage 
    
  - `runoffSurface_directIndirectFroSoil`: assumes surface runoff is the sum of direct fraction of overland runoff and indirect fraction of surface water storage. Direct fraction is additionally dependent on frozen fraction of the grid 
    
  - `runoffSurface_indirect`: assumes all overland runoff is recharged to surface water first, which then generates surface runoff 
    
  - `runoffSurface_none`: sets surface runoff [surface_runoff] from the storage to zero 
    
  
- `saturatedFraction`: Saturated fraction of a grid cell 
  - `saturatedFraction_none`: sets the land.states.soilWSatFrac [saturated soil fraction] to zero 
    
  
- `snowFraction`: Calculate snow cover fraction 
  - `snowFraction_HTESSEL`: computes the snow pack &amp; fraction of snow cover following the HTESSEL approach 
    
  - `snowFraction_binary`: compute the fraction of snow cover. 
    
  - `snowFraction_none`: sets the snow fraction to zero 
    
  
- `snowMelt`: Calculate snowmelt and update s.w.wsnow 
  - `snowMelt_Tair`: computes the snow melt term as function of air temperature 
    
  - `snowMelt_TairRn`: instantiate the potential snow melt based on temperature &amp; net radiation on days with f_airT &gt; 0.0°C. instantiate the potential snow melt based on temperature &amp; net radiation on days with f_airT &gt; 0.0 °C 
    
  
- `soilProperties`: Soil properties (hydraulic properties) 
  - `soilProperties_Saxton1986`: assigns the soil hydraulic properties based on Saxton; 1986 
    
  - `soilProperties_Saxton2006`: assigns the soil hydraulic properties based on Saxton; 2006 to land.soilProperties.sp_ 
    
  
- `soilTexture`: Soil texture (sand,silt,clay, and organic matter fraction) 
  - `soilTexture_constant`: sets the soil texture properties as constant 
    
  - `soilTexture_forcing`: sets the soil texture properties from input 
    
  
- `soilWBase`: Distribution of soil hydraulic properties over depth 
  - `soilWBase_smax1Layer`: defines the maximum soil water content of 1 soil layer as fraction of the soil depth defined in the model_structure.json based on the TWS model for the Northern Hemisphere 
    
  - `soilWBase_smax2Layer`: defines the maximum soil water content of 2 soil layers as fraction of the soil depth defined in the model_structure.json based on the older version of the Pre-Tokyo Model 
    
  - `soilWBase_smax2fRD4`: defines the maximum soil water content of 2 soil layers the first layer is a fraction [i.e. 1] of the soil depth the second layer is a linear combination of scaled rooting depth data from forcing 
    
  - `soilWBase_uniform`: distributes the soil hydraulic properties for different soil layers assuming an uniform vertical distribution of all soil properties 
    
  
- `sublimation`: Calculate sublimation and update snow water equivalent 
  - `sublimation_GLEAM`: instantiates the Priestley-Taylor term for sublimation following GLEAM. computes sublimation following GLEAM 
    
  - `sublimation_none`: sets the snow sublimation to zero 
    
  
- `transpiration`: calclulate the actual transpiration 
  - `transpiration_coupled`: calculate the actual transpiration as function of gpp &amp; WUE 
    
  - `transpiration_demandSupply`: calculate the actual transpiration as the minimum of the supply &amp; demand 
    
  - `transpiration_none`: sets the actual transpiration to zero 
    
  
- `transpirationDemand`: Demand-driven transpiration 
  - `transpirationDemand_CASA`: calculate the supply limited transpiration as function of volumetric soil content &amp; soil properties; as in the CASA model 
    
  - `transpirationDemand_PET`: calculate the climate driven demand for transpiration as a function of PET &amp; α for vegetation 
    
  - `transpirationDemand_PETfAPAR`: calculate the climate driven demand for transpiration as a function of PET &amp; fAPAR 
    
  - `transpirationDemand_PETvegFraction`: calculate the climate driven demand for transpiration as a function of PET &amp; α for vegetation; &amp; vegetation fraction 
    
  
- `transpirationSupply`: Supply-limited transpiration 
  - `transpirationSupply_CASA`: calculate the supply limited transpiration as function of volumetric soil content &amp; soil properties; as in the CASA model 
    
  - `transpirationSupply_Federer1982`: calculate the supply limited transpiration as a function of max rate parameter &amp; avaialable water 
    
  - `transpirationSupply_wAWC`: calculate the supply limited transpiration as the minimum of fraction of total AWC &amp; the actual available moisture 
    
  - `transpirationSupply_wAWCvegFraction`: calculate the supply limited transpiration as the minimum of fraction of total AWC &amp; the actual available moisture; scaled by vegetated fractions 
    
  
- `treeFraction`: Fractional coverage of trees 
  - `treeFraction_constant`: sets frac_tree as a constant 
    
  - `treeFraction_forcing`: sets land.states.frac_tree from forcing 
    
  
- `vegAvailableWater`: Plant available water 
  - `vegAvailableWater_rootWaterEfficiency`: sets the maximum fraction of water that root can uptake from soil layers as constant. calculate the actual amount of water that is available for plants 
    
  - `vegAvailableWater_sigmoid`: calculate the actual amount of water that is available for plants 
    
  
- `vegFraction`: Fractional coverage of vegetation 
  - `vegFraction_constant`: sets frac_vegetation as a constant 
    
  - `vegFraction_forcing`: sets land.states.frac_vegetation from forcing 
    
  - `vegFraction_scaledEVI`: sets frac_vegetation by scaling the EVI value 
    
  - `vegFraction_scaledLAI`: sets frac_vegetation by scaling the LAI value 
    
  - `vegFraction_scaledNDVI`: sets frac_vegetation by scaling the NDVI value 
    
  - `vegFraction_scaledNIRv`: sets frac_vegetation by scaling the NIRv value 
    
  - `vegFraction_scaledfAPAR`: sets frac_vegetation by scaling the fAPAR value 
    
  
- `wCycle`: Apply the delta storage changes to storage variables 
  - `wCycle_combined`: computes the algebraic sum of storage and delta storage 
    
  - `wCycle_components`: update the water cycle pools per component 
    
  
- `wCycleBase`: set the basics of the water cycle pools 
  - `wCycleBase_simple`: counts the number of layers in each water storage pools 
    
  
- `waterBalance`: Calculate the water balance 
  - `waterBalance_simple`: check the water balance in every time step 
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.addToEachElem' href='#Sindbad.addToEachElem'><span class="jlbinding">Sindbad.addToEachElem</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
addToEachElem(v::SVector, Δv:Real)
addToEachElem(v::AbstractVector, Δv:Real)
```


add Δv to each element of v when v is a StaticVector or a Vector.

**Arguments**
- `v`: a StaticVector or AbstractVector
  
- `Δv`: the value to be added to each element
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.addToElem' href='#Sindbad.addToElem'><span class="jlbinding">Sindbad.addToElem</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
addToElem(v::SVector, Δv, v_zero, ind::Int)
addToElem(v::AbstractVector, Δv, _, ind::Int)
```


**Arguments**
- `v`: a StaticVector or AbstractVector
  
- `Δv`: the value to be added
  
- `v_zero`: a StaticVector of zeros
  
- `ind::Int`: the index of the element to be added
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.addVec' href='#Sindbad.addVec'><span class="jlbinding">Sindbad.addVec</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
addVec(v::SVector, Δv::SVector)
addVec(v::AbstractVector, Δv::AbstractVector)
```


add Δv to v when v is a StaticVector or a Vector.

**Arguments**
- `v`: a StaticVector or AbstractVector
  
- `Δv`: a StaticVector or AbstractVector
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.checkMissingVarInfo' href='#Sindbad.checkMissingVarInfo'><span class="jlbinding">Sindbad.checkMissingVarInfo</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
checkMissingVarInfo(appr)
```


Check for missing variable information in the SINDBAD variable catalog for a given approach or model.

**Description**

The `checkMissingVarInfo` function identifies variables used in a SINDBAD model or approach that are missing detailed information in the SINDBAD variable catalog. It inspects the inputs and outputs of the model&#39;s methods (`define`, `precompute`, `compute`, `update`) and checks if their metadata (e.g., `long_name`, `description`, `units`) is properly defined. If any information is missing, it provides a warning and displays the missing details.

**Arguments**
- `appr`: The SINDBAD model or approach to check for missing variable information. This can be a specific approach or a model containing multiple approaches.
  
- if no argument is provided, it checks all approaches in the model.
  

**Returns**
- `nothing`: The function does not return a value but prints warnings and missing variable details to the console.
  

**Behavior**
- For a specific approach, it checks the inputs and outputs of the methods (`define`, `precompute`, `compute`, `update`) for missing variable information.
  
- For a model, it recursively checks all sub-approaches for missing variable information.
  
- If a variable is missing metadata, it displays the missing details and provides guidance for adding the variable to the SINDBAD variable catalog.
  

**Example**

```julia
# Check for missing variable information in a specific approach
checkMissingVarInfo(ambientCO2_constant)

# Check for missing variable information in all approaches of a model
checkMissingVarInfo(cCycle)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.clampZeroOne-Tuple{Any}' href='#Sindbad.clampZeroOne-Tuple{Any}'><span class="jlbinding">Sindbad.clampZeroOne</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
clampZeroOne(num)
```


returns max(min(num, 1), 0)

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.cumSum!-Tuple{AbstractVector, AbstractVector}' href='#Sindbad.cumSum!-Tuple{AbstractVector, AbstractVector}'><span class="jlbinding">Sindbad.cumSum!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
cumSum!(i_n::AbstractVector, o_ut::AbstractVector)
```


fill out the output vector with the cumulative sum of elements from input vector

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.defaultVariableInfo' href='#Sindbad.defaultVariableInfo'><span class="jlbinding">Sindbad.defaultVariableInfo</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
defaultVariableInfo(string_key = false)
```


a central helper function to get the default information of a sindbad variable as a dictionary

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.flagLower-Tuple{AbstractMatrix}' href='#Sindbad.flagLower-Tuple{AbstractMatrix}'><span class="jlbinding">Sindbad.flagLower</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
flagLower(A::AbstractMatrix)
```


returns a matrix of same shape as input with 1 for all below diagonal elements and 0 elsewhere

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.flagUpper-Tuple{AbstractMatrix}' href='#Sindbad.flagUpper-Tuple{AbstractMatrix}'><span class="jlbinding">Sindbad.flagUpper</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
flagUpper(A::AbstractMatrix)
```


returns a matrix of same shape as input with 1 for all above diagonal elements and 0 elsewhere

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.generateSindbadApproach-Tuple{Symbol, String, Symbol, String, Int64}' href='#Sindbad.generateSindbadApproach-Tuple{Symbol, String, Symbol, String, Int64}'><span class="jlbinding">Sindbad.generateSindbadApproach</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
generateSindbadApproach(model_name::Symbol, model_purpose::String, appr_name::Symbol, appr_purpose::String, n_parameters::Int; methods=(:define, :precompute, :compute, :update), force_over_write=:none)
```


Generate a SINDBAD model and/or approach with code templates.

**Due to risk of overwriting code, the function only succeeds if y|Y||Yes|Ya, etc., are given in the confirmation prompt. This function only works if the call is copy-pasted into the REPL and not evaluated from a file/line. See the example below for the syntax.**

**Description**

The `generateSindbadApproach` function creates a SINDBAD model and/or approach by generating code templates for their structure, parameters, methods, and documentation. It ensures consistency with the SINDBAD framework and adheres to naming conventions. If the model or approach already exists, it avoids overwriting existing files unless explicitly permitted. The generated code includes placeholders for methods (`define`, `precompute`, `compute`, `update`) and automatically generates docstrings for the model and approach. 

_Note that the newly created approaches are tracked by changes in `tmp_precompile_placeholder.jl` in the Sindbad root. The new models/approaches are automatically included ONLY when REPL is restarted._

**Arguments**
- `model_name`: The name of the SINDBAD model to which the approach belongs.
  
- `model_purpose`: A string describing the purpose of the model.
  
- `appr_name`: The name of the approach to be generated.
  
- `appr_purpose`: A string describing the purpose of the approach.
  
- `n_parameters`: The number of parameters required by the approach.
  
- `methods`: A tuple of method names to include in the approach (default: `(:define, :precompute, :compute, :update)`).
  
- `force_over_write`: A symbol indicating whether to overwrite existing files or types. Options are:
  - `:none` (default): Do not overwrite existing files or types.
    
  - `:model`: Overwrite the model file and type.
    
  - `:approach`: Overwrite the approach file and type.
    
  - `:both`: Overwrite both model and approach files and types.
    
  

**Returns**
- `nothing`: The function generates the required files and writes them to the appropriate directory.
  

**Behavior**
- If the model does not exist, it generates a new model file with the specified `model_name` and `model_purpose`.
  
- If the approach does not exist, it generates a new approach file with the specified `appr_name`, `appr_purpose`, and `n_parameters`.
  
- Ensures that the approach name follows the SINDBAD naming convention (`<model_name>_<approach_name>`).
  
- Prompts the user for confirmation before generating files to avoid accidental overwrites.
  
- Includes placeholders for methods (`define`, `precompute`, `compute`, `update`) and generates a consistent docstring for the approach.
  

**Example**

```julia
# Generate a new SINDBAD approach for an existing model

generateSindbadApproach(:ambientCO2, "Represents ambient CO2 concentration", :constant, "Sets ambient CO2 as a constant", 1)

# Generate a new SINDBAD model and approach

generateSindbadApproach(:newModel, "Represents a new SINDBAD model", :newApproach, "Implements a new approach for the model", 2)

# Generate a SINDBAD model and approach with force_over_write

generateSindbadApproach(:newModel, "Represents a new SINDBAD model", :newApproach, "Implements a new approach for the model", 2; force_over_write=:both) # overwrite both model and approach

generateSindbadApproach(:newModel, "Represents a new SINDBAD model", :newApproach, "Implements a new approach for the model", 2; force_over_write=:approach) # overwrite just approach approach
```


**Notes**
- The function ensures that the generated code adheres to SINDBAD conventions and includes all necessary metadata and documentation.
  
- If the model or approach already exists, the function does not overwrite the files unless explicitly confirmed by the user.
  
- The function provides warnings and prompts to ensure safe file generation and minimize the risk of accidental overwrites.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getFrac-Tuple{Any, Any}' href='#Sindbad.getFrac-Tuple{Any, Any}'><span class="jlbinding">Sindbad.getFrac</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getFrac(num, den)
```


return either a ratio or numerator depending on whether denomitor is a zero

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getInOutModel' href='#Sindbad.getInOutModel'><span class="jlbinding">Sindbad.getInOutModel</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getInOutModel(model::Sindbad.Types.LandEcosystem)
getInOutModel(model::Sindbad.Types.LandEcosystem, model_func::Symbol)
getInOutModel(model::Sindbad.Types.LandEcosystem, model_funcs::Tuple)
```


Parses and retrieves the inputs, outputs, and parameters (I/O/P) of SINDBAD models for specified functions or all functions.

**Arguments:**
- `model::Sindbad.Types.LandEcosystem`: A SINDBAD model instance. If no additional arguments are provided, parses all inputs, outputs, and parameters for all functions of the model.
  
- `model_func::Symbol`: (Optional) A single symbol representing a specific model function to parse (e.g., `:precompute`, `:parameters`, `:compute`).
  
- `model_funcs::Tuple`: (Optional) A tuple of symbols representing multiple model functions to parse (e.g., `(:precompute, :parameters)`).
  

**Returns:**
- An `OrderedDict` containing the parsed inputs, outputs, and parameters for the specified functions or all functions of the model:
  - `:input`: A tuple of input variables for the model function(s).
    
  - `:output`: A tuple of output variables for the model function(s).
    
  - `:approach`: The name of the model or function being parsed.
    
  

**Notes:**
- If `model_func` or `model_funcs` is not provided, the function parses all default SINDBAD model functions (`:parameters`, `:compute`, `:define`, `:precompute`, `:update`).
  
- For each function:
  - Inputs are extracted from lines containing `⇐`, `land.`, or `forcing.`.
    
  - Outputs are extracted from lines containing `⇒`.
    
  - Warnings are issued for unextracted variables from `land` or `forcing` that do not follow the convention of unpacking variables locally using `@unpack_nt`.
    
  
- If `:parameters` is included in `model_funcs`, the function directly retrieves model parameters using `modelParameter`.
  

**Examples:**
1. **Parsing all functions of a model**:
  

```julia
model_io = getInOutModel(my_model)
```

1. **Parsing a specific function of a model**:
  

```julia
compute_io = getInOutModel(my_model, :compute)
```

1. **Parsing multiple functions of a model**:
  

```julia
io_data = getInOutModel(my_model, (:precompute, :parameters))
```

1. **Handling warnings for unextracted variables**:
  - If a variable from `land` or `forcing` is not unpacked using `@unpack_nt`, a warning is issued to encourage better coding practices.
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getInOutModels' href='#Sindbad.getInOutModels'><span class="jlbinding">Sindbad.getInOutModels</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getInOutModels(ind_range::UnitRange{Int64}=1:10000)
getInOutModels(models::Tuple)
getInOutModels(models, model_funcs::Tuple)
getInOutModels(models, model_func::Symbol)
```


Parses and retrieves the inputs, outputs, and parameters (I/O/P) of multiple SINDBAD models with varying levels of specificity.

**Arguments:**
1. **For the first variant**:
  - `ind_range::UnitRange{Int64}`: A range to select models from all possible SINDBAD models (default: `1:10000`).  This can be set to a smaller range (e.g., `1:10`) to parse a subset of models for testing purposes.
    
  
2. **For the second variant**:
  - `models::Tuple`: A tuple of instantiated SINDBAD models. Used when working with specific model instances rather than selecting from all possible models.
    
  
3. **For the third variant**:
  - `models`: A tuple of instantiated SINDBAD models.
    
  - `model_funcs::Tuple`: A tuple of symbols representing model functions to parse (e.g., `(:precompute, :compute)`). Allows parsing multiple specific functions of the provided models.
    
  
4. **For the fourth variant**:
  - `models`: A tuple of instantiated SINDBAD models.
    
  - `model_func::Symbol`: A single symbol specifying one model function to parse (e.g., `:precompute`). Used when only one function&#39;s inputs and outputs need to be analyzed.
    
  

**Returns:**
- An `OrderedDict` containing the parsed inputs, outputs, and parameters for the specified models and functions:
  - Keys represent the model names.
    
  - Values are `OrderedDict`s containing the parsed I/O/P for the specified functions.
    
  

**Notes:**
- **Default Behavior**:
  - If `ind_range` is provided, the function selects models from the global SINDBAD model dictionary using the specified range.
    
  - If `model_funcs` or `model_func` is not provided, the function parses all default SINDBAD model functions (`:parameters`, `:compute`, `:define`, `:precompute`, `:update`).
    
  
- **Input and Output Parsing**:
  - Inputs are extracted from lines containing `⇐`, `land.`, or `forcing.`.
    
  - Outputs are extracted from lines containing `⇒`.
    
  - Warnings are issued for unextracted variables from `land` or `forcing` that do not follow the convention of unpacking variables locally using `@unpack_nt`.
    
  
- **Integration with `getInOutModel`**:
  - This function internally calls `getInOutModel` for each model and function to retrieve the I/O/P details.
    
  

**Examples:**
1. **Parsing all models in a range**:
  

```julia
model_io = getInOutModels(1:10)
```

1. **Parsing specific models**:
  

```julia
model_io = getInOutModels((model1, model2))
```

1. **Parsing specific functions of models**:
  

```julia
model_io = getInOutModels((model1, model2), (:precompute, :compute))
```

1. **Parsing a single function of models**:
  

```julia
model_io = getInOutModels((model1, model2), :compute)
```

1. **Handling warnings for unextracted variables**:
  - If a variable from `land` or `forcing` is not unpacked using `@unpack_nt`, a warning is issued to encourage better coding practices.
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getMethodTypes-Tuple{Any}' href='#Sindbad.getMethodTypes-Tuple{Any}'><span class="jlbinding">Sindbad.getMethodTypes</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getMethodTypes(fn)
```


Retrieve the types of the arguments for all methods of a given function.

**Arguments**
- `fn`: The function for which the method argument types are to be retrieved.
  

**Returns**
- A vector containing the types of the arguments for each method of the function.
  

**Example**

```julia
function example_function(x::Int, y::String) end
function example_function(x::Float64, y::Bool) end

types = getMethodTypes(example_function)
println(types) # Output: [Int64, Float64]
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getSindbadModelOrder-Tuple{Any}' href='#Sindbad.getSindbadModelOrder-Tuple{Any}'><span class="jlbinding">Sindbad.getSindbadModelOrder</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSindbadModelOrder(model_name)
```


helper function to return the default order of a sindbad model

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getSindbadModels-Tuple{}' href='#Sindbad.getSindbadModels-Tuple{}'><span class="jlbinding">Sindbad.getSindbadModels</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSindbadModels()
```


helper function to return a dictionary of sindbad model and approaches

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getTypedModel' href='#Sindbad.getTypedModel'><span class="jlbinding">Sindbad.getTypedModel</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getTypedModel(model::String, model_timestep="day", num_type=Float64)
getTypedModel(model::Symbol, model_timestep="day", num_type=Float64)
```


Get a SINDBAD model and instantiate it with the given datatype.

**Arguments**
- `model::String or Symbol`: A SINDBAD model name.
  
- `model_timestep`: A time step for the model run (default: `"day"`).
  
- `num_type`: A number type to use for model parameters (default: Float64).
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getUniqueVarNames-Tuple{Any}' href='#Sindbad.getUniqueVarNames-Tuple{Any}'><span class="jlbinding">Sindbad.getUniqueVarNames</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getUniqueVarNames(var_pairs)
```


return the list of variable names to be used to write model outputs to a field. - checks if the variable name is duplicated across different fields of SINDBAD land
- uses `field__variablename` in case of duplicates, else uses the actual model variable name
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getUnitConversionForParameter-Tuple{Any, Any}' href='#Sindbad.getUnitConversionForParameter-Tuple{Any, Any}'><span class="jlbinding">Sindbad.getUnitConversionForParameter</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getUnitConversionForParameter(p_timescale, model_timestep)
```


helper/wrapper function to get unit conversion factors for model parameters that are timescale dependent

**Arguments:**
- `p_timescale`: time scale of a SINDBAD model parameter
  
- `model_timestep`: time step of the model run
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getVarFull-Tuple{Any}' href='#Sindbad.getVarFull-Tuple{Any}'><span class="jlbinding">Sindbad.getVarFull</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getVarFull(var_pair)
```


return the variable full name used as the key in the catalog of sindbad_variables from a pair consisting of the field and subfield of SINDBAD land. Convention is `field__subfield` of land

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getVariableInfo' href='#Sindbad.getVariableInfo'><span class="jlbinding">Sindbad.getVariableInfo</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getVariableInfo(vari_b, t_step = day)
```


**Arguments:**
- `vari_b`: a variable name in the form of field__subfield
  
- `t_step`: time step of the variable, default is &quot;day&quot;
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getVariableInfo-2' href='#Sindbad.getVariableInfo-2'><span class="jlbinding">Sindbad.getVariableInfo</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getVariableInfo(vari_b::Symbol, t_step = day)
```


**Arguments:**
- `vari_b`: a variable name
  
- `t_step`: time step of the variable, default is &quot;day&quot;
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getZix' href='#Sindbad.getZix'><span class="jlbinding">Sindbad.getZix</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getZix(dat::SubArray)
getZix(dat::SubArray, zixhelpersPool)
getZix(dat::Array, zixhelpersPool)
getZix(dat::SVector, zixhelpersPool)
```


returns the indices of a view for a subArray

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.isInvalid-Tuple{Any}' href='#Sindbad.isInvalid-Tuple{Any}'><span class="jlbinding">Sindbad.isInvalid</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
isInvalid(_data::Number)
```


Checks if a number is invalid (e.g., `nothing`, `missing`, `NaN`, or `Inf`).

**Arguments:**
- `_data`: The input number.
  

**Returns:**

`true` if the number is invalid, otherwise `false`.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.maxOne-Tuple{Any}' href='#Sindbad.maxOne-Tuple{Any}'><span class="jlbinding">Sindbad.maxOne</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
maxOne(num)
```


returns max(num, 1)

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.maxZero-Tuple{Any}' href='#Sindbad.maxZero-Tuple{Any}'><span class="jlbinding">Sindbad.maxZero</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
maxZero(num)
```


returns max(num, 0)

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.minOne-Tuple{Any}' href='#Sindbad.minOne-Tuple{Any}'><span class="jlbinding">Sindbad.minOne</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
minOne(num)
```


returns min(num, 1)

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.minZero-Tuple{Any}' href='#Sindbad.minZero-Tuple{Any}'><span class="jlbinding">Sindbad.minZero</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
minZero(num)
```


returns min(num, 0)

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.modelParameter' href='#Sindbad.modelParameter'><span class="jlbinding">Sindbad.modelParameter</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
modelParameter(models, model::Symbol)
modelParameter(model::Sindbad.Types.LandEcosystem, show=true)
```


Return and optionally display the current parameters of a given SINDBAD model.

**Arguments**
- `models`: A list/collection of SINDBAD models, required when `model` is a Symbol.
  
- `model::Symbol`: A SINDBAD model name.
  
- `model::Sindbad.Types.LandEcosystem`: A SINDBAD model instance of type LandEcosystem.
  
- `show::Bool`: A flag to print parameters to the screen (default: true).
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.modelParameters-Tuple{Any}' href='#Sindbad.modelParameters-Tuple{Any}'><span class="jlbinding">Sindbad.modelParameters</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
modelParameters(models)
```


shows the current parameters of all given models

**Arguments:**
- `models`: a list/collection of SINDBAD models
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.offDiag-Tuple{AbstractMatrix}' href='#Sindbad.offDiag-Tuple{AbstractMatrix}'><span class="jlbinding">Sindbad.offDiag</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
offDiag(A::AbstractMatrix)
```


returns a vector comprising of off diagonal elements of a matrix

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.offDiagLower-Tuple{AbstractMatrix}' href='#Sindbad.offDiagLower-Tuple{AbstractMatrix}'><span class="jlbinding">Sindbad.offDiagLower</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
offDiagLower(A::AbstractMatrix)
```


returns a vector comprising of below diagonal elements of a matrix

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.offDiagUpper-Tuple{AbstractMatrix}' href='#Sindbad.offDiagUpper-Tuple{AbstractMatrix}'><span class="jlbinding">Sindbad.offDiagUpper</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
offDiagUpper(A::AbstractMatrix)
```


returns a vector comprising of above diagonal elements of a matrix

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.repElem' href='#Sindbad.repElem'><span class="jlbinding">Sindbad.repElem</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
repElem(v::AbstractVector, v_elem, _, _, ind::Int)
repElem(v::SVector, v_elem, v_zero, v_one, ind::Int)
```


**Arguments**
- `v`: a StaticVector or AbstractVector
  
- `v_elem`: the value to be replaced with
  
- `v_zero`: a StaticVector of zeros
  
- `v_one`: a StaticVector of ones
  
- `ind::Int`: the index of the element to be replaced
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.repVec' href='#Sindbad.repVec'><span class="jlbinding">Sindbad.repVec</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
repVec(v::AbstractVector, v_new)
repVec(v::SVector, v_new)
```


replaces the values of a vector with a new value

**Arguments:**
- `v`: an AbstractVector or a StaticVector
  
- `v_new`: a new value to replace the old one
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.setComponentFromMainPool-Union{Tuple{zix}, Tuple{s_comps}, Tuple{s_main}, Tuple{Any, Any, Val{s_main}, Val{s_comps}, Val{zix}}} where {s_main, s_comps, zix}' href='#Sindbad.setComponentFromMainPool-Union{Tuple{zix}, Tuple{s_comps}, Tuple{s_main}, Tuple{Any, Any, Val{s_main}, Val{s_comps}, Val{zix}}} where {s_main, s_comps, zix}'><span class="jlbinding">Sindbad.setComponentFromMainPool</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setComponentFromMainPool(land, helpers, Val{s_main}, Val{s_comps}, Val{zix})
```

- sets the component pools value using the values for the main pool
  
- name are generated using the components in helpers so that the model formulations are not specific for poolnames and are dependent on model structure.json
  

**Arguments:**
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `helpers`: helper NT with necessary objects for model run and type consistencies
  
- `::Val{s_main}`: a NT with names of the main pools
  
- `::Val{s_comps}`: a NT with names of the component pools
  
- `::Val{zix}`: a NT with zix of each pool
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.setComponents-Union{Tuple{zix}, Tuple{s_comps}, Tuple{s_main}, Tuple{Any, Any, Val{s_main}, Val{s_comps}, Val{zix}}} where {s_main, s_comps, zix}' href='#Sindbad.setComponents-Union{Tuple{zix}, Tuple{s_comps}, Tuple{s_main}, Tuple{Any, Any, Val{s_main}, Val{s_comps}, Val{zix}}} where {s_main, s_comps, zix}'><span class="jlbinding">Sindbad.setComponents</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setComponents(land, helpers, Val{s_main}, Val{s_comps}, Val{zix})
```


**Arguments:**
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `helpers`: helper NT with necessary objects for model run and type consistencies
  
- `::Val{s_main}`: a NT with names of the main pools
  
- `::Val{s_comps}`: a NT with names of the component pools
  
- `::Val{zix}`: a NT with zix of each pool
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.setMainFromComponentPool-Union{Tuple{zix}, Tuple{s_comps}, Tuple{s_main}, Tuple{Any, Any, Val{s_main}, Val{s_comps}, Val{zix}}} where {s_main, s_comps, zix}' href='#Sindbad.setMainFromComponentPool-Union{Tuple{zix}, Tuple{s_comps}, Tuple{s_main}, Tuple{Any, Any, Val{s_main}, Val{s_comps}, Val{zix}}} where {s_main, s_comps, zix}'><span class="jlbinding">Sindbad.setMainFromComponentPool</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setMainFromComponentPool(land, helpers, Val{s_main}, Val{s_comps}, Val{zix})
```

- sets the main pool from the values of the component pools
  
- name are generated using the components in helpers so that the model formulations are not specific for poolnames and are dependent on model structure.json
  

**Arguments:**
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
  
- `helpers`: helper NT with necessary objects for model run and type consistencies
  
- `::Val{s_main}`: a NT with names of the main pools
  
- `::Val{s_comps}`: a NT with names of the component pools
  
- `::Val{zix}`: a NT with zix of each pool
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.totalS-Tuple{Any, Any}' href='#Sindbad.totalS-Tuple{Any, Any}'><span class="jlbinding">Sindbad.totalS</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
totalS(s, sΔ)
```


return total storage amount given the storage and the current delta storage without creating an allocation for a temporary array

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.totalS-Tuple{Any}' href='#Sindbad.totalS-Tuple{Any}'><span class="jlbinding">Sindbad.totalS</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
totalS(s)
```


return total storage amount given the storage without creating an allocation for a temporary array

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.whatIs' href='#Sindbad.whatIs'><span class="jlbinding">Sindbad.whatIs</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
whatIs(var_name::String)
whatIs(var_field::String, var_sfield::String)
whatIs(var_field::Symbol, var_sfield::Symbol)
```


A helper function to return the information of a SINDBAD variable

**Arguments:**
- `var_name`: name of the variable
  
- `var_field`: field of the variable
  
- `var_sfield`: subfield of the variable
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.@add_to_elem-Tuple{Expr}' href='#Sindbad.@add_to_elem-Tuple{Expr}'><span class="jlbinding">Sindbad.@add_to_elem</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@add_to_elem
```


macro to add to an element of a vector or a static vector.    

**Example**

```julia
helpers = (; pools =(;
        zeros=(; cOther = 0.0f0,),
        ones = (; cOther = 1.0f0 ))
        )
cOther = [100.0f0, 1.0f0]
# and then add 1.0f0 to the first element of cOther
@add_to_elem 1 ⇒ (cOther, 1, :cOther)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.@pack_nt-Tuple{Any}' href='#Sindbad.@pack_nt-Tuple{Any}'><span class="jlbinding">Sindbad.@pack_nt</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@pack_nt
```


macro to pack variables into a named tuple.

**Example**

```julia
@pack_nt begin
    (a, b) ⇒ land.diagnostics
    (c, d, f) ⇒ land.fluxes
end
# or 
@pack_nt (a, b) ⇒ land.diagnostics
# or 
@pack_nt a ⇒ land.diagnostics
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.@rep_elem-Tuple{Expr}' href='#Sindbad.@rep_elem-Tuple{Expr}'><span class="jlbinding">Sindbad.@rep_elem</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@rep_elem
```


macro to replace an element of a vector or a static vector.

**Example**

```julia
helpers = (; pools =(;
        zeros=(; cOther = 0.0f0,),
        ones = (; cOther = 1.0f0 ))
        )
cOther = [100.0f0, 1.0f0]
# and then replace the first element of cOther with 1.0f0
@rep_elem 1 ⇒ (cOther, 1, :cOther) 
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.@rep_vec-Tuple{Expr}' href='#Sindbad.@rep_vec-Tuple{Expr}'><span class="jlbinding">Sindbad.@rep_vec</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@rep_vec
```


macro to replace a vector or a static vector with a new value.

**Example**

```julia
_vec = [100.0f0, 2.0f0]
# and then replace the vector with 1.0f0
@rep_vec _vec ⇒ 1.0f0
# or with a new vector
@rep_vec _vec ⇒ [3.0f0, 2.0f0]

```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.@unpack_nt-Tuple{Any}' href='#Sindbad.@unpack_nt-Tuple{Any}'><span class="jlbinding">Sindbad.@unpack_nt</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@unpack_nt
```


macro to unpack variables from a named tuple.

**Example**

```julia
@unpack_nt (f1, f2) ⇐ forcing # named tuple
@unpack_nt var1 ⇐ land.diagnostics # named tuple
# or 
@unpack_nt begin
    (f1, f2) ⇐ forcing
    var1 ⇐ land.diagnostics
end
```


</details>


## Internal {#Internal}


<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.checkDisplayVariableDict-Tuple{Any}' href='#Sindbad.checkDisplayVariableDict-Tuple{Any}'><span class="jlbinding">Sindbad.checkDisplayVariableDict</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
checkDisplayVariableDict(var_full)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.displayVariableDict' href='#Sindbad.displayVariableDict'><span class="jlbinding">Sindbad.displayVariableDict</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
displayVariableDict(dk, dv, exist = true)
```


a helper function to display the variable information in a dict form. This also allow for direct pasting when an unknown variable is queried

**Arguments:**
- `dk`: a variable to use as the key
  
- `dv`: a variable to use as the key
  
- `exist`: whether the display is for an entry that exists or not
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.flagOffDiag-Tuple{AbstractMatrix}' href='#Sindbad.flagOffDiag-Tuple{AbstractMatrix}'><span class="jlbinding">Sindbad.flagOffDiag</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
flagOffDiag(A::AbstractMatrix)
```


returns a matrix of same shape as input with 1 for all non diagonal elements

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.generateApproachCode-NTuple{4, Any}' href='#Sindbad.generateApproachCode-NTuple{4, Any}'><span class="jlbinding">Sindbad.generateApproachCode</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
generateApproachCode(model_name, appr_name, appr_purpose, n_parameters; methods=(:define, :precompute, :compute, :update))
```


Generate the code template for a SINDBAD approach. 

**Description**

The `generateApproachCode` function creates a code template for a SINDBAD approach. It defines the structure, parameters, methods, and documentation for the approach, ensuring consistency with the SINDBAD framework. The generated code includes placeholders for methods (`define`, `precompute`, `compute`, `update`) and automatically generates a docstring for the approach.

**Arguments**
- `model_name`: The name of the SINDBAD model to which the approach belongs.
  
- `appr_name`: The name of the approach to be generated.
  
- `appr_purpose`: A string describing the purpose of the approach.
  
- `n_parameters`: The number of parameters required by the approach.
  
- `methods`: A tuple of method names to include in the approach (default: `(:define, :precompute, :compute, :update)`).
  

**Returns**
- A string containing the generated code template for the approach.
  

**Behavior**
- If `n_parameters` is greater than 0, the function generates a parameterized structure for the approach, including default values and metadata for each parameter.
  
- For each method in `methods`, the function generates a placeholder implementation with comments and instructions for customization.
  
- The function also generates a purpose definition and a docstring for the approach, including placeholders for extended help, references, and versioning.
  

**Example**

```julia
# Generate code for an approach with 2 parameters
approach_code = generateApproachCode(:ambientCO2, :ambientCO2_constant, "sets ambient_CO2 as a constant", 2)

println(approach_code)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.generateModelCode-Tuple{Any, Any}' href='#Sindbad.generateModelCode-Tuple{Any, Any}'><span class="jlbinding">Sindbad.generateModelCode</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
generateModelCode(model_name, model_purpose)
```


Generate the code template for a SINDBAD model.

**Description**

The `generateModelCode` function creates a code template for a SINDBAD model. It defines the model&#39;s structure, purpose, and includes all associated approaches. The generated code ensures consistency with the SINDBAD framework and provides a standardized starting point for defining new models.

**Arguments**
- `model_name`: The name of the SINDBAD model to be generated.
  
- `model_purpose`: A string describing the purpose of the model.
  

**Returns**
- A string containing the generated code template for the model.
  

**Behavior**
- Defines the model as an abstract type that inherits from `LandEcosystem`.
  
- Sets the purpose of the model using the `purpose` function.
  
- Includes all approaches associated with the model using the `includeApproaches` function.
  
- Generates a placeholder docstring for the model, including a reference to `$(getModelDocString)`.
  

**Example**

```julia
# Generate code for a SINDBAD model
model_code = generateModelCode(:ambientCO2, "Represents the ambient CO2 concentration in the ecosystem.")

println(model_code)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getFullVariableKey-Tuple{String, String}' href='#Sindbad.getFullVariableKey-Tuple{String, String}'><span class="jlbinding">Sindbad.getFullVariableKey</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getFullVariableKey(var_field::String, var_sfield::String)
```


returns a symbol with `field__subfield` of land to be used as a key for an entry in variable catalog

**Arguments:**
- `var_field`: land field of the variable
  
- `var_sfield`: land subfield of the variable
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getParameterValue-Tuple{Any, Any, Any}' href='#Sindbad.getParameterValue-Tuple{Any, Any, Any}'><span class="jlbinding">Sindbad.getParameterValue</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getParameterValue(model, parameter_name, model_timestep)
```


get a value of a given model parameter with units corrected

**Arguments:**
- `model`: selected model
  
- `parameter_name`: name of the parameter
  
- `model_timestep`: time step of the model run
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getVarField-Tuple{Any}' href='#Sindbad.getVarField-Tuple{Any}'><span class="jlbinding">Sindbad.getVarField</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getVarField(var_pair)
```


return the field name from a pair consisting of the field and subfield of SINDBAD land

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getVarName-Tuple{Any}' href='#Sindbad.getVarName-Tuple{Any}'><span class="jlbinding">Sindbad.getVarName</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getVarName(var_pair)
```


return the model variable name from a pair consisting of the field and subfield of SINDBAD land

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.getVariableCatalogFromLand-Tuple{Any}' href='#Sindbad.getVariableCatalogFromLand-Tuple{Any}'><span class="jlbinding">Sindbad.getVariableCatalogFromLand</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getVariableCatalogFromLand(land)
```


a helper function to tentatively build a default variable catalog by parsing the fields and subfields of land. This is now a legacy function because it is not recommended way to generate a new catalog. The current catalog (sindbad_variables) has finalized entries, and new entries to the catalog should to be added there directly

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.processPackNT-Tuple{Any}' href='#Sindbad.processPackNT-Tuple{Any}'><span class="jlbinding">Sindbad.processPackNT</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
processPackNT(ex)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.processUnpackNT-Tuple{Any}' href='#Sindbad.processUnpackNT-Tuple{Any}'><span class="jlbinding">Sindbad.processUnpackNT</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
processUnpackNT(ex)
```


</details>

