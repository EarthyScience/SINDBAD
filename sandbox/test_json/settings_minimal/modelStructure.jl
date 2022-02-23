
#"1.c": "This json defines the structure of SINDBAD model run by setting 1) path of coreTEM and modules 2) user selected",    
#"2.c": "approaches 3) structure of water and carbon states",
#"3.c": "If approaches are not set here, a default of dummy (blank/empty) will be used",
#"4.c": "If structure of carbon pools are changed, make sure to be consistent in size (nLayers) with params of cCycleBase approaches",

using Sinbad
using Sinbad.Models

selected_models = [getStates_simple(), rainSnow_simpleorwhatever(), snowMelt_snowFrac(), evapSoil_demSup(), transpiration_demSup(), updateState_wSimple()]

# Might need to find a way to state spinup usage

#=
"states":
	{
		"w":
		{
			"pools" :
			[
				["w.Soil", 		4, 	100],
				["w.GW", 		1, 	0],
				["w.Snow", 		1, 	0]
			],
			"combine":		[false,"wPools",0],
			"wSoilLayersThickness":    [50, 200,750, 1000]
		},
		"wd":
		{
			"pools" :
			[
				["WTD", 		1, 	0],
				["w.SnowFrac", 	1, 	0],
				["w.Total", 	1, 	400]
			],
			"combine":		[false,"wStates",0]
		},
		"c":
		{
        "pools" :
        [["noC", 		1, 	0]
    ],
        "oldNames":		[],
        "comment": "",
		"combine":		[true,"cEco",100]
		}
	}
=#