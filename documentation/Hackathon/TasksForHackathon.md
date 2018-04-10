---
geometry: margin=2cm
breaklines: true
---
# Homework before Hackathon
* Document the options that are dependent (SK)
  * Flags are defined in a different way in the new info. While coding, we may need to check if we need to have a megaflag 'e.g., ccycle=off' to disable all other flags for carbon cycle.
* hardcoded values in info (see [here](https://git.bgc-jena.mpg.de/sindbad/sindbad/wikis/infooccur) for all occurrences of 'info.')
  * for information, all occurrences of 'info.' are there. Hardcoded ones will need to be filtered and removed as we go...?
* Which variables of the info should come from config files and which are generated (:white_check_mark:  included in the proposed info)

* Conventions  :white_check_mark: 
  * Naming functions
  * Naming of Sindbad objects (info, f, de) and their fields
  * Coding Conventions wrt Model Structure --> very critical for code interpretation and generation
  * Where to put the functions? In the same m file, or same directory? e.g., functions used for Setup_Forcing

# Tasks for Hackathon
* __Clean-up (ALL)__
 * Go through all the issues and clean them.
 * Directories and files (see [Directory tree](https://git.bgc-jena.mpg.de/sindbad/sindbad/wikis/directorytree))
 * replace all old netcdf functions and commands with inbuilt matlab functions
 * replace all old string comparison (legacy) functions with the new ones from MATLAB
 * rename all existing modules using the new conventions
 * cleanup/renaming of the directories in the tools.
   * Not discussed, somehow, but can be organized according to modeling steps 
     * ReadConfig
     * ReadForcing
     * SetupInfo
     * GenerateObjects
     * GenerateCode
     * Utils
     * SpinUp
     * Optimization
     * ProcOutput
     
   
 * replace all 'i' with 'tix' (may be at the end of Hackathon)
 

* __Configuration and JSON (CN)__
  * config files and json
  * read configuration of approaches
  * info for optimization (with SK and NC)

* __Setupinfo and model structure (MJ)__

  * ensure that the new naming of modules are compatible with code generator
  * check if separators such as '_' are supported
  * implicit time steps and how to create the arrays of different sizes

* __Optimization (NC)__
  * Handling of information from parameter configuration for approaches
  * Creation of Initial matrices only once in optimization mode (reduce redundancy)
  * Handling of situation when initial values of storage are dependent on some approaches for parameters such as PTFs (with MJ?)
  * Generation of default settings for different optimization schemes and how to overwrite default values (with SK)

* __Organization of Pools and Names + Spin UP (SK)__
  * Naming and organization of states in the configuration file (with NC-matrix operation and MJ-code generation)
  * Implementation of single layered States
  * Flexibility in implementation of multiple layers for a state (e.g., multiple soil layers)
  * Prepare and filter out variables needed for spinup.
    * overwrite states instead of putting them into large matrix (with MJ)
  * different ways of preparing the forcing and running spinup (with NC)
    * MSC, random years, n times the years, etc.
* __I/O interface (TT)__
  * Check how it is done in the optimization test script (for Input, GetGlobalForcing.m)
  * Put together the plotting functions that are used for output (low prio)
 
