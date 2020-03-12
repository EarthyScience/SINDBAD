# General

-   Always follow all the conventions in this document. In case there is
    a question on clarification, ask an experienced developer.

-   Maintain associations between function names and field names of the
    'info'. For example,

    -   Optimization is abbreviated to opti in info. So, a function that
        prepares the optimization should be prepOpti.m rather than
        prepare\_Optimization.m.

    -   The model is referred to as tem. The functions that runs the
        model is named runTEM.m rather than runModel.m.

-   Consider the perspective of "someone else" who needs to "modify how"
    things are done with respect to "something"; i.e., tangibility of
    the variables, function names, and so on.

    -   For example,

        -   a function calculates the outflow for a pool based on
            different mathematical formulations. If the output flux is
            say baseflow (Qbase) from groundwater (wGW) storage. For a
            linear function, use the name Qbase\_linwGW.m

        -   A variable should be named in a way that explains what is
            being done. For GPP as a function of Tair should be GPPfTair
            = ....

    -   for making the code intuitive and maintaining the integrity of
        the model.

-   Always report inconsistencies, bugs, and error in the code to the
    development team.

    -   This should always be done by creating an issue in gitLab.


# Variables


-   The state variables of an element are identified with the
    starting letter of the element at the beginning of a variable
    name. 'c' and 'w' are used for carbon and water state variables,
    respectively.

    -   For example, soil moisture storage is name *wSoil*.
        Vegetation carbon pool is represented as *cVeg*.

-   All the water storages are represented by *wPools*.

-   All the carbon pools are represented by a single variable
    *cEco*, which may contain *cVeg*, *cRoot*, and so on.

    -   Note that cEco is not the total carbon storage. It is a
        variable that has all the component pools in one array. For
        example, if there are 14 pools (nZix) and 1000 pixels
        (nPix), the size of cEco for 1 time step is 1000,14,1.

    -   This variable is only generated when combinePools option is
        set to true in modelStructure\[.json\] configuration file.


-   The time index is represented by *tix*.

-   The space index is represented by *pix*.

-   The index for vertical layers is represented by *zix*.

-   The size of the domain in time, space, and vertical layers are
    *nTix*, *nPix*, and *nZix*, respectively.

**Never use**

-   'tix' in an approach for anything else than the time index.

-   the SINDBAD variables *f, fe, fx, s, d, p, info, tix, pix, zix*
    inside m files for approaches for anything else than the
    intended meaning.

-   variable names that are used by matlab or other system command.
    From MATLAB command line, check if the variable name (VarName)
    is already defined by using

    -   exist *VarName*

**Avoid using**

-   single letters as variables as far as possible for clarity.

-   suffix of number to quickly name several variables. To keep the
    code clean and readable, use reasonable and understandable
    variable names.

Currently, we have not followed the conventions on variable naming. For
reference, a list of variables following ALMA, CMIP, and CF conventions
are put together at
[https://git.bgc-jena.mpg.de/sindbad/sindbad/wikis/variablelist]{https://git.bgc-jena.mpg.de/sindbad/sindbad/wikis/variablelist}.


# Modules
-   Each module has a separate directory.

    -   The directories are named in a logical way to provide key
        information on the overarching process and the main function of
        the module.

-   For calculating the effect of one variable on the other, the modules
    are named in three parts:

    -   The first part indicates the overarching process or a
        biogeochemical variable, e.g. *GPP*

    -   The second, optional part is additional information that relates
        the first and third part, e.g.

        -   *f*: first part is the function of third part

        -   *2*: direction of a flow (e.g., wSoil2wGW for a transfer
            from soil moisture storage to groundwater pool).

    -   The third part is the main driver such as temperature, or an
        object like soil evaporation component of evapotranspiration.

    -   For example:

        -   *GPPfTair* - GPP as function of air temperature)

        -   *wG2wSoil* -- Groundwater flow to soil (capillary rise)

-   Hydrological fluxes are often starting with **Q**, e.g., *Qsnw* for
    snowmelt, *Qsat* for saturation excess runoff.

-   All evapotranspiration components, except transpiration, start with
    **Evap** and end with the component, e.g., *EvapSoil*.

-   **Act** is used at the end of variable name to represent the actual
    amount. For example, *GPPAct* includes the effect of temperature,
    soil moisture etc. on the potential GPP.

-   Carbon cycle modules start with the letter 'c'.

-   A short summary of the modules currently available in SINDBAD is in
    the following table.

Table 2. A list of SINDBAD Modules

| SN | Module Name      | Module description                                                                   | Remarks                                                                                                    |
|----|------------------|--------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------|
| 1  | cAlloc           | Carbon Allocation                                                                    |                                                                                                            |
| 2  | cAllocfLAI       | Carbon Allocation as a function of LAI                                               |                                                                                                            |
| 3  | cAllocfNut       | Carbon Allocation as a function of nutrients                                         |                                                                                                            |
| 4  | cAllocfTreeFrac | Carbon Allocation as a function of tree cover                                        |                                                                                                            |
| 5  | cAllocfTsoil     | Carbon Allocation as a function of soil temperature                                  |                                                                                                            |
| 6  | cAllocfwSoil     | Carbon Allocation as a function of soil moisture                                     |                                                                                                            |
| 7  | cCycle           | Carbon cycle                                                                         | Calculates the transfers of carbon and gets the current carbon storages                                    |
| 8  | cCycleBase       | The base carbon cycle                                                                | Sets up the parameters for carbon transfers (called before calculating transfer, allocation, and turnover) |
| 9  | cFlowAct         | Actual carbon transfer among carbon pools                                            |                                                                                                            |
| 10 | cFlowfpSoil      | Carbon transfer as a function of soil parameters                                     |                                                                                                            |
| 11 | cFlowfpVeg       | Carbon transfer as a function of vegetation parameters                               |                                                                                                            |
| 12 | cTauAct          | Actual carbon turnover rate                                                          |                                                                                                            |
| 13 | cTaufLAI         | Carbon turnover rate as a function of LAI                                            |                                                                                                            |
| 14 | cTaufpSoil       | Carbon turnover rate as a function of soil parameters                                |                                                                                                            |
| 15 | cTaufpVeg        | Carbon turnover rate as a function of vegetation parameters                          |                                                                                                            |
| 16 | cTaufTsoil       | Carbon turnover rate as a function of soil temperature                               |                                                                                                            |
| 17 | cTaufwSoil       | Carbon turnover rate as a function of soil moisture                                  |                                                                                                            |
| 18 | EvapInt          | Interception Evaporation/loss                                                        |                                                                                                            |
| 19 | EvapSoil         | Soil evaporation                                                                     |                                                                                                            |
| 20 | EvapSub          | Sublimation                                                                          |                                                                                                            |
| 21 | getStates        | get the state of storages at the beginning of the time step                          | called at the beginning of a time step before any module                                                   |
| 22 | GPPact           | Actual GPP                                                                           |                                                                                                            |
| 23 | GPPdem           | Demand limited GPP                                                                   |                                                                                                            |
| 24 | GPPfRdiff        | GPP as a function of diffused radiation                                              |                                                                                                            |
| 25 | GPPfRdir         | GPP as a function of direct radiation                                                |                                                                                                            |
| 26 | GPPfTair         | GPP as a function of air temperature                                                 |                                                                                                            |
| 27 | GPPfVPD          | GPP as a function of vapor pressure deficit                                          |                                                                                                            |
| 28 | GPPfwSoil        | GPP as a function of soil moisture                                                   |                                                                                                            |
| 29 | GPPpot           | Potential GPP                                                                        |                                                                                                            |
| 30 | pSoil            | soil parameterization                                                                |                                                                                                            |
| 31 | pTopo            | topographical parameters                                                             |                                                                                                            |
| 32 | pVeg             | vegetation parameters                                                                |                                                                                                            |
| 33 | Qbase            | Base runoff/Baseflow                                                                 |                                                                                                            |
| 34 | QinfExc          | Infiltration excess runoff                                                           |                                                                                                            |
| 35 | Qint             | Interflow runoff                                                                     |                                                                                                            |
| 36 | Qsat             | Saturated excess runoff                                                              |                                                                                                            |
| 37 | Qsnw             | Snowmelt                                                                             |                                                                                                            |
| 38 | QwGRchg          | Recharge to groundwater reservoir                                                    |                                                                                                            |
| 39 | QwSoilRchg       | Recharge to soil/buffer reservoir                                                    |                                                                                                            |
| 40 | RAact            | Actual autotrophic respiration                                                       |                                                                                                            |
| 41 | RAfTair          | Autotrophic respiration as a function of air temperature                             |                                                                                                            |
| 42 | storeStates      | store the states of the current time step (s.prev.) to be used in the next time step | called at the end of a time step                                                                           |
| 43 | TranAct          | Actual transpiration                                                                 |                                                                                                            |
| 44 | TranfwSoil       | Transpiration as a function of soil moisture                                         |                                                                                                            |
| 45 | wG2wSoil         | water available from groundwater to flow to soil moisture reservoir (capillary flux) |                                                                                                            |
| 46 | wRootUptake      | root water uptake                                                                    |                                                                                                            |
| 47 | wSnwFr           | Snow cover fraction of a grid cell                                                   |                                                                                                            |
| 48 | wSoilSatFr       | Saturated fraction of a grid cell                                                    |                                                                                                            |
| 49 | WUE              | water use efficiency                                                                 |                                                                                                            |



# Approaches

-   Each approach for a given module should have its own sub-directory.

-   The calculations for an approach can either be written in one matlab
    function ('full'), or they can be split into two parts in order to
    improve computational efficiency:

    -   parts that can be precomputed ('prec')

    -   parts that are state dependent ('dyna')

-   Thus, there should be the following files within the approach's
    sub-directory:

    -   The '**full**' file for the approach

        -   includes the full code of the approach with precomputations
            and dynamic calculations.

        -   An implementation of a new approach should always be done
            with the full file.

        -   The full file is named as:

            -   *\[ModuleName\]\_\[ApproachName\].m*, e.g.,
                *cAlloc\_Fix.m*

            -   This function is called from within the time loop. So,
                it includes *tix* in the input arguments.

                -   *function \[f,fe,fx,s,d,p\] =
                    cAlloc\_Fix(f,fe,fx,s,d,p,info, tix)*

        -   SINDBAD can be forced to use the full version by setting the
            *runFull* option in the *modelStructure\[.json\]*
            configuration file to *True* .

    -   Instead of/in addition to the full approach file, it is possible
        to split the full code into two .m files with precomputations
        and dynamic calculations separated as:

        -   '**prec**'

            -   a .m file with the code and calculations that are
                **independent of states** and can be ***prec***omputed
                outside the time loop.

                -   *prec\_\[ModuleName\]\_\[ApproachName\].m,* e.g.,
                    *prec\_cAlloc\_Fix.m *

                -   This function is independent of state and is not
                    called from within the time loop. So, it does not
                    include *tix* in the inform within the time loop.
                    So, it does not include *tix* in the input
                    arguments.

                    -   function \[f,fe,fx,s,d,p\] =
                        prec\_cAlloc\_Fix(f,fe,fx,s,d,p,info)

        -   '**dyna**'

            -   a .m file with the code and calculations that are
                **dependent on states (time)** and should be computed
                within the time loop. These time-dependent calculations
                are referred as ***dyna***mic in time, and named as:

                -   *dyna\_\[ModuleName\]\_\[ApproachName\].m*, e.g.,
                    *dyna\_cAlloc\_Fix.m*

                -   Similar to the 'full' function, this function is
                    called from within the time loop. So, it includes
                    *tix* in the input arguments.

                    -   function \[f,fe,fx,s,d,p\] =
                        dyna\_cAlloc\_Fix(f,fe,fx,s,d,p,info, tix)

        -   In case the ***prec*** and ***dyna*** files are not
            provided, the ***runFull* option must be set to True** in
            the *modelStructure\[.json\]* configuration file.

    -   If needed, a **parameter file** that includes information on the
        parameters, their values, value ranges, etc.

        -   The format should be *.json*.

        -   The file is named as *\[ModuleName\]\_\[ApproachName\].json*

        -   If no parameter files are provided, the parameters of the
            model cannot be changed, i.e. optimized, and need be
            hard-coded in the approach file(s).

            -   See
                model/modules/Qint/Qint\_Bergstroem/Qint\_Bergstroem.json
                for an example.

-   Besides, two special approaches exist for each module:

    -   A '**dummy'** approach: A dummy approach is an empty approach.

        -   It does not have any calculation and does not calculate any
            output variable.

            -   Therefore, effectively, choosing a dummy approach is the
                same as switching off a module without changing the list
                of modules executed in the core.

        -   The dummy approach is the **default for all modules**. Only
            the modules for which approaches other than dummy have been
            set in the *modelStructure\[.json\]* are turned 'on'.

        -   **When a new module is implemented, a dummy approach should
            always be created.**

        -   **Dummy approaches do not need *prec* and *dyna* functions
            and can only have the full function with no content.**

    -   A '**none'** approach: A none approach is used when the output
        variable refers to 'no effect', for e.g., when a calculated
        stress scalar is always set to 1.

        -   **It is not necessarily equivalent to the "dummy".**

-   The *name of an approach* (full, prec, and dyna) should always
    include the name of the module as,

    -   \[ModuleName\]\_\[ApproachName\].m

-   The ApproachName part of the name should reflect the module,
    actions, calculated variables, and/or include information on

    -   **How** a variable is calculated **using what**

        -   e.g., *Qsnw\_nonlinRad.m* for snowmelt based on non-linear
            function of radiation. Note than Qsnw is the name of the
            module.

    -   **Which method** is being used to do the calculation

        -   e.g., *TranAct\_TEA.m* for calculation of actual
            transpiration based on the TEA algorithm.

    -   The **author's last name and year** of publication if the
        approach is based on a previous study,

        -   as \[*ModuleName\]\_LastNameYYYY.m*

        -   e.g. *Qbas\_Zhang2008.m* for calculation of saturated runoff
            based on Zhang et al. (2008).

-   **Each approach should have the same input and output arguments**.

    -   e.g. *function \[f,fe,fx,s,d,p\] =
        \[ModuleName\]\_\[ApproachName\](f,fe,fx,s,d,p,info, tix)*

-   Each approach function needs to have an 'end' or 'return' in the
    last line.

-   **Never use: **

    -   **'\_' within the \[ApproachName\].**

    -   the variables '*f,fe,fx,s,d,p,info,tix*' inside the approaches'
        .m files

# Functions

This convention of functions is only applicable to all functions except
the **modules and approaches**, which shoud **follow their own
conventions** described beforehand.

-   The function naming should follow a clear and tangible pattern of
    \[Action\]\[Object\].

    -   The name of the action should always start with a small letter
        for typeability/writability.

    -   The name of the object should always start with a capital letter
        for readability.

-   For consistency, the actions and their purposes are defined clearly
    in the following table.

    -   If there are missing actions, then such actions should be
        proposed to core developer before being implemented.

-   The objects may include:

    -   A metric such as the model cost based on a specific study. For
        example, a function named calcCostTWSPaper calculates the model
        cost as described in the TWS paper.

    -   conceptual model components such as model output or structure,
        e.g., editINFOsettings.m

    -   the function's purpose, i.e., the use of the output of the
        function, e.g., *aggObs4Optimization.m*.

-   The naming of the objects, especially for functions setting up the
    'info' should reflect the naming conventions used in the
    organization of the info.

Table 3. Actions used in naming functions

| Action           | Explanation                                                                                                        | Comment                                                        | Example                                              |
|------------------|--------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------|------------------------------------------------------|
| agg              | Aggregate variable                                                                                                 |                                                                | aggOutput                                            |
| calc             | Calculate or compute a variable                                                                                    | e.g., usage in approaches                                      | calcGPPfTair                                         |
| check            | Carry out a check                                                                                                  |                                                                | checkModelStructure, checkCarbonBalance, checkBounds, checkDataSanity |
| create           | Creating objects such as arrays that can be copied in subsequent parts of the model                                | speeds up the model                                            |                                                      |
| dyna             | exclusively used for naming the approaches to identify the dynamic time-dependent part of an approach              | to calculate variables that are dependent on states            | dyna_module_approach.m                               |
| edit             | Edit the objects. Currently used in editing the fields of info                                                     |                                                                | editINFOsettings                                     |
| gen              | Generate                                                                                                           |                                                                | genCode4Core                                         |
| get              | Get information from modules                                                                                       |                                                                | getDates, getCore                                    |
| init             | Initialize. Use only in the context of initializing storage states.                                                |                                                                |                                                      |
| keep             | Keep something (don’t overwrite). Use for states to access the storage from previous time step without overwriting |                                                                |                                                      |
| prep             | Prepare an object                                                                                                  |                                                                | prepForcing                                          |
| prec             | exclusively used for naming the approaches to identify the precomputation part                                     | to calculate variables that are independent of states and time | prec_module_approach.m                               |
| read             | Read information from files                                                                                        |                                                                | readParamsConfig, readOutputConfig, readRestartfile                         |
| run              | Run model or spinup or optimizer                                                                                   |                                                                | runModel                                             |
| set              | Set or modify contents of Info based on config files                                                               |                                                                | setTime                                              |
| setup            | Setting something up, often related to conceptual model components                                                 |                                                                | setupModelStructure, setupExperiment                                  |
| store            | Store the full time-series of a state/flux variable in memory                                                      |                                                                | storeStates                                          |
| write            | Write to file                                                                                                      |                                                                | writeStates                                          |

# Documentation

-   All functions and modules should be documented at the beginning with
    a fixed standard format. They should at least have the following
    fields:

    -   Usages with Inputs and Outputs

    -   Requires

    -   Purposes

    -   Conventions

    -   References

    -   Versions

The header of a function should contain at least the following:

```matlab
% Usages:
%   [s,d,info] = createStatesArrays(s,d,info)
%
% Requires:
%   + a list of variables:
%       ++ state variables: info.tem.model.variables.states.input
%   + information on whether or not to combine the pool:
%       ++ info.tem.model.variables.states.input.(sv).combine
% Purposes:
%   + Creates the arrays for the state variables needed to run the model.
 
% Conventions:
%   + d.storedStates.[VarName]: nPix,nZix,nTix
%
% Created by:
%   + Sujan Koirala (skoirala@bgc-jena.mpg.de)
%
% References:
%   +
%
% Versions:
%   + 1.0 on 17.04.2018

```
-   All mathematical equations should be written in the comments or near
    where the equation is coded. This is necessary to track if there is
    error in the intended formulation.

-   Detailed comments should be inserted throughout the code when
    complicated steps need to be taken.

-   Later, the code comments will be converted to official documentation
    using mtoc++ and doxygen (<https://github.com/mdrohmann/mtocpp> and
    <http://www.ians.uni-stuttgart.de/MoRePaS/software/mtocpp/docs/tools.html>)

