# Todo list

### new

- change order of the model based on order in modelStructure

- clean exports, move them to jl files *DONE*

- get the forcing size (time) and deal with the static variables and variables with depth dimension.
- handle dates with model simulation and forcing, i.e., run the model for a sub-slice of forcing time series
  - generate forcing for spinup, esp. picking a random full year from the full forcing time series or calculating the mean seasonal cycle
- Lossfunctions
  - allow picking loss function metric from json
  - do spatio-temporal aggregation needed for cost functions
- time series of Arrays *DONE* --> need to figure out a way to save a matrix with ntime * nlayer size... now is a vector of ntime with a vector of nlayer in each time step # DONE
- load and overwrite the default parameters.. in other words, run the model with optimized/saved parameter set


## Sujan

- fix water balance error in the first time step *DONE*
- include deltaSnowW *DONE*
- include deltaSurfaceW *DONE*

- cleanup models
  - groundWRecharge *DONE*
  - soilProperties: ask lazaro how I can use the additional function and pass the parameter of the main model
  - surfaceRunoff *DONE*
  - saturationExcess *DONE*
  - overland *DONE*
  - infExcess *DONE*
  - rootwateruptake *DONE*
  - drainage *DONE*
  - groundWSoilWInteraction *DONE*
  - groundWsurfaceWInteraction*DONE*
  - gppAirT *DONE*
  - aRespiration *DONE*
  - cAllocation... *DONE*


## Lazaro

- doing the forward run from experiment *DONE*
- remove comments from json (only works for top-level comments. Should extend for nested keys) *DONE up to second level*
- update JSON package to use the latest one
  - maintain order of models when reading from json and converting to namedtuple. Necessary for cCycle. *DONE*
- add settype function handle to helpers so that types can be changed on the go *DONE*
- filtering the outputs based on opti and output[json] *DONE* for output. Needs work for optim *DONE*
