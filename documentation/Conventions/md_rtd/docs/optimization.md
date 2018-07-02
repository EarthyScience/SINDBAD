# Optimization Basics

The SINDBAD framework provides modular functionality to optimize the TEM using different optimization algorithms, cost functions, and data streams. The information related to optimization are identified with the string 'opti' in info.

- The optimization option for an experiment is turned on by setting the runOpti flag to true in modelRun.json file in the settings directory.
- The algorithm to use for an experiment is set in opti.json file in the settings directory.
- The cost function to use for an experiment is set in opti.json file in the settings directory.
- The observation constraints to use for an experiment is also set in opti.json file in the settings directory.


## Structure

The functions and library needed to optimize SINBAD are located in optimization directory in the SINDBAD root. This directory should not be used for any user-specific functions and files.

```bash
.
├── algorithms
│   ├── cmaes
│   │   ├── cmaes.m
│   │   └── options_cmaes.json
│   └── lsqnonlin
│       └── options_lsqnonlin.json
├── costFunctions
│   ├── CostMultiConstraint
│   │   ├── calcCostMultiConstraint.m
│   │   └── options_CostMultiConstraint.json
│   └── CostTWSPaper
│       ├── calcCostTWSPaper.m
│       └── options_CostTWSPaper.json
├── optimizers
│   ├── optimizeTEM.m
│   └── optimizeTEM_cmaes.m
└── utils
    └── calcCostTEM.m
```


## Algorithms

- Each algorithm should have a unique directory.
- Directory should have the same name as the matlab function for the algorithm.
- The directory for an algorithm may have
    - A matlab function for the optimization algorithm
    - A file in json format with the default options with the name as 'options_'[algorithmName].json.
    - **both files are optional in case of inbuilt matlab optimization algorithms or if the optimization is to be run with default options**.
- <span style="color:red">The existing files and directories in the algorithm directory should never be edited, moved, or renamed.</span>
- <span style="color:blue">Additional non-default options for an algorithm may be passed to the optimization experiment</span>
    - <span style="color:blue">set the path of another json file (with same format as the default one) in the field nonDefOptFile (under algorithm) in opti.json file in the settings directory.</span>
    - <span style="color:blue">These user-defined files should be saved in **other 'user' directories than the algorithms directory under main optimization directory.**</span>

## Cost Functions

- Like algorithm, each cost function should have a unique directory.

- Directory should be named in a logical way [costName] so that it reflects the cost or the study that the cost function is taken from.
- The directory of a cost functions has:
    - A matlab function that calculates the cost. This file is named as calc[CostName].m
    - An optional file in json format with the default options with the name as 'options_'CostName.json.
- <span style="color:red">The existing files and directories in the costFunctions directory should never be edited, moved, or renamed.</span>

- <span style="color:blue">Additional non-default options for a cost function may be passed to the optimization experiment</span>
    - <span style="color:blue">set the path of another json file (with same format as the default one) in the field nonDefOptFile (under costFun) in opti.json file in the settings directory.</span>
    - <span style="color:blue">These user-defined files should be saved in **other 'user' directories than the costFunctions directory under main optimization directory.**</span>

## Optimizers

- The optimizer essentially connects the model, data, cost function, and optimization algorithm.
- Each optimization algorithm can be given an optimizer.
    - The optimizer should be named as optimizeTEM_[algorithmName].m
    - If such optimizer function is not provided, the optimizeTEM function is used with default system options of the optimization algorithm.
- The optimizer calls the optimization algorithm (with user defined options) and passes ir the calcCostTEM function in the utils directory.
    - calcCostTEM runs the model and calls the cost function (with its options) and evaluates the model cost, which is minimized by the optimization algorithm.
    - <span style="color:red">calcCostTEM function should never be edited.</span>
- <span style="color:blue">**Create a copy of the optimizer when a new optimizer for a new optimization algorithm is added.**</span>