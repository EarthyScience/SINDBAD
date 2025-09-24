
# Model Structure Configuration {#Model-Structure-Configuration}

The `model_structure.json` file defines the building blocks of an ecosystem model for SINDBAD experiments. It consists of two main sections: model selection and pool configuration.

## Model Selection {#Model-Selection}

This section defines the ecosystem processes to be included in the experiment. Only listed processes are activated during execution.

### Default Model Settings {#Default-Model-Settings}

The `default_model` section specifies default properties for all models, which can be overridden in individual model configurations.

:::tabs

== Explanation

```json
"default_model": {
    "implicit_t_repeat": "Number of times a model runs within a single time step",
    "use_in_spinup": "Flag indicating if the model is used during spinup"
}
```


== Example

```json
"default_model": {
    "implicit_t_repeat": 1,
    "use_in_spinup": true
}
```


:::

### Model Configuration {#Model-Configuration}

The `models` section lists selected models with their corresponding approaches. In SINDBAD:
- A `model` represents an ecosystem process
  
- An `approach` represents the implementation method
  

:::tabs

== Explanation

```json
"models": {
    "process_name": {
        "approach": "Implementation method for the process",
        "use_in_spinup": "Override default spinup behavior"
    }
}
```


== Example

```json
"models": {
    "ambientCO2": {
        "approach": "forcing"
    },
    "autoRespiration": {
        "approach": "Thornley2000A"
    },
    "cAllocation": {
        "approach": "GSI"
    }
}
```


:::

::: tip Model Dependencies
- Use `standard_sindbad_models` to view the complete list of available models
  
- Ensure model combinations are feasible (some processes depend on others)
  
- Example: Snow processes require snowfall in the model structure
  

:::

## Pools and Storages {#Pools-and-Storages}

This section configures model components that contribute to mass balance calculations.

### Pool Configuration {#Pool-Configuration}

Each pool is defined under the `pools` section with its components and state variables.

:::tabs

== Explanation

```json
"pools": {
    "pool_type": {
        "combine": "Variable name for combined pool values",
        "components": {
            "component_name": [
                "Layer configuration (number of layers or depth list)",
                "Initial storage value"
            ]
        },
        "state_variables": {
            "variable_name": "Initial value"
        }
    }
}
```


== Example

```json
"pools": {
    "carbon": {
        "combine": "cEco",
        "components": {
            "cVeg": {
                "Root": [1, 25.0],
                "Wood": [1, 25.0],
                "Leaf": [1, 25.0],
                "Reserve": [1, 10.0]
            },
            "cLit": {
                "Fast": [1, 100.0],
                "Slow": [1, 250.0]
            },
            "cSoil": {
                "Slow": [1, 500.0],
                "Old": [1, 1000.0]
            }
        },
        "state_variables": {}
    },
    "water": {
        "combine": "TWS",
        "components": {
            "soilW": [[50.0, 200.0, 750.0, 1000.0], 100.0],
            "groundW": [1, 1000.0],
            "snowW": [1, 0.01],
            "surfaceW": [1, 0.01]
        },
        "state_variables": {
            "Δ": 0.0
        }
    }
}
```


:::

::: info Pool Structure
- Each pool type (e.g., carbon, water) has its own configuration
  
- Components define individual storage elements
  
- State variables track additional pool-related metrics
  

:::

::: warning Configuration Guidelines
- Ensure pool configurations match model requirements
  
- Verify initial values are within reasonable ranges
  
- Check layer configurations match forcing data dimensions
  

:::
