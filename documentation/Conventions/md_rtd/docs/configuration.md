The SINDBAD model structure and simulations are defined by a set of
**configuration files written in the .json format**. All the configuration
files for a given experiment should be saved inside a separate directory
within the **settings** directory of the SINDBAD root. An example of a
set of configuration files is in settings/cCycle\_debug directory of
root SINDBAD directory.

While developing, it is recommended to change the names of the
configuration files, so that the they can be easily associated with the
respective experiment, and to keep the experiment setup traceable and
reproduceable. For example, the file names below can be extended with
additional information, e.g. *spinup.json* can be changed to
*spinup\_cCycle\_2000years.json*.

In the following, the configuration files of SINDBAD are described briefly.

# experiment 
The central configuration file for a simulation is the **experiment
    file** *\[experiment\*.json\]*, which lists the paths to the individual configuration files.
```json
{
	"name": "FluxnetSiteOptimization",
	"domain": "FR-Hes",
	"configFiles": {
		"forcing"		: "settings/runOpti/forcing.json",
		"modelStructure": "settings/runOpti/modelStructure_cCycle_CASA.json",
		"constants"		: "settings/runOpti/constants.json",
		"modelRun"		: "settings/runOpti/modelRun.json",
		"output"		: "settings/runOpti/output.json",
		"spinup"		: "settings/runOpti/spinup.json",
		"params"		: "settings/runOpti/params.json",
		"opti"			: "settings/runOpti/opti.json"
	},
	"outputInfoFile": "sandbox/sb_runOpti/FR-Hes/FluxnetSiteOptimizationInfo4FR-Hes.json",
	"outputDirPath"	: "sandbox/sb_runOpti/FR-Hes/"
}
```
# forcing
contains the information related to each forcing
    variable as well as the name of the function to read the forcing
    data files and put the data in SINDBAD structure **f**.
```json
{
	"funName": {
		"import": "readExpStruct",
		"check": "checkInputData"
	},
	"Comments": "to get forcing from ExpStruct of TWS model",
	"size": [Inf, Inf],
	"VariableNames": ["LAI","Rn", "Rain", "Snow", "Tair", "TairDay", "PsurfDay","PET"],
	"LAI": {
		"VariableUnit": "m2 m-2",
		"SourceVariableName": "LAI",
		"SourceVariableUnit": "m2 m-2",
		"Source2sindbadUnit": "*1",
		"isCategorical": false,
		"NameShort": "LAI",
		"SpaceTimeType": "normal",
		"SourceDataProductName": "dummy",
		"DataPath": "input/testInput_TWSmodel/ExpStruct_1000pix_10years_test.mat"
    },
}
```
# modelStructure
contains the information related to the selected
    approaches for the modules, as well as the information related to
    carbon and water state variables. It also contains the paths for

-   the modules directory

-   the core (default is *coreTEM.m*)
```json
{
	"paths": 
	{
		"coreTEM":  		"model/core/coreTEM.m",
		"modulesDir": 		"model/modules/"
	},

	"modules": 
	{
		"getStates": 
		{
			"apprName": 	"getStates_simple",
			"runFull": 		true,
            "use4spinup":   false
		},
		"cFlowAct":
		{
			"apprName": 	"cFlowAct_simple",
			"runFull": 		true,
            "use4spinup":   false
		},
	},	
	"states": 
	{
		"w": 
		{
			"pools" : 
			[
				["w.Surf", 		1, 	"zeros"],
				["w.Soil", 		1, 	"zeros"],
                ...
            ],
			"combine":		[false,"wPools","zeros"]
		},
		"wd": 
		{
			"pools" : 
			[
				["WTD", 		1, 	"zeros"],
				["w.SnowFrac", 	1, 	"zeros"]
			],
			"combine":		[false,"wStates","zeros"]
		},
		"c": 
		{
		"pools" : 
		[
			["c.Veg.Root.F",	1,	"zeros"],
			["c.Veg.Root.C",	1,	"zeros"],
			["c.Veg.Wood",		1,	"zeros"],
	        ...
		],
		}
	}
}

```
# constants
contains a list of physical constants that can be
    accessed in any function within SINDBAD.
```json
{
	"constants":
	{
		"G": [0]
	}
}
```
# modelRun
contains configuration for setting up the model,
    generating the code, and running the model:

-   Information related to the time period of the model run.

-   The temporary directory for a SINDBAD simulation (*runDir*).

-   The paths of the generated core and *precOnce*.

-   If and what checks for carbon and water balance should be done.

-   The precision of the array (computation) to be used during the
	SINDBAD simulation.
```json
{
	"time": 
	{
		"step": 				"d",
		"sDate": 				"2002-01-01",
		"eDate": 				"2011-12-31",
		"nYears": 				[10],
		"nStepsDay": 			[1],
		"nStepsYear": 			[365]
	},
	"paths": {
		"runDir": 				"output/CASA/",
		"genCode": 
		{
			"coreTEM": 			"",
			"preCompOnce": 		""
		}
	},
	"flags": 
	{
		"forwardRun": 			true,
		"runGenCode": 			true,
		"genCode": 				true,
		"genRedMemCode": 		false,
		"runOpti": 				false,
		"checks": 
		{
			"massBalance": 
			{
				"carbon": 		false,
				"water": 		false
			},
			"numeric": 			false,
			"bounds": 			false
		}
	},
	"rules": 
	{
		"arrayPrecision": 		"single"
	}
}
```
#output
contains the information on the model output, and the
    list of variables that should be stored during the model simulation.
```json
{
	"variables": {
		"to": {
			"write": ["s.w.wGW", "s.w.wSnow", "s.w.wSoil","s.c.cEco"]
		}
	}
}
```
#spinup
contains the information on how to carry out the spinup,
    such as number of model years to run, or if the spinup should be
    loaded from a file, etc.
```json
{
	"sequence": 
	[
		{
			"funHandleSpin": 		"runCoreTEM",
			"funHandleStop": 		"",
			"funAddInputs": 		[false,false,true],
			"nLoops": 				10
		},
		{
			"funHandleSpin": 		"runCoreTEM",
			"funHandleStop": 		"",
			"funAddInputs": 		[true,true,false],
			"nLoops": 1
		}
	],
	"paths": 
	{
		"restartFile": 				"settings/restartFile.xxx"
	},
	"flags": 
	{
		"recycleMSC": 				true,
		"runSpinup": 				true,
		"loadSpinup": 				false
	}
}
```
#opti
contains information on the optimization, such as the
    optimization scheme, the parameters to be optimized, a list of
    observational constraints and a function to read them, etc.
```json
{
	"costFun": {
		"costName": "calcCostTWSPaper",
		"costFunsFile": "optimization/costFunctions/optionsCostFunctions.json"
	},
	"method": {
		"funName": "cmaes",
		"defaultOptimOptions": "optimization/optimSchemes/optionsOptimizationSchemes.json"
	},
	"params2opti": ["wSnwFr.CoverParam", ....],
	"checks": "",
	"constraints": {
		"funName": {
			"import": "readExpStructConstraints",
			"check": ""
		},
		"Comments": "to get calibration data from ExpStruct of TWS model",
		"VariableNames": ["TWSobs", "SWEobs", "Evapobs", "Qrobs"],
		"TWSobs": {
			"VariableUnit": "mm",
			"SourceVariableName": "TWSobs",
			"SourceVariableUnit": "mm",
			"Source2sindbadUnit": "*1",
			"isCategorical": false,
			"NameShort": "TWSobs",
			"SpaceTimeType": "normal",
			"SourceDataProductName": "GRACE mascon",
			"DataPath": "testInput_TWSmodel/ExpStruct_1000pix_10years_test.mat",
			"VariableUncertainty": {
				"Data": {
					"DataPath": "testInput_TWSmodel/ExpStruct_1000pix_10years_test.mat",
				    "funName": "readExpStructConstraintsUncert",
					"SourceVariableName": "TWSobs_uncert"
					},
				"funName": "",
				"constValue" : []
			}
}

```
In all the configuration files, comments can be added as follows.

-   Add a top-level field of json with the name/key as 'Numeric.c',
    where numeric represents the comment number (can be any number but
    try to keep it to less than 9 comments in a single file), and .c is
    the identifier for the comment in the json parser (e.g.,
    readConfigFiles.m).

	-   For example, if you have three comments in a json file with
        fields/keys 1.c, 2.c, and 3.c. While reading, the comments are
        put in as values of above fields.
```json
{
	"1.c": 						"This json defines the settings for running SINDBAD by setting 1) time period and paths 2) directory for saving generated code and info", 
	"2.c":						"3) flags for running optimization (runOpti), generate code (genCode), running generated code (true), reduce memory usage by defining ",
	"3.c":						"variables in only one time step (genRedMemCode), and check water and carbon balance and data sanity, 4) rules for array precision during model run",
}
```
-   Note that these comments are just to make the configuration file
    intuitive and self-explanatory.

-   When these conventions are followed, they are not stored in the
    'info' structure while running SINDBAD.

