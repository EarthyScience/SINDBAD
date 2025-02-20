As a first step of an experiment, SINDBAD preprocessor parses the settings and consolidates them into 
information that is needed for building the model structure, and running the experiment. This ```NamedTuple``` is named ```info```.

::: warning

```info``` is reserved variable name and users should not overwrite.

:::


The ```info``` is essentially the brain of SINDBAD experiment, as it stores all the information needed to read the data, run and/or optimize the model, and process the output.

### The main fields
The main fields or branches of the info structure are as follows:

-   **experiment**: name, domain, version, user, date of running, full
    paths of all other configuration files (forcing, model structure,
    constants (physical), model run, output, and optimization (optional)

-   **tem**: information on model, forcing, parameters, spinup runs,
    etc.

-   **opti**: all Information related to optimization including cost
    function, optimization method, data constraints, parameters, etc.

### Conventions on info


