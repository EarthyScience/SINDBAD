export defaultVariableInfo
export sindbad_variables
export whatIs

orD = DataStructures.OrderedDict
sindbad_variables = orD{Symbol,orD{Symbol,String}}(
    :PET__Tair_prev => orD(
        :standard_name => "Tair_prev",
        :long_name => "Tair_previous_timestep",
        :units => "degree_C",
        :land_field => "PET",
        :description => "air temperature in the previous time step"
    ),
    :WUE__WUE => orD(
        :standard_name => "WUE",
        :long_name => "assimilation_over_evaporation",
        :units => "gC/mmH2O",
        :land_field => "WUE",
        :description => "water use efficiency of the ecosystem"
    ),
    :WUE__WUENoCO2 => orD(
        :standard_name => "WUENoCO2",
        :long_name => "assimilation_over_evaporation_without_co2_effect",
        :units => "gC/mmH2O",
        :land_field => "WUE",
        :description => "water use efficiency of the ecosystem without CO2 effect"
    ),
    :autoRespirationAirT__auto_respiration_f_airT => orD(
        :standard_name => "auto_respiration_f_airT",
        :long_name => "air_temperature_effect_autotrophic_respiration",
        :units => "scalar",
        :land_field => "autoRespirationAirT",
        :description => "effect of air temperature on autotrophic respiration. 0: no decomposition, >1 increase in decomposition rate"
    ),
    :autoRespiration__k_respiration_maintain => orD(
        :standard_name => "k_respiration_maintain",
        :long_name => "loss_rate_maintenance_respiration",
        :units => "/time",
        :land_field => "autoRespiration",
        :description => "metabolism rate for maintenance respiration"
    ),
    :autoRespiration__k_respiration_maintain_su => orD(
        :standard_name => "k_respiration_maintain_su",
        :long_name => "loss_rate_maintenance_respiration_spinup",
        :units => "/time",
        :land_field => "autoRespiration",
        :description => "metabolism rate for maintenance respiration to be used in old analytical solution to steady state"
    ),
    :cAllocationLAI__c_allocation_f_LAI => orD(
        :standard_name => "c_allocation_f_LAI",
        :long_name => "LAI_effect_carbon_allocation",
        :units => "fraction",
        :land_field => "cAllocationLAI",
        :description => "effect of LAI on carbon allocation. 1: no stress, 0: complete stress"
    ),
    :cAllocationNutrients__c_allocation_f_W_N => orD(
        :standard_name => "c_allocation_f_W_N",
        :long_name => "W_N_effect_carbon_allocation",
        :units => "fraction",
        :land_field => "cAllocationNutrients",
        :description => "effect of water and nutrient on carbon allocation. 1: no stress, 0: complete stress"
    ),
    :cAllocationRadiation__c_allocation_f_cloud => orD(
        :standard_name => "c_allocation_f_cloud",
        :long_name => "cloud_effect_carbon_allocation",
        :units => "fraction",
        :land_field => "cAllocationRadiation",
        :description => "effect of cloud on carbon allocation. 1: no stress, 0: complete stress"
    ),
    :cAllocationSoilT__c_allocation_f_soilT => orD(
        :standard_name => "c_allocation_f_soilT",
        :long_name => "soil_temperature_effect_carbon_allocation",
        :units => "scalar",
        :land_field => "cAllocationSoilT",
        :description => "effect of soil temperature on carbon allocation. 1: no stress, 0: complete stress"
    ),
    :cAllocationSoilW__c_allocation_f_soilW => orD(
        :standard_name => "c_allocation_f_soilW",
        :long_name => "soil_moisture_effect_carbon_allocation",
        :units => "fraction",
        :land_field => "cAllocationSoilW",
        :description => "effect of soil moisture on carbon allocation. 1: no stress, 0: complete stress"
    ),
    :cAllocationTreeFraction__cVeg_names_for_c_allocation_frac_tree => orD(
        :standard_name => "cVeg_names_for_c_allocation_frac_tree",
        :long_name => "veg_pools_corrected_for_tree_cover",
        :units => "string",
        :land_field => "cAllocationTreeFraction",
        :description => "name of vegetation carbon pools used in tree fraction correction for carbon allocation"
    ),
    :cAllocation__cVeg_names => orD(
        :standard_name => "cVeg_names",
        :long_name => "name_veg_pools",
        :units => "string",
        :land_field => "cAllocation",
        :description => "name of vegetation carbon pools used for carbon allocation"
    ),
    :cAllocation__cVeg_nzix => orD(
        :standard_name => "cVeg_nzix",
        :long_name => "number_per_veg_pool",
        :units => "number",
        :land_field => "cAllocation",
        :description => "number of pools/layers in each vegetation carbon component"
    ),
    :cAllocation__cVeg_zix => orD(
        :standard_name => "cVeg_zix",
        :long_name => "index_veg_pools",
        :units => "number",
        :land_field => "cAllocation",
        :description => "number of pools/layers in each vegetation carbon component"
    ),
    :cAllocation__c_allocation_to_veg => orD(
        :standard_name => "c_allocation_to_veg",
        :long_name => "carbon_allocation_veg",
        :units => "fraction",
        :land_field => "cAllocation",
        :description => "carbon allocation to each vvegetation pool"
    ),
    :cCycleBase__C_to_N_cVeg => orD(
        :standard_name => "C_to_N_cVeg",
        :long_name => "carbon_to_nitrogen_ratio",
        :units => "ratio",
        :land_field => "cCycleBase",
        :description => "carbon to nitrogen ratio in the vegetation pools"
    ),
    :cCycleBase__c_eco_k_base => orD(
        :standard_name => "c_eco_k_base",
        :long_name => "c eco k base",
        :units => "/time",
        :land_field => "cCycleBase",
        :description => "base carbon decomposition rate of the carbon pools"
    ),
    :cCycleBase__c_flow_A_array => orD(
        :standard_name => "c_flow_A_array",
        :long_name => "carbon_flow_array",
        :units => "fraction",
        :land_field => "cCycleBase",
        :description => "an array indicating the flow direction and connections across different pools, with elements larger than 0 indicating flow from column pool to row pool"
    ),
    :cCycleBase__c_flow_order => orD(
        :standard_name => "c_flow_order",
        :long_name => "carbon_flow_order",
        :units => "number",
        :land_field => "cCycleBase",
        :description => "order of pooling while calculating the carbon flow"
    ),
    :cCycleBase__c_giver => orD(
        :standard_name => "c_giver",
        :long_name => "carbon_giver_pool",
        :units => "number",
        :land_field => "cCycleBase",
        :description => "index of the source carbon pool for a given flow"
    ),
    :cCycleBase__c_model => orD(
        :standard_name => "c_model",
        :long_name => "base_carbon_model",
        :units => "symbol",
        :land_field => "cCycleBase",
        :description => "a base carbon cycle model to loop through the pools and fill the main or component pools needed for using static arrays. A mandatory field for every carbon model realization"
    ),
    :cCycleBase__c_remain => orD(
        :standard_name => "c_remain",
        :long_name => "carbon_remain",
        :units => "gC/m2",
        :land_field => "cCycleBase",
        :description => "amount of carbon to keep in the ecosystem vegetation pools in case of disturbances"
    ),
    :cCycleBase__c_taker => orD(
        :standard_name => "c_taker",
        :long_name => "carbon_taker_pool",
        :units => "number",
        :land_field => "cCycleBase",
        :description => "index of the source carbon pool for a given flow"
    ),
    :cCycleBase__c_τ_eco => orD(
        :standard_name => "c_τ_eco",
        :long_name => "carbon_turnover_per_pool",
        :units => "years",
        :land_field => "cCycleBase",
        :description => "number of years needed for carbon turnover per carbon pool"
    ),
    :cCycleBase__ηA => orD(
        :standard_name => "ηA",
        :long_name => "eta_autotrophic_pools",
        :units => "number",
        :land_field => "cCycleBase",
        :description => "scalar of autotrophic carbon pool for steady state guess"
    ),
    :cCycleBase__ηH => orD(
        :standard_name => "ηH",
        :long_name => "eta_heterotrophic_pools",
        :units => "number",
        :land_field => "cCycleBase",
        :description => "scalar of heterotrophic carbon pool for steady state guess"
    ),
    :cCycleConsistency__giver_lower_indices => orD(
        :standard_name => "giver_lower_indices",
        :long_name => "carbon_giver_lower_indices",
        :units => "number",
        :land_field => "cCycleConsistency",
        :description => "indices of carbon pools whose flow is >0 below the diagonal in carbon flow matrix"
    ),
    :cCycleConsistency__giver_lower_unique => orD(
        :standard_name => "giver_lower_unique",
        :long_name => "carbon_giver_lower_unique_indices",
        :units => "number",
        :land_field => "cCycleConsistency",
        :description => "unique indices of carbon pools whose flow is >0 below the diagonal in carbon flow matrix"
    ),
    :cCycleConsistency__giver_upper_indices => orD(
        :standard_name => "giver_upper_indices",
        :long_name => "carbon_giver_upper_indices",
        :units => "number",
        :land_field => "cCycleConsistency",
        :description => "indices of carbon pools whose flow is >0 above the diagonal in carbon flow matrix"
    ),
    :cCycleConsistency__giver_upper_unique => orD(
        :standard_name => "giver_upper_unique",
        :long_name => "carbon_giver_upper_unique_indices",
        :units => "number",
        :land_field => "cCycleConsistency",
        :description => "unique indices of carbon pools whose flow is >0 above the diagonal in carbon flow matrix"
    ),
    :cCycleDisturbance__c_lose_to_zix_vec => orD(
        :standard_name => "c_lose_to_zix_vec",
        :long_name => "index_carbon_loss_to_pool",
        :units => "",
        :land_field => "cCycleDisturbance",
        :description => ""
    ),
    :cCycleDisturbance__zix_veg_all => orD(
        :standard_name => "zix_veg_all",
        :long_name => "index_all_veg_pools",
        :units => "",
        :land_field => "cCycleDisturbance",
        :description => ""
    ),
    :cFlowSoilProperties__p_E_vec => orD(
        :standard_name => "p_E_vec",
        :long_name => "p E vec",
        :units => "",
        :land_field => "cFlowSoilProperties",
        :description => ""
    ),
    :cFlowSoilProperties__p_F_vec => orD(
        :standard_name => "p_F_vec",
        :long_name => "p F vec",
        :units => "",
        :land_field => "cFlowSoilProperties",
        :description => ""
    ),
    :cFlowVegProperties__p_E_vec => orD(
        :standard_name => "p_E_vec",
        :long_name => "p E vec",
        :units => "",
        :land_field => "cFlowVegProperties",
        :description => "carbon flow efficiency"
    ),
    :cFlowVegProperties__p_F_vec => orD(
        :standard_name => "p_F_vec",
        :long_name => "p F vec",
        :units => "fraction",
        :land_field => "cFlowVegProperties",
        :description => "carbon flow efficiency fraction"
    ),
    :cFlow__aSrc => orD(
        :standard_name => "aSrc",
        :long_name => "carbon_source_pool_name",
        :units => "string",
        :land_field => "cFlow",
        :description => "name of the source pool for the carbon flow"
    ),
    :cFlow__aTrg => orD(
        :standard_name => "aTrg",
        :long_name => "carbon_target_pool_name",
        :units => "string",
        :land_field => "cFlow",
        :description => "name of the target pool for carbon flow"
    ),
    :cFlow__c_flow_A_vec_ind => orD(
        :standard_name => "c_flow_A_vec_ind",
        :long_name => "index_carbon_flow_vector",
        :units => "number",
        :land_field => "cFlow",
        :description => "indices of flow from giver to taker for carbon flow vector"
    ),
    :cFlow__eco_stressor => orD(
        :standard_name => "eco_stressor",
        :long_name => "carbon_flow_ecosystem_stressor",
        :units => "fraction",
        :land_field => "cFlow",
        :description => "ecosystem stress on carbon flow"
    ),
    :cFlow__eco_stressor_prev => orD(
        :standard_name => "eco_stressor_prev",
        :long_name => "carbon_flow_ecosystem_stressor_previous_timestep",
        :units => "fraction",
        :land_field => "cFlow",
        :description => "ecosystem stress on carbon flow in the previous time step"
    ),
    :cFlow__k_shedding_leaf => orD(
        :standard_name => "k_shedding_leaf",
        :long_name => "carbon_shedding_rate_leaf",
        :units => "/time",
        :land_field => "cFlow",
        :description => "loss rate of carbon flow from leaf to litter"
    ),
    :cFlow__k_shedding_leaf_frac => orD(
        :standard_name => "k_shedding_leaf_frac",
        :long_name => "carbon_shedding_fraction_leaf",
        :units => "fraction",
        :land_field => "cFlow",
        :description => "fraction of carbon loss from leaf that flows to litter pool"
    ),
    :cFlow__k_shedding_root => orD(
        :standard_name => "k_shedding_root",
        :long_name => "carbon_shedding_rate_root",
        :units => "/time",
        :land_field => "cFlow",
        :description => "loss rate of carbon flow from root to litter"
    ),
    :cFlow__k_shedding_root_frac => orD(
        :standard_name => "k_shedding_root_frac",
        :long_name => "carbon_shedding_fraction_root",
        :units => "fraction",
        :land_field => "cFlow",
        :description => "fraction of carbon loss from root that flows to litter pool"
    ),
    :cFlow__leaf_to_reserve => orD(
        :standard_name => "leaf_to_reserve",
        :long_name => "carbon_flow_rate_leaf_to_reserve",
        :units => "/time",
        :land_field => "cFlow",
        :description => "loss rate of carbon flow from leaf to reserve"
    ),
    :cFlow__leaf_to_reserve_frac => orD(
        :standard_name => "leaf_to_reserve_frac",
        :long_name => "carbon_flow_fraction_leaf_to_reserve",
        :units => "fraction",
        :land_field => "cFlow",
        :description => "fraction of carbon loss from leaf that flows to leaf"
    ),
    :cFlow__reserve_to_leaf => orD(
        :standard_name => "reserve_to_leaf",
        :long_name => "carbon_flow_rate_reserve_to_leaf",
        :units => "/time",
        :land_field => "cFlow",
        :description => "loss rate of carbon flow from reserve to root"
    ),
    :cFlow__reserve_to_leaf_frac => orD(
        :standard_name => "reserve_to_leaf_frac",
        :long_name => "carbon_flow_fraction_reserve_to_leaf",
        :units => "fraction",
        :land_field => "cFlow",
        :description => "fraction of carbon loss from reserve that flows to leaf"
    ),
    :cFlow__reserve_to_root => orD(
        :standard_name => "reserve_to_root",
        :long_name => "carbon_flow_rate_reserve_to_root",
        :units => "/time",
        :land_field => "cFlow",
        :description => "loss rate of carbon flow from reserve to root"
    ),
    :cFlow__reserve_to_root_frac => orD(
        :standard_name => "reserve_to_root_frac",
        :long_name => "carbon_flow_fraction_reserve_to_root",
        :units => "fraction",
        :land_field => "cFlow",
        :description => "fraction of carbon loss from reserve that flows to root"
    ),
    :cFlow__root_to_reserve => orD(
        :standard_name => "root_to_reserve",
        :long_name => "carbon_flow_rate_root_to_reserve",
        :units => "/time",
        :land_field => "cFlow",
        :description => "loss rate of carbon flow from root to reserve"
    ),
    :cFlow__root_to_reserve_frac => orD(
        :standard_name => "root_to_reserve_frac",
        :long_name => "carbon_flow_fraction_root_to_reserve",
        :units => "fraction",
        :land_field => "cFlow",
        :description => "fraction of carbon loss from root that flows to reserve"
    ),
    :cFlow__slope_eco_stressor => orD(
        :standard_name => "slope_eco_stressor",
        :long_name => "slope_carbon_flow_ecosystem_stressor",
        :units => "/time",
        :land_field => "cFlow",
        :description => "potential rate of change in ecosystem stress on carbon flow"
    ),
    :cTauLAI__c_eco_k_f_LAI => orD(
        :standard_name => "c_eco_k_f_LAI",
        :long_name => "LAI_effect_carbon_decomposition_rate",
        :units => "fraction",
        :land_field => "cTauLAI",
        :description => "effect of LAI on carbon decomposition rate. 1: no stress, 0: complete stress"
    ),
    :cTauSoilProperties__c_eco_k_f_soil_props => orD(
        :standard_name => "c_eco_k_f_soil_props",
        :long_name => "soil_property_effect_carbon_decomposition_rate",
        :units => "fraction",
        :land_field => "cTauSoilProperties",
        :description => "effect of soil_props on carbon decomposition rate. 1: no stress, 0: complete stress"
    ),
    :cTauSoilT__c_eco_k_f_soilT => orD(
        :standard_name => "c_eco_k_f_soilT",
        :long_name => "soil_temperature_effect_carbon_decomposition_rate",
        :units => "scalar",
        :land_field => "cTauSoilT",
        :description => "effect of soil temperature on heterotrophic respiration respiration. 0: no decomposition, >1 increase in decomposition"
    ),
    :cTauSoilW__c_eco_k_f_soilW => orD(
        :standard_name => "c_eco_k_f_soilW",
        :long_name => "soil_moisture_effect_carbon_decomposition_rate",
        :units => "fraction",
        :land_field => "cTauSoilW",
        :description => "effect of soil moisture on carbon decomposition rate. 1: no stress, 0: complete stress"
    ),
    :cTauVegProperties__LIGEFF => orD(
        :standard_name => "LIGEFF",
        :long_name => "LIGEFF",
        :units => "fraction",
        :land_field => "cTauVegProperties",
        :description => ""
    ),
    :cTauVegProperties__LIGNIN => orD(
        :standard_name => "LIGNIN",
        :long_name => "LIGNIN",
        :units => "fraction",
        :land_field => "cTauVegProperties",
        :description => ""
    ),
    :cTauVegProperties__LITC2N => orD(
        :standard_name => "LITC2N",
        :long_name => "LITC2N",
        :units => "fraction",
        :land_field => "cTauVegProperties",
        :description => ""
    ),
    :cTauVegProperties__MTF => orD(
        :standard_name => "MTF",
        :long_name => "MTF",
        :units => "fraction",
        :land_field => "cTauVegProperties",
        :description => ""
    ),
    :cTauVegProperties__SCLIGNIN => orD(
        :standard_name => "SCLIGNIN",
        :long_name => "SCLIGNIN",
        :units => "fraction",
        :land_field => "cTauVegProperties",
        :description => ""
    ),
    :cTauVegProperties__c_eco_k_f_veg_props => orD(
        :standard_name => "c_eco_k_f_veg_props",
        :long_name => "vegetation_property_effect_carbon_decomposition_rate",
        :units => "fraction",
        :land_field => "cTauVegProperties",
        :description => "effect of veg_props on carbon decomposition rate. 1: no stress, 0: complete stress"
    ),
    :deriveVariables__aboveground_biomass => orD(
        :standard_name => "aboveground_biomass",
        :long_name => "aboveground_woody_biomass",
        :units => "gC/m2",
        :land_field => "deriveVariables",
        :description => "carbon content on the cVegWood component",
    ),
    :fluxes__auto_respiration => orD(
        :standard_name => "auto_respiration",
        :long_name => "autotrophic_respiration",
        :units => "gC/m2/time",
        :land_field => "fluxes",
        :description => "carbon loss due to autotrophic respiration"
    ),
    :fluxes__base_runoff => orD(
        :standard_name => "base_runoff",
        :long_name => "base_runoff",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "base runoff"
    ),
    :fluxes__drainage => orD(
        :standard_name => "drainage",
        :long_name => "soil_moisture_drainage",
        :units => "mm/time",
        :land_field => "drainage",
        :description => "soil moisture drainage per soil layer"
    ),
    :fluxes__eco_respiration => orD(
        :standard_name => "ecosystem_respiration",
        :long_name => "total_ecosystem_respiration",
        :units => "gC/m2/time",
        :land_field => "fluxes",
        :description => "carbon loss due to ecosystem respiration"
    ),
    :fluxes__evaporation => orD(
        :standard_name => "evaporation",
        :long_name => "soil_evaporation",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "evaporation from the first soil layer"
    ),
    :fluxes__evapotranspiration => orD(
        :standard_name => "evapotranspiration",
        :long_name => "total_land_evaporation",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "total land evaporation including soil evaporation, vegetation transpiration, snow sublimation, and interception loss"
    ),
    :fluxes__gpp => orD(
        :standard_name => "gpp",
        :long_name => "gross_primary_productivity",
        :units => "gC/m2/time",
        :land_field => "fluxes",
        :description => "gross primary prorDcutivity"
    ),
    :fluxes__gw_capillary_flux => orD(
        :standard_name => "gw_capillary_flux",
        :long_name => "groundwater_capillary_flux",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "capillary flux from top groundwater layer to the lowermost soil layer"
    ),
    :fluxes__gw_recharge => orD(
        :standard_name => "gw_recharge",
        :long_name => "groundwater_recharge",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "net groundwater recharge from the lowermost soil layer, positive => soil to groundwater"
    ),
    :fluxes__hetero_respiration => orD(
        :standard_name => "hetero_respiration",
        :long_name => "heterotrophic_respiration",
        :units => "gC/m2/time",
        :land_field => "fluxes",
        :description => "carbon loss due to heterotrophic respiration"
    ),
    :fluxes__interflow_runoff => orD(
        :standard_name => "interflow_runoff",
        :long_name => "interflow_runoff",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "runoff loss from interflow in soil layers"
    ),
    :fluxes__interception => orD(
        :standard_name => "interception",
        :long_name => "interception_loss",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "interception evaporation loss"
    ),
    :fluxes__PET_evaporation => orD(
        :standard_name => "PET_evaporation",
        :long_name => "potential_soil_evaporation",
        :units => "mm/time",
        :land_field => "evaporation",
        :description => "potential soil evaporation"
    ),
    :fluxes__nee => orD(
        :standard_name => "nee",
        :long_name => "net_ecosystem_exchange",
        :units => "gC/m2/time",
        :land_field => "fluxes",
        :description => "net ecosystem carbon exchange for the ecosystem. negative value indicates carbon sink."
    ),
    :fluxes__npp => orD(
        :standard_name => "npp",
        :long_name => "carbon_net_primary_productivity",
        :units => "gC/m2/time",
        :land_field => "fluxes",
        :description => "net primary prorDcutivity"
    ),
    :fluxes__overland_runoff => orD(
        :standard_name => "overland_runoff",
        :long_name => "overland_runoff",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "overland runoff as a fraction of incoming water"
    ),
    :fluxes__percolation => orD(
        :standard_name => "percolation",
        :long_name => "soil_water_percolation",
        :units => "mm/time",
        :land_field => "percolation",
        :description => "amount of moisture percolating to the top soil layer"
    ),
    :fluxes__PET => orD(
        :standard_name => "PET",
        :long_name => "potential_evapotranspiration",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "potential evapotranspiration"
    ),
    :fluxes__precip => orD(
        :standard_name => "precip",
        :long_name => "total_precipiration",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "total land precipitation including snow and rain"
    ),
    :fluxes__rain => orD(
        :standard_name => "rain",
        :long_name => "rainfall",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "amount of precipitation in liquid form"
    ),
    :fluxes__runoff => orD(
        :standard_name => "runoff",
        :long_name => "total_runoff",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "total runoff"
    ),
    :fluxes__sat_excess_runoff => orD(
        :standard_name => "sat_excess_runoff",
        :long_name => "saturation_excess_runoff",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "saturation excess runoff"
    ),
    :fluxes__snow => orD(
        :standard_name => "snow",
        :long_name => "snowfall",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "amount of precipitation in solid form"
    ),
    :fluxes__snow_melt => orD(
        :standard_name => "snow_melt",
        :long_name => "snow_melt_flux",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "snow melt"
    ),
    :fluxes__soil_capillary_flux => orD(
        :standard_name => "soil_capillary_flux",
        :long_name => "soil_capillary_flux",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "soil capillary flux per layer"
    ),
    :fluxes__sublimation => orD(
        :standard_name => "sublimation",
        :long_name => "snow_sublimation",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "sublimation of the snow"
    ),
    :fluxes__surface_runoff => orD(
        :standard_name => "surface_runoff",
        :long_name => "total_surface_runoff",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "total surface runoff"
    ),
    :fluxes__transpiration => orD(
        :standard_name => "transpiration",
        :long_name => "transpiration",
        :units => "mm/time",
        :land_field => "fluxes",
        :description => "transpiration"
    ),
    :gppAirT__gpp_f_airT => orD(
        :standard_name => "gpp_f_airT",
        :long_name => "air_temperature_effect_gpp",
        :units => "fraction",
        :land_field => "gppAirT",
        :description => "effect of air temperature on gpp. 1: no stress, 0: complete stress"
    ),
    :gppDemand__gpp_climate_stressors => orD(
        :standard_name => "gpp_climate_stressors",
        :long_name => "climate_effect_per_factor_gpp",
        :units => "fraction",
        :land_field => "gppDemand",
        :description => "a collection of all gpp climate stressors including light, temperature, radiation, and vpd"
    ),
    :gppDemand__gpp_demand => orD(
        :standard_name => "gpp_demand",
        :long_name => "demand_driven_gpp",
        :units => "gC/m2/time",
        :land_field => "gppDemand",
        :description => "demand driven gross primary prorDuctivity"
    ),
    :gppDemand__gpp_f_climate => orD(
        :standard_name => "gpp_f_climate",
        :long_name => "net_climate_effect_gpp",
        :units => "fraction",
        :land_field => "gppDemand",
        :description => "effect of climate on gpp. 1: no stress, 0: complete stress"
    ),
    :gppDiffRadiation__CI_max => orD(
        :standard_name => "CI_max",
        :long_name => "maximum_cloudiness_index",
        :units => "fraction",
        :land_field => "gppDiffRadiation",
        :description => "maximum of cloudiness index until the time step from the beginning of simulation (including spinup)"
    ),
    :gppDiffRadiation__CI_min => orD(
        :standard_name => "CI_min",
        :long_name => "minimum_cloudiness_index",
        :units => "fraction",
        :land_field => "gppDiffRadiation",
        :description => "minimum of cloudiness index until the time step from the beginning of simulation (including spinup)"
    ),
    :gppDiffRadiation__gpp_f_cloud => orD(
        :standard_name => "gpp_f_cloud",
        :long_name => "cloudiness_index_effect_gpp",
        :units => "fraction",
        :land_field => "gppDiffRadiation",
        :description => "effect of cloud on gpp. 1: no stress, 0: complete stress"
    ),
    :gppDirRadiation__gpp_f_light => orD(
        :standard_name => "gpp_f_light",
        :long_name => "light_effect_gpp",
        :units => "fraction",
        :land_field => "gppDirRadiation",
        :description => "effect of light on gpp. 1: no stress, 0: complete stress"
    ),
    :gppPotential__gpp_potential => orD(
        :standard_name => "gpp_potential",
        :long_name => "potential_productivity",
        :units => "gC/m2/time",
        :land_field => "gppPotential",
        :description => "potential gross primary prorDcutivity"
    ),
    :gppSoilW__gpp_f_soilW => orD(
        :standard_name => "gpp_f_soilW",
        :long_name => "soil_moisture_effect_gpp",
        :units => "fraction",
        :land_field => "gppSoilW",
        :description => "effect of soil moisture on gpp. 1: no stress, 0: complete stress"
    ),
    :gppSoilW__t_two => orD(
        :standard_name => "t_two",
        :long_name => "t two",
        :units => "number",
        :land_field => "gppSoilW",
        :description => "a type stable 2"
    ),
    :gppVPD__gpp_f_vpd => orD(
        :standard_name => "gpp_f_vpd",
        :long_name => "vapor_pressure_deficit_effect_gpp",
        :units => "fraction",
        :land_field => "gppVPD",
        :description => "effect of vpd on gpp. 1: no stress, 0: complete stress"
    ),
    :pools__TWS => orD(
        :standard_name => "TWS",
        :long_name => "terrestrial_water_storage",
        :units => "mm",
        :land_field => "pools",
        :description => "terrestrial water storage including all water pools"
    ),
    :pools__cEco => orD(
        :standard_name => "cEco",
        :long_name => "ecosystem_carbon_storage_content",
        :units => "gC/m2",
        :land_field => "pools",
        :description => "carbon content of cEco pool(s)"
    ),
    :pools__cLit => orD(
        :standard_name => "cLit",
        :long_name => "litter_carbon_storage_content",
        :units => "gC/m2",
        :land_field => "pools",
        :description => "carbon content of cLit pool(s)"
    ),
    :pools__cLitFast => orD(
        :standard_name => "cLitFast",
        :long_name => "litter_carbon_storage_content_fast_turnover",
        :units => "gC/m2",
        :land_field => "pools",
        :description => "carbon content of cLitFast pool(s)"
    ),
    :pools__cLitSlow => orD(
        :standard_name => "litter_carbon_storage_content_slow_turnover",
        :long_name => "cLitSlow",
        :units => "gC/m2",
        :land_field => "pools",
        :description => "carbon content of cLitSlow pool(s)"
    ),
    :pools__cSoil => orD(
        :standard_name => "cSoil",
        :long_name => "soil_carbon_storage_content",
        :units => "gC/m2",
        :land_field => "pools",
        :description => "carbon content of cSoil pool(s)"
    ),
    :pools__cSoilOld => orD(
        :standard_name => "cSoilOld",
        :long_name => "old_soil_carbon_storage_content_slow_turnover",
        :units => "gC/m2",
        :land_field => "pools",
        :description => "carbon content of cSoilOld pool(s)"
    ),
    :pools__cSoilSlow => orD(
        :standard_name => "cSoilSlow",
        :long_name => "soil_carbon_storage_content_slow_turnover",
        :units => "gC/m2",
        :land_field => "pools",
        :description => "carbon content of cSoilSlow pool(s)"
    ),
    :pools__cVeg => orD(
        :standard_name => "cVeg",
        :long_name => "vegetation_carbon_storage_content",
        :units => "gC/m2",
        :land_field => "pools",
        :description => "carbon content of cVeg pool(s)"
    ),
    :pools__cVegLeaf => orD(
        :standard_name => "cVegLeaf",
        :long_name => "leaf_carbon_storage_content",
        :units => "gC/m2",
        :land_field => "pools",
        :description => "carbon content of cVegLeaf pool(s)"
    ),
    :pools__cVegReserve => orD(
        :standard_name => "cVegReserve",
        :long_name => "reserve_carbon_storage_content",
        :units => "gC/m2",
        :land_field => "pools",
        :description => "carbon content of cVegReserve pool(s) that does not respire"
    ),
    :pools__cVegRoot => orD(
        :standard_name => "cVegRoot",
        :long_name => "root_carbon_storage_content",
        :units => "gC/m2",
        :land_field => "pools",
        :description => "carbon content of cVegRoot pool(s)"
    ),
    :pools__cVegWood => orD(
        :standard_name => "cVegWood",
        :long_name => "wood_carbon_storage_content",
        :units => "gC/m2",
        :land_field => "pools",
        :description => "carbon content of cVegWood pool(s)"
    ),
    :pools__groundW => orD(
        :standard_name => "groundW",
        :long_name => "groundwater_storage",
        :units => "mm",
        :land_field => "pools",
        :description => "water storage in groundW pool(s)"
    ),
    :pools__snowW => orD(
        :standard_name => "snowW",
        :long_name => "snow_water_equivalent",
        :units => "mm",
        :land_field => "pools",
        :description => "water storage in snowW pool(s)"
    ),
    :pools__soilW => orD(
        :standard_name => "soilW",
        :long_name => "soil_moisture_storage",
        :units => "mm",
        :land_field => "pools",
        :description => "water storage in soilW pool(s)"
    ),
    :pools__surfaceW => orD(
        :standard_name => "surfaceW",
        :long_name => "surface_water_storage",
        :units => "mm",
        :land_field => "pools",
        :description => "water storage in surfaceW pool(s)"
    ),
    :rootMaximumDepth__sum_soil_depth => orD(
        :standard_name => "sum_soil_depth",
        :long_name => "total_depth_of_soil_column",
        :units => "mm",
        :land_field => "rootMaximumDepth",
        :description => "total depth of soil"
    ),
    :rootWaterEfficiency__cumulative_soil_depths => orD(
        :standard_name => "cumulative_soil_depths",
        :long_name => "cumulative_soil_depth",
        :units => "mm",
        :land_field => "rootWaterEfficiency",
        :description => "the depth to the bottom of each soil layer"
    ),
    :rootWaterEfficiency__root_over => orD(
        :standard_name => "root_over",
        :long_name => "is_root_over",
        :units => "boolean",
        :land_field => "rootWaterEfficiency",
        :description => "a boolean indicating if the root is allowed to exract water from a given layer depending on maximum rooting depth"
    ),
    :soilProperties__sp_kFC => orD(
        :standard_name => "sp_kFC",
        :long_name => "soil_property_kFC",
        :units => "mm/time",
        :land_field => "soilProperties",
        :description => "calculated/input hydraulic conductivity of soil at field capacity per layer"
    ),
    :soilProperties__sp_kSat => orD(
        :standard_name => "sp_kSat",
        :long_name => "soil_property_k_saturated",
        :units => "mm/time",
        :land_field => "soilProperties",
        :description => "calculated/input hydraulic conductivity of soil at saturation per layer"
    ),
    :soilProperties__sp_kWP => orD(
        :standard_name => "sp_kWP",
        :long_name => "soil_property_k_wilting_point",
        :units => "mm/time",
        :land_field => "soilProperties",
        :description => "calculated/input hydraulic conductivity of soil at wilting point per layer"
    ),
    :soilProperties__sp_α => orD(
        :standard_name => "sp_α",
        :long_name => "soil_property_α",
        :units => "number",
        :land_field => "soilProperties",
        :description => "calculated/input alpha parameter of soil per layer"
    ),
    :soilProperties__sp_β => orD(
        :standard_name => "sp_β",
        :long_name => "soil_property_β",
        :units => "number",
        :land_field => "soilProperties",
        :description => "calculated/input beta parameter of soil per layer"
    ),
    :soilProperties__sp_θFC => orD(
        :standard_name => "sp_θFC",
        :long_name => "soil_property_θ_field_capacity",
        :units => "m3/m3",
        :land_field => "soilProperties",
        :description => "calculated/input moisture content of soil at field capacity per layer"
    ),
    :soilProperties__sp_θSat => orD(
        :standard_name => "sp_θSat",
        :long_name => "soil_property_θ_saturated",
        :units => "m3/m3",
        :land_field => "soilProperties",
        :description => "calculated/input moisture content of soil at saturation (porosity) per layer"
    ),
    :soilProperties__sp_θWP => orD(
        :standard_name => "sp_θWP",
        :long_name => "soil_property_θ_wilting_point",
        :units => "m3/m3",
        :land_field => "soilProperties",
        :description => "calculated/input moisture content of soil at wilting point per layer"
    ),
    :soilProperties__sp_ψFC => orD(
        :standard_name => "sp_ψFC",
        :long_name => "soil_property_ψ_field_capacity",
        :units => "m",
        :land_field => "soilProperties",
        :description => "calculated/input matric potential of soil at field capacity per layer"
    ),
    :soilProperties__sp_ψSat => orD(
        :standard_name => "sp_ψSat",
        :long_name => "soil_property_ψ_saturated",
        :units => "m",
        :land_field => "soilProperties",
        :description => "calculated/input matric potential of soil at saturation per layer"
    ),
    :soilProperties__sp_ψWP => orD(
        :standard_name => "sp_ψWP",
        :long_name => "soil_property_ψ_wilting_point",
        :units => "m",
        :land_field => "soilProperties",
        :description => "calculated/input matric potential of soil at wiliting point per layer"
    ),
    :soilProperties__unsat_k_model => orD(
        :standard_name => "unsat_k_model",
        :long_name => "unsat k model",
        :units => "symbol",
        :land_field => "soilProperties",
        :description => "name of the model used to calculate unsaturated hydraulic conductivity"
    ),
    :soilTexture__st_CLAY => orD(
        :standard_name => "st_CLAY",
        :long_name => "soil_texture_CLAY",
        :units => "fraction",
        :land_field => "soilTexture",
        :description => "fraction of clay content in the soil"
    ),
    :soilTexture__st_ORGM => orD(
        :standard_name => "st_ORGM",
        :long_name => "soil_texture_ORGM",
        :units => "fraction",
        :land_field => "soilTexture",
        :description => "fraction of organic matter content in the soil per layer"
    ),
    :soilTexture__st_SAND => orD(
        :standard_name => "st_SAND",
        :long_name => "soil_texture_SAND",
        :units => "fraction",
        :land_field => "soilTexture",
        :description => "fraction of sand content in the soil per layer"
    ),
    :soilTexture__st_SILT => orD(
        :standard_name => "st_SILT",
        :long_name => "soil_texture_SILT",
        :units => "fraction",
        :land_field => "soilTexture",
        :description => "fraction of silt content in the soil per layer"
    ),
    :soilWBase__kFC => orD(
        :standard_name => "soil_kFC",
        :long_name => "k_field_capacity",
        :units => "mm/time",
        :land_field => "soilWBase",
        :description => "hydraulic conductivity of soil at field capacity per layer"
    ),
    :soilWBase__kSat => orD(
        :standard_name => "kSat",
        :long_name => "k_saturated",
        :units => "mm/time",
        :land_field => "soilWBase",
        :description => "hydraulic conductivity of soil at saturation per layer"
    ),
    :soilWBase__kWP => orD(
        :standard_name => "kWP",
        :long_name => "k_wilting_point",
        :units => "mm/time",
        :land_field => "soilWBase",
        :description => "hydraulic conductivity of soil at wilting point per layer"
    ),
    :soilWBase__wAWC => orD(
        :standard_name => "wAWC",
        :long_name => "w_available_water_capacity",
        :units => "mm",
        :land_field => "soilWBase",
        :description => "maximum amount of water available for vegetation/transpiration per soil layer (wSat-WP)"
    ),
    :soilWBase__wFC => orD(
        :standard_name => "wFC",
        :long_name => "w_field_capacity",
        :units => "mm",
        :land_field => "soilWBase",
        :description => "amount of water in the soil at field capacity per layer"
    ),
    :soilWBase__wSat => orD(
        :standard_name => "wSat",
        :long_name => "w_saturated",
        :units => "mm",
        :land_field => "soilWBase",
        :description => "amount of water in the soil at saturation per layer"
    ),
    :soilWBase__wWP => orD(
        :standard_name => " wWP",
        :long_name => "wilting_point",
        :units => "mm",
        :land_field => "soilWBase",
        :description => "amount of water in the soil at wiliting point per layer"
    ),
    :soilWBase__soil_α => orD(
        :standard_name => "soil_α",
        :long_name => "soil_α",
        :units => "number",
        :land_field => "soilWBase",
        :description => "alpha parameter of soil per layer"
    ),
    :soilWBase__soil_β => orD(
        :standard_name => "soil_β",
        :long_name => "soil_β",
        :units => "number",
        :land_field => "soilWBase",
        :description => "beta parameter of soil per layer"
    ),
    :soilWBase__θFC => orD(
        :standard_name => "θFC",
        :long_name => "θ_field_capacity",
        :units => "m3/m3",
        :land_field => "soilWBase",
        :description => "moisture content of soil at field capacity per layer"
    ),
    :soilWBase__θSat => orD(
        :standard_name => "θSat",
        :long_name => "θ_saturated",
        :units => "m3/m3",
        :land_field => "soilWBase",
        :description => "moisture content of soil at saturation (porosity) per layer"
    ),
    :soilWBase__θWP => orD(
        :standard_name => "θWP",
        :long_name => "θ_wilting_point",
        :units => "m3/m3",
        :land_field => "soilWBase",
        :description => "moisture content of soil at wilting point per layer"
    ),
    :soilWBase__ψFC => orD(
        :standard_name => "ψFC",
        :long_name => "ψ_field_capacity",
        :units => "m",
        :land_field => "soilWBase",
        :description => "matric potential of soil at field capacity per layer"
    ),
    :soilWBase__ψSat => orD(
        :standard_name => "ψSat",
        :long_name => "ψ_saturated",
        :units => "m",
        :land_field => "soilWBase",
        :description => "matric potential of soil at saturation per layer"
    ),
    :soilWBase__ψWP => orD(
        :standard_name => "ψWP",
        :long_name => "ψ_wilting_point",
        :units => "m",
        :land_field => "soilWBase",
        :description => "matric potential of soil at wiliting point per layer"
    ),
    :soilWBase__sum_wAWC => orD(
        :standard_name => "sum_available_water_capacity",
        :long_name => "sum_available_water_capacity",
        :units => "mm",
        :land_field => "soilWBase",
        :description => "total amount of water available for vegetation/transpiration"
    ),
    :soilWBase__sum_wFC => orD(
        :standard_name => "sum_wFC",
        :long_name => "sum_w_field_capacity",
        :units => "mm",
        :land_field => "soilWBase",
        :description => "total amount of water in the soil at field capacity"
    ),
    :soilWBase__sum_wSat => orD(
        :standard_name => "sum_wSat",
        :long_name => "sum_w_saturated",
        :units => "mm",
        :land_field => "soilWBase",
        :description => "total amount of water in the soil at saturation"
    ),
    :soilWBase__sum_WP => orD(
        :standard_name => "sum_WP",
        :long_name => "sum_wilting_point",
        :units => "mm",
        :land_field => "soilWBase",
        :description => "total amount of water in the soil at wiliting point"
    ),
    :soilWBase__soil_layer_thickness => orD(
        :standard_name => "soil_layer_thickness",
        :long_name => "soil_thickness_per_layer",
        :units => "mm",
        :land_field => "soilWBase",
        :description => "thickness of each soil layer"
    ),
    :states__LAI => orD(
        :standard_name => "LAI",
        :long_name => "leaf_area_index",
        :units => "m2/m2",
        :land_field => "states",
        :description => "leaf area index"
    ),
    :states__WBP => orD(
        :standard_name => "WBP",
        :long_name => "water_balance_pool",
        :units => "mm",
        :land_field => "states",
        :description => "water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation"
    ),
    :states__ambient_CO2 => orD(
        :standard_name => "ambient_CO2",
        :long_name => "ambient_CO2_concentration",
        :units => "ppm",
        :land_field => "states",
        :description => "ambient co2 concentration"
    ),
    :states__auto_respiration_growth => orD(
        :standard_name => "auto_respiration_growth",
        :long_name => "growth_respiration",
        :units => "gC/m2/time",
        :land_field => "states",
        :description => "growth respiration per vegetation pool"
    ),
    :states__auto_respiration_maintain => orD(
        :standard_name => "auto_respiration_maintain",
        :long_name => "maintenance_respiration",
        :units => "gC/m2/time",
        :land_field => "states",
        :description => "maintenance respiration per vegetation pool"
    ),
    :states__cEco_prev => orD(
        :standard_name => "cEco_prev",
        :long_name => "ecosystem_carbon_pool_previous_timestep",
        :units => "gC/m2",
        :land_field => "states",
        :description => "ecosystem carbon content of the previous time step"
    ),
    :states__c_allocation => orD(
        :standard_name => "c_allocation",
        :long_name => "cabon_allocation",
        :units => "fraction",
        :land_field => "states",
        :description => "fraction of gpp allocated to different (live) carbon pools"
    ),
    :states__c_eco_efflux => orD(
        :standard_name => "c_eco_efflux",
        :long_name => "autotrophic_carbon_loss",
        :units => "gC/m2/time",
        :land_field => "states",
        :description => "losss of carbon from (live) vegetation pools due to autotrophic respiration"
    ),
    :states__c_eco_flow => orD(
        :standard_name => "c_eco_flow",
        :long_name => "net_carbon_flow",
        :units => "gC/m2/time",
        :land_field => "states",
        :description => "flow of carbon to a given carbon pool from other carbon pools"
    ),
    :states__c_eco_influx => orD(
        :standard_name => "c_eco_influx",
        :long_name => "net_carbon_influx",
        :units => "gC/m2/time",
        :land_field => "states",
        :description => "net influx from allocation and efflux (npp) to each (live) carbon pool"
    ),
    :states__c_eco_k => orD(
        :standard_name => "c_eco_k",
        :long_name => "carbon_decomposition_rate",
        :units => "/time",
        :land_field => "states",
        :description => "decomposition rate of carbon per pool"
    ),
    :states__c_eco_npp => orD(
        :standard_name => "c_eco_npp",
        :long_name => "carbon_net_primary_productivity",
        :units => "gC/m2/time",
        :land_field => "states",
        :description => "npp of each carbon pool"
    ),
    :states__c_eco_out => orD(
        :standard_name => "c_eco_out",
        :long_name => "total_carbon_loss",
        :units => "gC/m2/time",
        :land_field => "states",
        :description => "outflux of carbon from each carbol pool"
    ),
    :states__c_flow_A_vec => orD(
        :standard_name => "c_flow_A_vec",
        :long_name => "carbon_flow_vector",
        :units => "fraction",
        :land_field => "states",
        :description => "fraction of the carbon loss fron a (giver) pool that flows to a (taker) pool"
    ),
    :states__fAPAR => orD(
        :standard_name => "fAPAR",
        :long_name => "fraction_absorbed_photosynthetic_radiation",
        :units => "fraction",
        :land_field => "states",
        :description => "fraction of absorbed photosynthetically active radiation"
    ),
    :states__frac_snow => orD(
        :standard_name => "frac_snow",
        :long_name => "fractional_snow_cover",
        :units => "fraction",
        :land_field => "states",
        :description => "fractional coverage of grid with snow"
    ),
    :states__frac_tree => orD(
        :standard_name => "frac_tree",
        :long_name => "fractional_tree_cover",
        :units => "fraction",
        :land_field => "states",
        :description => "fractional coverage of grid with trees"
    ),
    :states__max_root_depth => orD(
        :standard_name => "max_root_depth",
        :long_name => "maximum_rooting_depth",
        :units => "mm",
        :land_field => "states",
        :description => "maximum depth of root"
    ),
    :states__PAW => orD(
        :standard_name => "PAW",
        :long_name => "plant_available_water",
        :units => "mm",
        :land_field => "states",
        :description => "amount of water available for transpiration per soil layer"
    ),
    :states__root_water_efficiency => orD(
        :standard_name => "root_water_efficiency",
        :long_name => "root_water_efficiency",
        :units => "fraction",
        :land_field => "states",
        :description => "a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer"
    ),
    :states__root_water_uptake => orD(
        :standard_name => "root_water_uptake",
        :long_name => "root_water_uptake",
        :units => "mm/time",
        :land_field => "states",
        :description => "amount of water uptaken for transpiration per soil layer"
    ),
    :states__total_water => orD(
        :standard_name => "total_water",
        :long_name => "total_water",
        :units => "mm",
        :land_field => "states",
        :description => "sum of water storage across all components"
    ),
    :states__total_water_prev => orD(
        :standard_name => "total_water_prev",
        :long_name => "total_water_previous",
        :units => "mm",
        :land_field => "states",
        :description => "sum of water storage across all components in previous time step"
    ),
    :states__transpiration_supply => orD(
        :standard_name => "transpiration_supply",
        :long_name => "supply_moisture_for_transpiration",
        :units => "mm",
        :land_field => "states",
        :description => "total amount of water available in soil for transpiration"
    ),
    :states__zero_c_eco_flow => orD(
        :standard_name => "zero_c_eco_flow",
        :long_name => "zero_vector_for_c_eco_flow",
        :units => "gC/m2/time",
        :land_field => "states",
        :description => "helper for resetting c_eco_flow in every time step"
    ),
    :states__zero_c_eco_influx => orD(
        :standard_name => "zero_c_eco_influx",
        :long_name => "zero_vector_for_c_eco_influx",
        :units => "gC/m2/time",
        :land_field => "states",
        :description => "helper for resetting c_eco_influx in every time step"
    ),
    :states__ΔTWS => orD(
        :standard_name => "ΔTWS",
        :long_name => "delta_change_TWS",
        :units => "mm",
        :land_field => "states",
        :description => "change in water storage in TWS pool(s)"
    ),
    :states__ΔcEco => orD(
        :standard_name => "ΔcEco",
        :long_name => "delta_change_cEco",
        :units => "mm",
        :land_field => "states",
        :description => "change in water storage in cEco pool(s)"
    ),
    :states__ΔgroundW => orD(
        :standard_name => "ΔgroundW",
        :long_name => "delta_change_groundW",
        :units => "mm",
        :land_field => "states",
        :description => "change in water storage in groundW pool(s)"
    ),
    :states__ΔsnowW => orD(
        :standard_name => "ΔsnowW",
        :long_name => "delta_change_snowW",
        :units => "mm",
        :land_field => "states",
        :description => "change in water storage in snowW pool(s)"
    ),
    :states__ΔsoilW => orD(
        :standard_name => "ΔsoilW",
        :long_name => "delta_change_soilW",
        :units => "mm",
        :land_field => "states",
        :description => "change in water storage in soilW pool(s)"
    ),
    :states__ΔsurfaceW => orD(
        :standard_name => "ΔsurfaceW",
        :long_name => "delta_change_surfaceW",
        :units => "mm",
        :land_field => "states",
        :description => "change in water storage in surfaceW pool(s)"
    ),
    :wCycleBase__n_TWS => orD(
        :standard_name => "n_TWS",
        :long_name => "num_layers_TWS",
        :units => "number",
        :land_field => "wCycleBase",
        :description => "total number of water pools"
    ),
    :wCycleBase__n_groundW => orD(
        :standard_name => "n_groundW",
        :long_name => "num_layers_groundW",
        :units => "number",
        :land_field => "wCycleBase",
        :description => "total number of layers in groundwater pool"
    ),
    :wCycleBase__n_snowW => orD(
        :standard_name => "n_snowW",
        :long_name => "num_layers_snowW",
        :units => "number",
        :land_field => "wCycleBase",
        :description => "total number of layers in snow pool"
    ),
    :wCycleBase__n_soilW => orD(
        :standard_name => "n_soilW",
        :long_name => "num_layers_soilW",
        :units => "number",
        :land_field => "wCycleBase",
        :description => "total number of layers in soil moisture pool"
    ),
    :wCycleBase__n_surfaceW => orD(
        :standard_name => "n_surfaceW",
        :long_name => "num_layers_surfaceW",
        :units => "number",
        :land_field => "wCycleBase",
        :description => "total number of layers in surface water pool"
    ),
    :wCycleBase__o_one => orD(
        :standard_name => "o_one",
        :long_name => "type_stable_one",
        :units => "numver",
        :land_field => "wCycleBase",
        :description => "a helper type stable 1 to be used across all models"
    ),
    :wCycleBase__w_model => orD(
        :standard_name => "w_model",
        :long_name => "w model",
        :units => "symbol",
        :land_field => "wCycleBase",
        :description => "a base water cycle model to loop through the pools and fill the main or component pools needed for using static arrays. A mandatory field for every water model/pool realization"
    ),
    :wCycleBase__z_zero => orD(
        :standard_name => "z_zero",
        :long_name => "type_stable_zero",
        :units => "number",
        :land_field => "wCycleBase",
        :description => "a helper type stable 0 to be used across all models"
    ),
    :states__water_balance => orD(
        :standard_name => "water_balance",
        :long_name => "water_balance_error",
        :units => "mm",
        :land_field => "states",
        :description => "misbalance of the water for the given time step calculated as the differences between total input, output and change in storages"
    )
)

"""
    checkDisplayVariableDict(var_full)


"""
function checkDisplayVariableDict(var_full)
    sind_var_names = keys(sindbad_variables)
    if var_full in sind_var_names
        print("\nExisting catalog entry for $var_full from src/tools/sindbadVariableCatalog.jl")
        displayVariableDict(var_full, sindbad_variables[var_full])
    else
        new_d = defaultVariableInfo()
        new_d[:land_field] = split(string(var_full), "__")[1]
        new_d[:standard_name] = split(string(var_full), "__")[2]
        print("\n")
        @warn "$(var_full) does not exist in current sindbad catalog of variables. If it is a new or known variable, create an entry and add to src/tools/sindbadVariableCatalog.jl with correct details using"
        displayVariableDict(var_full, new_d, false)
    end
    return nothing
end


"""
    defaultVariableInfo(string_key = false)

a central helper function to get the default information of a sindbad variable as a dictionary
"""
function defaultVariableInfo(string_key=false)
    if string_key
        return DataStructures.OrderedDict(
            "standard_name" => "",
            "long_name" => "",
            "units" => "",
            "land_field" => "",
            "description" => ""
        )
    else
        return DataStructures.OrderedDict(
            :standard_name => "",
            :long_name => "",
            :units => "",
            :land_field => "",
            :description => ""
        )
    end
end


"""
    displayVariableDict(dk, dv, exist = true)

a helper function to display the variable information in a dict form. This also allow for direct pasting when an unknown variable is queried

# Arguments:
- `dk`: a variable to use as the key
- `dv`: a variable to use as the key
- `exist`: whether the display is for an entry that exists or not
"""
function displayVariableDict(dk, dv, exist=true)
    print("\n\n")
    if exist
        print(":$(dk)\n")
    else
        print(":$(dk) => orD(\n")
    end
    foreach(dv) do dvv
        if exist
            println("   $dvv,")
        else
            println("       $dvv,")
        end
    end
    if !exist
        print(" )\n")
    end
    return nothing
end


"""
    getFullVariableKey(var_field::String, var_sfield::String)

returns a symbol with field__subfield of land to be used as a key for an entry in variable catalog

# Arguments:
- `var_field`: land field of the variable
- `var_sfield`: land subfield of the variable
"""
function getFullVariableKey(var_field::String, var_sfield::String)
    return Symbol(var_field * "__" * var_sfield)
end


"""
    getVariableCatalogFromLand(land)

a helper function to tentatively build a default variable catalog by parsing the fields and subfields of land. This is now a legacy function because it is not recommended way to generate a new catalog. The current catalog (sindbad_variables) has finalized entries, and new entries to the catalog should to be added there directly
"""
function getVariableCatalogFromLand(land)
    default_varib = defaultVariableInfo()
    landprops = propertynames(land)
    varnames = []
    variCat = DataStructures.OrderedDict()
    for lf in landprops
        lsf = propertynames(getproperty(land, lf))
        for lsff in lsf
            keyname = Symbol(string(lf) * "__" * string(lsff))
            push!(varnames, keyname)
        end
    end
    varnames = sort(varnames)
    for var_sym in varnames
        varn = string(var_sym)
        field = split(varn, "__")[1]
        subfield = split(varn, "__")[2]
        var_dict = copy(default_varib)
        var_dict[:standard_name] = subfield
        var_dict[:long_name] = replace(subfield, "_" => " ")
        var_dict[:land_field] = field
        if field == "fluxes"
            if startswith(subfield, "c_")
                var_dict[:units] = "gC/m2/time"
                var_dict[:description] = "carbon flux as $(var_dict[:long_name])"
            else
                var_dict[:units] = "mm/time"
                var_dict[:description] = "water flux as $(var_dict[:long_name])"
            end
        elseif field == "pools"
            if startswith(subfield, "c")
                var_dict[:units] = "gC/m2"
                var_dict[:description] = "carbon content of $((subfield)) pool(s)"
            elseif endswith(subfield, "W")
                var_dict[:units] = "mm"
                var_dict[:description] = "water storage in $((subfield)) pool(s)"
            end
        elseif field == "states"
            if startswith(subfield, "Δ")
                poolname = replace(subfield, "Δ" => "")
                if startswith(poolname, " c")
                    var_dict[:units] = "gC/m2"
                    var_dict[:description] = "change in carbon content of $(poolname) pool(s)"
                else
                    var_dict[:units] = "mm"
                    var_dict[:description] = "change in water storage in $(poolname) pool(s)"
                end
            else
                var_dict[:units] = "-"
            end
        elseif startswith(subfield, "frac_")
            var_dict[:units] = "fraction"
        end
        if occursin("_k", subfield)
            if endswith(subfield, "_frac")
                var_dict[:units] = "fraction"
            else
                var_dict[:units] = "/time"
            end
        end
        if occursin("_f_", subfield)
            var_af = split(subfield, "_f_")[1]
            var_afft = split(subfield, "_f_")[2]
            var_dict[:description] = "effect of $(var_afft) on $(var_af). 1: no stress, 0: complete stress"
            var_dict[:units] = "-"
        end
        variCat[var_sym] = var_dict
    end
    return variCat
end


"""
    getVariableInfo(vari_b, t_step = day)


"""
function getVariableInfo(vari_b, t_step="day")
    vname = getVarFull(vari_b)
    return getVariableInfo(vname, t_step)
end

"""
    getVariableInfo(vari_b::Symbol, t_step = day)


"""
function getVariableInfo(vari_b::Symbol, t_step="day")
    catalog = sindbad_variables
    default_info = defaultVariableInfo(true)
    default_keys = Symbol.(keys(default_info))
    o_varib = copy(default_info)
    if vari_b ∈ keys(catalog)
        var_info = catalog[vari_b]
        var_fields = keys(var_info)
        all_fields = Tuple(unique([default_keys..., var_fields...]))
        for var_field ∈ all_fields
            field_value = nothing
            if haskey(default_info, var_field)
                field_value = default_info[var_field]
            else
                field_value = var_info[var_field]
            end
            if haskey(var_info, var_field)
                var_prop = var_info[var_field]
                if !isnothing(var_prop) && length(var_prop) > 0
                    field_value = var_info[var_field]
                end
            end
            if var_field == :units
                if !isnothing(field_value)
                    field_value = replace(field_value, "time" => t_step)
                else
                    field_value = ""
                end
            end
            var_field_str = string(var_field)
            o_varib[var_field_str] = field_value
        end
    end
    if isnothing(o_varib["standard_name"])
        o_varib["standard_name"] = split(vari_b, "__")[1]
    end
    if isnothing(o_varib["description"])
        o_varib["description"] = ""
    end
    return Dict(o_varib)
end


"""
    getVarField(var_pair)

return the field name from a pair consisting of the field and subfield of SINDBAD land
"""
function getVarField(var_pair)
    return first(var_pair)
end

"""
    getVarFull(var_pair)

return the variable full name used as the key in the catalog of sindbad_variables from a pair consisting of the field and subfield of SINDBAD land. Convention is field__subfield of land
"""
function getVarFull(var_pair)
    return Symbol(String(first(var_pair)) * "__" * String(last(var_pair)))
end


"""
    getVarName(var_pair)

return the model variable name from a pair consisting of the field and subfield of SINDBAD land
"""
function getVarName(var_pair)
    return last(var_pair)
end


"""
    whatIs(var_name::String)

a helper function to return the information of a SINDBAD variable
"""
function whatIs(var_name::String)
    if startswith(var_name, "land")
        var_name = var_name[6:end]
    end
    var_field = split(var_name, ".")[1]
    var_sfield = split(var_name, ".")[2]
    var_full = getFullVariableKey(var_field, var_sfield)
    println("\nchecking $var_name as :$var_full in sindbad_variables catalog...")
    checkDisplayVariableDict(var_full)
    return nothing
end

"""
    whatIs(var_field::String, var_sfield::String)

a helper function to return the information of a SINDBAD variable
"""
function whatIs(var_field::String, var_sfield::String)
    var_full = getFullVariableKey(var_field, var_sfield)
    println("\nchecking $var_field field and $var_sfield subfield as :$var_full in sindbad_variables catalog...")
    checkDisplayVariableDict(var_full)
    return nothing
end

"""
    whatIs(var_field::Symbol, var_sfield::Symbol)

a helper function to return the information of a SINDBAD variable
"""
function whatIs(var_field::Symbol, var_sfield::Symbol)
    var_full = getFullVariableKey(string(var_field), string(var_sfield))
    println("\nchecking :$var_field field and :$var_sfield subfield as :$var_full in sindbad_variables catalog...")
    checkDisplayVariableDict(var_full)
    return nothing
end