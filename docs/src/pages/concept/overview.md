The SINDBAD framework provides a seamless integration of model and multiple data streams using different optimization schemes and integration methods. To achieve that, the framework is built in a way that consider Input, Initial conditions, parameters, model processes, observations and integration methods as part of one system (as seen in figure below)


![SINDBAD Conceptual Framework](https://www.bgc-jena.mpg.de/~skoirala/ms_sindbad/latest/images/figures/others/conceptual_overview.png)
Fig. SINDBAD Conceptual Framework

To achieve that flexibility of switching between diverse options and challenges, SINDBAD provides modularity regarding 
- model structure
- input data
- observation data
- integration methods


These information on selected approaches and options are provided through configuration files, and they are stored in a consistent way in different SINDBAD objects and structures, so that the model technically always sees the same information. 

Fundamentally, SINDBAD consists of the following components:

- Read the [configuration files](../settings/overview)
- Process the [information needed for experiment](./info)
  - [model structure and pools](./TEM)
  - [simulation setup](./experiment)
  - create [land data structure](./land)
- read the forcing and/or observation data
- prepare for the model run
- run the experiment
- save output
