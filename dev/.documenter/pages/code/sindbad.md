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
- `EVI`: Enhanced Vegetation Index 
  - `EVI_constant`: Sets EVI as a constant value. 
    
  - `EVI_forcing`: Gets EVI from forcing data. 
    
  
- `LAI`: Leaf Area Index 
  - `LAI_cVegLeaf`: LAI as a function of cVegLeaf and SLA. 
    
  - `LAI_constant`: sets LAI as a constant value. 
    
  - `LAI_forcing`: Gets LAI from forcing data. 
    
  
- `NDVI`: Normalized Difference Vegetation Index. 
  - `NDVI_constant`: Sets NDVI as a constant value. 
    
  - `NDVI_forcing`: Gets NDVI from forcing data. 
    
  
- `NDWI`: Normalized Difference Water Index. 
  - `NDWI_constant`: Sets NDWI as a constant value. 
    
  - `NDWI_forcing`: Gets NDWI from forcing data. 
    
  
- `NIRv`: Near-infrared reflectance of terrestrial vegetation. 
  - `NIRv_constant`: Sets NIRv as a constant value. 
    
  - `NIRv_forcing`: Gets NIRv from forcing data. 
    
  
- `PET`: Potential evapotranspiration. 
  - `PET_Lu2005`: Calculates PET using Lu et al. (2005) method. 
    
  - `PET_PriestleyTaylor1972`: Calculates PET using Priestley-Taylor (1972) method. 
    
  - `PET_forcing`: Gets PET from forcing data. 
    
  
- `PFT`: Plant Functional Type (PFT) classification. 
  - `PFT_constant`: Sets a uniform PFT class. 
    
  
- `WUE`: Water Use Efficiency (WUE). 
  - `WUE_Medlyn2011`: Calculates WUE as a function of daytime mean VPD and ambient CO₂, following Medlyn et al. (2011). 
    
  - `WUE_VPDDay`: Calculates WUE as a function of WUE at 1 hPa and daily mean VPD. 
    
  - `WUE_VPDDayCo2`: Calculates WUE as a function of WUE at 1 hPa daily mean VPD and linear CO₂ relationship. 
    
  - `WUE_constant`: Sets WUE as a constant value. 
    
  - `WUE_expVPDDayCo2`: Calculates WUE as a function of WUE at 1 hPa, daily mean VPD, and an exponential CO₂ relationship. 
    
  
- `ambientCO2`: Ambient CO₂ concentration. 
  - `ambientCO2_constant`: Sets ambient CO₂ to a constant value. 
    
  - `ambientCO2_forcing`: Gets ambient CO₂ from forcing data. 
    
  
- `autoRespiration`: Autotrophic respiration for growth and maintenance. 
  - `autoRespiration_Thornley2000A`: Calculates autotrophic maintenance and growth respiration using Thornley and Cannell (2000) Model A, where maintenance respiration is prioritized. 
    
  - `autoRespiration_Thornley2000B`: Calculates autotrophic maintenance and growth respiration using Thornley and Cannell (2000) Model B, where growth respiration is prioritized. 
    
  - `autoRespiration_Thornley2000C`: Calculates autotrophic maintenance and growth respiration using Thornley and Cannell (2000) Model C, which includes growth, degradation, and resynthesis. 
    
  - `autoRespiration_none`: Sets autotrophic respiration fluxes to 0. 
    
  
- `autoRespirationAirT`: Effect of air temperature on autotrophic respiration. 
  - `autoRespirationAirT_Q10`: Calculates the effect of air temperature on maintenance respiration using a Q10 function. 
    
  - `autoRespirationAirT_none`: No air temperature effect on autotrophic respiration. 
    
  
- `cAllocation`: Allocation fraction of NPP to different vegetation pools. 
  - `cAllocation_Friedlingstein1999`: Dynamically allocates carbon based on LAI, moisture, and nutrient availability, following Friedlingstein et al. (1999). 
    
  - `cAllocation_GSI`: Dynamically allocates carbon based on temperature, water, and radiation stressors following the GSI approach. 
    
  - `cAllocation_fixed`: Sets carbon allocation to each pool using fixed allocation parameters. 
    
  - `cAllocation_none`: Sets carbon allocation to 0. 
    
  
- `cAllocationLAI`: Estimates allocation to the leaf pool given light limitation constraints to photosynthesis, using LAI dynamics. 
  - `cAllocationLAI_Friedlingstein1999`: Estimates the effect of light limitation on carbon allocation via LAI, based on Friedlingstein et al. (1999). 
    
  - `cAllocationLAI_none`: Sets the LAI effect on allocation to 1 (no effect). 
    
  
- `cAllocationNutrients`: Pseudo-effect of nutrients on carbon allocation. 
  - `cAllocationNutrients_Friedlingstein1999`: Calculates pseudo-nutrient limitation based on Friedlingstein et al. (1999). 
    
  - `cAllocationNutrients_none`: Sets the pseudo-nutrient limitation to 1 (no effect). 
    
  
- `cAllocationRadiation`: Effect of radiation on carbon allocation. 
  - `cAllocationRadiation_GSI`: Calculates the radiation effect on allocation using the GSI method. 
    
  - `cAllocationRadiation_RgPot`: Calculates the radiation effect on allocation using potential radiation instead of actual radiation. 
    
  - `cAllocationRadiation_gpp`: Sets the radiation effect on allocation equal to that for GPP. 
    
  - `cAllocationRadiation_none`: Sets the radiation effect on allocation to 1 (no effect). 
    
  
- `cAllocationSoilT`: Effect of soil temperature on carbon allocation. 
  - `cAllocationSoilT_Friedlingstein1999`: Calculates the partial temperature effect on decomposition and mineralization based on Friedlingstein et al. (1999). 
    
  - `cAllocationSoilT_gpp`: Sets the temperature effect on allocation equal to that for GPP. 
    
  - `cAllocationSoilT_gppGSI`: Calculates the temperature effect on allocation as for GPP using the GSI approach. 
    
  - `cAllocationSoilT_none`: Sets the temperature effect on allocation to 1 (no effect). 
    
  
- `cAllocationSoilW`: Effect of soil moisture on carbon allocation. 
  - `cAllocationSoilW_Friedlingstein1999`: Calculates the partial moisture effect on decomposition and mineralization based on Friedlingstein et al. (1999). 
    
  - `cAllocationSoilW_gpp`: Sets the moisture effect on allocation equal to that for GPP. 
    
  - `cAllocationSoilW_gppGSI`: Calculates the moisture effect on allocation as for GPP using the GSI approach. 
    
  - `cAllocationSoilW_none`: Sets the moisture effect on allocation to 1 (no effect). 
    
  
- `cAllocationTreeFraction`: Adjusts carbon allocation according to tree cover. 
  - `cAllocationTreeFraction_Friedlingstein1999`: Adjusts allocation coefficients according to the fraction of trees to herbaceous plants and fine to coarse root partitioning. 
    
  
- `cBiomass`: Computes aboveground biomass (AGB). 
  - `cBiomass_simple`: Calculates AGB `simply` as the sum of wood and leaf carbon pools. 
    
  - `cBiomass_treeGrass`: Considers the tree-grass fraction to include different vegetation pools while calculating AGB. For Eddy Covariance sites with tree cover, AGB = leaf + wood biomass. For grass-only sites, AGB is set to the wood biomass, which is constrained to be near 0 after optimization. 
    
  - `cBiomass_treeGrass_cVegReserveScaling`: Same as `cBiomass_treeGrass`.jl, but includes scaling for the relative fraction of the reserve carbon to not allow for large reserve compared to the rest of the vegetation carbol pool. 
    
  
- `cCycle`: Compute fluxes and changes (cycling) of carbon pools. 
  - `cCycle_CASA`: Carbon cycle wtih components based on the CASA approach. 
    
  - `cCycle_GSI`: Carbon cycle with components based on the GSI approach, including carbon allocation, transfers, and turnover rates. 
    
  - `cCycle_simple`: Carbon cycle with components based on the simplified version of the CASA approach. 
    
  
- `cCycleBase`: Defines the base properties of the carbon cycle components. For example, components of carbon pools, their turnover rates, and flow matrix. 
  - `cCycleBase_CASA`: Structure and properties of the carbon cycle components used in the CASA approach. 
    
  - `cCycleBase_GSI`: Structure and properties of the carbon cycle components as needed for a dynamic phenology-based carbon cycle in the GSI approach. 
    
  - `cCycleBase_GSI_PlantForm`: Same as GSI, additionally allowing for scaling of turnover parameters based on plant forms. 
    
  - `cCycleBase_GSI_PlantForm_LargeKReserve`: Same as cCycleBase_GSI_PlantForm, but with a default of larger turnover of reserve pool so that it respires and flows. 
    
  - `cCycleBase_simple`: Structure and properties of the carbon cycle components as needed for a simplified version of the CASA approach. 
    
  
- `cCycleConsistency`: Consistency and sanity checks in carbon allocation and transfers. 
  - `cCycleConsistency_simple`: Checks consistency in the cCycle vector, including c_allocation and cFlow. 
    
  
- `cCycleDisturbance`: Disturbance of the carbon cycle pools. 
  - `cCycleDisturbance_WROASTED`: Moves carbon in reserve pool to slow litter pool, and all other carbon pools except reserve pool to their respective carbon flow target pools during disturbance events. 
    
  - `cCycleDisturbance_cFlow`: Moves carbon in all pools except reserve to their respective carbon flow target pools during disturbance events. 
    
  
- `cFlow`: Transfer rates for carbon flow between different pools. 
  - `cFlow_CASA`: Carbon transfer rates between pools as modeled in CASA. 
    
  - `cFlow_GSI`: Carbon transfer rates between pools based on the GSI approach, using stressors such as soil moisture, temperature, and light. 
    
  - `cFlow_none`: Sets carbon transfers between pools to 0 (no transfer); sets c_giver and c_taker matrices to empty; retrieves the transfer matrix. 
    
  - `cFlow_simple`: Carbon transfer rates between pools modeled a simplified version of CASA. 
    
  
- `cFlowSoilProperties`: Effect of soil properties on carbon transfers between pools. 
  - `cFlowSoilProperties_CASA`: Effect of soil properties on carbon transfers between pools as modeled in CASA. 
    
  - `cFlowSoilProperties_none`: Sets carbon transfers between pools to 0 (no transfer). 
    
  
- `cFlowVegProperties`: Effect of vegetation properties on carbon transfers between pools. 
  - `cFlowVegProperties_CASA`: Effect of vegetation properties on carbon transfers between pools as modeled in CASA. 
    
  - `cFlowVegProperties_none`: Sets carbon transfers between pools to 0 (no transfer). 
    
  
- `cTau`: Actual decomposition/turnover rates of all carbon pools considering the effect of stressors. 
  - `cTau_mult`: Combines all effects that change the turnover rates by multiplication. 
    
  - `cTau_none`: Sets the decomposition/turnover rates of all carbon pools to 0, i.e., no carbon decomposition and flow. 
    
  
- `cTauLAI`: Effect of LAI on turnover rates of carbon pools. 
  - `cTauLAI_CASA`: Effect of LAI on turnover rates and computes the seasonal cycle of litterfall and root litterfall based on LAI variations, as modeled in CASA. 
    
  - `cTauLAI_none`: Sets the litterfall scalar values to 1 (no LAI effect). 
    
  
- `cTauSoilProperties`: Effect of soil texture on soil decomposition rates 
  - `cTauSoilProperties_CASA`: Compute soil texture effects on turnover rates [k] of cMicSoil 
    
  - `cTauSoilProperties_none`: Set soil texture effects to ones (ineficient, should be pix zix_mic) 
    
  
- `cTauSoilT`: Effect of soil temperature on decomposition rates. 
  - `cTauSoilT_Q10`: Effect of soil temperature on decomposition rates using a Q10 function. 
    
  - `cTauSoilT_none`: Sets the effect of soil temperature on decomposition rates to 1 (no temperature effect). 
    
  
- `cTauSoilW`: Effect of soil moisture on decomposition rates. 
  - `cTauSoilW_CASA`: Effect of soil moisture on decomposition rates as modeled in CASA, using the belowground moisture effect (BGME) from the Century model. 
    
  - `cTauSoilW_GSI`: Effect of soil moisture on decomposition rates based on the GSI approach. 
    
  - `cTauSoilW_none`: Sets the effect of soil moisture on decomposition rates to 1 (no moisture effect). 
    
  
- `cTauVegProperties`: Effect of vegetation properties on soil decomposition rates. 
  - `cTauVegProperties_CASA`: Effect of vegetation type on decomposition rates as modeled in CASA. 
    
  - `cTauVegProperties_none`: Sets the effect of vegetation properties on decomposition rates to 1 (no vegetation effect). 
    
  
- `cVegetationDieOff`: Fraction of vegetation pools that die off. 
  - `cVegetationDieOff_forcing`: Get the fraction of vegetation that die off from forcing data. 
    
  
- `capillaryFlow`: Capillary flux of water from lower to upper soil layers (upward soil moisture movement). 
  - `capillaryFlow_VanDijk2010`: Computes the upward capillary flux of water through soil layers using the Van Dijk (2010) method. 
    
  
- `constants`: Defines constants and variables that are independent of model structure. 
  - `constants_numbers`: Includes constants for numbers such as 1 to 10. 
    
  
- `deriveVariables`: Derives additional variables based on other SINDBAD models and saves them into land.deriveVariables. 
  - `deriveVariables_simple`: Incudes derivation of few variables that may be commonly needed for optimization against some datasets. 
    
  
- `drainage`: Drainage flux of water from upper to lower soil layers. 
  - `drainage_dos`: Drainage flux based on an exponential function of soil moisture degree of saturation. 
    
  - `drainage_kUnsat`: Drainage flux based on unsaturated hydraulic conductivity. 
    
  - `drainage_wFC`: Drainage flux based on overflow above field capacity. 
    
  
- `evaporation`: Bare soil evaporation. 
  - `evaporation_Snyder2000`: Bare soil evaporation using the relative drying rate of soil following Snyder (2000). 
    
  - `evaporation_bareFraction`: Bare soil evaporation from the non-vegetated fraction of the grid as a linear function of soil moisture and potential evaporation. 
    
  - `evaporation_demandSupply`: Bare soil evaporation using a demand-supply limited approach. 
    
  - `evaporation_fAPAR`: Bare soil evaporation from the non-absorbed fAPAR (as a proxy for vegetation fraction) and potential evaporation. 
    
  - `evaporation_none`: Bare soil evaporation set to 0. 
    
  - `evaporation_vegFraction`: Bare soil evaporation from the non-vegetated fraction and potential evaporation. 
    
  
- `evapotranspiration`: Evapotranspiration. 
  - `evapotranspiration_sum`: Evapotranspiration as a sum of all potential components 
    
  
- `fAPAR`: Fraction of absorbed photosynthetically active radiation. 
  - `fAPAR_EVI`: fAPAR as a linear function of EVI. 
    
  - `fAPAR_LAI`: fAPAR as a function of LAI. 
    
  - `fAPAR_cVegLeaf`: fAPAR based on the carbon pool of leaves, specific leaf area (SLA), and kLAI. 
    
  - `fAPAR_cVegLeafBareFrac`: fAPAR based on the carbon pool of leaves, but only for the vegetated fraction. 
    
  - `fAPAR_constant`: Sets fAPAR as a constant value. 
    
  - `fAPAR_forcing`: Gets fAPAR from forcing data. 
    
  - `fAPAR_vegFraction`: fAPAR as a linear function of vegetation fraction. 
    
  
- `getPools`: Retrieves the amount of water at the beginning of the time step. 
  - `getPools_simple`: Simply take throughfall as the maximum available water. 
    
  
- `gpp`: Gross Primary Productivity (GPP). 
  - `gpp_coupled`: GPP based on transpiration supply and water use efficiency (coupled). 
    
  - `gpp_min`: GPP with potential scaled by the minimum stress scalar of demand and supply for uncoupled model structures. 
    
  - `gpp_mult`: GPP with potential scaled by the product of stress scalars of demand and supply for uncoupled model structures. 
    
  - `gpp_none`: Sets GPP to 0. 
    
  - `gpp_transpirationWUE`: GPP based on transpiration and water use efficiency. 
    
  
- `gppAirT`: Effect of temperature on GPP: 1 indicates no temperature stress, 0 indicates complete stress. 
  - `gppAirT_CASA`: Temperature effect on GPP based as implemented in CASA. 
    
  - `gppAirT_GSI`: Temperature effect on GPP based on the GSI implementation of LPJ. 
    
  - `gppAirT_MOD17`: Temperature effect on GPP based on the MOD17 model. 
    
  - `gppAirT_Maekelae2008`: Temperature effect on GPP based on Maekelae (2008). 
    
  - `gppAirT_TEM`: Temperature effect on GPP based on the TEM model. 
    
  - `gppAirT_Wang2014`: Temperature effect on GPP based on Wang (2014). 
    
  - `gppAirT_none`: Sets temperature stress on GPP to 1 (no stress). 
    
  
- `gppDemand`: Combined effect of environmental demand on GPP. 
  - `gppDemand_min`: Demand GPP as the minimum of all stress scalars (most limiting factor). 
    
  - `gppDemand_mult`: Demand GPP as the product of all stress scalars. 
    
  - `gppDemand_none`: Sets the scalar for demand GPP to 1 and demand GPP to 0. 
    
  
- `gppDiffRadiation`: Effect of diffuse radiation (Cloudiness scalar) on GPP: 1 indicates no diffuse radiation effect, 0 indicates complete effect. 
  - `gppDiffRadiation_GSI`: Cloudiness scalar (radiation diffusion) on GPP potential based on the GSI implementation of LPJ. 
    
  - `gppDiffRadiation_Turner2006`: Cloudiness scalar (radiation diffusion) on GPP potential based on Turner (2006). 
    
  - `gppDiffRadiation_Wang2015`: Cloudiness scalar (radiation diffusion) on GPP potential based on Wang (2015). 
    
  - `gppDiffRadiation_none`: Sets the cloudiness scalar (radiation diffusion) for GPP potential to 1. 
    
  
- `gppDirRadiation`: Effect of direct radiation (light effect) on GPP: 1 indicates no direct radiation effect, 0 indicates complete effect. 
  - `gppDirRadiation_Maekelae2008`: Light saturation scalar (light effect) on GPP potential based on Maekelae (2008). 
    
  - `gppDirRadiation_none`: Sets the light saturation scalar (light effect) on GPP potential to 1. 
    
  
- `gppPotential`: Potential GPP based on maximum instantaneous radiation use efficiency. 
  - `gppPotential_Monteith`: Potential GPP based on radiation use efficiency model/concept of Monteith. 
    
  
- `gppSoilW`: Effect of soil moisture on GPP: 1 indicates no soil water stress, 0 indicates complete stress. 
  - `gppSoilW_CASA`: Soil moisture stress on GPP potential based on base stress and the relative ratio of PET and PAW (CASA). 
    
  - `gppSoilW_GSI`: Soil moisture stress on GPP potential based on the GSI implementation of LPJ. 
    
  - `gppSoilW_Keenan2009`: Soil moisture stress on GPP potential based on Keenan (2009). 
    
  - `gppSoilW_Stocker2020`: Soil moisture stress on GPP potential based on Stocker (2020). 
    
  - `gppSoilW_none`: Sets soil moisture stress on GPP potential to 1 (no stress). 
    
  
- `gppVPD`: Effect of vapor pressure deficit (VPD) on GPP: 1 indicates no VPD stress, 0 indicates complete stress. 
  - `gppVPD_MOD17`: VPD stress on GPP potential based on the MOD17 model. 
    
  - `gppVPD_Maekelae2008`: VPD stress on GPP potential based on Maekelae (2008). 
    
  - `gppVPD_PRELES`: VPD stress on GPP potential based on Maekelae (2008) and includes the CO₂ effect based on the PRELES model. 
    
  - `gppVPD_expco2`: VPD stress on GPP potential based on Maekelae (2008) and includes the CO₂ effect. 
    
  - `gppVPD_none`: Sets VPD stress on GPP potential to 1 (no stress). 
    
  
- `groundWRecharge`: Groundwater recharge. 
  - `groundWRecharge_dos`: Groundwater recharge as an exponential function of the degree of saturation of the lowermost soil layer. 
    
  - `groundWRecharge_fraction`: Groundwater recharge as a fraction of the moisture in the lowermost soil layer. 
    
  - `groundWRecharge_kUnsat`: Groundwater recharge as the unsaturated hydraulic conductivity of the lowermost soil layer. 
    
  - `groundWRecharge_none`: Sets groundwater recharge to 0. 
    
  
- `groundWSoilWInteraction`: Groundwater-soil moisture interactions (e.g., capillary flux, water exchange). 
  - `groundWSoilWInteraction_VanDijk2010`: Upward flow of water from groundwater to the lowermost soil layer using the Van Dijk (2010) method. 
    
  - `groundWSoilWInteraction_gradient`: Delayed/Buffer storage that gives water to the soil when the soil is dry and receives water from the soil when the buffer is low. 
    
  - `groundWSoilWInteraction_gradientNeg`: Delayed/Buffer storage that does not give water to the soil when the soil is dry, but receives water from the soil when the soil is wet and the buffer is low. 
    
  - `groundWSoilWInteraction_none`: Sets groundwater capillary flux to 0 for no interaction between soil moisture and groundwater. 
    
  
- `groundWSurfaceWInteraction`: Water exchange between surface and groundwater. 
  - `groundWSurfaceWInteraction_fracGradient`: Moisture exchange between groundwater and surface water as a fraction of the difference between their storages. 
    
  - `groundWSurfaceWInteraction_fracGroundW`: Depletion of groundwater to surface water as a fraction of groundwater storage. 
    
  
- `interception`: Interception loss. 
  - `interception_Miralles2010`: Interception loss according to the Gash model of Miralles, 2010. 
    
  - `interception_fAPAR`: Interception loss as a fraction of fAPAR. 
    
  - `interception_none`: Sets interception loss to 0. 
    
  - `interception_vegFraction`: Interception loss as a fraction of vegetation cover. 
    
  
- `percolation`: Percolation through the top of soil 
  - `percolation_WBP`: Percolation as a difference of throughfall and surface runoff loss. 
    
  
- `plantForm`: Plant form of the ecosystem. 
  - `plantForm_PFT`: Differentiate plant form based on PFT. 
    
  - `plantForm_fixed`: Sets plant form to a fixed form with 1: tree, 2: shrub, 3:herb. Assumes tree as default. 
    
  
- `rainIntensity`: Rainfall intensity. 
  - `rainIntensity_forcing`: Gets rainfall intensity from forcing data. 
    
  - `rainIntensity_simple`: Rainfall intensity as a linear function of rainfall amount. 
    
  
- `rainSnow`: Rain and snow partitioning. 
  - `rainSnow_Tair`: Rain and snow partitioning based on a temperature threshold. 
    
  - `rainSnow_forcing`: Sets rainfall and snowfall from forcing data, with snowfall scaled if the snowfall_scalar parameter is optimized. 
    
  - `rainSnow_rain`: All precipitation is assumed to be liquid rain with 0 snowfall. 
    
  
- `rootMaximumDepth`: Maximum rooting depth. 
  - `rootMaximumDepth_fracSoilD`: Maximum rooting depth as a fraction of total soil depth. 
    
  
- `rootWaterEfficiency`: Water uptake efficiency by roots for each soil layer. 
  - `rootWaterEfficiency_constant`: Water uptake efficiency by roots set as a constant for each soil layer. 
    
  - `rootWaterEfficiency_expCvegRoot`: Water uptake efficiency by roots set according to total root carbon. 
    
  - `rootWaterEfficiency_k2Layer`: Water uptake efficiency by roots set as a calibration parameter for each soil layer (for two soil layers). 
    
  - `rootWaterEfficiency_k2fRD`: Water uptake efficiency by roots set as a function of vegetation fraction, and for the second soil layer, as a function of rooting depth from different datasets. 
    
  - `rootWaterEfficiency_k2fvegFraction`: Water uptake efficiency by roots set as a function of vegetation fraction, and for the second soil layer, as a function of rooting depth from different datasets, which is further scaled by the vegetation fraction. 
    
  
- `rootWaterUptake`: Root water uptake from soil. 
  - `rootWaterUptake_proportion`: Root uptake from each soil layer proportional to the relative plant water availability in the layer. 
    
  - `rootWaterUptake_topBottom`: Root uptake from each soil layer from top to bottom, using maximul available water in each layer. 
    
  
- `runoff`: Total runoff. 
  - `runoff_sum`: Runoff as a sum of all potential components. 
    
  
- `runoffBase`: Baseflow. 
  - `runoffBase_Zhang2008`: Baseflow from a linear groundwater storage following Zhang (2008). 
    
  - `runoffBase_none`: Sets base runoff to 0. 
    
  
- `runoffInfiltrationExcess`: Infiltration excess runoff. 
  - `runoffInfiltrationExcess_Jung`: Infiltration excess runoff as a function of rain intensity and vegetated fraction. 
    
  - `runoffInfiltrationExcess_kUnsat`: Infiltration excess runoff based on unsaturated hydraulic conductivity. 
    
  - `runoffInfiltrationExcess_none`: Sets infiltration excess runoff to 0. 
    
  
- `runoffInterflow`: Interflow runoff. 
  - `runoffInterflow_none`: Sets interflow runoff to 0. 
    
  - `runoffInterflow_residual`: Interflow as a fraction of the available water balance pool. 
    
  
- `runoffOverland`: Total overland runoff that passes to surface storage. 
  - `runoffOverland_Inf`: Overland flow due to infiltration excess runoff. 
    
  - `runoffOverland_InfIntSat`: Overland flow as the sum of infiltration excess, interflow, and saturation excess runoffs. 
    
  - `runoffOverland_Sat`: Overland flow due to saturation excess runoff. 
    
  - `runoffOverland_none`: Sets overland runoff to 0. 
    
  
- `runoffSaturationExcess`: Saturation excess runoff. 
  - `runoffSaturationExcess_Bergstroem1992`: Saturation excess runoff using the original Bergström method. 
    
  - `runoffSaturationExcess_Bergstroem1992MixedVegFraction`: Saturation excess runoff using the Bergström method with separate parameters for vegetated and non-vegetated fractions. 
    
  - `runoffSaturationExcess_Bergstroem1992VegFraction`: Saturation excess runoff using the Bergström method with parameters scaled by vegetation fraction. 
    
  - `runoffSaturationExcess_Bergstroem1992VegFractionFroSoil`: Saturation excess runoff using the Bergström method with parameters scaled by vegetation fraction and frozen soil fraction. 
    
  - `runoffSaturationExcess_Bergstroem1992VegFractionPFT`: Saturation excess runoff using the Bergström method with parameters scaled by vegetation fraction separated by different PFTs. 
    
  - `runoffSaturationExcess_Zhang2008`: Saturation excess runoff as a function of incoming water and PET following Zhang (2008). 
    
  - `runoffSaturationExcess_none`: Sets saturation excess runoff to 0. 
    
  - `runoffSaturationExcess_satFraction`: Saturation excess runoff as a fraction of the saturated fraction of a grid-cell. 
    
  
- `runoffSurface`: Surface runoff generation. 
  - `runoffSurface_Orth2013`: Surface runoff directly calculated using delay coefficient for the last 60 days based on the Orth et al. (2013) method. 
    
  - `runoffSurface_Trautmann2018`: Surface runoff directly calculated using delay coefficient for the last 60 days based on the Orth et al. (2013) method, but with a different delay coefficient as implemented in Trautmann et al. (2018). 
    
  - `runoffSurface_all`: All overland runoff generates surface runoff. 
    
  - `runoffSurface_directIndirect`: Surface runoff as the sum of the direct fraction of overland runoff and the indirect fraction of surface water storage. 
    
  - `runoffSurface_directIndirectFroSoil`: Surface runoff as the sum of the direct fraction of overland runoff and the indirect fraction of surface water storage, with the direct fraction additionally dependent on the frozen fraction of the grid. 
    
  - `runoffSurface_indirect`: All overland runoff is collected in surface water storage first, which in turn generates indirect surface runoff. 
    
  - `runoffSurface_none`: Sets surface runoff to 0. 
    
  
- `saturatedFraction`: Saturated fraction of a grid-cell. 
  - `saturatedFraction_none`: Sets the saturated soil fraction to 0. 
    
  
- `snowFraction`: Snow cover fraction. 
  - `snowFraction_HTESSEL`: Snow cover fraction following the HTESSEL approach. 
    
  - `snowFraction_binary`: Snow cover fraction using a binary approach. 
    
  - `snowFraction_none`: Sets the snow cover fraction to 0. 
    
  
- `snowMelt`: Snowmelt. 
  - `snowMelt_Tair`: Snowmelt as a function of air temperature. 
    
  - `snowMelt_TairRn`: Snowmelt based on temperature and net radiation when air temperature exceeds 0°C. 
    
  
- `soilProperties`: Soil hydraulic properties. 
  - `soilProperties_Saxton1986`: Soil hydraulic properties based on Saxton (1986). 
    
  - `soilProperties_Saxton2006`: Soil hydraulic properties based on Saxton (2006). 
    
  
- `soilTexture`: Soil texture (sand, silt, clay, and organic matter fraction). 
  - `soilTexture_constant`: Sets soil texture properties as constant values. 
    
  - `soilTexture_forcing`: Gets Soil texture properties from forcing data. 
    
  
- `soilWBase`: Base soil hydraulic properties over soil layers. 
  - `soilWBase_smax1Layer`: Maximum soil water content of one soil layer as a fraction of total soil depth, based on the Trautmann et al. (2018) model. 
    
  - `soilWBase_smax2Layer`: Maximum soil water content of two soil layers as fractions of total soil depth, based on the older version of the Pre-Tokyo Model. 
    
  - `soilWBase_smax2fRD4`: Maximum soil water content of two soil layers: the first layer as a fraction of soil depth, the second as a linear combination of scaled rooting depth data from forcing. 
    
  - `soilWBase_uniform`: Soil hydraulic properties distributed for different soil layers assuming a uniform vertical distribution. 
    
  
- `sublimation`: Snow sublimation. 
  - `sublimation_GLEAM`: Sublimation using the Priestley-Taylor term following the GLEAM approach. 
    
  - `sublimation_none`: Sets snow sublimation to 0. 
    
  
- `transpiration`: Transpiration. 
  - `transpiration_coupled`: Transpiration as a function of GPP and WUE. 
    
  - `transpiration_demandSupply`: Transpiration as the minimum of supply and demand. 
    
  - `transpiration_none`: Sets transpiration to 0. 
    
  
- `transpirationDemand`: Demand-limited transpiration. 
  - `transpirationDemand_CASA`: Demand-limited transpiration as a function of volumetric soil content and soil properties, as in the CASA model. 
    
  - `transpirationDemand_PET`: Demand-limited transpiration as a function of PET and a vegetation parameter. 
    
  - `transpirationDemand_PETfAPAR`: Demand-limited transpiration as a function of PET and fAPAR. 
    
  - `transpirationDemand_PETvegFraction`: Demand-limited transpiration as a function of PET, a vegetation parameter, and vegetation fraction. 
    
  
- `transpirationSupply`: Supply-limited transpiration. 
  - `transpirationSupply_CASA`: Supply-limited transpiration as a function of volumetric soil content and soil properties, as in the CASA model. 
    
  - `transpirationSupply_Federer1982`: Supply-limited transpiration as a function of a maximum rate parameter and available water, following Federer (1982). 
    
  - `transpirationSupply_wAWC`: Supply-limited transpiration as the minimum of the fraction of total available water capacity and available moisture. 
    
  - `transpirationSupply_wAWCvegFraction`: Supply-limited transpiration as the minimum of the fraction of total available water capacity and available moisture, scaled by vegetated fractions. 
    
  
- `treeFraction`: Tree cover fraction. 
  - `treeFraction_constant`: Sets tree cover fraction as a constant value. 
    
  - `treeFraction_forcing`: Gets tree cover fraction from forcing data. 
    
  
- `vegAvailableWater`: Plant available water (PAW), i.e., the amount of water available for transpiration. 
  - `vegAvailableWater_rootWaterEfficiency`: PAW as a function of soil moisture and root water extraction efficiency. 
    
  - `vegAvailableWater_sigmoid`: PAW using a sigmoid function of soil moisture. 
    
  
- `vegFraction`: Vegetation cover fraction. 
  - `vegFraction_constant`: Sets vegetation fraction as a constant value. 
    
  - `vegFraction_forcing`: Gets vegetation fraction from forcing data. 
    
  - `vegFraction_scaledEVI`: Vegetation fraction as a linear function of EVI. 
    
  - `vegFraction_scaledLAI`: Vegetation fraction as a linear function of LAI. 
    
  - `vegFraction_scaledNDVI`: Vegetation fraction as a linear function of NDVI. 
    
  - `vegFraction_scaledNIRv`: Vegetation fraction as a linear function of NIRv. 
    
  - `vegFraction_scaledfAPAR`: Vegetation fraction as a linear function of fAPAR. 
    
  
- `wCycle`: Apply the delta storage changes to storage variables 
  - `wCycle_combined`: computes the algebraic sum of storage and delta storage 
    
  - `wCycle_components`: update the water cycle pools per component 
    
  
- `wCycleBase`: Sets the basic structure of the water cycle storages. 
  - `wCycleBase_simple`: Through `wCycle`.jl, adjust/update the variables for each storage separately and for TWS. 
    
  
- `waterBalance`: Water balance 
  - `waterBalance_simple`: Simply checks the water balance as P-ET-R-ds/dt. 
    
  

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
<summary><a id='Sindbad.showInfo-NTuple{4, Any}' href='#Sindbad.showInfo-NTuple{4, Any}'><span class="jlbinding">Sindbad.showInfo</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
showInfo(func, file_name, line_number, info_message; spacer=" ", n_f=1, n_m=1)
```


Logs an informational message with optional function, file, and line number context.

**Arguments**
- `func`: The function object or `nothing` if not applicable.
  
- `file_name`: The name of the file where the message originates.
  
- `line_number`: The line number in the file.
  
- `info_message`: The message to log.
  
- `spacer`: (Optional) String used for spacing in the log output (default: `" "`).
  
- `n_f`: (Optional) Number of times to repeat `spacer` before the function/file info (default: `1`).
  
- `n_m`: (Optional) Number of times to repeat `spacer` before the message (default: `1`).
  

**Example**

```julia
showInfo(myfunc, "myfile.jl", 42, "Computation finished")
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.showInfoSeparator-Tuple{}' href='#Sindbad.showInfoSeparator-Tuple{}'><span class="jlbinding">Sindbad.showInfoSeparator</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
showInfoSeparator(; sep_text="", sep_width=100, display_color=(223,184,21))
```


Prints a visually distinct separator line to the console, optionally with centered text.

**Arguments**
- `sep_text`: (Optional) A string to display centered within the separator. If empty, a line of dashes is printed. Default is `""`.
  
- `sep_width`: (Optional) The total width of the separator line. Default is `100`.
  
- `display_color`: (Optional) An RGB tuple specifying the color of the separator line. Default is `(223,184,21)`.
  

**Example**

```julia
showInfoSeparator()
showInfoSeparator(sep_text=" SECTION START ", sep_width=80)
```


**Notes**
- The separator line is colored for emphasis.
  
- Useful for visually dividing output sections in logs or the console.
  

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

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.showInfoColored-Tuple{String, Any}' href='#Sindbad.showInfoColored-Tuple{String, Any}'><span class="jlbinding">Sindbad.showInfoColored</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
showInfoColored(s::String, color)
```


Returns a string with segments enclosed in backticks (`) colored using the specified RGB color.

**Arguments**
- `s::String`: The input string. Segments to be colored should be enclosed in backticks (e.g., `"This is`colored`text"`).
  
- `color`: An RGB tuple (e.g., `(0, 152, 221)`) specifying the foreground color to use.
  

**Returns**
- A string with the specified segments colored, suitable for display in terminals that support ANSI color codes.
  

**Example**

```julia
println(showInfoColored("This is `colored` text", (0, 152, 221)))
```


This will print &quot;This is colored text&quot; with &quot;colored&quot; in the specified color.

**Notes**
- Only the segments between backticks are colored; other text remains uncolored.
  
- The function uses Crayons.jl for coloring, so output is best viewed in compatible terminals.
  

</details>

