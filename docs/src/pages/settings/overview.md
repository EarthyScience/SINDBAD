## SINDBAD Configuration 

SINDBAD is configurable to adapt to different model structure and model data integration approaches depending on the scientific goals and challenges. 

In a conventional modeling experiments, these would require changes to the internal model code and or additional scripts. 

In SINDBAD, this is accomplished through a series of **configuration files written in the .json format**, which would set all the information needed to run an experiment based on one realization of terrestrial ecosystem model and associated model-data-integration strategies.

The main configuration files of SINDBAD are listed in the table below

| SN | Prefix | Required? | Purpose | 
| :----: | :----| :----: | :------|
| 1 | [experiment](experiment.md) | yes | the basics for experiment along with the information of additional settings of running simulation | 
| 2 | [forcing](forcing.md) | yes | sets the information related to the forcing dataset | 
| 3 | [model_structure](model_structure.md) | yes | sets the information of model processes and pools | 
| 4 | [optimization](optimization.md) | no | sets the information needed to do parameter optimization or calculate model performance compared with observations | 
| 5 | [parameters](parameters.md) | no | provides interface to run an experiment with non-default parameter values | 



::: tip
- All the configuration files for a given experiment are recommended to be saved inside a separate directory within the **settings_*** directory of the SINDBAD experiments folder. 

- An example of a set of configuration files are included in ```examples``` directory. 
While developing, it is recommended to change the names of the configuration files, so that the they can be easily associated with the respective experiment, and to keep the experiment setup traceable and reproducible. 

:::
