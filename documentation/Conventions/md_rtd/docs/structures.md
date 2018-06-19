# What are SINDBAD Structures?

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


Table 1. An overview of the SINDBAD structures

| Name           	| What?                                                         	| Size               	| Main Convention           	| Special Fields*        	|
|----------------	|---------------------------------------------------------------	|--------------------	|---------------------------	|------------------------	|
| f              	| Forcing climate variables                                     	| nPix,nTix          	| f.[VarName]               	|                        	|
| fe             	| Extra forcings, precomputations                               	| nPix,nTix          	| fe.[ModuleName].[VarName] 	|                        	|
| fx             	| Fluxes                                                        	| nPix,nTix          	| fx.[VarName]              	|                        	|
| s              	| State variables, state dependent parameters in s.cd.p_*, etc. 	| nPix,nZix          	| s.c.c[VarName], s.cd.[VarName], s.w.w[VarName], s.wd.[VarName]            	|     s.prev                    	|
| d              	| Diagnostics                                                   	| nPix,nTix          	| d.[ModuleName].[VarName]  	| d.prev, d.storedStates 	|
| p              	| Parameters                                                    	| nPix,1 or a scalar 	| p.[ModuleName].[VarName]  	|                        	|
|                	|                                                               	|                    	|                           	|                        	|



__*Can have different sizes of array compared to other variables in the same structure. Can include objects that cannot strictly be categorized into a specifice structure.__

# Forcing (f)   

The 'f' stores the forcing variables related to climate.

-   The forcing variables are stored as *f.\[VarName\]. *

-   The size of a forcing variable is *nPix,nTix*.

-   All other forcings, that are not purely climatic, should be
    stored in s, fe, and d. For example, leaf area index
    (LAI)/fraction of Photosynthetically Active Radiation (fPAR),
    that may be forced, should be copied to s.cd.LAI or s.cd.fPAR.
    This allows for flexibility of either getting the variable from
    forcing or calculating them prognostically.

# Extra Forcing (fe)

The 'fe' stores the pre-computed 'extra forcing'.

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

# Fluxes (fx)

The 'fx' stores all the flux variables.

-   The variables are added in the **fx** using the following
    convention

    -   *fx.\[VarName\]*

    -   Make sure that the name of the variables added in the **fx**
        structure are unique and intuitive.

-   The size for variables in **fx** is *nPix,nTix*

#States (s)

The 's' stores the state variables that are either storage
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

# Diagnostics (d)

The 'd' stores all diagnostic variables.

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

# Parameters (p)

The 'p' stores all the parameters of the model.

-   The parameters that do not change in time are stored as:

    -   *p.\[ModuleName\].\[VarName\]*

-   The scalar parameters, i.e., one value, are spatialized to
    *nPix,1* in the precomputation part of the approach (module, as
    the parameters for an approach of a module is stored in
    p.ModuleName.) to which the parameter belongs.

-   **Note that the parameters that depend on the states are stored
    in *s.cd.p\_\** or s*.wd.p\_\**. See the explanation for the
    structure s for details.**