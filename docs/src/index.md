```@raw html
---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "SINDBAD"
  text: "STRATEGIES TO INTEGRATE DATA AND BIOGEOCHEMICAL MODELS"
  tagline: A model data integration framework
  image:
    src: /logo.png
    alt: Sindbad
  actions:
    - theme: brand
      text: Start
      link: /install
    - theme: alt
      text: Land
      link: /modelling_design
    - theme: alt
      text: Repo
      link: 
    - theme: alt
      text: Docs
      link: /models
features:
  - icon: <img width="64" height="64" src="https://img.icons8.com/external-xnimrodx-lineal-gradient-xnimrodx/64/external-3d-design-design-tools-xnimrodx-lineal-gradient-xnimrodx.png" alt="modular-icon"/>
    title: Challenge
    details: To represent carbon and water cycles in terrestrial ecosystems models. 

  - icon: <img width="64" height="64" src="https://img.icons8.com/external-xnimrodx-lineal-gradient-xnimrodx/64/external-3d-design-design-tools-xnimrodx-lineal-gradient-xnimrodx.png" alt="modular-icon"/>
    title: Goal
    details: To develop an agnostic and modular framework for model development and hypothesis testing.

  - icon: <img width="64" height="64" src="https://img.icons8.com/external-filled-outline-geotatah/64/external-appraise-risk-management-color-filled-outline-geotatah.png" alt="community"/>
    title: Team & Community
    link: /pages/about/team
    details: Use existing models or approaches, build your own, contribute to the package, expand.

  - icon: <img width="64" height="64" src="https://img.icons8.com/external-filled-outline-geotatah/64/external-appraise-risk-management-color-filled-outline-geotatah.png" alt="TEM-icon"/>
    title: Concept
    link: /pages/concept/overview
    details: Simulate and evaluate carbon and water fluxes with different terrestrial ecosystem models.

  - icon: <img width="78" height="78" src="https://img.icons8.com/external-filled-color-icons-papa-vector/78/external-Adjustment-Problem-choosing-business-tools-filled-color-icons-papa-vector.png" alt="optim-icon"/>
    title: Tutorials
    link: /pages/about/team
    details: Integrate observations via parameter inversion approaches or data assimilation methods.

  - icon: <img width="50" height="50" src="https://img.icons8.com/bubbles/50/mind-map.png" alt="hybrid-icon"/>
    title: Code
    link: /pages/code/sindbad
    details: Learn the representation of model parameters or of ecosystem processes via neural networks.
---
```


## Installation

In the Julia REPL type:

````julia
julia> ]
pkg > add https://git.bgc-jena.mpg.de/sindbad/Sindbad.jl.git
````

The ] character starts the Julia package manager. Hit backspace key to return to Julia prompt.

## Check installation

Check Sindbad.jl version with:

````julia
julia> ]
pkg > st Sindbad
````

## Start using Sindbad

Sindbad comes with several predefined models, which you can use individually or in combination.

```julia
using Sindbad
```
