%{ 
Notes to structure the SINDBAD terrestrial ecosystem model

Objectives
    - converge on the structure of the terrestrial ecosystem model of 
    SINDBAD
    The current code should change in order to:
        1) be more modular -> facilitate development and model-data fusion
        2) allow usage at different levels
            -> whole model as well as individual components
        3) allow usage from site level to regional application
    In particular
        - clarify and harmonize the code, and remove current 
        inconsistencies in naming
		- be able to operate completely through memory

Thoughts about the code of the model

The core variables of the model should be stored in structure variables 
with easily interpretable variable names.

The logic in the structures follows Liu and Gupta WRR 2007: the ecosystem 
is divided in (initial) states, forcing, parameters, output.

So we should have the following main structure variables:
- forcing 
	- with all the input variables needed to run the model
    - all the intermediately needed variables can also be stored in this 
    structure (e.g. PET, soil temperature, ... forcing.AIRT)
	- to make it simple, easier to read, name it "f". Then, for example, 
    air temperature can be simply f.AIRT.
        - the long name would be forcing.AIRT -> for the output?

- states 
	- with all the carbon and water pools simulated by the model 
	- to make it simpler, easier to read, call it "s", e.g. s.cLEAF, 
    s.cS_ROOT, for water would be s.wSOIL1
    - the long versions would be, e.g., states.carbon.plant.tree.leaf or 
    states.water.soil.layer1
    - NOTE: currently, in CASA, we allow a maximum of 2 PFTs, one of trees 
    and one of grasses, discriminated by the tree vegetation cover. For now
    we should maintain it and differentiate it in the structure variables, 
    e.g.:
        - states.carbon.vegetation.leaf = states.carbon.plant.tree.leaf + states.carbon.plant.grass.leaf
        in short form
        - s.cLEAF = s.t.cLEAF + s.g.cLEAF

- parameters 
    - with ALL the parameters needed to run the model. If not all of them 
    are there we need to load them from the ancillary text files. Naming 
    should be something like (parameters.plant.tree.EMAX -> p.EMAX)

- fluxes
    - with all the fluxes we estimate, e.g.:
    fluxes.carbon.vegetation.ra	: fx.RA 
    fluxes.carbon.vegetation.gpp: fx.GPP

- modules 
    - which modules to use in the model (m.) When we have more than one way 
    to estimate a certain process, we should explicitely state here how we 
    do it, e.g.:
        - m.ps	(model.vegetation.Photosynthesis)
        - m.cc	(model.vegetation.CanopyConductance)
        - m.sm	(model.hydrology.SoilMoisture)
        - m.rht	(model.soil.SensitivityTemperature)

- diagnostics
    - we can compute diagnostic properties during the runs (e.g. 
    instantaneous light use efficiency or water use efficiency)
        - d.LUE
        - d.WUE

Naming conventions:
    - I am very comfortable with using the current naming conventions 
    inside the model. What I propose is to have minimum changes e.g. 
    AIRT -> f.AIRT, PPTT -> f.PPTT, CPOOLS('LEAF').value -> s.cLEAF, etc
    If there are any suggestions that we should change this now we can see 
    about it too (e.g. adjusting to e.g. CMIP5?)

At a certain point we shold converge on a common folder structure. Out of 
the box I come up with something like this (but this should be seen 
according to what we have done already)
	code
		casa
		optimization
        utils
		...
	docs
		literature (cool papers, could be broken down by topics)
		papers_out 
		stem (needed documentation for the model)
		optimization (needed documentation for the model)
		...
	data
		input
			fluxnet
			...
		output
		...
	...

One thought about parameters:
    - for land cover change aspects, we should have the parameters being 
    matrices (space x time) that would only change in time if there would 
    be a land cover change. This also has implications in terms of the 
    carbon pools and emissions. We think about it later.

Clarification about the 3 steps of running the model
    - spin-up 1 - reach equilibrium in NPP and soil moisture (~5 years)
    - spin-up 2 - reach equilibrium in veg and soil C pools (~2k->10k 
    years, that is why we have the implicit solution)
    - transient - estimate C and H2O fluxes and pools for contemporaneous 
    period

%}