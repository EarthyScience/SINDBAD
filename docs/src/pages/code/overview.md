# SINDBAD Packages Overview

This page provides an overview of all SINDBAD packages and their main functionalities.

| Package | Description | Key Features |
|---------|-------------|--------------|
| [Core](sindbad.md) | Core package `Sindbad` | Main framework for model core and processes |
| [Data](data.md) | Data handling | Input/output operations, data processing, and handling |
| [Experiment](experiment.md) | Simulation experiments | Experiment setup, configuration, and execution |
| [Metrics](metrics.md) | Performance metrics | Cost functions, evaluation metrics, and validation tools |
| [ML](ml.md) | Machine learning | Machine learning integration and model training |
| [Models](models.md) | Model implementations | Ecosystem model processes and approaches |
| [Optimization](optimization.md) | Optimization methods | Parameter optimization and calibration |
| [Setup](setup.md) | Setup utilities | configuration of SINDBAD experiment and setup |
| [TEM](tem.md) | Terrestrial Ecosystem Model | Core ecosystem modeling framework |
| [Utils](utils.md) | Utility functions | Helper functions and common utilities for all packages|
| [Visuals](visuals.md) | Visualization tools | Plotting and data visualization (to be developed..) |


## Code Documentation

The code documentation is automatically generated from the docstrings of the definitions and functions.

::: tip What are `Exported` and `Internal` entities/code/functions?

- `Exported` entities (functions, structs, types, constants):

These are explicitly made available to users using the `export` keyword, allowing them to be accessed without prefixing them with the module name.

- `Internal` entities (non-exported):

These remain accessible but require qualification with the module name (e.g., `MyModule.SomeType`), indicating that they are intended for internal use.

:::
## Sindbad Package Dependencies

```mermaid
graph TD
    A[Sindbad] --> B[Data]
    A --> C[Experiment]
    A --> D[Metrics]
    A --> E[ML]
    A --> F[Models]
    A --> G[Optimization]
    A --> H[Setup]
    A --> I[TEM]
    A --> J[Utils]
    A --> K[Visuals]
    F --> I
    C --> F
    C --> I
    G --> F
    G --> I
    D --> G
    E --> F
    E --> I
    J --> B
    J --> C
    J --> D
    J --> E
    J --> F
    J --> G
    J --> I
    K --> B
    K --> D
    K --> I
```

## Package Descriptions

### Core Packages
- **Sindbad**: The main package that provides the core framework functionality and serves as the entry point for SINDBAD applications.
- **Models**: Contains implementations of various ecosystem model components and approaches.
- **Data**: Handles all data-related operations including input/output, data processing, and management.
- **TEM**: Provides the Terrestrial Ecosystem Model framework and its core functionality.

### Modeling Packages
- **Experiment**: Manages experiment setup, configuration, and execution workflows.
- **Metrics**: Implements performance metrics, cost functions, and validation tools.
- **ML**: Integrates machine learning capabilities for model training and analysis.
- **Optimization**: Provides methods for parameter optimization and model calibration.

### Utility Packages
- **Setup**: Contains installation and configuration tools.
- **Utils**: Provides helper functions and common utilities used across the framework.
- **Visuals**: Offers tools for data visualization and plotting.

::: tip Package Usage

- Most packages can be used independently for specific tasks
- The core `Sindbad` package is required for full framework functionality

::: 