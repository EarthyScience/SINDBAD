# SINDBAD Information Structure

The `info` structure serves as the central information hub for SINDBAD experiments. During experiment initialization, the SINDBAD preprocessor parses configuration settings and consolidates them into a comprehensive `NamedTuple` named `info`.

::: warning Reserved Variable

The `info` variable name is reserved within SINDBAD. Users should not attempt to overwrite or modify this variable directly.

:::

## Purpose and Functionality

The `info` structure acts as the central nervous system of a SINDBAD experiment, containing all necessary information for:
- Data ingestion and processing
- Model initialization and execution
- Optimization configuration
- Output generation and analysis

## Structure Overview

The `info` structure is organized into three main branches:

### 1. Experiment Configuration (`experiment`)
Contains experiment metadata and file paths:
- Basic information: name, domain, version, user, execution date
- Configuration file paths:
  - Forcing data
  - Model structure
  - Physical constants
  - Model run settings
  - Output configuration
  - Optimization settings (optional)

### 2. Terrestrial Ecosystem Model (`tem`)
Stores model-specific information:
- Model structure and processes
- Forcing data configuration
- Parameter settings
- Spinup configuration
- Additional model-related settings

### 3. Optimization Settings (`opti`)
Contains optimization-related information:
- Cost function configuration
- Optimization algorithm settings
- Observational constraints
- Parameter optimization settings
- Performance metrics

## Usage Guidelines

- Access information using dot notation (e.g., `info.experiment.name`)
- Refer to specific fields when configuring model components
- Use the structure to track experiment settings and state
- Maintain consistency with configuration files


