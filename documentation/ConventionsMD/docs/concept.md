![](media/simpleConcept.png)

Figure: A simple schematic of main SINDBAD components and conceptual flow (dotted arrows are the functional calls)
# SINDBAD Concepts
The SINDBAD framework provides a seamless integration of model and multiple data streams using different optimization schemes. For that, modularity regarding model structure, input/output handling and model optimization are key. These information on selected approaches and options are provided through configuration files, and they are stored in a consistent way in different SINDBAD objects and structures, so that the model technically always sees the same information. Fundamentally, SINDBAD consists of the following components:

## info

- The info is essentially the brain of SINDBAD.
- Technically, it is a structure that stores all the information needed to read the data, run and/or optimize the model, and processthe output.
- This information together defines the experimental setup
    and are read and processed from different configuration files.

## TEM

- TEM stands for Terrestrial Ecosystem Model, and provides functionalities for running the model in several modes, such as for spinup, forward run, precomputation, etc.

- TEM includes four functions:

    - ***runTEM***: The main function that runs the precomputation, spinup. Both these functions execute coreTEM.

    - ***runPrecOnceTEM***: Runs the precomputation "once". It refers to precomputations that do not need to be redone in every iteration of optimization because the outcome is independent of the optimized parameter(s).

    - ***runSpinupTEM***: Runs the model in spinup mode. Only the subset of modules that are needed for the spinup are run. Unlike precomputations, the spin up is redone every time in optimization.

    - ***runCoreTEM***: Runs the coreTEM.

- The information about 'how' to run the TEM in different modes are parsed through the configuration files.

- Different modes of model run are inferred from the set of inputs that are passed while calling *runTEM* in *workflowTEM.m*.

- **Do not rename or edit the functions in the tem directory. If needed, consult the SINDBAD development team.**

## core  

- The core driver which loops over time and executes all the selected approaches for biogeochemical processes.
- By design,the core can be modified by anyone to accommodate different ways to run the modules, e.g., different orders of modules, implicit time steps, etc.

- The default core is named coreTEM.m.

- **Never change/edit the default core.**

    - In case the core is modified, a copy of the *coreTEM.m* should be created.
    - Always follow a logical naming for the core such as *coreTEM\_experiment.m*.
    - To use the modified core, the path to the core for an experiment has to be changed in the *modelStructure\[.json\]* configuration file.

## module

The overarching process, response, or a variable that may be parameterized using different approaches, e.g., surface runoff or GPP. A module consists of different approaches.

## approach

A representation or a calculation function of one process, response, or a variable. For example, a function that calculates surface runoff using overflow method, or an equation to calculate GPP as a function of global radiation.

- ***Carefully read and strictly follow the conventions on modules and approaches*** that are provided in the latter sections of this convention.

## experiment

- A set-up of a model simulation with a given forcing, parameter, optimization scheme, spinup, forward run, etc.
- The configuration files for each of the above steps should be provided in the *experiment\*\[.json\]*.

## model structure

- A set of information spanning selected modules and approaches from coreTEM with an associated core (i.e. sequence of modules, possibly nested time loops etc.). 
- In the info, the fields related to model structure are identified by the string 'ms'.

## precomputation  

- Precomputation refers to computations of the core that can be executed outside the time loop. Essentially, these calculations are independent of state variables.
- Precomputations are particularly beneficial in terms of computational performance for a single time series or small spatial domains.
- Precomputations are being separated automatically into "once" and "always".
    - "Once" refers to precomputations that do not need to be done in every iteration of optimization because the outcome is independent of the optimized parameter(s).
    - "Always" refers to precomputations that need to be done in every iteration of optimization because the outcome depends on optimized parameter(s). precAlways is executed every time the core is called, but outside the time loop.

- Precomputation is represented by the string 'prec' throughout the code, info, and configuration files.

# generated code

- The generated code refers to the parsed matlab function that puts together all the executable code from all functional calls in the core.
- Given the options, the code for precomputation and the dynamic (core) are generated for forward run and spinup.
- The options in configuration and the fields of info related to code generation are identified by the string 'gen'.
- The execution time for generated core is usually faster than raw model.
- **In order for code generation to be correct, all conventions on variables and fields of the SINDBAD structures need to be strictly followed.**

# reduced memory

- Reduced memory (redMem in configuration and info) refers to the execution of the model in a memory-efficient manner.

- This mode is designed for simulations when the full time series of a variable is not needed.

- In this mode, all the variables that are not needed to be "stored" (see output configuration file) will be automatically changed to size *nPix*,1 instead of *nPix,nTix* sized arrays. This will significantly reduce the memory load of the model. 
- **Note that this feature is only available while running the generated code.**