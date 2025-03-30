This document provides the conventions and guidelines for development of
the framework for **[S]{.underline}trategies to [IN]{.underline}tegrate
[D]{.underline}ata and [B]{.underline}iogeochemic[A]{.underline}l
mo[D]{.underline}els** (SINDBAD) model-data integration.

Access to SINDBAD Repository
----------------------------

-   SINDBAD is **not an open source modeling framework**, and it is
    available only to the members of the Department of Biogeochemical
    Integration at the Max Planck Institute for Biogeochemistry in Jena,
    Germany.

-   SINDBAD is hosted in the git repository system (gitLab) of the
    MPI-BGC at

    -   <https://git.bgc-jena.mpg.de/sindbad/sindbad>

-   In case you do not have a gitLab account, contact
    git@bgc-jena.mpg.de to register for an account.

-   For access to the SINDBAD repository, contact either Sujan Koirala
    (<skoirala@bgc-jena.mpg.de>), Martin Jung (<mjung@bgc-jena.mpg.de>),
    or Nuno Carvalhais (<ncarval@bgc-jena.mpg.de>).

Once there is an access to the repository, **everyone (users and
developers) should create a development branch from the master. The
branch should have a unique and logical name associated with the project
or a person.**

-   The SINDBAD code under development should only be pushed to each
    **person/project's own development branch**.

-   Once the development has been tested thoroughly, a merge request to
    the master branch should be created.

    -   Merge requests to the master branch will be handled by masters
        of the repository.

-   Any one, who is new to git is highly recommended to go through the
    basic tutorials.

    -   An example of a good tutorial is at
        <https://tutorialzine.com/2016/06/learn-git-in-30-minutes>

    -   In some cases, beginner's tutorial course for git is provided by
        Fabian Gans (<fgans@bgc-jena.mpg.de>) and/or Thomas Wutzler
        (<twutz@bgc-jena.mpg.de>) at the BGI department. Check the
        presentations in the following directory and contact them
        directly for further possibilities.

        -   /Net/Groups/BGI/department/Courses/git

-   Recommended git softwares

    -   Command line with gitHub desktop (free)

    -   gitKraken (commercial or free for 12 months for github students
        account)

    -   Sourcetree (proprietary)

    -   The integrated development editor 'atom', which is available for
        all operating systems.

        -   Can be downloaded from <https://atom.io>.

        -   Atom provides inbuilt git integration. There are several
            tutorials for git integration in atom. The example below is
            recommended because\.... ;-)

            -   <https://www.youtube.com/watch?v=duQwcAEV4hk>

Developers
----------

-   Active developers:

    -   Nuno Carvalhais (<ncarval@bgc-jena.mpg.de>)

    -   Martin Jung (<mjung@bgc-jena.mpg.de>)

    -   Sujan Koirala (<skoirala@bgc-jena.mpg.de>)

    -   Tina Trautmann (<ttraut@bgc-jena.mpg.de>)

-   Previous developers:

    -   Christoph Niemann

General Conventions for Development
-----------------------------------

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

![](media/image2.png){width="6.385683508311461in"
height="2.2149529746281713in"}

Figure 1. A simple schematic of main SINDBAD components and conceptual
flow (dotted arrows are the functional calls)

Main Components
---------------

The SINDBAD framework provides a seamless integration of model and
multiple data streams using different optimization schemes. For that,
modularity regarding model structure, input/output handling and model
optimization are key. These information on selected approaches and
options are provided through configuration files, and they are stored in
a consistent way in different SINDBAD objects and structures, so that
the model technically always sees the same information. Fundamentally,
SINDBAD consists of the following components:

-   The '**info'**: The info is essentially the brain of SINDBAD.
    Technically, it is a structure that stores all the information
    needed to read the data, run and/or optimize the model, and process
    the output. This information together defines the experimental setup
    and are read and processed from different configuration files.

-   The '**TEM**': TEM stands for Terrestrial Ecosystem Model, and
    provides functionalities for running the model in several modes,
    such as for spinup, forward run, precomputation, etc.

    -   TEM includes four functions:

        -   ***runTEM***: The main function that runs the
            precomputation, spinup. Both these functions execute
            coreTEM.

        -   ***runPrecOnceTEM***: Runs the precomputation "once". It
            refers to precomputations that do not need to be redone in
            every iteration of optimization because the outcome is
            independent of the optimized parameter(s).

        -   ***runSpinupTEM***: Runs the model in spinup mode. Only the
            subset of modules that are needed for the spinup are run.
            Unlike precomputations, the spin up is redone every time in
            optimization.

        -   ***runCoreTEM***: Runs the coreTEM.

    -   The information about 'how' to run the TEM in different modes
        are parsed through the configuration files.

    -   Different modes of model run are inferred from the set of inputs
        that are passed while calling *runTEM* in *workflowTEM.m*.

    -   **Do not rename or edit the functions in the tem directory. If
        needed, consult the SINDBAD development team.**

-   The '**core**': The core driver which loops over time and executes
    all the selected approaches for biogeochemical processes. By design,
    the core can be modified by anyone to accommodate different ways to
    run the modules, e.g., different orders of modules, implicit time
    steps, etc.

    -   The default core is named coreTEM.m. **Never change/edit the
        default core.**

    -   In case the core is modified, a copy of the *coreTEM.m* should
        be created.

        -   Always follow a logical naming for the core such as
            *coreTEM\_experiment.m*.

        -   To use the modified core, the path to the core for an
            experiment has to be changed in the
            *modelStructure\[.json\]* configuration file.

-   A '**module'**: The overarching process, response, or a variable
    that may be parameterized using different approaches, e.g., surface
    runoff or GPP. A module consists of different approaches.

-   An '**approach'**: A representation or a calculation function of one
    process, response, or a variable. For example, a function that
    calculates surface runoff using overflow method, or an equation to
    calculate GPP as a function of global radiation.

    -   ***Carefully read and strictly follow the conventions on modules
        and approaches*** that are provided in the latter sections of
        this convention*.*

Main Conceptual Terms
---------------------

-   An '**experiment'**: A set-up of a model simulation with a given
    forcing, parameter, optimization scheme, spinup, forward run, etc.
    The configuration files for each of the above steps should be
    provided in the *experiment\*\[.json\]*.

-   A '**model structure'**: A set of information spanning selected
    modules and approaches from coreTEM with an associated core (i.e.
    sequence of modules, possibly nested time loops etc.). In the info,
    the fields related to model structure are identified by the string
    'ms'.

-   The '**precomputation':** Precomputation refers to computations of
    the core that can be executed outside the time loop. Essentially,
    these calculations are independent of state variables.
    Precomputations are particularly beneficial in terms of
    computational performance for a single time series or small spatial
    domains. Precomputations are being separated automatically into
    "once" and "always". "Once" refers to precomputations that do not
    need to be done in every iteration of optimization because the
    outcome is independent of the optimized parameter(s). "Always"
    refers to precomputations that need to be done in every iteration of
    optimization because the outcome depends on optimized parameter(s).
    precAlways is executed every time the core is called, but outside
    the time loop. Precomputation is represented by the string 'prec'
    throughout the code, info, and configuration files.

-   The **'generated code':** The generated code refers to the parsed
    matlab function that puts together all the executable code from all
    functional calls in the core. Given the options, the code for
    precomputation and the dynamic (core) are generated for forward run
    and spinup. The options in configuration and the fields of info
    related to code generation are identified by the string 'gen'. The
    execution time for generated core is usually faster than raw model.
    **In order for code generation to be correct, all conventions on
    variables and fields of the SINDBAD structures need to be strictly
    followed.**

-   The '**reduced memory**': Reduced memory (redMem in configuration
    and info) refers to the execution of the model in a memory-efficient
    manner. This mode is designed for simulations when the full time
    series of a variable is not needed. In this mode, all the variables
    that are not needed to be "stored" (see output configuration file)
    will be automatically changed to size *nPix*,1 instead of
    *nPix,nTix* sized arrays. This will significantly reduce the memory
    load of the model. Note that this feature is only available while
    running the generated code.

Variable Naming and Conventions
-------------------------------

-   State variables:

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

-   Indices:

    -   The time index is represented by *tix*.

    -   The space index is represented by *pix*.

    -   The index for vertical layers is represented by *zix*.

    -   The size of the domain in time, space, and vertical layers are
        *nTix*, *nPix*, and *nZix*, respectively.

-   **Never use **

    -   'tix' in an approach for anything else than the time index.

    -   the SINDBAD variables *f, fe, fx, s, d, p, info, tix, pix, zix*
        inside m files for approaches for anything else than the
        intended meaning.

    -   variable names that are used by matlab or other system command.
        From MATLAB command line, check if the variable name (VarName)
        is already defined by using

        -   exist *VarName*

-   **Avoid using**

    -   single letters as variables as far as possible for clarity.

    -   suffix of number to quickly name several variables. To keep the
        code clean and readable, use reasonable and understandable
        variable names.

Currently, we have not followed the conventions on variable naming. For
reference, a list of variables following ALMA, CMIP, and CF conventions
are put together at
<https://git.bgc-jena.mpg.de/sindbad/sindbad/wikis/variablelist>.

Main Fields and Conventions of info
-----------------------------------

The info is essentially the brain of SINDBAD. Technically, it is a
structure that stores all the information needed to read the data, run
and/or optimize the model, and process the output based on an
experimental setup that is provided by different configuration files.

The main fields or branches of the info structure are as follows:

-   **experiment**: name, domain, version, user, date of running, full
    paths of all other configuration files (forcing, model structure,
    constants (physical), model run, output, and optimization (optional)

-   **tem**: information on model, forcing, parameters, spinup runs,
    etc.

-   **opti**: all Information related to optimization including cost
    function, optimization method, data constraints, parameters, etc.

-   **postProcess:** post processing information such as spatial and
    temporal aggregations, metric calculations, etc.

A graphical representation of the full info is available at:

<http://bgc-jena.mpg.de/~skoirala/sindbad_info/inforad.html>

The conventions for different fields of info are as follows:

-   **flags:** all information that goes into flags field can only take
    two values: 0 and 1. As such, the flags should only be used for
    True/False, On/Off cases.

-   **paths:** all paths variables should point to the absolute path of
    the file. Note that this will be platform (for access to network
    drive)- and machine (for access to local drive)- dependent.

-   **variables:** all values in the variables field of info should
    contain a list.

    -   For example, *variables.to.store* should be a list of variables
        to be stored in the memory.

-   The fields listed above can be different subfields of the info at
    different depths depending on their association with the main field.
    Thus, they should always be inferred with respect to higher level
    fields.

    -   For example, a field called *.flags* can be inside *tem.model*
        or *tem.spinup*. The first set of flags is for model run, and
        second set is for spinup.

Table 1. An overview of the SINDBAD structures

+-------------+-------------+-------------+-------------+-------------+
| Name        | What?       | Size        | Main        | Special     |
|             |             |             | Convention  | Fields\*    |
+=============+=============+=============+=============+=============+
| f           | Forcing     | nPix,nTix   | f.\[VarName |             |
|             | climate     |             | \]          |             |
|             | variables   |             |             |             |
+-------------+-------------+-------------+-------------+-------------+
| fe          | Extra       | nPix,nTix   | fe.\[Module |             |
|             | forcings,   |             | Name\].\[Va |             |
|             | precomputat |             | rName\]     |             |
|             | ions        |             |             |             |
+-------------+-------------+-------------+-------------+-------------+
| fx          | Fluxes      | nPix,nTix   | fx.\[VarNam |             |
|             |             |             | e\]         |             |
+-------------+-------------+-------------+-------------+-------------+
| s           | State       | nPix,nZix   | s.c.c\[VarN | s.prev      |
|             | variables,  |             | ame\]       |             |
|             | state       |             |             |             |
|             | dependent   |             | s.cd.\[VarN |             |
|             | parameters  |             | ame\]       |             |
|             | in          |             |             |             |
|             | s.cd.p\_\*, |             | s.w.w\[VarN |             |
|             | etc.        |             | ame\]       |             |
|             |             |             |             |             |
|             |             |             | s.wd.\[VarN |             |
|             |             |             | ame\]       |             |
+-------------+-------------+-------------+-------------+-------------+
| d           | Diagnostics | nPix,nTix   | d.\[ModuleN | d.prev,     |
|             |             |             | ame\].\[Var | d.storedSta |
|             |             |             | Name\]      | tes         |
+-------------+-------------+-------------+-------------+-------------+
| p           | Parameters  | nPix,1 or a | p.\[ModuleN |             |
|             |             | scalar      | ame\].\[Var |             |
|             |             |             | Name\]      |             |
+-------------+-------------+-------------+-------------+-------------+
| *\*Can have |
| different   |
| sizes of    |
| array       |
| compared to |
| other       |
| variables   |
| in the same |
| structure.  |
| Can include |
| objects     |
| that cannot |
| strictly be |
| categorized |
| into a      |
| specifice   |
| structure.* |
+-------------+-------------+-------------+-------------+-------------+

SINDBAD Structures
------------------

Besides the info, all other variables and information needed to execute
the experiment and run the TEM are stored in different structures as
well. These structures and their corresponding conventions are explained
below. To enable modularity of the TEM, all approaches are called with
the info, and the same set of SINDBAD structures (with time step, tix,
being the difference between precomputed and dynamic parts of an
approach; see the conventions for approaches). The variables and data
needed within each approach are extracted from these structures. An
overview of the structures is provided in Table 1. All developers are
strongly recommended to read the full explanation, as well.

-   **f**: The 'f' stores the forcing variables related to climate.

    -   The forcing variables are stored as *f.\[VarName\]. *

    -   The size of a forcing variable is *nPix,nTix*.

    -   All other forcings, that are not purely climatic, should be
        stored in s, fe, and d. For example, leaf area index
        (LAI)/fraction of Photosynthetically Active Radiation (fPAR),
        that may be forced, should be copied to s.cd.LAI or s.cd.fPAR.
        This allows for flexibility of either getting the variable from
        forcing or calculating them prognostically.

-   **fe**: The 'fe' stores the pre-computed 'extra forcing\'.

    -   These are the variables within an approach that are independent
        of the state variables and can be calculated using vector
        operations outside the time loop. For example:

        -   Potential variables that are only dependent on climate
            forcing, e.g., potential snowmelt, potential
            evapotranspiration.

        -   Stressors (scalars) that are exclusively computed in
            precomputations from forcing. For example, scaled snowfall,
            if the scaling factor is not optimized.

    -   Essentially, the variables in **fe** are intermediate
        calculations that are used when the state dependent variables
        are calculated. Therefore, they do not always have meanings and
        may be cryptic:

        -   A numerical array which is used for calculating some other
            variable.

        -   The product of all stressors (water effect, light effect,
            etc.).

    -   The variables are stored in **fe** as

        -   *fe.\[ModuleName\].\[Variable\]*

            -   This makes sure that the precomputed extra forcing for a
                module is under the subfield for that particular module.

        -   The size of the variables in **fe** is *nPix,nTix*

-   **fx**: The 'fx' stores all the flux variables.

    -   The variables are added in the **fx** using the following
        convention

        -   *fx.\[VarName\]*

        -   Make sure that the name of the variables added in the **fx**
            structure are unique and intuitive.

    -   The size for variables in **fx** is *nPix,nTix*

-   **s**: The 's' stores the state variables that are either storage
    pools or storage-related diagnostics.

    -   The top-level fields in **s** are divided according to the
        element of the cycle.

        -   *s.w.\[VarName\]* for water storages

        -   *s.wd.\[VarName\]* for "diagnostic" state variables of water
            that are not storage, e.g., water table depth, snow cover
            fraction

        -   *s.c* for carbon storages

        -   *s.cd* for "diagnostic" state variables of carbon

        -   *cd* and *wd* can also store

            -   the module parameters that are dependent on states using
                the following convention:

                -   *s.cd.p\_\[ModuleName\]\_ParameterName*

                -   *s.wd.p\_\[ModuleName\]\_ParameterName*

            -   the forcing variables that are not strictly climatic.
                For example, LAI and fPAR which can either be forced or
                calculated prognostically should be stored in s.cd.

    -   The variable names for each storage should always start with the
        letter 'c' or 'w' for carbon and water storages, respectively.
        For example, *s.w.wSoil*, *s.c.cVeg*, etc. (see variable naming
        and conventions)

    -   The variables in *s.\*.* are either of size *nPix,1* or
        *nPix,nZix*.

        -   The variables are overwritten in every time step, and,
            therefore, do not have time dimension.

        -   The time series of storage variables are stored in
            *d.storedStates*.

    -   Like d (see the following part), **s** also has a special field
        *s.prev.* for storing state variables of the previous time step.

        -   for carbon storages: *s.prev\_s\_c\_\[VarName\]*

        -   for carbon states: *s.prev\_s\_cd\_\[VarName\]*

        -   for water storages: *s.prev\_s\_w\_\[VarName\]*

        -   for water states: *s.prev\_s\_wd\_\[VarName\]*

        -   For **states**, the size is nPix,1

        -   For **storages**, the size is nPix,nZix

    -   Note that some states that are an input (e.g., LAI) and not
        exclusively updated in the model may be stored in forcing
        structure **f**.

-   **d**: The 'd' stores all diagnostic variables.

    -   In general, they include variables that have some meaningful
        purposes (that would interest the users), e.g., stressors like
        demand-driven GPP, temperature effect on GPP, water effect,
        light effect, etc.

    -   **note:** Variables that refer to states (e.g. snow cover
        fraction) shall not be in **d** but in **s** (*s.cd* or *s.wd*)

    -   The variables are stored in the **d** using the following
        convention

        -   *d.\[ModuleName\].\[Variable\]*

    -   The size of the variables is *nPix,nTix*.

    -   **d has two special fields **

        -   ***d.prev*:**

            -   This is used to keep track of variables from **f**,
                **fe**, **fx** and **d** (except those from states
                **s**) from previous time step.

            -   All the fields of *d.prev.* should have size 1 in the
                time dimension.

            -   The conventions for the field names are distinct for the
                variables in different SINDBAD structures:

                -   for forcings (**f**):

                    -   *d.prev.f\_\[ VarName\]*

                    -   size is *nPix,1*

                -   for fluxes (**fx**):

                    -   *d.prev.fx\_\[VarName\]*

                    -   size is *nPix,1*

                -   for extra forcing (**fe**) and diagnostics (**d**):

                    -   *d.prev.d\_\[ModuleName\]\_\[VarName\]*

                    -   *fe.prev.fe\_\[ModuleName\]\_\[VarName\]*

                    -   size is *nPix,1*

            -   The state variables of the previous time step are stored
                in *s.prev.*

        -   **d.storedStates:**

            -   stores the time series of state variables, if needed.
                The variables in storedStates are in .*variablesToStore
                and* .*variablesTowrite*.

            -   The list of state variables to store are given in the
                configuration file for output\[.json\] in the field
                *variables.to.store*. The variables in this field should
                be

                -   *d.storedStates.\[poolName\] *

                    -   poolName is the short variable name without the
                        upper fields of structure **s**. For example,
                        *s.w.wSoil \[nPix,nZix\]* would be stored in
                        *d.storedStates.wSoil \[nPix,nZix,nTix\]*.

                -   size is *nPix,nZix,nTix*

-   **p**: The 'p' stores all the parameters of the model.

    -   The parameters that do not change in time are stored as:

        -   *p.\[ModuleName\].\[VarName\]*

    -   The scalar parameters, i.e., one value, are spatialized to
        *nPix,1* in the precomputation part of the approach (module, as
        the parameters for an approach of a module is stored in
        p.ModuleName.) to which the parameter belongs.

    -   **Note that the parameters that depend on the states are stored
        in *s.cd.p\_\** or s*.wd.p\_\**. See the explanation for the
        structure s for details.\
        **

Conventions on Modules
----------------------

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

  SN   Module Name        Module description                                                                     Remarks
  ---- ------------------ -------------------------------------------------------------------------------------- ------------------------------------------------------------------------------------------------------------
  1    cAlloc             Carbon Allocation                                                                      
  2    cAllocfLAI         Carbon Allocation as a function of LAI                                                 
  3    cAllocfNut         Carbon Allocation as a function of nutrients                                           
  4    cAllocfTreeFrac   Carbon Allocation as a function of tree cover                                          
  5    cAllocfTsoil       Carbon Allocation as a function of soil temperature                                    
  6    cAllocfwSoil       Carbon Allocation as a function of soil moisture                                       
  7    cCycle             Carbon cycle                                                                           Calculates the transfers of carbon and gets the current carbon storages
  8    cCycleBase         The base carbon cycle                                                                  Sets up the parameters for carbon transfers (called before calculating transfer, allocation, and turnover)
  9    cFlowAct           Actual carbon transfer among carbon pools                                              
  10   cFlowfpSoil        Carbon transfer as a function of soil parameters                                       
  11   cFlowfpVeg         Carbon transfer as a function of vegetation parameters                                 
  12   cTauAct            Actual carbon turnover rate                                                            
  13   cTaufLAI           Carbon turnover rate as a function of LAI                                              
  14   cTaufpSoil         Carbon turnover rate as a function of soil parameters                                  
  15   cTaufpVeg          Carbon turnover rate as a function of vegetation parameters                            
  16   cTaufTsoil         Carbon turnover rate as a function of soil temperature                                 
  17   cTaufwSoil         Carbon turnover rate as a function of soil moisture                                    
  18   EvapInt            Interception Evaporation/loss                                                          
  19   EvapSoil           Soil evaporation                                                                       
  20   EvapSub            Sublimation                                                                            
  21   getStates          get the state of storages at the beginning of the time step                            called at the beginning of a time step before any module
  22   GPPact             Actual GPP                                                                             
  23   GPPdem             Demand limited GPP                                                                     
  24   GPPfRdiff          GPP as a function of diffused radiation                                                
  25   GPPfRdir           GPP as a function of direct radiation                                                  
  26   GPPfTair           GPP as a function of air temperature                                                   
  27   GPPfVPD            GPP as a function of vapor pressure deficit                                            
  28   GPPfwSoil          GPP as a function of soil moisture                                                     
  29   GPPpot             Potential GPP                                                                          
  30   pSoil              soil parameterization                                                                  
  31   pTopo              topographical parameters                                                               
  32   pVeg               vegetation parameters                                                                  
  33   Qbase              Base runoff/Baseflow                                                                   
  34   QinfExc            Infiltration excess runoff                                                             
  35   Qint               Interflow runoff                                                                       
  36   Qsat               Saturated excess runoff                                                                
  37   Qsnw               Snowmelt                                                                               
  38   QwGRchg            Recharge to groundwater reservoir                                                      
  39   QwSoilRchg         Recharge to soil/buffer reservoir                                                      
  40   RAact              Actual autotrophic respiration                                                         
  41   RAfTair            Autotrophic respiration as a function of air temperature                               
  42   storeStates        store the states of the current time step (s.prev.) to be used in the next time step   called at the end of a time step
  43   TranAct            Actual transpiration                                                                   
  44   TranfwSoil         Transpiration as a function of soil moisture                                           
  45   wG2wSoil           water available from groundwater to flow to soil moisture reservoir (capillary flux)   
  46   wRootUptake        root water uptake                                                                      
  47   wSnwFr             Snow cover fraction of a grid cell                                                     
  48   wSoilSatFr         Saturated fraction of a grid cell                                                      
  49   WUE                water use efficiency                                                                   

Conventions on Approaches
-------------------------

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

Conventions on Functions
------------------------

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

+-----------------+-----------------+-----------------+-----------------+
| Action          | Explanation     | Comment         | Example         |
+=================+=================+=================+=================+
| agg             | Aggregate       |                 | aggOutput       |
|                 | variable        |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| calc            | Calculate or    | e.g., usage in  | calcGPPfTair    |
|                 | compute a       | approaches      |                 |
|                 | variable        |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| check           | Carry out a     |                 | checkModelStruc |
|                 | check           |                 | ture,           |
|                 |                 |                 | checkCarbonBala |
|                 |                 |                 | nce,            |
|                 |                 |                 | checkBounds     |
|                 |                 |                 |                 |
|                 |                 |                 | checkDataSanity |
+-----------------+-----------------+-----------------+-----------------+
| create          | Creating        | speeds up the   |                 |
|                 | objects such as | model           |                 |
|                 | arrays that can |                 |                 |
|                 | be copied in    |                 |                 |
|                 | subsequent      |                 |                 |
|                 | parts of the    |                 |                 |
|                 | model           |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| dyna            | **exclusively** | to calculate    | dyna\_module\_a |
|                 | used for naming | variables that  | pproach.m       |
|                 | the approaches  | are dependent   |                 |
|                 | to identify the | on states       |                 |
|                 | dynamic         |                 |                 |
|                 | time-dependent  |                 |                 |
|                 | part of an      |                 |                 |
|                 | approach        |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| edit            | Edit the        |                 | editINFOsetting |
|                 | objects.        |                 | s               |
|                 | Currently used  |                 |                 |
|                 | in editing the  |                 |                 |
|                 | fields of info  |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| gen             | Generate        |                 | genCode4Core    |
+-----------------+-----------------+-----------------+-----------------+
| get             | Get information |                 | getDates,       |
|                 | from modules    |                 | getCore         |
+-----------------+-----------------+-----------------+-----------------+
| init            | Initialize. Use |                 |                 |
|                 | only in the     |                 |                 |
|                 | context of      |                 |                 |
|                 | initializing    |                 |                 |
|                 | storage states. |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| keep            | Keep something  |                 |                 |
|                 | (don't          |                 |                 |
|                 | overwrite). Use |                 |                 |
|                 | for states to   |                 |                 |
|                 | access the      |                 |                 |
|                 | storage from    |                 |                 |
|                 | previous time   |                 |                 |
|                 | step without    |                 |                 |
|                 | overwriting     |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| prep            | Prepare an      |                 | prepForcing     |
|                 | object          |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| prec            | **exclusively** | to calculate    | prec\_module\_a |
|                 | used for naming | variables that  | pproach.m       |
|                 | the approaches  | are independent |                 |
|                 | to identify the | of states and   |                 |
|                 | precomputation  | time            |                 |
|                 | part            |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| read            | Read            |                 | readParamsConfi |
|                 | information     |                 | g               |
|                 | from files      |                 |                 |
|                 |                 |                 | readOutputConfi |
|                 |                 |                 | g               |
|                 |                 |                 |                 |
|                 |                 |                 | readRestartfile |
+-----------------+-----------------+-----------------+-----------------+
| run             | Run model or    |                 | runModel        |
|                 | spinup or       |                 |                 |
|                 | optimizer       |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| set             | Set or modify   |                 | setTime         |
|                 | contents of     |                 |                 |
|                 | Info based on   |                 |                 |
|                 | config files    |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| setup           | Setting         |                 | setupModelStruc |
|                 | something up,   |                 | ture            |
|                 | often related   |                 |                 |
|                 | to conceptual   |                 | setupExperiment |
|                 | model           |                 |                 |
|                 | components      |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| store           | Store the full  |                 | storeStates     |
|                 | time-series of  |                 |                 |
|                 | a state/flux    |                 |                 |
|                 | variable in     |                 |                 |
|                 | memory          |                 |                 |
+-----------------+-----------------+-----------------+-----------------+
| write           | Write to file   |                 | writeStates     |
+-----------------+-----------------+-----------------+-----------------+

Conventions on Documentation
----------------------------

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

-   All mathematical equations should be written in the comments or near
    where the equation is coded. This is necessary to track if there is
    error in the intended formulation.

-   Detailed comments should be inserted throughout the code when
    complicated steps need to be taken.

-   Later, the code comments will be converted to official documentation
    using mtoc++ and doxygen (<https://github.com/mdrohmann/mtocpp> and
    <http://www.ians.uni-stuttgart.de/MoRePaS/software/mtocpp/docs/tools.html>)

Configuration Files of SINDBAD
------------------------------

The SINDBAD model structure and simulations are defined by a set of
configuration files written in the .json format. All the configuration
files for a given experiment should be saved inside a separate directory
within the **settings** directory of the SINDBAD root. An example of a
set of configuration files is in settings/cCycle\_debug directory of
root SINDBAD directory.

While developing, it is recommended to change the names of the
configuration files, so that the they can be easily associated with the
respective experiment, and to keep the experiment setup traceable and
reproduceable. For example, the file names below can be extended with
additional information, e.g. *spinup.json* can be changed to
*spinup\_cCycle\_2000years.json*.

-   The central configuration file for a simulation is the **experiment
    file** *\[experiment\*.json\]*, which lists the paths of the
    following configuration files.

-   **forcing**: includes the information related to each forcing
    variable as well as the name of the function to read the forcing
    data files and put the data in SINDBAD structure **f**.

-   **modelStructure**: contains the information related to the selected
    approaches for the modules, as well as the information related to
    carbon and water state variables. It also contains the paths for

    -   the modules directory

    -   the core (default is *coreTEM.m*)

-   **constants**: contains a list of physical constants that can be
    accessed in any function within SINDBAD.

-   **modelRun**: includes configuration for setting up the model,
    generating the code, and running the model:

    -   Information related to the time period of the model run.

    -   The temporary directory for a SINDBAD simulation (*runDir*).

    -   The paths of the generated core and *precOnce*.

    -   If and what checks for carbon and water balance should be done.

    -   The precision of the array (computation) to be used during the
        SINDBAD simulation.

-   **output**: contains the information on the model output, and the
    list of variables that should be stored during the model simulation.

-   **spinup**: contains the information on how to carry out the spinup,
    such as number of model years to run, or if the spinup should be
    loaded from a file, etc.

-   **opti**: contains information on the optimization, such as the
    optimization scheme, the parameters to be optimized, a list of
    observational constraints and a function to read them, etc.

In all the configuration files, comments can be added as follows.

-   Add a top-level field of json with the name/key as 'Numeric.c',
    where numeric represents the comment number (can be any number but
    try to keep it to less than 9 comments in a single file), and .c is
    the identifier for the comment in the json parser (e.g.,
    readConfigFiles.m).

    -   For example, if you have three comments in a json file with
        fields/keys 1.c, 2.c, and 3.c. While reading, the comments are
        put in as values of above fields.

-   Note that these comments are just to make the configuration file
    intuitive and self-explanatory.

-   When these conventions are followed, they are not stored in the
    'info' structure while running SINDBAD.
