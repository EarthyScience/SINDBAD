## model structure
The settings for model structure defines the building blocks of an ecosystem model for a given experiment. The settings are broadly of two sections

### Model selection
In this section, a list of model processes are put together to form an ecosystem model for an experiment. Only the processes listed below are activated during the execution of the experiment.

First a ```default_model``` is defined which list the default properties for all models which can be overwritten for each model setting.

In the ```models``` section, the selected models are listed with the ```approach``` for each model. Note that, in SINDBAD a ```model``` represents an ecosystem process while an ```approach``` means a method. 

The complete list of models and its order of call can be accessed with the variable ```sindbad_models``` which is exported by ```Sindbad``` package.

````json
{
"default_model": {
    "order": the order or an index of the model to change the internal order of sindbad_models,
    "use_in_spinup": a flag indicating if the model is used during spinup. By default, if the value is set as true, all models will be called during spinup
  },
"models": {
    "drainage": {
      "approach": This sets the approach to use for the process of drainage, e.g., "dos"
    },
    "waterBalance": {
      "approach": an approach "simple" is used,
      "use_in_spinup": and by setting false, this process is ignored during spinup
    }
  },
````
Note that the list of models should always represent a sufficient set of ecosystem processes, and not all combinations of models lead to feasible model structure due to dependencies of the processes. For instance, snow processes are irrelevant if the snowfall is not included in the model structure.

### Pools and Storages
In this section, the model setup includes the information for the pools and/or storages in the model. By definition, the pools and storage are the components of the model which contribute to the mass balance. 

Under ```pools```, each element is the main field, e.g., ```carbon``` and ```water```.


````json
"pools": {
    "carbon": {
      "combine": name of the variable to use for all carbon pools, e.g., "cEco" would be an array with which includes all carbon pools listed under components,
      "components": {
        "cVeg": {
          "Root": with a list as value with either a number of layers or a list of depths as first element, and initial pool storage in the second, e.g., [1, 25.0],
          "Wood": [1, 25.0]
        }
      },
      "state_variables": This includes a dictionary of extra variables which would be created during setup with initial value. By default, it is empty as "{}".
    },
    "water": {
      "combine": "TWS",
      "components": {
        "soilW": [[50.0, 200.0, 750.0, 1000.0], 100.0]
      },
      "state_variables": {
        "Δ": a value of 0.0 would create a variable ΔsoilW under land.states with same type as soilW
      }
    }
}
````