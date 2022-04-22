# Todo list

## Lazaro

- change order of the model based on order in modelStructure
- doing the forward run from experiment # DONE
- remove comments from json (only works for top-level comments. Should extend for nested keys)
- update JSON package to use the latest one
  - maintain order of models when reading from json and converting to namedtuple. Necessary for cCycle.
- add settype function handle to helpers so that types can be changed on the go # DONE
- filtering the outputs based on opti and output[json] #DONE for output. Needs work for optim
- handle dates with model simulation and forcing, i.e., run the model for a sub-slice of forcing time series
  - generate forcing for spinup, esp. picking a random full year from the full forcing time series or calculating the mean seasonal cycle
- Lossfunctions
  - allow picking loss function metric from json
  - do spatio-temporal aggregation needed

## Sujan

- fix water balance error in the first time step # DONE
- include deltaSnowW #DONE
- include deltaSurfaceW
- cleanup models
  - groundWRecharge # DONE
  - soilProperties: ask lazaro how I can use the additional function and pass the parameter of the main model
  - surfaceRunoff
  - saturationExcess
  - overland
  - infExcess
  - rootwateruptake
  - drainage
  - groundWSoilWInteraction # DONE
  - groundWsurfaceWInteraction# DONE
  - gppAirT
