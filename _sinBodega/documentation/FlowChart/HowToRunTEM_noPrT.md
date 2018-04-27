---
geometry: margin=2cm
breaklines: true
---
# HowToRunTEM
    The main script to run the model


## 1. temFullSetup
    set up the info with all the model settings and forcings

### 1.1 temInfo
    set up time information
    set up spinup info[grph.pdf](/uploads/e8e524faae9334a515f37b5c98dfc09d/grph.pdf)
    load or do spin up
    setup info on carbon and water pools, and whether to savestates
    info on to generate and run the generated code

### 1.2 temApproaches
    set the module approaches/methods
    either default
    or user-defined ones in info
* **_GetModuleNamesFromCore_**
        
		Get the non-standard/default modules set in the ms flag of the info
    * **_GetMfunctionContents_**

            In this case, just gets the content of core.m to get the list of all the modules called

### 1.3 temParams
    Get the parameter variable names and values from excel files of the the selected modules


### 1.4 temHelpers
    define zeros, ones and nans matrices with same size as the forcing/domain
    information on the size and ID of carbon pools

### 1.5 temStatesToSave
    prepare the list of which states to save
    based on savestates flag
    need to changes things here when new storages are added

### 1.6 SetupInfoModelStructure
    put together all info on modules, core, precomp, and so on
    core.m is hardcoded here
* **_GetModuleNamesFromCore_**
        
		Get the non-standard/default modules set in the ms flag of the info
    * **_GetMfunctionContents_**

            In this case, just gets the content of core.m to get the list of all the modules called
* **_ImportPrecsModules_**
        
        Goes through each of the modules with prefix "prec_", and get the contents of those file into precs structure       
		Goes through the main module of each method, and get the contents in modules structure
    * **_GatherCode_**

            has '/' hardcoded
        * **_GetMfunctionContents_**

                gets the content of m file at a given absolute path
                calls the same function from inside
                may be some  necessary magic?
* **_GetInputOutputFromCode_**
        
		done twice
		use the precs structure from ImportPrecsModules and identify inputs and outputs for each precomputation module
        use the modules structure from ImportPrecsModules and identify inputs and outputs for each module
* **_GetAllInputsOutputs_**
 
        use the precs and modules structure from ImportPrecsModules and identify unique inputs and outputs for all modules
* **_GetVariablesToRemember_**

        Not clear what this does
    * **_splitZstr_**

            splits a string with a given delimiter
* **_CheckPrecompAlways_**

        check if a precomputation part of a module needs to be calculated all the times.
        This happens when a precomputation part has an optimization parameter.
        the doalways flag for such prec module is set to 1
* **_WriteCode_**

        Generates the code. Core is renamed as core_expName.m
        deletes the existing file and rewrites a new one with every run
        get the contents from precs and modules and writes it to the above file
        from line 140 onwards, has some hard coded lines for auto resp and CCycle, relevant to the spinup --> does not look clean at all
    * **_splitZstr_**

            splits a string with a given delimiter
* **_check_ModelIntegrity_**

        Compatibility is here simply assessed by checking if all inputs from fe,fx,d,s are also some output of the same or another function (order of computations is not checked);
        returns 1 for compatible and 0 for incompatible


## 2. tem
    gets the info, runs the model, saves the states, and so on

### 2.1 doSpinUp
    runs the model for spin up
* **_mkSpinUpData_**
        
		prepare the spin-up data
        takes data from every variable for each year and converts it to some "synthesis" data based on number of time steps in mkSpinUpYear
        saves a copy of info and fSpin/InfoSpin
    * **_mkSpinUpYear_**

            Makes data for each year using number of time steps per year from info.timeScale.stepsPerYear
            uses den to calculate the mean?
        * **_mkHvec_**

                Creates a vector of data (horizontal or vertical)
        * **_isleapyear_**

                Checks if a year is a leap year
* **_temHelpers_**
        
		define zeros, ones and nans matrices with same size as the forcing/domain
        information on the size and ID of carbon pools
* **_initTEMStruct_**
        
		Initialize the arrays for allocation, and set initialize storages to default values
        In the doSpinUp case, the following modules are called to initialize the storage and allocation pools
    * **_PreAllocate_**

            initialize carbon allocation pools
            also the variables in the saveState of info
        * **_splitZstr_**

                splits a string with a given delimiter
    * **_InitializeVariables_**

            Initialize the storage variables
            Probably, need to set the new  storages as well
            Also the soil moisture effects on GPP are initialized here
        * **_initCpools_**

                Set all carbon cycle pools to zero
                the names of the carbon cycle pools are hard written here
        * **_initSMpools_**

                Set the SM value for each soil layer to iniAWC * the height of soil layer
    * **_CheckInitialisedStates_**

            check if the variables with s. have been initialized
            check if the variables have been initialized but now used
* **_runModel_**
        
		Runs the model with spinup data and info
        runModel(fSU,feSU,fxSU,sSU,dSU,p,infoSpin,1,0,0)
        Only does the precomp, flag 1 for DoPrec0
        does it for all precomp scripts with doalways flag as 0
        For wPools 
        runModel(fSU,feSU,fxSU,sSU,dSU,p,infoSpin,0,1,0)
        flag DoCore is 1
        runs the core
        uses hard coded modules for CCycle and Autoresp	(Prec_AutoResp_ATC_A','Prec_AutoResp_ATC_B'
		,'Prec_AutoResp_ATC_C','Prec_CCycle_CASA) for Use4SpinUP flag
        why are there so many carbon cycle stuff hard-coded into runmodel (a question)?
        if CCycle_CASA is the info.approaches in the doSpinup, it runs the hard coded part above using Use4SpinUP flag
    * **_core_**

            runs every module in a fixed order
            called for every time step
        * **_Module 1_**

                module for a given process
        * **_Module 2_**
        * **_Module 3_**
        * **_..._**
* **_CASA\_fast_**
        
		only if CCycle_CASA is used
* **_CASA\_forceEquilibrium_**
        
		only if CCycle__forceEquilibrium is used

### 2.2 initTEMStruct
    In this case, the info and results are passed into this script
    sets the storages and allocation from the output of spin up run

### 2.3 runModel
    runs twice
    for precomp runModel(f,fe,fx,s,d,p,info,1,0,0)
    for core runModel(f,fe,fx,s,d,p,info,0,1,0)

* **_core_**
        
		runs every module in a fixed order
        called for every time step
    * **_Module 1_**
    * **_Module 2_**
    * **_Module 3_**
    * **_..._**

### 2.4 temAggStates
    saves overwritten states into time series
    uses info.variables.aggStates
    for some reason, the carbon pools to aggregate are hard-coded here 
	('cVeg','cLitter','cSoil','cLeaf','cWood','cRoot','cMisc','cCwd',
	'cLitterAbove','cLitterBelow','cSoilFast','cSoilMedium','cSoilSlow','cTotal')

### 2.5 CheckCarbonBalance
    checks the carbon balance

### 2.6 CheckWaterBalance
    checks the water balance
