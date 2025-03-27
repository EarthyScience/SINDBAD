# SINDBAD Spinup

In SINDBAD, the **Spinup** is envisioned as a (collection of) step(s)/sequences within a bigger model simulation after which the ecosystem states and pools reach equilibrium for a given set of climate, model parameters, and land characteristics. Any changes in the data and model should be accompanied by a correspoding Spinup.

## Triggering Spinup

Spinup options are available in experiment settings file. First in the ```flags``` section as,

````json
  "flags": {
    "spinup_TEM": true,
    "store_spinup": false,
````

where 
- ```spinup_TEM``` is the flag to activate the spinup of the model.
- ```store_spinup``` is the flag to activate store the spinup results from every spinup sequence.


## Spinup Setup

The details of spinup are set through ```model_spinup``` section which looks like:
```json
  "model_spinup": {
    "restart_file": null,
    "sequence": [
      {
        "forcing": "all_years",
        "n_repeat": 1,
        "spinup_mode": "all_forward_models"
      }
    ]
  }
```
where 
- ```restart_file``` is the path to the restart file with the model states and pools from the previously saved simulation. ```null``` means no restart file.
- ```sequence``` is a vector of dictionary of spinup steps that are executed serially during the spinup of the model. Each spinup sequence consists of the 
  - ```forcing``` is the forcing variant to be used during the sequence
  - ```n_repeat``` is the number of times the sequence will be executed
  - ```spinup_mode``` denotes the spinup method. It can be run of all the selected models in the structure, a subset of it, or any other method implemented

Depending on the experiment need, many sub-sequence can be added to spinup sequence with each of them following the same pattern. 


## Which spinup methods are available

Spinup methods are stored in spinup functions within SindbadTEM. The different methods are dispatched on types generated. 

```julia
using SindbadTEM

?SindbadTEM.spinup
```

### How to add a new spinup method

Spinup methods are added as subtypes of ```SindbadSpinupMethods``` in ```SinbadSetup```. The methods defined can be listed as,

```julia
using SindbadSetup
subtypes(SindbadSetup.SindbadSpinupMethods)
```

So, the first step to adding a method is to define a subtype of ```SindbadSpinupMethods``` in ```runtimeDispatchTypes.jl``` of ```SinbadSetup```.


Once this is defined, a corresponding method has to be added in ```spinupTEM``` in ```SindbadTEM```. Strictly follow the arguments using examples provided in the current methods to implement a new method.

