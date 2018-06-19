# What is the info?

The info is essentially the brain of SINDBAD. Technically, it is a
structure that stores all the information needed to read the data, run
and/or optimize the model, and process the output based on an
experimental setup that is provided by different configuration files.

# The main fields
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

![](media/sindbad_info.png)

Figure: An overview of SINDBAD info. An interactive representation of the full info is available at:

[http://intra.bgc-jena.mpg.de/bgi/projects/sindbad/graphs/sindbad_info/inforad.html](http://intra.bgc-jena.mpg.de/bgi/projects/sindbad/graphs/sindbad_info/inforad.html)

# Conventions on info
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
