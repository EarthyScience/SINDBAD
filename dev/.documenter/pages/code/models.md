<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models' href='#Sindbad.Models'><span class="jlbinding">Sindbad.Models</span></a> <Badge type="info" class="jlObjectType jlModule" text="Module" /></summary>



```julia
Sindbad.Models
```


The core module for defining and implementing models and approaches of ecosystem processes in the SINDBAD framework.

**Description**

The `Sindbad.Models` module provides the infrastructure for defining and implementing terrestrial ecosystem models within the SINDBAD framework. It includes tools for model definition, parameter management, and method implementation.

**Key Features**
- Model definition and inheritance from `LandEcosystem`
  
- Parameter management with metadata (bounds, units, timescale)
  
- Standardized method implementation (define, precompute, compute, update)
  
- Model documentation and purpose tracking
  
- Model approach management and validation
  

**Required Methods**

All models must implement at least one of the following methods:
- `define`: Initialize arrays and variables
  
- `precompute`: Prepare variables for computation
  
- `compute`: Perform model calculations
  
- `update`: Update model state
  

**Metadata Macros**
- `@bounds`: Define parameter bounds
  
- `@describe`: Add parameter descriptions
  
- `@units`: Specify parameter units
  
- `@timescale`: Define temporal scale of the parameter that is used to determine the units of the parameter and their conversion factors
  
- `@with_kw`: Enable keyword argument construction
  

**Usage**

```julia
using Sindbad.Models

# Define a new model
abstract type MyModel <: LandEcosystem end
purpose(::Type{MyModel}) = "Description of my model"

# Define an approach
@bounds @describe @units @timescale @with_kw struct MyModel_v1{T} <: MyModel
    param1::T = 1.0 | (0.0, 2.0) | "Description" | "units" | "timescale"
end

# Implement required methods
function define(params::MyModel_v1, forcing, land, helpers)
    # Initialize arrays and variables
    return land
end
```


**Notes**
- Models should follow the SINDBAD modeling conventions
  
- All parameters should have appropriate metadata
  
- Methods should be implemented efficiently for performance
  
- Documentation should be comprehensive and clear
  

</details>


## Available Models {#Available-Models}

### EVI {#EVI}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.EVI' href='#Sindbad.Models.EVI'><span class="jlbinding">Sindbad.Models.EVI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Enhanced vegetation index
```



---


**Approaches**
- `EVI_constant`: sets EVI as a constant
  
- `EVI_forcing`: sets land.states.EVI from forcing
  

</details>


:::details EVI approaches

:::tabs

== EVI_constant
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.EVI_constant' href='#Sindbad.Models.EVI_constant'><span class="jlbinding">Sindbad.Models.EVI_constant</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets EVI as a constant

**Parameters**
- **Fields**
  - `constant_EVI`: 1.0 ∈ [0.0, 1.0] =&gt; EVI (`unitless` @ `all` timescales)
    
  

**Methods:**

`precompute`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `states.EVI`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :EVI)` for information on how to add the variable to the catalog.
    
  

`define, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `EVI_constant.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: cleaned up the code  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== EVI_forcing
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.EVI_forcing' href='#Sindbad.Models.EVI_forcing'><span class="jlbinding">Sindbad.Models.EVI_forcing</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets land.states.EVI from forcing

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_EVI`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_EVI)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.EVI`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :EVI)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `EVI_forcing.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### LAI {#LAI}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.LAI' href='#Sindbad.Models.LAI'><span class="jlbinding">Sindbad.Models.LAI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Leaf area index
```



---


**Approaches**
- `LAI_cVegLeaf`: sets land.states.LAI from the carbon in the leaves of the previous time step
  
- `LAI_constant`: sets LAI as a constant
  
- `LAI_forcing`: sets land.states.LAI from forcing
  

</details>


:::details LAI approaches

:::tabs

== LAI_cVegLeaf
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.LAI_cVegLeaf' href='#Sindbad.Models.LAI_cVegLeaf'><span class="jlbinding">Sindbad.Models.LAI_cVegLeaf</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets land.states.LAI from the carbon in the leaves of the previous time step

**Parameters**
- **Fields**
  - `SLA`: 0.016 ∈ [0.01, 0.024] =&gt; specific leaf area (units: `m^2.gC^-1` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.cVegLeaf`: carbon content of cVegLeaf pool(s)
    
  
- **Outputs**
  - `states.LAI`: leaf area index
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `LAI_cVegLeaf.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 05.05.2020 [sbesnard]
  

_Created by_
- sbesnard
  

</details>


== LAI_constant
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.LAI_constant' href='#Sindbad.Models.LAI_constant'><span class="jlbinding">Sindbad.Models.LAI_constant</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets LAI as a constant

**Parameters**
- **Fields**
  - `constant_LAI`: 3.0 ∈ [1.0, 12.0] =&gt; LAI (units: `m2/m2` @ `all` timescales)
    
  

**Methods:**

`precompute`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `states.LAI`: leaf area index
    
  

`define, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `LAI_constant.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: cleaned up the code  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== LAI_forcing
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.LAI_forcing' href='#Sindbad.Models.LAI_forcing'><span class="jlbinding">Sindbad.Models.LAI_forcing</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets land.states.LAI from forcing

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_LAI`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_LAI)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.LAI`: leaf area index
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `LAI_forcing.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: moved LAI from land.LAI.LAI to land.states.LAI  
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### NDVI {#NDVI}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.NDVI' href='#Sindbad.Models.NDVI'><span class="jlbinding">Sindbad.Models.NDVI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Normalized difference vegetation index
```



---


**Approaches**
- `NDVI_constant`: sets NDVI as a constant
  
- `NDVI_forcing`: sets land.states.NDVI from forcing
  

</details>


:::details NDVI approaches

:::tabs

== NDVI_constant
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.NDVI_constant' href='#Sindbad.Models.NDVI_constant'><span class="jlbinding">Sindbad.Models.NDVI_constant</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets NDVI as a constant

**Parameters**
- **Fields**
  - `constant_NDVI`: 1.0 ∈ [0.0, 1.0] =&gt; NDVI (`unitless` @ `all` timescales)
    
  

**Methods:**

`precompute`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `states.NDVI`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :NDVI)` for information on how to add the variable to the catalog.
    
  

`define, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `NDVI_constant.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 29.04.2020 [sbesnard]: new module  
  

_Created by_
- sbesnard
  

</details>


== NDVI_forcing
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.NDVI_forcing' href='#Sindbad.Models.NDVI_forcing'><span class="jlbinding">Sindbad.Models.NDVI_forcing</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets land.states.NDVI from forcing

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_NDVI`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_NDVI)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.NDVI`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :NDVI)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `NDVI_forcing.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 29.04.2020 [sbesnard]
  

_Created by_
- sbesnard
  

</details>


:::


---


### NDWI {#NDWI}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.NDWI' href='#Sindbad.Models.NDWI'><span class="jlbinding">Sindbad.Models.NDWI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Normalized difference water index
```



---


**Approaches**
- `NDWI_constant`: sets NDWI as a constant
  
- `NDWI_forcing`: sets land.states.NDWI from forcing
  

</details>


:::details NDWI approaches

:::tabs

== NDWI_constant
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.NDWI_constant' href='#Sindbad.Models.NDWI_constant'><span class="jlbinding">Sindbad.Models.NDWI_constant</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets NDWI as a constant

**Parameters**
- **Fields**
  - `constant_NDWI`: 1.0 ∈ [0.0, 1.0] =&gt; NDWI (`unitless` @ `all` timescales)
    
  

**Methods:**

`precompute`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `states.NDWI`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :NDWI)` for information on how to add the variable to the catalog.
    
  

`define, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `NDWI_constant.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 29.04.2020 [sbesnard]: new module  
  

_Created by_
- sbesnard
  

</details>


== NDWI_forcing
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.NDWI_forcing' href='#Sindbad.Models.NDWI_forcing'><span class="jlbinding">Sindbad.Models.NDWI_forcing</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets land.states.NDWI from forcing

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_NDWI`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_NDWI)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.NDWI`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :NDWI)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `NDWI_forcing.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 29.04.2020 [sbesnard]
  

_Created by_
- sbesnard
  

</details>


:::


---


### NIRv {#NIRv}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.NIRv' href='#Sindbad.Models.NIRv'><span class="jlbinding">Sindbad.Models.NIRv</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Near-infrared reflectance of terrestrial vegetation
```



---


**Approaches**
- `NIRv_constant`: sets NIRv as a constant
  
- `NIRv_forcing`: sets land.states.NIRv from forcing
  

</details>


:::details NIRv approaches

:::tabs

== NIRv_constant
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.NIRv_constant' href='#Sindbad.Models.NIRv_constant'><span class="jlbinding">Sindbad.Models.NIRv_constant</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets NIRv as a constant

**Parameters**
- **Fields**
  - `constant_NIRv`: 1.0 ∈ [0.0, 1.0] =&gt; NIRv (`unitless` @ `all` timescales)
    
  

**Methods:**

`precompute`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `states.NIRv`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :NIRv)` for information on how to add the variable to the catalog.
    
  

`define, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `NIRv_constant.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 29.04.2020 [sbesnard]: new module  
  

_Created by_
- sbesnard
  

</details>


== NIRv_forcing
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.NIRv_forcing' href='#Sindbad.Models.NIRv_forcing'><span class="jlbinding">Sindbad.Models.NIRv_forcing</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets land.states.NIRv from forcing

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_NIRv`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_NIRv)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.NIRv`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :NIRv)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `NIRv_forcing.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 29.04.2020 [sbesnard]
  

_Created by_
- sbesnard
  

</details>


:::


---


### PET {#PET}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.PET' href='#Sindbad.Models.PET'><span class="jlbinding">Sindbad.Models.PET</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Set/get potential evapotranspiration
```



---


**Approaches**
- `PET_Lu2005`: Calculates land.fluxes.PET from the forcing variables
  
- `PET_PriestleyTaylor1972`: Calculates land.fluxes.PET from the forcing variables
  
- `PET_forcing`: sets land.fluxes.PET from the forcing
  

</details>


:::details PET approaches

:::tabs

== PET_Lu2005
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.PET_Lu2005' href='#Sindbad.Models.PET_Lu2005'><span class="jlbinding">Sindbad.Models.PET_Lu2005</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Calculates land.fluxes.PET from the forcing variables

**Parameters**
- **Fields**
  - `α`: 1.26 ∈ [0.1, 2.0] =&gt; calibration constant: α = 1.26 for wet or humid (`unitless` @ `all` timescales)
    
  - `svp_1`: 0.2 ∈ [-Inf, Inf] =&gt; saturation vapor pressure temperature curve parameter 1 (`unitless` @ `all` timescales)
    
  - `svp_2`: 0.00738 ∈ [-Inf, Inf] =&gt; saturation vapor pressure temperature curve parameter 2 (`unitless` @ `all` timescales)
    
  - `svp_3`: 0.8072 ∈ [-Inf, Inf] =&gt; saturation vapor pressure temperature curve parameter 3 (`unitless` @ `all` timescales)
    
  - `svp_4`: 7.0 ∈ [-Inf, Inf] =&gt; saturation vapor pressure temperature curve parameter 4 (`unitless` @ `all` timescales)
    
  - `svp_5`: 0.000116 ∈ [-Inf, Inf] =&gt; saturation vapor pressure temperature curve parameter 5 (`unitless` @ `all` timescales)
    
  - `sh_cp`: 0.001013 ∈ [-Inf, Inf] =&gt; specific heat of moist air at constant pressure (1.013 kJ/kg/°C) (units: `MJ/kg/°C` @ `all` timescales)
    
  - `elev`: 0.0 ∈ [0.0, 8848.0] =&gt; elevation (units: `m` @ `all` timescales)
    
  - `pres_sl`: 101.29 ∈ [0.0, 101.3] =&gt; atmospheric pressure at sea level (units: `kpa` @ `all` timescales)
    
  - `pres_elev`: 0.01055 ∈ [-Inf, Inf] =&gt; rate of change of atmospheric pressure with elevation (units: `kpa/m` @ `all` timescales)
    
  - `λ_base`: 2.501 ∈ [-Inf, Inf] =&gt; latent heat of vaporization (units: `MJ/kg` @ `all` timescales)
    
  - `λ_airT`: 0.002361 ∈ [-Inf, Inf] =&gt; rate of change of latent heat of vaporization with temperature (units: `MJ/kg/°C` @ `all` timescales)
    
  - `γ_resistance`: 0.622 ∈ [-Inf, Inf] =&gt; ratio of canopy resistance to atmospheric resistance (`unitless` @ `all` timescales)
    
  - `Δt`: 2.0 ∈ [-Inf, Inf] =&gt; time delta for calculation of G (units: `day` @ `all` timescales)
    
  - `G_base`: 4.2 ∈ [-Inf, Inf] =&gt; base groundheat flux (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `forcing.f_airT`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `fluxes.PET`: potential evapotranspiration
    
  - `states.Tair_prev`: air temperature in the previous time step
    
  

`compute`:
- **Inputs**
  - `forcing.f_rn`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rn)` for information on how to add the variable to the catalog.
    
  - `forcing.f_airT`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT)` for information on how to add the variable to the catalog.
    
  - `states.Tair_prev`: air temperature in the previous time step
    
  
- **Outputs**
  - `fluxes.PET`: potential evapotranspiration
    
  - `states.Tair_prev`: air temperature in the previous time step
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `PET_Lu2005.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Lu
  

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


== PET_PriestleyTaylor1972
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.PET_PriestleyTaylor1972' href='#Sindbad.Models.PET_PriestleyTaylor1972'><span class="jlbinding">Sindbad.Models.PET_PriestleyTaylor1972</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Calculates land.fluxes.PET from the forcing variables

**Parameters**
- **Fields**
  - `Δ_1`: 6.11 ∈ [-Inf, Inf] =&gt; parameter 1 for calculating Δ (`unitless` @ `all` timescales)
    
  - `Δ_2`: 17.26938818 ∈ [-Inf, Inf] =&gt; parameter 2 for calculating Δ (`unitless` @ `all` timescales)
    
  - `Δ_3`: 237.3 ∈ [-Inf, Inf] =&gt; parameter 3 for calculating Δ (`unitless` @ `all` timescales)
    
  - `Lhv_1`: 5.147 ∈ [-Inf, Inf] =&gt; parameter 1 for calculating Lhv (`unitless` @ `all` timescales)
    
  - `Lhv_2`: -0.0004643 ∈ [-Inf, Inf] =&gt; parameter 2 for calculating Lhv (`unitless` @ `all` timescales)
    
  - `Lhv_3`: 2.6466 ∈ [-Inf, Inf] =&gt; parameter 3 for calculating Lhv (`unitless` @ `all` timescales)
    
  - `γ_1`: 0.4 ∈ [-Inf, Inf] =&gt; parameter 1 for calculating γ (`unitless` @ `all` timescales)
    
  - `γ_2`: 0.622 ∈ [-Inf, Inf] =&gt; parameter 2 for calculating γ (`unitless` @ `all` timescales)
    
  - `PET_1`: 1.26 ∈ [-Inf, Inf] =&gt; parameter 1 for calculating PET (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_rn`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rn)` for information on how to add the variable to the catalog.
    
  - `forcing.f_airT`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT)` for information on how to add the variable to the catalog.
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.PET`: potential evapotranspiration
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `PET_PriestleyTaylor1972.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Priestley, C. H. B., &amp; TAYLOR, R. J. (1972). On the assessment of surface heat  flux &amp; evaporation using large-scale parameters.  Monthly weather review, 100[2], 81-92.
  

_Versions_
- 1.0 on 20.03.2020 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


== PET_forcing
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.PET_forcing' href='#Sindbad.Models.PET_forcing'><span class="jlbinding">Sindbad.Models.PET_forcing</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets land.fluxes.PET from the forcing

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_PET`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_PET)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `fluxes.PET`: potential evapotranspiration
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `PET_forcing.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### PFT {#PFT}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.PFT' href='#Sindbad.Models.PFT'><span class="jlbinding">Sindbad.Models.PFT</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Vegetation PFT
```



---


**Approaches**
- `PFT_constant`: sets a uniform PFT class
  

</details>


:::details PFT approaches

:::tabs

== PFT_constant
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.PFT_constant' href='#Sindbad.Models.PFT_constant'><span class="jlbinding">Sindbad.Models.PFT_constant</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets a uniform PFT class

**Parameters**
- **Fields**
  - `PFT`: 1.0 ∈ [1.0, 13.0] =&gt; Plant functional type (units: `class` @ `all` timescales)
    
  

**Methods:**

`precompute`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `PFT.PFT`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:PFT, :PFT)` for information on how to add the variable to the catalog.
    
  

`define, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `PFT_constant.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
  

_Created by_
- unknown [xxx]
  

</details>


:::


---


### WUE {#WUE}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.WUE' href='#Sindbad.Models.WUE'><span class="jlbinding">Sindbad.Models.WUE</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Quantify Water Use Efficiency (WUE).
```



---


**Approaches**
- `WUE_Medlyn2011`: calculates the WUE/AOE ci/ca as a function of daytime mean VPD. calculates the WUE/AOE ci/ca as a function of daytime mean VPD &amp; ambient co2
  
- `WUE_VPDDay`: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD
  
- `WUE_VPDDayCo2`: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD
  
- `WUE_constant`: calculates the WUE/AOE as a constant in space &amp; time
  
- `WUE_expVPDDayCo2`: calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD
  

</details>


:::details WUE approaches

:::tabs

== WUE_Medlyn2011
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.WUE_Medlyn2011' href='#Sindbad.Models.WUE_Medlyn2011'><span class="jlbinding">Sindbad.Models.WUE_Medlyn2011</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the WUE/AOE ci/ca as a function of daytime mean VPD. calculates the WUE/AOE ci/ca as a function of daytime mean VPD &amp; ambient co2

**Parameters**
- **Fields**
  - `g1`: 3.0 ∈ [0.5, 12.0] =&gt; stomatal conductance parameter (units: `kPa^0.5` @ `all` timescales)
    
  - `ζ`: 1.0 ∈ [0.85, 3.5] =&gt; sensitivity of WUE to ambient co2 (`unitless` @ `all` timescales)
    
  - `diffusivity_ratio`: 1.6 ∈ [-Inf, Inf] =&gt; Ratio of the molecular diffusivities for water vapor and CO2 (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `WUE.umol_to_gC`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:WUE, :umol_to_gC)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `forcing.f_psurf_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_psurf_day)` for information on how to add the variable to the catalog.
    
  - `forcing.f_VPD_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_VPD_day)` for information on how to add the variable to the catalog.
    
  - `states.ambient_CO2`: ambient co2 concentration
    
  - `WUE.umol_to_gC`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:WUE, :umol_to_gC)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.ci`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :ci)` for information on how to add the variable to the catalog.
    
  - `states.ciNoCO2`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :ciNoCO2)` for information on how to add the variable to the catalog.
    
  - `diagnostics.WUENoCO2`: water use efficiency of the ecosystem without CO2 effect
    
  - `diagnostics.WUE`: water use efficiency of the ecosystem
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `WUE_Medlyn2011.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Knauer J, El-Madany TS, Zaehle S, Migliavacca M [2018] Bigleaf—An R  package for the calculation of physical &amp; physiological ecosystem  properties from eddy covariance data. PLoS ONE 13[8]: e0201114. https://doi.org/10.1371/journal.pone.0201114
  
- MEDLYN; B.E.; DUURSMA; R.A.; EAMUS; D.; ELLSWORTH; D.S.; PRENTICE; I.C.  BARTON; C.V.M.; CROUS; K.Y.; DE ANGELIS; P.; FREEMAN; M. &amp; WINGATE  L. (2011), Reconciling the optimal &amp; empirical approaches to  modelling stomatal conductance. Global Change Biology; 17: 2134-2144.  doi:10.1111/j.1365-2486.2010.02375.x
  
- Medlyn; B.E.; Duursma; R.A.; Eamus; D.; Ellsworth; D.S.; Colin Prentice  I.; Barton; C.V.M.; Crous; K.Y.; de Angelis; P.; Freeman; M. &amp;  Wingate, L. (2012), Reconciling the optimal &amp; empirical approaches to  modelling stomatal conductance. Glob Change Biol; 18: 3476-3476.  doi:10.1111/j.1365-2486.2012.02790.
  

_Versions_
- 1.0 on 11.11.2020 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

_Notes_
- unit conversion: C_flux[gC m-2 d-1] &lt; - CO2_flux[(umol CO2 m-2 s-1)] *  1e-06 [umol2mol] * 0.012011 [Cmol] * 1000 [kg2g] * 86400 [days2seconds]  from Knauer; 2019
  
- water: mmol m-2 s-1: /1000 [mol m-2 s-1] * .018015 [Wmol in kg/mol] * 84600
  

</details>


== WUE_VPDDay
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.WUE_VPDDay' href='#Sindbad.Models.WUE_VPDDay'><span class="jlbinding">Sindbad.Models.WUE_VPDDay</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD

**Parameters**
- **Fields**
  - `WUE_one_hpa`: 9.2 ∈ [4.0, 17.0] =&gt; WUE at 1 hpa VPD (units: `gC/mmH2O` @ `all` timescales)
    
  - `kpa_to_hpa`: 10.0 ∈ [-Inf, Inf] =&gt; unit conversion kPa to hPa (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_VPD_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_VPD_day)` for information on how to add the variable to the catalog.
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.WUE`: water use efficiency of the ecosystem
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `WUE_VPDDay.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]
  

_Created by_
- Jake Nelson [jnelson]: for the typical values &amp; ranges of WUEat1hPa  across fluxNet sites
  
- skoirala | @dr-ko
  

</details>


== WUE_VPDDayCo2
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.WUE_VPDDayCo2' href='#Sindbad.Models.WUE_VPDDayCo2'><span class="jlbinding">Sindbad.Models.WUE_VPDDayCo2</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD

**Parameters**
- **Fields**
  - `WUE_one_hpa`: 9.2 ∈ [4.0, 17.0] =&gt; WUE at 1 hpa VPD (units: `gC/mmH2O` @ `all` timescales)
    
  - `base_ambient_CO2`: 380.0 ∈ [300.0, 500.0] =&gt;  (units: `ppm` @ `all` timescales)
    
  - `sat_ambient_CO2`: 500.0 ∈ [100.0, 2000.0] =&gt;  (units: `ppm` @ `all` timescales)
    
  - `kpa_to_hpa`: 10.0 ∈ [-Inf, Inf] =&gt; unit conversion kPa to hPa (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_VPD_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_VPD_day)` for information on how to add the variable to the catalog.
    
  - `states.ambient_CO2`: ambient co2 concentration
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.WUENoCO2`: water use efficiency of the ecosystem without CO2 effect
    
  - `diagnostics.WUE`: water use efficiency of the ecosystem
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `WUE_VPDDayCo2.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]
  

_Created by_
- Jake Nelson [jnelson]: for the typical values &amp; ranges of WUEat1hPa  across fluxNet sites
  
- skoirala | @dr-ko
  

</details>


== WUE_constant
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.WUE_constant' href='#Sindbad.Models.WUE_constant'><span class="jlbinding">Sindbad.Models.WUE_constant</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the WUE/AOE as a constant in space &amp; time

**Parameters**
- **Fields**
  - `constant_WUE`: 4.1 ∈ [1.0, 10.0] =&gt; mean FluxNet WUE (units: `gC/mmH2O` @ `all` timescales)
    
  

**Methods:**

`precompute`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `diagnostics.WUE`: water use efficiency of the ecosystem
    
  

`define, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `WUE_constant.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]
  

_Created by_
- Jake Nelson [jnelson]: for the typical values &amp; ranges of WUE across fluxNet  sites
  
- skoirala | @dr-ko
  

</details>


== WUE_expVPDDayCo2
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.WUE_expVPDDayCo2' href='#Sindbad.Models.WUE_expVPDDayCo2'><span class="jlbinding">Sindbad.Models.WUE_expVPDDayCo2</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD

**Parameters**
- **Fields**
  - `WUE_one_hpa`: 9.2 ∈ [2.0, 20.0] =&gt; WUE at 1 hpa VPD (units: `gC/mmH2O` @ `all` timescales)
    
  - `κ`: 0.4 ∈ [0.06, 0.7] =&gt;  (units: `kPa-1` @ `all` timescales)
    
  - `base_ambient_CO2`: 380.0 ∈ [300.0, 500.0] =&gt;  (units: `ppm` @ `all` timescales)
    
  - `sat_ambient_CO2`: 500.0 ∈ [10.0, 2000.0] =&gt;  (units: `ppm` @ `all` timescales)
    
  - `kpa_to_hpa`: 10.0 ∈ [-Inf, Inf] =&gt; unit conversion kPa to hPa (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_VPD_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_VPD_day)` for information on how to add the variable to the catalog.
    
  - `states.ambient_CO2`: ambient co2 concentration
    
  
- **Outputs**
  - `diagnostics.WUENoCO2`: water use efficiency of the ecosystem without CO2 effect
    
  - `diagnostics.WUE`: water use efficiency of the ecosystem
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `WUE_expVPDDayCo2.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 31.03.2021 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### ambientCO2 {#ambientCO2}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.ambientCO2' href='#Sindbad.Models.ambientCO2'><span class="jlbinding">Sindbad.Models.ambientCO2</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
sets/gets ambient CO2 concentration
```



---


**Approaches**
- `ambientCO2_constant`: sets ambient_CO2 to a constant value
  
- `ambientCO2_forcing`: sets ambient_CO2 from forcing
  

</details>


:::details ambientCO2 approaches

:::tabs

== ambientCO2_constant
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.ambientCO2_constant' href='#Sindbad.Models.ambientCO2_constant'><span class="jlbinding">Sindbad.Models.ambientCO2_constant</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets ambient_CO2 to a constant value

**Parameters**
- **Fields**
  - `constant_ambient_CO2`: 400.0 ∈ [200.0, 5000.0] =&gt; atmospheric CO2 concentration (units: `ppm` @ `all` timescales)
    
  

**Methods:**

`precompute`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `states.ambient_CO2`: ambient co2 concentration
    
  

`define, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `ambientCO2_constant.jl`. Check the Extended help for user-defined information._


---


**Extended help**

This function assigns a constant value of ambient CO2 concentration to the land model state.  The value is derived from the `constant_ambient_CO2` parameter defined in the `ambientCO2_constant` structure.

_References_
- None
  

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


== ambientCO2_forcing
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.ambientCO2_forcing' href='#Sindbad.Models.ambientCO2_forcing'><span class="jlbinding">Sindbad.Models.ambientCO2_forcing</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets ambient_CO2 from forcing

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_ambient_CO2`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_ambient_CO2)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.ambient_CO2`: ambient co2 concentration
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `ambientCO2_forcing.jl`. Check the Extended help for user-defined information._


---


**Extended help**

This function assigns ambient CO2 concentration from the forcing data (`f_ambient_CO2`) to the land model state for the current time step.

_References_
- None
  

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### autoRespiration {#autoRespiration}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.autoRespiration' href='#Sindbad.Models.autoRespiration'><span class="jlbinding">Sindbad.Models.autoRespiration</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
estimates autotrophic respiration for growth and maintenance
```



---


**Approaches**
- `autoRespiration_Thornley2000A`: estimates autotrophic respiration as maintenance + growth respiration according to Thornley &amp; Cannell [2000]: MODEL A - maintenance respiration is given priority.
  
- `autoRespiration_Thornley2000B`: estimates autotrophic respiration as maintenance + growth respiration according to Thornley &amp; Cannell [2000]: MODEL B - growth respiration is given priority.
  
- `autoRespiration_Thornley2000C`: estimates autotrophic respiration as maintenance + growth respiration according to Thornley &amp; Cannell [2000]: MODEL C - growth, degradation &amp; resynthesis view of respiration. Computes the km [maintenance [respiration] coefficient].
  
- `autoRespiration_none`: sets the autotrophic respiration flux from all vegetation pools to zero.
  

</details>


:::details autoRespiration approaches

:::tabs

== autoRespiration_Thornley2000A
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.autoRespiration_Thornley2000A' href='#Sindbad.Models.autoRespiration_Thornley2000A'><span class="jlbinding">Sindbad.Models.autoRespiration_Thornley2000A</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



estimates autotrophic respiration as maintenance + growth respiration according to Thornley &amp; Cannell [2000]: MODEL A - maintenance respiration is given priority.

**Parameters**
- **Fields**
  - `RMN`: 0.009085714285714286 ∈ [0.0009085714285714285, 0.09085714285714286] =&gt; Nitrogen efficiency rate of maintenance respiration (units: `gC/gN/day` @ `day` timescale)
    
  - `YG`: 0.75 ∈ [0.0, 1.0] =&gt; growth yield coefficient, or growth efficiency. Loosely: (1-YG)*GPP is growth respiration (units: `gC/gC` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.k_respiration_maintain`: metabolism rate for maintenance respiration
    
  - `diagnostics.k_respiration_maintain_su`: metabolism rate for maintenance respiration to be used in old analytical solution to steady state
    
  - `fluxes.auto_respiration_growth`: growth respiration per vegetation pool
    
  - `fluxes.auto_respiration_maintain`: maintenance respiration per vegetation pool
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  

`compute`:
- **Inputs**
  - `diagnostics.k_respiration_maintain`: metabolism rate for maintenance respiration
    
  - `diagnostics.k_respiration_maintain_su`: metabolism rate for maintenance respiration to be used in old analytical solution to steady state
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  - `fluxes.auto_respiration_growth`: growth respiration per vegetation pool
    
  - `fluxes.auto_respiration_maintain`: maintenance respiration per vegetation pool
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `pools.cVeg`: carbon content of cVeg pool(s)
    
  - `fluxes.gpp`: gross primary prorDcutivity
    
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  - `diagnostics.auto_respiration_f_airT`: effect of air temperature on autotrophic respiration. 0: no decomposition, &gt;1 increase in decomposition rate
    
  
- **Outputs**
  - `diagnostics.k_respiration_maintain`: metabolism rate for maintenance respiration
    
  - `diagnostics.k_respiration_maintain_su`: metabolism rate for maintenance respiration to be used in old analytical solution to steady state
    
  - `fluxes.auto_respiration_growth`: growth respiration per vegetation pool
    
  - `fluxes.auto_respiration_maintain`: maintenance respiration per vegetation pool
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `autoRespiration_Thornley2000A.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Amthor, J. S. (2000), The McCree-de Wit-Penning de Vries-Thornley  respiration paradigms: 30 years later, Ann Bot-London, 86[1], 1-20.  Ryan, M. G. (1991), Effects of Climate Change on Plant Respiration, Ecol  Appl, 1[2], 157-167.
  
- Thornley, J. H. M., &amp; M. G. R. Cannell [2000], Modelling the components  of plant respiration: Representation &amp; realism, Ann Bot-London, 85[1]  55-67.
  

_Versions_
- 1.0 on 06.05.2022 [ncarvalhais/skoirala]: cleaned up the code
  

_Created by_
- ncarvalhais
  

_Notes_
- Questions - practical - leave raAct per pool; | make a field land.fluxes.ra  that has all the autotrophic respiration components together?  
  

</details>


== autoRespiration_Thornley2000B
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.autoRespiration_Thornley2000B' href='#Sindbad.Models.autoRespiration_Thornley2000B'><span class="jlbinding">Sindbad.Models.autoRespiration_Thornley2000B</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



estimates autotrophic respiration as maintenance + growth respiration according to Thornley &amp; Cannell [2000]: MODEL B - growth respiration is given priority.

**Parameters**
- **Fields**
  - `RMN`: 0.009085714285714286 ∈ [0.0009085714285714285, 0.09085714285714286] =&gt; Nitrogen efficiency rate of maintenance respiration (units: `gC/gN/day` @ `day` timescale)
    
  - `YG`: 0.75 ∈ [0.0, 1.0] =&gt; growth yield coefficient, or growth efficiency. Loosely: (1-YG)*GPP is growth respiration (units: `gC/gC` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.k_respiration_maintain`: metabolism rate for maintenance respiration
    
  - `diagnostics.k_respiration_maintain_su`: metabolism rate for maintenance respiration to be used in old analytical solution to steady state
    
  - `fluxes.auto_respiration_growth`: growth respiration per vegetation pool
    
  - `fluxes.auto_respiration_maintain`: maintenance respiration per vegetation pool
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  

`compute`:
- **Inputs**
  - `diagnostics.k_respiration_maintain`: metabolism rate for maintenance respiration
    
  - `diagnostics.k_respiration_maintain_su`: metabolism rate for maintenance respiration to be used in old analytical solution to steady state
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  - `fluxes.auto_respiration_growth`: growth respiration per vegetation pool
    
  - `fluxes.auto_respiration_maintain`: maintenance respiration per vegetation pool
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `pools.cVeg`: carbon content of cVeg pool(s)
    
  - `fluxes.gpp`: gross primary prorDcutivity
    
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.auto_respiration_f_airT`: effect of air temperature on autotrophic respiration. 0: no decomposition, &gt;1 increase in decomposition rate
    
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  
- **Outputs**
  - `diagnostics.k_respiration_maintain`: metabolism rate for maintenance respiration
    
  - `diagnostics.k_respiration_maintain_su`: metabolism rate for maintenance respiration to be used in old analytical solution to steady state
    
  - `fluxes.auto_respiration_growth`: growth respiration per vegetation pool
    
  - `fluxes.auto_respiration_maintain`: maintenance respiration per vegetation pool
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `autoRespiration_Thornley2000B.jl`. Check the Extended help for user-defined information._   


---


**Extended help**

_References_
- Amthor, J. S. (2000), The McCree-de Wit-Penning de Vries-Thornley  respiration paradigms: 30 years later, Ann Bot-London, 86[1], 1-20.  Ryan, M. G. (1991), Effects of Climate Change on Plant Respiration, Ecol  Appl, 1[2], 157-167.
  
- Thornley, J. H. M., &amp; M. G. R. Cannell [2000], Modelling the components  of plant respiration: Representation &amp; realism, Ann Bot-London, 85[1]  55-67.
  

_Versions_
- 1.0 on 06.05.2022 [ncarvalhais/skoirala]: cleaned up the code
  

_Created by_
- ncarvalhais
  

_Notes_
- Questions - practical - leave raAct per pool; | make a field land.fluxes.ra  that has all the autotrophic respiration components together?  
  

</details>


== autoRespiration_Thornley2000C
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.autoRespiration_Thornley2000C' href='#Sindbad.Models.autoRespiration_Thornley2000C'><span class="jlbinding">Sindbad.Models.autoRespiration_Thornley2000C</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



estimates autotrophic respiration as maintenance + growth respiration according to Thornley &amp; Cannell [2000]: MODEL C - growth, degradation &amp; resynthesis view of respiration. Computes the km [maintenance [respiration] coefficient].

**Parameters**
- **Fields**
  - `RMN`: 0.009085714285714286 ∈ [0.0009085714285714285, 0.09085714285714286] =&gt; Nitrogen efficiency rate of maintenance respiration (units: `gC/gN/day` @ `day` timescale)
    
  - `YG`: 0.75 ∈ [0.0, 1.0] =&gt; growth yield coefficient, or growth efficiency. Loosely: (1-YG)*GPP is growth respiration (units: `gC/gC` @ `all` timescales)
    
  - `MTF`: 0.85 ∈ [-Inf, Inf] =&gt;  (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.k_respiration_maintain`: metabolism rate for maintenance respiration
    
  - `diagnostics.k_respiration_maintain_su`: metabolism rate for maintenance respiration to be used in old analytical solution to steady state
    
  - `diagnostics.Fd`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :Fd)` for information on how to add the variable to the catalog.
    
  - `fluxes.auto_respiration_growth`: growth respiration per vegetation pool
    
  - `fluxes.auto_respiration_maintain`: maintenance respiration per vegetation pool
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  

`compute`:
- **Inputs**
  - `diagnostics.k_respiration_maintain`: metabolism rate for maintenance respiration
    
  - `diagnostics.k_respiration_maintain_su`: metabolism rate for maintenance respiration to be used in old analytical solution to steady state
    
  - `diagnostics.Fd`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :Fd)` for information on how to add the variable to the catalog.
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  - `fluxes.auto_respiration_growth`: growth respiration per vegetation pool
    
  - `fluxes.auto_respiration_maintain`: maintenance respiration per vegetation pool
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `pools.cVeg`: carbon content of cVeg pool(s)
    
  - `fluxes.gpp`: gross primary prorDcutivity
    
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.auto_respiration_f_airT`: effect of air temperature on autotrophic respiration. 0: no decomposition, &gt;1 increase in decomposition rate
    
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.k_respiration_maintain`: metabolism rate for maintenance respiration
    
  - `diagnostics.k_respiration_maintain_su`: metabolism rate for maintenance respiration to be used in old analytical solution to steady state
    
  - `fluxes.auto_respiration_growth`: growth respiration per vegetation pool
    
  - `fluxes.auto_respiration_maintain`: maintenance respiration per vegetation pool
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `autoRespiration_Thornley2000C.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Amthor, J. S. (2000), The McCree-de Wit-Penning de Vries-Thornley  respiration paradigms: 30 years later, Ann Bot-London, 86[1], 1-20.  Ryan, M. G. (1991), Effects of Climate Change on Plant Respiration, Ecol  Appl, 1[2], 157-167.
  
- Thornley, J. H. M., &amp; M. G. R. Cannell [2000], Modelling the components  of plant respiration: Representation &amp; realism, Ann Bot-London, 85[1]  55-67.
  

_Versions_
- 1.0 on 06.05.2022 [ncarvalhais/skoirala]: cleaned up the code
  

_Created by_
- ncarvalhais
  

_Notes_
- Questions - practical - leave raAct per pool; | make a field land.fluxes.ra  that has all the autotrophic respiration components together?  
  

</details>


== autoRespiration_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.autoRespiration_none' href='#Sindbad.Models.autoRespiration_none'><span class="jlbinding">Sindbad.Models.autoRespiration_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the autotrophic respiration flux from all vegetation pools to zero.

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `states.c_eco_efflux`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :c_eco_efflux)` for information on how to add the variable to the catalog.
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `autoRespiration_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_Notes_ Applicability: no C cycle; or computing/inputing NPP directly, e.g. like in Potter et al., (1993) and follow up approaches.

_References_ https://doi.org/10.1029/93GB02725

</details>


:::


---


### autoRespirationAirT {#autoRespirationAirT}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.autoRespirationAirT' href='#Sindbad.Models.autoRespirationAirT'><span class="jlbinding">Sindbad.Models.autoRespirationAirT</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
temperature effect on autotrophic respiration
```



---


**Approaches**
- `autoRespirationAirT_Q10`: temperature effect on autotrophic maintenance respiration following a Q10 response model
  
- `autoRespirationAirT_none`: sets the temperature effect on autotrophic respiration to one (i.e. no effect)
  

</details>


:::details autoRespirationAirT approaches

:::tabs

== autoRespirationAirT_Q10
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.autoRespirationAirT_Q10' href='#Sindbad.Models.autoRespirationAirT_Q10'><span class="jlbinding">Sindbad.Models.autoRespirationAirT_Q10</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



temperature effect on autotrophic maintenance respiration following a Q10 response model

**Parameters**
- **Fields**
  - `Q10`: 2.0 ∈ [1.05, 3.0] =&gt; Q10 parameter for maintenance respiration (`unitless` @ `all` timescales)
    
  - `ref_airT`: 20.0 ∈ [0.0, 40.0] =&gt; Reference temperature for the maintenance respiration (units: `°C` @ `all` timescales)
    
  - `Q10_base`: 10.0 ∈ [-Inf, Inf] =&gt; base temperature difference (units: `°C` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_airT`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.auto_respiration_f_airT`: effect of air temperature on autotrophic respiration. 0: no decomposition, &gt;1 increase in decomposition rate
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `autoRespirationAirT_Q10.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Amthor, J. S. (2000), The McCree-de Wit-Penning de Vries-Thornley  respiration paradigms: 30 years later, Ann Bot-London, 86[1], 1-20.
  
- Ryan, M. G. (1991), Effects of Climate Change on Plant Respiration, Ecol  Appl, 1[2], 157-167.
  
- Thornley, J. H. M., &amp; M. G. R. Cannell [2000], Modelling the components  of plant respiration: Representation &amp; realism, Ann Bot-London, 85[1]  55-67.
  

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: clean up  
  

_Created by_
- ncarvalhais
  

_Notes_

</details>


== autoRespirationAirT_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.autoRespirationAirT_none' href='#Sindbad.Models.autoRespirationAirT_none'><span class="jlbinding">Sindbad.Models.autoRespirationAirT_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the temperature effect on autotrophic respiration to one (i.e. no effect)

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.auto_respiration_f_airT`: effect of air temperature on autotrophic respiration. 0: no decomposition, &gt;1 increase in decomposition rate
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `autoRespirationAirT_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cAllocation {#cAllocation}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocation' href='#Sindbad.Models.cAllocation'><span class="jlbinding">Sindbad.Models.cAllocation</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Compute the allocation of C fixed by photosynthesis to the different vegetation pools (fraction of the net carbon fixation received by each vegetation carbon pool on every times step).
```



---


**Approaches**
- `cAllocation_Friedlingstein1999`: Compute the fraction of fixed C that is allocated to the different plant organs following the scheme of Friedlingstein et al., 1999 (section `Allocation response to multiple stresses``).
  
- `cAllocation_GSI`: Compute the fraction of fixated C that is allocated to the different plant organs. The allocation is dynamic in time according to temperature, water &amp; radiation stressors estimated following the GSI approach. Inspired by the work of Friedlingstein et al., 1999, based on Sharpe and Rykiel 1991, but here following the growing season index (GSI) as stress diagnostics, following Forkel et al 2014 and 2015, based on Jolly et al., 2005.
  
- `cAllocation_fixed`: Compute the fraction of net primary production (NPP) allocated to different plant organs with fixed allocation parameters. 
  

The allocation is adjusted based on the TreeFrac fraction (land.states.frac_tree).  Root allocation is further divided into fine (cf2Root) and coarse roots (cf2RootCoarse) according to the frac_fine_to_coarse parameter.
- `cAllocation_none`: sets the carbon allocation to zero (nothing to allocated)
  

</details>


:::details cAllocation approaches

:::tabs

== cAllocation_Friedlingstein1999
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocation_Friedlingstein1999' href='#Sindbad.Models.cAllocation_Friedlingstein1999'><span class="jlbinding">Sindbad.Models.cAllocation_Friedlingstein1999</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Compute the fraction of fixed C that is allocated to the different plant organs following the scheme of Friedlingstein et al., 1999 (section `Allocation response to multiple stresses``).

**Parameters**
- **Fields**
  - `so`: 0.3 ∈ [0.0, 1.0] =&gt; fractional carbon allocation to stem for non-limiting conditions (units: `fractional` @ `all` timescales)
    
  - `ro`: 0.3 ∈ [0.0, 1.0] =&gt; fractional carbon allocation to root for non-limiting conditions (units: `fractional` @ `all` timescales)
    
  - `rel_Y`: 2.0 ∈ [1.0, Inf] =&gt; normalization parameter (units: `dimensionless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  - `cAllocation.cVeg_names`: name of vegetation carbon pools used for carbon allocation
    
  - `cAllocation.cVeg_nzix`: number of pools/layers in each vegetation carbon component
    
  - `cAllocation.cVeg_zix`: number of pools/layers in each vegetation carbon component
    
  - `cAllocation.c_allocation_to_veg`: carbon allocation to each vvegetation pool
    
  

`compute`:
- **Inputs**
  - `states.c_allocation`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :c_allocation)` for information on how to add the variable to the catalog.
    
  - `cAllocation.cVeg_names`: name of vegetation carbon pools used for carbon allocation
    
  - `cAllocation.cVeg_nzix`: number of pools/layers in each vegetation carbon component
    
  - `cAllocation.cVeg_zix`: number of pools/layers in each vegetation carbon component
    
  - `cAllocation.c_allocation_to_veg`: carbon allocation to each vvegetation pool
    
  - `diagnostics.c_allocation_f_W_N`: effect of water and nutrient on carbon allocation. 1: no stress, 0: complete stress
    
  - `diagnostics.c_allocation_f_LAI`: effect of LAI on carbon allocation. 1: no stress, 0: complete stress
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocation_Friedlingstein1999.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Friedlingstein; P.; G. Joel; C.B. Field; &amp; I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.
  

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


== cAllocation_GSI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocation_GSI' href='#Sindbad.Models.cAllocation_GSI'><span class="jlbinding">Sindbad.Models.cAllocation_GSI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Compute the fraction of fixated C that is allocated to the different plant organs. The allocation is dynamic in time according to temperature, water &amp; radiation stressors estimated following the GSI approach. Inspired by the work of Friedlingstein et al., 1999, based on Sharpe and Rykiel 1991, but here following the growing season index (GSI) as stress diagnostics, following Forkel et al 2014 and 2015, based on Jolly et al., 2005.

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `cAllocation.cVeg_names`: name of vegetation carbon pools used for carbon allocation
    
  - `cAllocation.cVeg_zix`: number of pools/layers in each vegetation carbon component
    
  - `cAllocation.cVeg_nzix`: number of pools/layers in each vegetation carbon component
    
  - `cAllocation.c_allocation_to_veg`: carbon allocation to each vvegetation pool
    
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  

`compute`:
- **Inputs**
  - `cAllocation.cVeg_names`: name of vegetation carbon pools used for carbon allocation
    
  - `cAllocation.cVeg_zix`: number of pools/layers in each vegetation carbon component
    
  - `cAllocation.cVeg_nzix`: number of pools/layers in each vegetation carbon component
    
  - `cAllocation.c_allocation_to_veg`: carbon allocation to each vvegetation pool
    
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  - `diagnostics.c_allocation_f_soilW`: effect of soil moisture on carbon allocation. 1: no stress, 0: complete stress
    
  - `diagnostics.c_allocation_f_soilT`: effect of soil temperature on carbon allocation. 1: no stress, 0: complete stress
    
  - `constants.t_two`: a type stable 2
    
  
- **Outputs**
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocation_GSI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Forkel M, Carvalhais N, Schaphoff S, von Bloh W, Migliavacca M, Thurner M, Thonicke K [2014] Identifying environmental controls on vegetation greenness phenology through model–data integration. Biogeosciences, 11, 7025–7050.
  
- Forkel, M., Migliavacca, M., Thonicke, K., Reichstein, M., Schaphoff, S., Weber, U., Carvalhais, N. (2015).  Codominant water control on global interannual variability and trends in land surface phenology &amp; greenness.
  
- Friedlingstein; P.; G. Joel; C.B. Field; &amp; I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.
  
- Jolly, William M., Ramakrishna Nemani, &amp; Steven W. Running. &quot;A generalized, bioclimatic index to predict foliar phenology in response to climate.&quot; Global Change Biology 11.4 [2005]: 619-632.
  
- Sharpe PJH, Rykiel EJ (1991) Modelling integrated response of plants to multiple stresses. In: Response of Plants to Multiple Stresses (eds Mooney HA, Winner WE, Pell EJ), pp. 205±224, Academic Press, San Diego, CA.
  

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais &amp; sbesnard
  

NotesCheck if we can partition C to leaf &amp; wood constrained by interception of light.

</details>


== cAllocation_fixed
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocation_fixed' href='#Sindbad.Models.cAllocation_fixed'><span class="jlbinding">Sindbad.Models.cAllocation_fixed</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Compute the fraction of net primary production (NPP) allocated to different plant organs with fixed allocation parameters.  The allocation is adjusted based on the TreeFrac fraction (land.states.frac_tree).  Root allocation is further divided into fine (cf2Root) and coarse roots (cf2RootCoarse) according to the frac_fine_to_coarse parameter.

**Parameters**
- **Fields**
  - `a_cVegRoot`: 0.3 ∈ [0.0, 1.0] =&gt; fraction of assimilated C allocated to cRoot (units: `fraction` @ `all` timescales)
    
  - `a_cVegWood`: 0.3 ∈ [0.0, 1.0] =&gt; fraction of assimilated C allocated to cWood (units: `fraction` @ `all` timescales)
    
  - `a_cVegLeaf`: 0.4 ∈ [0.0, 1.0] =&gt; fraction of assimilated C allocated to cLeaf (units: `fraction` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `land.land_pools = pools`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:land, :land_pools = pools)` for information on how to add the variable to the catalog.
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  - `cAllocation.cVeg_names`: name of vegetation carbon pools used for carbon allocation
    
  - `cAllocation.cVeg_nzix`: number of pools/layers in each vegetation carbon component
    
  - `cAllocation.cVeg_zix`: number of pools/layers in each vegetation carbon component
    
  - `cAllocation.c_allocation_to_veg`: carbon allocation to each vvegetation pool
    
  

`precompute`:
- **Inputs**
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  - `cAllocation.cVeg_names`: name of vegetation carbon pools used for carbon allocation
    
  - `cAllocation.cVeg_nzix`: number of pools/layers in each vegetation carbon component
    
  - `cAllocation.cVeg_zix`: number of pools/layers in each vegetation carbon component
    
  - `cAllocation.c_allocation_to_veg`: carbon allocation to each vvegetation pool
    
  
- **Outputs**
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  

`compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocation_fixed.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Ciais; P.; Collatz; G.; Mahecha; M. D.  Montagnani; L.; Papale; D.; Rambal; S.; &amp; Seixas; J.: Identification of  Vegetation &amp; Soil Carbon Pools out of Equilibrium in a Process Model  via Eddy Covariance &amp; Biometric Constraints; Glob. Change Biol.; 16  2813?2829; doi: 10.1111/j.1365-2486.2009.2173.x; 2010.#
  
- Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; &amp; S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite &amp; surface data.  Global Biogeochemical Cycles. 7: 811-841.
  

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


== cAllocation_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocation_none' href='#Sindbad.Models.cAllocation_none'><span class="jlbinding">Sindbad.Models.cAllocation_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the carbon allocation to zero (nothing to allocated)

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocation_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cAllocationLAI {#cAllocationLAI}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationLAI' href='#Sindbad.Models.cAllocationLAI'><span class="jlbinding">Sindbad.Models.cAllocationLAI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Estimates allocation to the leaf pool given light limitation constraints to photosynthesis. Estimation via dynamics in leaf area index (LAI). Dynamic allocation approach.
```



---


**Approaches**
- `cAllocationLAI_Friedlingstein1999`: Estimate the effect of light limitation on carbon allocation via leaf area index (LAI) based on Friedlingstein et al., 1999.
  
- `cAllocationLAI_none`: sets the LAI effect on allocation to one (no effect)
  

</details>


:::details cAllocationLAI approaches

:::tabs

== cAllocationLAI_Friedlingstein1999
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationLAI_Friedlingstein1999' href='#Sindbad.Models.cAllocationLAI_Friedlingstein1999'><span class="jlbinding">Sindbad.Models.cAllocationLAI_Friedlingstein1999</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Estimate the effect of light limitation on carbon allocation via leaf area index (LAI) based on Friedlingstein et al., 1999.

**Parameters**
- **Fields**
  - `kext`: 0.5 ∈ [0.0, 1.0] =&gt; extinction coefficient of LAI effect on allocation (`unitless` @ `all` timescales)
    
  - `min_f_LAI`: 0.1 ∈ [0.0, 1.0] =&gt; minimum LAI effect on allocation (`unitless` @ `all` timescales)
    
  - `max_f_LAI`: 1.0 ∈ [0.0, 1.0] =&gt; maximum LAI effect on allocation (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.LAI`: leaf area index
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_LAI`: effect of LAI on carbon allocation. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationLAI_Friedlingstein1999.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Friedlingstein; P.; G. Joel; C.B. Field; &amp; I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.
  

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


== cAllocationLAI_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationLAI_none' href='#Sindbad.Models.cAllocationLAI_none'><span class="jlbinding">Sindbad.Models.cAllocationLAI_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the LAI effect on allocation to one (no effect)

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_LAI`: effect of LAI on carbon allocation. 1: no stress, 0: complete stress
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationLAI_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cAllocationNutrients {#cAllocationNutrients}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationNutrients' href='#Sindbad.Models.cAllocationNutrients'><span class="jlbinding">Sindbad.Models.cAllocationNutrients</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
(pseudo)effect of nutrients on carbon allocation
```



---


**Approaches**
- `cAllocationNutrients_Friedlingstein1999`: pseudo-nutrient limitation calculation based on Friedlingstein1999
  
- `cAllocationNutrients_none`: sets the pseudo-nutrient limitation to one (no effect)
  

</details>


:::details cAllocationNutrients approaches

:::tabs

== cAllocationNutrients_Friedlingstein1999
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationNutrients_Friedlingstein1999' href='#Sindbad.Models.cAllocationNutrients_Friedlingstein1999'><span class="jlbinding">Sindbad.Models.cAllocationNutrients_Friedlingstein1999</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



pseudo-nutrient limitation calculation based on Friedlingstein1999

**Parameters**
- **Fields**
  - `min_L`: 0.1 ∈ [0.0, 1.0] =&gt;  (`unitless` @ `all` timescales)
    
  - `max_L`: 1.0 ∈ [0.0, 1.0] =&gt;  (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  - `properties.∑w_awc`: total amount of water available for vegetation/transpiration
    
  - `diagnostics.c_allocation_f_soilW`: effect of soil moisture on carbon allocation. 1: no stress, 0: complete stress
    
  - `diagnostics.c_allocation_f_soilT`: effect of soil temperature on carbon allocation. 1: no stress, 0: complete stress
    
  - `fluxes.PET`: potential evapotranspiration
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `cAllocationNutrients.c_allocation_f_W_N`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cAllocationNutrients, :c_allocation_f_W_N)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationNutrients_Friedlingstein1999.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Friedlingstein; P.; G. Joel; C.B. Field; &amp; I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.
  

_Notes_
- &quot;There is no explicit estimate of soil mineral nitrogen in the version of CASA used for these simulations. As a surrogate; we assume that spatial variability in nitrogen mineralization &amp; soil organic matter decomposition are identical [Townsend et al. 1995]. Nitrogen availability; N; is calculated as the product of the temperature &amp; moisture abiotic factors used in CASA for the calculation of microbial respiration [Potter et al. 1993].&quot; in Friedlingstein et al., 1999.#
  

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


== cAllocationNutrients_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationNutrients_none' href='#Sindbad.Models.cAllocationNutrients_none'><span class="jlbinding">Sindbad.Models.cAllocationNutrients_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the pseudo-nutrient limitation to one (no effect)

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_W_N`: effect of water and nutrient on carbon allocation. 1: no stress, 0: complete stress
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationNutrients_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cAllocationRadiation {#cAllocationRadiation}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationRadiation' href='#Sindbad.Models.cAllocationRadiation'><span class="jlbinding">Sindbad.Models.cAllocationRadiation</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Effect of radiation on carbon allocation
```



---


**Approaches**
- `cAllocationRadiation_GSI`: radiation effect on allocation using GSI method
  
- `cAllocationRadiation_RgPot`: radiation effect on allocation using potential radiation instead of actual one
  
- `cAllocationRadiation_gpp`: radiation effect on allocation = the same for GPP
  
- `cAllocationRadiation_none`: sets the radiation effect on allocation to one (no effect)
  

</details>


:::details cAllocationRadiation approaches

:::tabs

== cAllocationRadiation_GSI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationRadiation_GSI' href='#Sindbad.Models.cAllocationRadiation_GSI'><span class="jlbinding">Sindbad.Models.cAllocationRadiation_GSI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



radiation effect on allocation using GSI method

**Parameters**
- **Fields**
  - `τ_rad`: 0.02 ∈ [0.001, 1.0] =&gt; temporal change rate for the light-limiting function (`unitless` @ `all` timescales)
    
  - `slope_rad`: 1.0 ∈ [0.01, 200.0] =&gt; slope parameters of a logistic function based on mean daily y shortwave downward radiation (`unitless` @ `all` timescales)
    
  - `base_rad`: 10.0 ∈ [0.0, 100.0] =&gt; inflection point parameters of a logistic function based on mean daily y shortwave downward radiation (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_cloud_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :c_allocation_f_cloud_prev)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `forcing.f_PAR`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_PAR)` for information on how to add the variable to the catalog.
    
  - `diagnostics.c_allocation_f_cloud_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :c_allocation_f_cloud_prev)` for information on how to add the variable to the catalog.
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.c_allocation_c_allocation_f_cloud`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :c_allocation_c_allocation_f_cloud)` for information on how to add the variable to the catalog.
    
  - `diagnostics.c_allocation_f_cloud_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :c_allocation_f_cloud_prev)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationRadiation_GSI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Forkel M, Carvalhais N, Schaphoff S, von Bloh W, Migliavacca M, Thurner M, Thonicke K [2014] Identifying environmental controls on vegetation greenness phenology through model–data integration. Biogeosciences, 11, 7025–7050.
  
- Forkel, M., Migliavacca, M., Thonicke, K., Reichstein, M., Schaphoff, S., Weber, U., Carvalhais, N. (2015).  Codominant water control on global interannual variability and trends in land surface phenology &amp; greenness.
  
- Jolly, William M., Ramakrishna Nemani, &amp; Steven W. Running. &quot;A generalized, bioclimatic index to predict foliar phenology in response to climate.&quot; Global Change Biology 11.4 [2005]: 619-632.
  

_Versions_
- 1.0 on 12.01.2020 [skoirala | @dr-ko]  
  

_Created by_
- ncarvalhais, sbesnard, skoirala
  

</details>


== cAllocationRadiation_RgPot
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationRadiation_RgPot' href='#Sindbad.Models.cAllocationRadiation_RgPot'><span class="jlbinding">Sindbad.Models.cAllocationRadiation_RgPot</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



radiation effect on allocation using potential radiation instead of actual one

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `forcing.f_rg_pot`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rg_pot)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `cAllocationRadiation.rg_pot_max`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cAllocationRadiation, :rg_pot_max)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `forcing.f_rg_pot`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rg_pot)` for information on how to add the variable to the catalog.
    
  - `cAllocationRadiation.rg_pot_max`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cAllocationRadiation, :rg_pot_max)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_cloud`: effect of cloud on carbon allocation. 1: no stress, 0: complete stress
    
  - `diagnostics.rg_pot_max`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :rg_pot_max)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationRadiation_RgPot.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 07.05.2025 [skoirala]
  

_Created by_
- skoirala
  

</details>


== cAllocationRadiation_gpp
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationRadiation_gpp' href='#Sindbad.Models.cAllocationRadiation_gpp'><span class="jlbinding">Sindbad.Models.cAllocationRadiation_gpp</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



radiation effect on allocation = the same for GPP

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `diagnostics.gpp_f_cloud`: effect of cloud on gpp. 1: no stress, 0: complete stress
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_cloud`: effect of cloud on carbon allocation. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationRadiation_gpp.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 26.01.2021 [skoirala | @dr-ko]  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== cAllocationRadiation_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationRadiation_none' href='#Sindbad.Models.cAllocationRadiation_none'><span class="jlbinding">Sindbad.Models.cAllocationRadiation_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the radiation effect on allocation to one (no effect)

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_cloud`: effect of cloud on carbon allocation. 1: no stress, 0: complete stress
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationRadiation_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cAllocationSoilT {#cAllocationSoilT}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationSoilT' href='#Sindbad.Models.cAllocationSoilT'><span class="jlbinding">Sindbad.Models.cAllocationSoilT</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Effect of soil temperature on carbon allocation
```



---


**Approaches**
- `cAllocationSoilT_Friedlingstein1999`: partial temperature effect on decomposition/mineralization based on Friedlingstein1999
  
- `cAllocationSoilT_gpp`: temperature effect on allocation = the same as gpp
  
- `cAllocationSoilT_gppGSI`: temperature effect on allocation from same for GPP based on GSI approach
  
- `cAllocationSoilT_none`: sets the temperature effect on allocation to one (no effect)
  

</details>


:::details cAllocationSoilT approaches

:::tabs

== cAllocationSoilT_Friedlingstein1999
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationSoilT_Friedlingstein1999' href='#Sindbad.Models.cAllocationSoilT_Friedlingstein1999'><span class="jlbinding">Sindbad.Models.cAllocationSoilT_Friedlingstein1999</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



partial temperature effect on decomposition/mineralization based on Friedlingstein1999

**Parameters**
- **Fields**
  - `min_f_soilT`: 0.5 ∈ [0.0, 1.0] =&gt; minimum allocation coefficient from temperature stress (`unitless` @ `all` timescales)
    
  - `max_f_soilT`: 1.0 ∈ [0.0, 1.0] =&gt; maximum allocation coefficient from temperature stress (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `diagnostics.c_allocation_f_soilT`: effect of soil temperature on carbon allocation. 1: no stress, 0: complete stress
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_soilT`: effect of soil temperature on carbon allocation. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationSoilT_Friedlingstein1999.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Friedlingstein; P.; G. Joel; C.B. Field; &amp; I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.
  

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


== cAllocationSoilT_gpp
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationSoilT_gpp' href='#Sindbad.Models.cAllocationSoilT_gpp'><span class="jlbinding">Sindbad.Models.cAllocationSoilT_gpp</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



temperature effect on allocation = the same as gpp

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `diagnostics.gpp_f_airT`: effect of air temperature on gpp. 1: no stress, 0: complete stress
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_soilT`: effect of soil temperature on carbon allocation. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationSoilT_gpp.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 26.01.2021 [skoirala | @dr-ko]  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== cAllocationSoilT_gppGSI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationSoilT_gppGSI' href='#Sindbad.Models.cAllocationSoilT_gppGSI'><span class="jlbinding">Sindbad.Models.cAllocationSoilT_gppGSI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



temperature effect on allocation from same for GPP based on GSI approach

**Parameters**
- **Fields**
  - `τ_Tsoil`: 0.2 ∈ [0.001, 1.0] =&gt; temporal change rate for the temperature-limiting function (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_soilT_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :c_allocation_f_soilT_prev)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `diagnostics.gpp_f_airT`: effect of air temperature on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.c_allocation_f_soilT_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :c_allocation_f_soilT_prev)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_soilT`: effect of soil temperature on carbon allocation. 1: no stress, 0: complete stress
    
  - `diagnostics.c_allocation_f_soilT_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :c_allocation_f_soilT_prev)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationSoilT_gppGSI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Forkel M, Carvalhais N, Schaphoff S, von Bloh W, Migliavacca M, Thurner M, Thonicke K [2014] Identifying environmental controls on vegetation greenness phenology through model–data integration. Biogeosciences, 11, 7025–7050.
  
- Forkel, M., Migliavacca, M., Thonicke, K., Reichstein, M., Schaphoff, S., Weber, U., Carvalhais, N. (2015).  Codominant water control on global interannual variability and trends in land surface phenology &amp; greenness.
  
- Jolly, William M., Ramakrishna Nemani, &amp; Steven W. Running. &quot;A generalized, bioclimatic index to predict foliar phenology in response to climate.&quot; Global Change Biology 11.4 [2005]: 619-632.
  

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais &amp; sbesnard
  

</details>


== cAllocationSoilT_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationSoilT_none' href='#Sindbad.Models.cAllocationSoilT_none'><span class="jlbinding">Sindbad.Models.cAllocationSoilT_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the temperature effect on allocation to one (no effect)

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_soilT`: effect of soil temperature on carbon allocation. 1: no stress, 0: complete stress
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationSoilT_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cAllocationSoilW {#cAllocationSoilW}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationSoilW' href='#Sindbad.Models.cAllocationSoilW'><span class="jlbinding">Sindbad.Models.cAllocationSoilW</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Effect of soil moisture on carbon allocation
```



---


**Approaches**
- `cAllocationSoilW_Friedlingstein1999`: partial moisture effect on decomposition/mineralization based on Friedlingstein1999
  
- `cAllocationSoilW_gpp`: moisture effect on allocation = the same as gpp
  
- `cAllocationSoilW_gppGSI`: moisture effect on allocation from same for GPP based on GSI approach
  
- `cAllocationSoilW_none`: sets the moisture effect on allocation to one (no effect)
  

</details>


:::details cAllocationSoilW approaches

:::tabs

== cAllocationSoilW_Friedlingstein1999
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationSoilW_Friedlingstein1999' href='#Sindbad.Models.cAllocationSoilW_Friedlingstein1999'><span class="jlbinding">Sindbad.Models.cAllocationSoilW_Friedlingstein1999</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



partial moisture effect on decomposition/mineralization based on Friedlingstein1999

**Parameters**
- **Fields**
  - `min_f_soilW`: 0.5 ∈ [0.0, 1.0] =&gt; minimum value for moisture stressor (`unitless` @ `all` timescales)
    
  - `max_f_soilW`: 0.8 ∈ [0.0, 1.0] =&gt; maximum value for moisture stressor (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `diagnostics.c_eco_k_f_soilW`: effect of soil moisture on carbon decomposition rate. 1: no stress, 0: complete stress
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_soilW`: effect of soil moisture on carbon allocation. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationSoilW_Friedlingstein1999.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Friedlingstein; P.; G. Joel; C.B. Field; &amp; I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.
  

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


== cAllocationSoilW_gpp
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationSoilW_gpp' href='#Sindbad.Models.cAllocationSoilW_gpp'><span class="jlbinding">Sindbad.Models.cAllocationSoilW_gpp</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



moisture effect on allocation = the same as gpp

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `diagnostics.gpp_f_soilW`: effect of soil moisture on gpp. 1: no stress, 0: complete stress
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_soilW`: effect of soil moisture on carbon allocation. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationSoilW_gpp.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 26.01.2021 [skoirala | @dr-ko]  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== cAllocationSoilW_gppGSI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationSoilW_gppGSI' href='#Sindbad.Models.cAllocationSoilW_gppGSI'><span class="jlbinding">Sindbad.Models.cAllocationSoilW_gppGSI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



moisture effect on allocation from same for GPP based on GSI approach

**Parameters**
- **Fields**
  - `τ_soilW`: 0.8 ∈ [0.001, 1.0] =&gt; temporal change rate for the water-limiting function (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `properties.∑w_sat`: total amount of water in the soil at saturation
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_soilW_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :c_allocation_f_soilW_prev)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `diagnostics.gpp_f_soilW`: effect of soil moisture on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.c_allocation_f_soilW_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :c_allocation_f_soilW_prev)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_soilW`: effect of soil moisture on carbon allocation. 1: no stress, 0: complete stress
    
  - `diagnostics.c_allocation_f_soilW_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :c_allocation_f_soilW_prev)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationSoilW_gppGSI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Forkel M, Carvalhais N, Schaphoff S, von Bloh W, Migliavacca M, Thurner M, Thonicke K [2014] Identifying environmental controls on vegetation greenness phenology through model–data integration. Biogeosciences, 11, 7025–7050.
  
- Forkel, M., Migliavacca, M., Thonicke, K., Reichstein, M., Schaphoff, S., Weber, U., Carvalhais, N. (2015).  Codominant water control on global interannual variability and trends in land surface phenology &amp; greenness.
  
- Jolly, William M., Ramakrishna Nemani, &amp; Steven W. Running. &quot;A generalized, bioclimatic index to predict foliar phenology in response to climate.&quot; Global Change Biology 11.4 [2005]: 619-632.
  

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais &amp; sbesnard
  

</details>


== cAllocationSoilW_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationSoilW_none' href='#Sindbad.Models.cAllocationSoilW_none'><span class="jlbinding">Sindbad.Models.cAllocationSoilW_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the moisture effect on allocation to one (no effect)

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_allocation_f_soilW`: effect of soil moisture on carbon allocation. 1: no stress, 0: complete stress
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationSoilW_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cAllocationTreeFraction {#cAllocationTreeFraction}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationTreeFraction' href='#Sindbad.Models.cAllocationTreeFraction'><span class="jlbinding">Sindbad.Models.cAllocationTreeFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Adjustment of carbon allocation according to tree cover
```



---


**Approaches**
- `cAllocationTreeFraction_Friedlingstein1999`: adjust the allocation coefficients according to the fraction of trees to herbaceous &amp; fine to coarse root partitioning
  

</details>


:::details cAllocationTreeFraction approaches

:::tabs

== cAllocationTreeFraction_Friedlingstein1999
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cAllocationTreeFraction_Friedlingstein1999' href='#Sindbad.Models.cAllocationTreeFraction_Friedlingstein1999'><span class="jlbinding">Sindbad.Models.cAllocationTreeFraction_Friedlingstein1999</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



adjust the allocation coefficients according to the fraction of trees to herbaceous &amp; fine to coarse root partitioning

**Parameters**
- **Fields**
  - `frac_fine_to_coarse`: 1.0 ∈ [0.0, 1.0] =&gt; carbon fraction allocated to fine roots (units: `fraction` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `cAllocationTreeFraction.cVeg_names_for_c_allocation_frac_tree`: name of vegetation carbon pools used in tree fraction correction for carbon allocation
    
  

`compute`:
- **Inputs**
  - `states.frac_tree`: fractional coverage of grid with trees
    
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  - `cAllocationTreeFraction.cVeg_names_for_c_allocation_frac_tree`: name of vegetation carbon pools used in tree fraction correction for carbon allocation
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cAllocationTreeFraction_Friedlingstein1999.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Friedlingstein; P.; G. Joel; C.B. Field; &amp; I.Y. Fung; 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol.; 5; 755-770; doi:10.1046/j.1365-2486.1999.00269.x.
  

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


:::


---


### cBiomass {#cBiomass}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cBiomass' href='#Sindbad.Models.cBiomass'><span class="jlbinding">Sindbad.Models.cBiomass</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Compute aboveground_biomass
```



---


**Approaches**
- `cBiomass_simple`: calculates aboveground biomass as a sum of wood and leaf carbon pools.
  
- `cBiomass_treeGrass`: This serves the in situ optimization of eddy covariance sites when using AGB as a constraint. In locations where tree cover is not zero, AGB = leaf + wood. In locations where is only grass, there are no observational constraints for AGB. AGB from EO mostly refers to forested locations. To ensure that the parameter set that emerges from optimization does not generate wood, while not assuming any prior on mass of leafs, the aboveground biomass of grasses is set to the wood value, that will be constrained against a pseudo-observational value close to 0. One expects that after optimization, cVegWood_sum will be close to 0 in locations where frac_tree = 0.
  
- `cBiomass_treeGrass_cVegReserveScaling`: same as treeGrass, but includes scaling for relative fraction of cVegReserve pool
  

</details>


:::details cBiomass approaches

:::tabs

== cBiomass_simple
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cBiomass_simple' href='#Sindbad.Models.cBiomass_simple'><span class="jlbinding">Sindbad.Models.cBiomass_simple</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates aboveground biomass as a sum of wood and leaf carbon pools.

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.cVegWood`: carbon content of cVegWood pool(s)
    
  - `pools.cVegLeaf`: carbon content of cVegLeaf pool(s)
    
  
- **Outputs**
  - `states.aboveground_biomass`: carbon content on the cVegWood component
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cBiomass_simple.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_

_Created by_

</details>


== cBiomass_treeGrass
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cBiomass_treeGrass' href='#Sindbad.Models.cBiomass_treeGrass'><span class="jlbinding">Sindbad.Models.cBiomass_treeGrass</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



This serves the in situ optimization of eddy covariance sites when using AGB as a constraint. In locations where tree cover is not zero, AGB = leaf + wood. In locations where is only grass, there are no observational constraints for AGB. AGB from EO mostly refers to forested locations. To ensure that the parameter set that emerges from optimization does not generate wood, while not assuming any prior on mass of leafs, the aboveground biomass of grasses is set to the wood value, that will be constrained against a pseudo-observational value close to 0. One expects that after optimization, cVegWood_sum will be close to 0 in locations where frac_tree = 0.

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.cVegWood`: carbon content of cVegWood pool(s)
    
  - `pools.cVegLeaf`: carbon content of cVegLeaf pool(s)
    
  - `states.frac_tree`: fractional coverage of grid with trees
    
  
- **Outputs**
  - `states.aboveground_biomass`: carbon content on the cVegWood component
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cBiomass_treeGrass.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_

_Created by_

</details>


== cBiomass_treeGrass_cVegReserveScaling
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cBiomass_treeGrass_cVegReserveScaling' href='#Sindbad.Models.cBiomass_treeGrass_cVegReserveScaling'><span class="jlbinding">Sindbad.Models.cBiomass_treeGrass_cVegReserveScaling</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



same as treeGrass, but includes scaling for relative fraction of cVegReserve pool

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.cVegWood`: carbon content of cVegWood pool(s)
    
  - `pools.cVegLeaf`: carbon content of cVegLeaf pool(s)
    
  - `pools.cVegReserve`: carbon content of cVegReserve pool(s) that does not respire
    
  - `pools.cVegRoot`: carbon content of cVegRoot pool(s)
    
  - `states.frac_tree`: fractional coverage of grid with trees
    
  
- **Outputs**
  - `states.aboveground_biomass`: carbon content on the cVegWood component
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cBiomass_treeGrass_cVegReserveScaling.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 07.05.2025 [skoirala]
  

_Created by_
- skoirala
  

</details>


:::


---


### cCycle {#cCycle}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycle' href='#Sindbad.Models.cCycle'><span class="jlbinding">Sindbad.Models.cCycle</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Allocate carbon to vegetation components
```



---


**Approaches**
- `cCycle_CASA`: Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools
  
- `cCycle_GSI`: Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools
  
- `cCycle_simple`: Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools
  

</details>


:::details cCycle approaches

:::tabs

== cCycle_CASA
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycle_CASA' href='#Sindbad.Models.cCycle_CASA'><span class="jlbinding">Sindbad.Models.cCycle_CASA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `cCycle.c_eco_efflux`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cCycle, :c_eco_efflux)` for information on how to add the variable to the catalog.
    
  - `cCycle.c_eco_influx`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cCycle, :c_eco_influx)` for information on how to add the variable to the catalog.
    
  - `cCycle.c_eco_flow`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cCycle, :c_eco_flow)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `cCycle.c_eco_efflux`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cCycle, :c_eco_efflux)` for information on how to add the variable to the catalog.
    
  - `cCycle.c_eco_influx`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cCycle, :c_eco_influx)` for information on how to add the variable to the catalog.
    
  - `cCycle.c_eco_flow`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cCycle, :c_eco_flow)` for information on how to add the variable to the catalog.
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  - `fluxes.c_eco_flow`: flow of carbon to a given carbon pool from other carbon pools
    
  - `fluxes.c_eco_influx`: net influx from allocation and efflux (npp) to each (live) carbon pool
    
  - `fluxes.c_eco_out`: outflux of carbon from each carbol pool
    
  - `fluxes.c_eco_npp`: npp of each carbon pool
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `pools.cVeg`: carbon content of cVeg pool(s)
    
  - `fluxes.gpp`: gross primary prorDcutivity
    
  - `diagnostics.c_eco_k`: decomposition rate of carbon per pool
    
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  - `cFlow.p_E_vec`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlow, :p_E_vec)` for information on how to add the variable to the catalog.
    
  - `cFlow.p_F_vec`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlow, :p_F_vec)` for information on how to add the variable to the catalog.
    
  - `cFlow.p_giver`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlow, :p_giver)` for information on how to add the variable to the catalog.
    
  - `cFlow.p_taker`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlow, :p_taker)` for information on how to add the variable to the catalog.
    
  - `constants.c_flow_order`: order of pooling while calculating the carbon flow
    
  - `diagnostics.c_eco_τ`: number of years needed for carbon turnover per carbon pool
    
  
- **Outputs**
  - `fluxes.nee`: net ecosystem carbon exchange for the ecosystem. negative value indicates carbon sink.
    
  - `fluxes.c_eco_npp`: npp of each carbon pool
    
  - `fluxes.auto_respiration`: carbon loss due to autotrophic respiration
    
  - `fluxes.eco_respiration`: carbon loss due to ecosystem respiration
    
  - `fluxes.hetero_respiration`: carbon loss due to heterotrophic respiration
    
  - `states.c_eco_efflux`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :c_eco_efflux)` for information on how to add the variable to the catalog.
    
  - `states.c_eco_flow`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :c_eco_flow)` for information on how to add the variable to the catalog.
    
  - `states.c_eco_influx`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :c_eco_influx)` for information on how to add the variable to the catalog.
    
  - `states.c_eco_out`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :c_eco_out)` for information on how to add the variable to the catalog.
    
  - `states.c_eco_npp`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :c_eco_npp)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cCycle_CASA.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  &amp; Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance &amp; inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
  
- Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., &amp; Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data &amp; ecosystem  modeling 1982–1998. Global &amp; Planetary Change, 39[3-4], 201-213.
  
- Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  &amp; Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite &amp; surface data. Global Biogeochemical Cycles, 7[4], 811-841.
  

_Versions_
- 1.0 on 28.02.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


== cCycle_GSI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycle_GSI' href='#Sindbad.Models.cCycle_GSI'><span class="jlbinding">Sindbad.Models.cCycle_GSI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `fluxes.c_eco_flow`: flow of carbon to a given carbon pool from other carbon pools
    
  - `fluxes.c_eco_influx`: net influx from allocation and efflux (npp) to each (live) carbon pool
    
  - `fluxes.c_eco_out`: outflux of carbon from each carbol pool
    
  - `fluxes.c_eco_npp`: npp of each carbon pool
    
  - `fluxes.zero_c_eco_flow`: helper for resetting c_eco_flow in every time step
    
  - `fluxes.zero_c_eco_influx`: helper for resetting c_eco_influx in every time step
    
  - `states.cEco_prev`: ecosystem carbon content of the previous time step
    
  - `pools.ΔcEco`: change in water storage in cEco pool(s)
    
  

`compute`:
- **Inputs**
  - `diagnostics.c_allocation`: fraction of gpp allocated to different (live) carbon pools
    
  - `diagnostics.c_eco_k`: decomposition rate of carbon per pool
    
  - `diagnostics.c_flow_A_vec`: fraction of the carbon loss fron a (giver) pool that flows to a (taker) pool
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  - `fluxes.c_eco_flow`: flow of carbon to a given carbon pool from other carbon pools
    
  - `fluxes.c_eco_influx`: net influx from allocation and efflux (npp) to each (live) carbon pool
    
  - `fluxes.c_eco_out`: outflux of carbon from each carbol pool
    
  - `fluxes.c_eco_npp`: npp of each carbon pool
    
  - `fluxes.zero_c_eco_flow`: helper for resetting c_eco_flow in every time step
    
  - `fluxes.zero_c_eco_influx`: helper for resetting c_eco_influx in every time step
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `pools.cVeg`: carbon content of cVeg pool(s)
    
  - `pools.ΔcEco`: change in water storage in cEco pool(s)
    
  - `states.cEco_prev`: ecosystem carbon content of the previous time step
    
  - `fluxes.gpp`: gross primary prorDcutivity
    
  - `constants.c_flow_order`: order of pooling while calculating the carbon flow
    
  - `constants.c_giver`: index of the source carbon pool for a given flow
    
  - `constants.c_taker`: index of the source carbon pool for a given flow
    
  - `models.c_model`: a base carbon cycle model to loop through the pools and fill the main or component pools needed for using static arrays. A mandatory field for every carbon model realization
    
  
- **Outputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `fluxes.nee`: net ecosystem carbon exchange for the ecosystem. negative value indicates carbon sink.
    
  - `fluxes.npp`: net primary prorDcutivity
    
  - `fluxes.auto_respiration`: carbon loss due to autotrophic respiration
    
  - `fluxes.eco_respiration`: carbon loss due to ecosystem respiration
    
  - `fluxes.hetero_respiration`: carbon loss due to heterotrophic respiration
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  - `fluxes.c_eco_flow`: flow of carbon to a given carbon pool from other carbon pools
    
  - `fluxes.c_eco_influx`: net influx from allocation and efflux (npp) to each (live) carbon pool
    
  - `fluxes.c_eco_out`: outflux of carbon from each carbol pool
    
  - `fluxes.c_eco_npp`: npp of each carbon pool
    
  - `states.cEco_prev`: ecosystem carbon content of the previous time step
    
  - `pools.ΔcEco`: change in water storage in cEco pool(s)
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cCycle_GSI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; &amp; S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite &amp; surface data.  Global Biogeochemical Cycles. 7: 811-841.
  

_Versions_
- 1.0 on 28.02.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


== cCycle_simple
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycle_simple' href='#Sindbad.Models.cCycle_simple'><span class="jlbinding">Sindbad.Models.cCycle_simple</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `pools.cVeg`: carbon content of cVeg pool(s)
    
  
- **Outputs**
  - `cCycle.zixVeg`: a vector of indices for vegetation pools within the array of carbon pools in cEco
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  - `fluxes.c_eco_flow`: flow of carbon to a given carbon pool from other carbon pools
    
  - `fluxes.c_eco_influx`: net influx from allocation and efflux (npp) to each (live) carbon pool
    
  - `fluxes.c_eco_out`: outflux of carbon from each carbol pool
    
  - `fluxes.c_eco_npp`: npp of each carbon pool
    
  - `fluxes.zero_c_eco_flow`: helper for resetting c_eco_flow in every time step
    
  - `fluxes.zero_c_eco_influx`: helper for resetting c_eco_influx in every time step
    
  - `states.cEco_prev`: ecosystem carbon content of the previous time step
    
  - `fluxes.nee`: net ecosystem carbon exchange for the ecosystem. negative value indicates carbon sink.
    
  - `fluxes.npp`: net primary prorDcutivity
    
  - `fluxes.auto_respiration`: carbon loss due to autotrophic respiration
    
  - `fluxes.eco_respiration`: carbon loss due to ecosystem respiration
    
  - `fluxes.hetero_respiration`: carbon loss due to heterotrophic respiration
    
  

`compute`:
- **Inputs**
  - `cCycle.zixVeg`: a vector of indices for vegetation pools within the array of carbon pools in cEco
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  - `fluxes.c_eco_flow`: flow of carbon to a given carbon pool from other carbon pools
    
  - `fluxes.c_eco_influx`: net influx from allocation and efflux (npp) to each (live) carbon pool
    
  - `fluxes.c_eco_out`: outflux of carbon from each carbol pool
    
  - `fluxes.c_eco_npp`: npp of each carbon pool
    
  - `fluxes.zero_c_eco_flow`: helper for resetting c_eco_flow in every time step
    
  - `fluxes.zero_c_eco_influx`: helper for resetting c_eco_influx in every time step
    
  - `states.cEco_prev`: ecosystem carbon content of the previous time step
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `diagnostics.c_flow_A_vec`: fraction of the carbon loss fron a (giver) pool that flows to a (taker) pool
    
  - `diagnostics.c_eco_k`: decomposition rate of carbon per pool
    
  - `pools.ΔcEco`: change in water storage in cEco pool(s)
    
  - `fluxes.gpp`: gross primary prorDcutivity
    
  - `constants.c_giver`: index of the source carbon pool for a given flow
    
  - `constants.c_taker`: index of the source carbon pool for a given flow
    
  - `constants.c_flow_order`: order of pooling while calculating the carbon flow
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `fluxes.nee`: net ecosystem carbon exchange for the ecosystem. negative value indicates carbon sink.
    
  - `fluxes.npp`: net primary prorDcutivity
    
  - `fluxes.auto_respiration`: carbon loss due to autotrophic respiration
    
  - `fluxes.eco_respiration`: carbon loss due to ecosystem respiration
    
  - `fluxes.hetero_respiration`: carbon loss due to heterotrophic respiration
    
  - `fluxes.c_eco_efflux`: losss of carbon from (live) vegetation pools due to autotrophic respiration
    
  - `fluxes.c_eco_flow`: flow of carbon to a given carbon pool from other carbon pools
    
  - `fluxes.c_eco_influx`: net influx from allocation and efflux (npp) to each (live) carbon pool
    
  - `fluxes.c_eco_out`: outflux of carbon from each carbol pool
    
  - `fluxes.c_eco_npp`: npp of each carbon pool
    
  - `states.cEco_prev`: ecosystem carbon content of the previous time step
    
  - `pools.ΔcEco`: change in water storage in cEco pool(s)
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cCycle_simple.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; &amp; S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite &amp; surface data.  Global Biogeochemical Cycles. 7: 811-841.
  

_Versions_
- 1.0 on 28.02.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


:::


---


### cCycleBase {#cCycleBase}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycleBase' href='#Sindbad.Models.cCycleBase'><span class="jlbinding">Sindbad.Models.cCycleBase</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Pool structure of the carbon cycle
```



---


**Approaches**
- `cCycleBase_CASA`: Compute carbon to nitrogen ratio &amp; base turnover rates
  
- `cCycleBase_GSI`: sets the basics for carbon cycle in the GSI approach
  
- `cCycleBase_GSI_PlantForm`: sets the basics for carbon cycle  pools as in the GSI, but allows for scaling of turnover parameters based on plant forms
  
- `cCycleBase_GSI_PlantForm_LargeKReserve`: same as cCycleBase_GSI_PlantForm but with a larger turnover of reserve so that it respires and flows
  
- `cCycleBase_simple`: Compute carbon to nitrogen ratio &amp; annual turnover rates
  

</details>


:::details cCycleBase approaches

:::tabs

== cCycleBase_CASA
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycleBase_CASA' href='#Sindbad.Models.cCycleBase_CASA'><span class="jlbinding">Sindbad.Models.cCycleBase_CASA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Compute carbon to nitrogen ratio &amp; base turnover rates

**Parameters**
- **Fields**
  - `annk`: [1.0, 0.03, 0.03, 1.0, 14.8, 3.9, 18.5, 4.8, 0.2424, 0.2424, 6.0, 7.3, 0.2, 0.0045] ∈ [[0.05, 0.002, 0.002, 0.05, 1.48, 0.39, 1.85, 0.48, 0.02424, 0.02424, 0.6, 0.73, 0.02, 0.0045], [3.3, 0.5, 0.5, 3.3, 148.0, 39.0, 185.0, 48.0, 2.424, 2.424, 60.0, 73.0, 2.0, 0.045]] =&gt; turnover rate of ecosystem carbon pools (units: `year-1` @ `all` timescales)
    
  - `c_flow_E_array`: [-1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.4 0.4 0.0 0.0 0.4 0.0 -1.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.45 0.45 0.0 0.4 0.0 -1.0 0.45 0.45; 0.0 0.0 0.0 0.0 0.0 0.6 0.0 0.55 0.6 0.6 0.4 0.0 -1.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.45 -1.0] ∈ [-Inf, Inf] =&gt; Transfer matrix for carbon at ecosystem level (`unitless` @ `all` timescales)
    
  - `cVegRootF_age_per_PFT`: [1.8, 1.2, 1.2, 5.0, 1.8, 1.0, 1.0, 0.0, 1.0, 2.8, 1.0, 1.0] ∈ [[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0]] =&gt; mean age of fine roots (units: `yr` @ `all` timescales)
    
  - `cVegRootC_age_per_PFT`: [41.0, 58.0, 58.0, 42.0, 27.0, 25.0, 25.0, 0.0, 5.5, 40.0, 1.0, 40.0] ∈ [[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0]] =&gt; mean age of coarse roots (units: `yr` @ `all` timescales)
    
  - `cVegWood_age_per_PFT`: [41.0, 58.0, 58.0, 42.0, 27.0, 25.0, 25.0, 0.0, 5.5, 40.0, 1.0, 40.0] ∈ [[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0]] =&gt; mean age of wood (units: `yr` @ `all` timescales)
    
  - `cVegLeaf_age_per_PFT`: [1.8, 1.2, 1.2, 5.0, 1.8, 1.0, 1.0, 0.0, 1.0, 2.8, 1.0, 1.0] ∈ [[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0, 20.0]] =&gt; mean age of leafs (units: `yr` @ `all` timescales)
    
  - `p_C_to_N_cVeg`: [25.0, 260.0, 260.0, 25.0] ∈ [-Inf, Inf] =&gt; carbon to nitrogen ratio in vegetation pools (units: `gC/gN` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.c_flow_A_array`: an array indicating the flow direction and connections across different pools, with elements larger than 0 indicating flow from column pool to row pool
    
  - `diagnostics.c_flow_E_array`: an array containing the efficiency of each flow in the c_flow_A_array
    
  

`compute`:
- **Inputs**
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.c_eco_k_base`: base carbon decomposition rate of the carbon pools
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cCycleBase_CASA.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  &amp; Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance &amp; inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
  
- Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., &amp; Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data &amp; ecosystem  modeling 1982–1998. Global &amp; Planetary Change, 39[3-4], 201-213.
  
- Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  &amp; Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite &amp; surface data. Global Biogeochemical Cycles, 7[4], 811-841.
  

_Versions_
- 1.0 on 28.05.2022 [skoirala | @dr-ko]: migrate to julia  
  

_Created by_
- ncarvalhais
  

</details>


== cCycleBase_GSI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycleBase_GSI' href='#Sindbad.Models.cCycleBase_GSI'><span class="jlbinding">Sindbad.Models.cCycleBase_GSI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the basics for carbon cycle in the GSI approach

**Parameters**
- **Fields**
  - `c_τ_Root`: 1.0 ∈ [0.05, 3.3] =&gt; turnover rate of root carbon pool (units: `year-1` @ `year` timescale)
    
  - `c_τ_Wood`: 0.03 ∈ [0.001, 10.0] =&gt; turnover rate of wood carbon pool (units: `year-1` @ `year` timescale)
    
  - `c_τ_Leaf`: 1.0 ∈ [0.05, 10.0] =&gt; turnover rate of leaf carbon pool (units: `year-1` @ `year` timescale)
    
  - `c_τ_Reserve`: 1.0e-11 ∈ [1.0e-12, 1.0] =&gt; Reserve does not respire, but has a small value to avoid  numerical error (units: `year-1` @ `year` timescale)
    
  - `c_τ_LitFast`: 14.8 ∈ [0.5, 148.0] =&gt; turnover rate of fast litter (leaf litter) carbon pool (units: `year-1` @ `year` timescale)
    
  - `c_τ_LitSlow`: 3.9 ∈ [0.39, 39.0] =&gt; turnover rate of slow litter carbon (wood litter) pool (units: `year-1` @ `year` timescale)
    
  - `c_τ_SoilSlow`: 0.2 ∈ [0.02, 2.0] =&gt; turnover rate of slow soil carbon pool (units: `year-1` @ `year` timescale)
    
  - `c_τ_SoilOld`: 0.0045 ∈ [0.00045, 0.045] =&gt; turnover rate of old soil carbon pool (units: `year-1` @ `year` timescale)
    
  - `c_flow_A_array`: [-1.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0; 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 -1.0 1.0 0.0 0.0 0.0 0.0; 1.0 0.0 1.0 -1.0 0.0 0.0 0.0 0.0; 1.0 0.0 1.0 0.0 -1.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0 0.0 -1.0 0.0 0.0; 0.0 0.0 0.0 0.0 1.0 1.0 -1.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 1.0 -1.0] ∈ [-Inf, Inf] =&gt; Transfer matrix for carbon at ecosystem level (`unitless` @ `all` timescales)
    
  - `p_C_to_N_cVeg`: [25.0, 260.0, 260.0, 10.0] ∈ [-Inf, Inf] =&gt; carbon to nitrogen ratio in vegetation pools (units: `gC/gN` @ `all` timescales)
    
  - `ηH`: 1.0 ∈ [0.01, 100.0] =&gt; scaling factor for heterotrophic pools after spinup (`unitless` @ `all` timescales)
    
  - `ηA`: 1.0 ∈ [0.01, 100.0] =&gt; scaling factor for vegetation pools after spinup (`unitless` @ `all` timescales)
    
  - `c_remain`: 10.0 ∈ [0.1, 100.0] =&gt; remaining carbon after disturbance (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.c_flow_A_array`: an array indicating the flow direction and connections across different pools, with elements larger than 0 indicating flow from column pool to row pool
    
  - `constants.c_flow_order`: order of pooling while calculating the carbon flow
    
  - `constants.c_taker`: index of the source carbon pool for a given flow
    
  - `constants.c_giver`: index of the source carbon pool for a given flow
    
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.c_eco_τ`: number of years needed for carbon turnover per carbon pool
    
  - `diagnostics.c_eco_k_base`: base carbon decomposition rate of the carbon pools
    
  - `models.c_model`: a base carbon cycle model to loop through the pools and fill the main or component pools needed for using static arrays. A mandatory field for every carbon model realization
    
  

`precompute`:
- **Inputs**
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.c_eco_k_base`: base carbon decomposition rate of the carbon pools
    
  - `diagnostics.c_eco_τ`: number of years needed for carbon turnover per carbon pool
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.c_eco_τ`: number of years needed for carbon turnover per carbon pool
    
  - `diagnostics.c_eco_k_base`: base carbon decomposition rate of the carbon pools
    
  - `diagnostics.ηA`: scalar of autotrophic carbon pool for steady state guess
    
  - `diagnostics.ηH`: scalar of heterotrophic carbon pool for steady state guess
    
  - `states.c_remain`: amount of carbon to keep in the ecosystem vegetation pools in case of disturbances
    
  

`compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cCycleBase_GSI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; &amp; S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite &amp; surface data.  Global Biogeochemical Cycles. 7: 811-841.
  

_Versions_
- 1.0 on 28.02.2020 [skoirala | @dr-ko]  
  

_Created by_
- ncarvalhais
  

</details>


== cCycleBase_GSI_PlantForm
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycleBase_GSI_PlantForm' href='#Sindbad.Models.cCycleBase_GSI_PlantForm'><span class="jlbinding">Sindbad.Models.cCycleBase_GSI_PlantForm</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the basics for carbon cycle  pools as in the GSI, but allows for scaling of turnover parameters based on plant forms

**Parameters**
- **Fields**
  - `c_τ_Root_scalar`: 1.0 ∈ [0.25, 4] =&gt; scalar for turnover rate of root carbon pool (units: `-` @ `all` timescales)
    
  - `c_τ_Wood_scalar`: 1.0 ∈ [0.25, 4] =&gt; scalar for turnover rate of wood carbon pool (units: `-` @ `all` timescales)
    
  - `c_τ_Leaf_scalar`: 1.0 ∈ [0.25, 4] =&gt; scalar for turnover rate of leaf carbon pool (units: `-` @ `all` timescales)
    
  - `c_τ_Litter_scalar`: 1.0 ∈ [0.25, 4] =&gt; scalar for turnover rate of litter carbon pool (units: `-` @ `all` timescales)
    
  - `c_τ_Reserve_scalar`: 1.0 ∈ [0.25, 4] =&gt; scalar for Reserve does not respire, but has a small value to avoid numerical error (units: `-` @ `all` timescales)
    
  - `c_τ_Soil_scalar`: 1.0 ∈ [0.25, 4] =&gt; scalar for turnover rate of soil carbon pool (units: `-` @ `all` timescales)
    
  - `c_τ_tree`: [1.0, 0.02, 1.0, 1.0e-11] ∈ [[0.25, 0.005, 0.25, 2.5e-12], [4.0, 0.08, 4.0, 4.0e-11]] =&gt; turnover of different organs of trees (units: `year-1` @ `year` timescale)
    
  - `c_τ_shrub`: [1.0, 0.2, 1.0, 1.0e-11] ∈ [[0.25, 0.05, 0.25, 2.5e-12], [4.0, 0.8, 4.0, 4.0e-11]] =&gt; turnover of different organs of shrubs (units: `year-1` @ `year` timescale)
    
  - `c_τ_herb`: [1.3333333333333333, 1.3333333333333333, 1.3333333333333333, 1.3333333333333333e-11] ∈ [[0.3333333333333333, 0.3333333333333333, 0.3333333333333333, 3.333333333333333e-12], [5.333333333333333, 5.333333333333333, 5.333333333333333, 5.333333333333333e-11]] =&gt; turnover of different organs of herbs (units: `year-1` @ `year` timescale)
    
  - `c_τ_LitFast`: 14.8 ∈ [0.5, 148.0] =&gt; turnover rate of fast litter (leaf litter) carbon pool (units: `year-1` @ `year` timescale)
    
  - `c_τ_LitSlow`: 3.9 ∈ [0.39, 39.0] =&gt; turnover rate of slow litter carbon (wood litter) pool (units: `year-1` @ `year` timescale)
    
  - `c_τ_SoilSlow`: 0.2 ∈ [0.02, 2.0] =&gt; turnover rate of slow soil carbon pool (units: `year-1` @ `year` timescale)
    
  - `c_τ_SoilOld`: 0.0045 ∈ [0.00045, 0.045] =&gt; turnover rate of old soil carbon pool (units: `year-1` @ `year` timescale)
    
  - `c_flow_A_array`: [-1.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0; 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 -1.0 1.0 0.0 0.0 0.0 0.0; 1.0 0.0 1.0 -1.0 0.0 0.0 0.0 0.0; 1.0 0.0 1.0 0.0 -1.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0 0.0 -1.0 0.0 0.0; 0.0 0.0 0.0 0.0 1.0 1.0 -1.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 1.0 -1.0] ∈ [-Inf, Inf] =&gt; Transfer matrix for carbon at ecosystem level (`unitless` @ `all` timescales)
    
  - `p_C_to_N_cVeg`: [25.0, 260.0, 260.0, 10.0] ∈ [-Inf, Inf] =&gt; carbon to nitrogen ratio in vegetation pools (units: `gC/gN` @ `all` timescales)
    
  - `ηH`: 1.0 ∈ [0.125, 8.0] =&gt; scaling factor for heterotrophic pools after spinup (`unitless` @ `all` timescales)
    
  - `ηA`: 1.0 ∈ [0.25, 4.0] =&gt; scaling factor for vegetation pools after spinup (`unitless` @ `all` timescales)
    
  - `c_remain`: 50.0 ∈ [0.1, 100.0] =&gt; remaining carbon after disturbance (units: `gC/m2` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.c_flow_A_array`: an array indicating the flow direction and connections across different pools, with elements larger than 0 indicating flow from column pool to row pool
    
  - `constants.c_flow_order`: order of pooling while calculating the carbon flow
    
  - `constants.c_taker`: index of the source carbon pool for a given flow
    
  - `constants.c_giver`: index of the source carbon pool for a given flow
    
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.c_eco_τ`: number of years needed for carbon turnover per carbon pool
    
  - `diagnostics.c_eco_k_base`: base carbon decomposition rate of the carbon pools
    
  - `diagnostics.zero_c_τ_pf`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :zero_c_τ_pf)` for information on how to add the variable to the catalog.
    
  - `models.c_model`: a base carbon cycle model to loop through the pools and fill the main or component pools needed for using static arrays. A mandatory field for every carbon model realization
    
  

`precompute`:
- **Inputs**
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.c_eco_k_base`: base carbon decomposition rate of the carbon pools
    
  - `diagnostics.c_eco_τ`: number of years needed for carbon turnover per carbon pool
    
  - `diagnostics.zero_c_τ_pf`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :zero_c_τ_pf)` for information on how to add the variable to the catalog.
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  - `states.plant_form`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :plant_form)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.c_eco_τ`: number of years needed for carbon turnover per carbon pool
    
  - `diagnostics.c_eco_k_base`: base carbon decomposition rate of the carbon pools
    
  - `diagnostics.ηA`: scalar of autotrophic carbon pool for steady state guess
    
  - `diagnostics.ηH`: scalar of heterotrophic carbon pool for steady state guess
    
  - `states.c_remain`: amount of carbon to keep in the ecosystem vegetation pools in case of disturbances
    
  

`compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cCycleBase_GSI_PlantForm.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; &amp; S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite &amp; surface data.  Global Biogeochemical Cycles. 7: 811-841.
  

_Versions_
- 1.0 on 28.02.2020 [skoirala | @dr-ko]  
  

_Created by_
- ncarvalhais
  

</details>


== cCycleBase_GSI_PlantForm_LargeKReserve
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycleBase_GSI_PlantForm_LargeKReserve' href='#Sindbad.Models.cCycleBase_GSI_PlantForm_LargeKReserve'><span class="jlbinding">Sindbad.Models.cCycleBase_GSI_PlantForm_LargeKReserve</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



same as cCycleBase_GSI_PlantForm but with a larger turnover of reserve so that it respires and flows

**Parameters**
- **Fields**
  - `c_τ_Root_scalar`: 1.0 ∈ [0.25, 4] =&gt; scalar for turnover rate of root carbon pool (units: `-` @ `all` timescales)
    
  - `c_τ_Wood_scalar`: 1.0 ∈ [0.25, 4] =&gt; scalar for turnover rate of wood carbon pool (units: `-` @ `all` timescales)
    
  - `c_τ_Leaf_scalar`: 1.0 ∈ [0.25, 4] =&gt; scalar for turnover rate of leaf carbon pool (units: `-` @ `all` timescales)
    
  - `c_τ_Litter_scalar`: 1.0 ∈ [0.25, 4] =&gt; scalar for turnover rate of litter carbon pool (units: `-` @ `all` timescales)
    
  - `c_τ_Reserve_scalar`: 1.0 ∈ [0.25, 4] =&gt; scalar for Reserve does not respire, but has a small value to avoid numerical error (units: `-` @ `all` timescales)
    
  - `c_τ_Soil_scalar`: 1.0 ∈ [0.25, 4] =&gt; scalar for turnover rate of soil carbon pool (units: `-` @ `all` timescales)
    
  - `c_τ_tree`: [1.0, 0.02, 1.0, 0.001] ∈ [[0.25, 0.005, 0.25, 0.00025], [4.0, 0.08, 4.0, 0.004]] =&gt; turnover of different organs of trees (units: `year-1` @ `year` timescale)
    
  - `c_τ_shrub`: [1.0, 0.2, 1.0, 0.001] ∈ [[0.25, 0.05, 0.25, 0.00025], [4.0, 0.8, 4.0, 0.004]] =&gt; turnover of different organs of shrubs (units: `year-1` @ `year` timescale)
    
  - `c_τ_herb`: [1.3333333333333333, 1.3333333333333333, 1.3333333333333333, 0.0013333333333333333] ∈ [[0.3333333333333333, 0.3333333333333333, 0.3333333333333333, 0.0003333333333333333], [5.333333333333333, 5.333333333333333, 5.333333333333333, 0.005333333333333333]] =&gt; turnover of different organs of herbs (units: `year-1` @ `year` timescale)
    
  - `c_τ_LitFast`: 14.8 ∈ [0.5, 148.0] =&gt; turnover rate of fast litter (leaf litter) carbon pool (units: `year-1` @ `year` timescale)
    
  - `c_τ_LitSlow`: 3.9 ∈ [0.39, 39.0] =&gt; turnover rate of slow litter carbon (wood litter) pool (units: `year-1` @ `year` timescale)
    
  - `c_τ_SoilSlow`: 0.2 ∈ [0.02, 2.0] =&gt; turnover rate of slow soil carbon pool (units: `year-1` @ `year` timescale)
    
  - `c_τ_SoilOld`: 0.0045 ∈ [0.00045, 0.045] =&gt; turnover rate of old soil carbon pool (units: `year-1` @ `year` timescale)
    
  - `c_flow_A_array`: [-1.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0; 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 -1.0 1.0 0.0 0.0 0.0 0.0; 1.0 0.0 1.0 -1.0 0.0 0.0 0.0 0.0; 1.0 0.0 1.0 0.0 -1.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0 0.0 -1.0 0.0 0.0; 0.0 0.0 0.0 0.0 1.0 1.0 -1.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 1.0 -1.0] ∈ [-Inf, Inf] =&gt; Transfer matrix for carbon at ecosystem level (`unitless` @ `all` timescales)
    
  - `p_C_to_N_cVeg`: [25.0, 260.0, 260.0, 10.0] ∈ [-Inf, Inf] =&gt; carbon to nitrogen ratio in vegetation pools (units: `gC/gN` @ `all` timescales)
    
  - `ηH`: 1.0 ∈ [0.125, 8.0] =&gt; scaling factor for heterotrophic pools after spinup (`unitless` @ `all` timescales)
    
  - `ηA`: 1.0 ∈ [0.25, 4.0] =&gt; scaling factor for vegetation pools after spinup (`unitless` @ `all` timescales)
    
  - `c_remain`: 50.0 ∈ [0.1, 100.0] =&gt; remaining carbon after disturbance (units: `gC/m2` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.c_flow_A_array`: an array indicating the flow direction and connections across different pools, with elements larger than 0 indicating flow from column pool to row pool
    
  - `constants.c_flow_order`: order of pooling while calculating the carbon flow
    
  - `constants.c_taker`: index of the source carbon pool for a given flow
    
  - `constants.c_giver`: index of the source carbon pool for a given flow
    
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.c_eco_τ`: number of years needed for carbon turnover per carbon pool
    
  - `diagnostics.c_eco_k_base`: base carbon decomposition rate of the carbon pools
    
  - `diagnostics.zero_c_τ_pf`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :zero_c_τ_pf)` for information on how to add the variable to the catalog.
    
  - `models.c_model`: a base carbon cycle model to loop through the pools and fill the main or component pools needed for using static arrays. A mandatory field for every carbon model realization
    
  

`precompute`:
- **Inputs**
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.c_eco_k_base`: base carbon decomposition rate of the carbon pools
    
  - `diagnostics.c_eco_τ`: number of years needed for carbon turnover per carbon pool
    
  - `diagnostics.zero_c_τ_pf`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :zero_c_τ_pf)` for information on how to add the variable to the catalog.
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  - `states.plant_form`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :plant_form)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.c_eco_τ`: number of years needed for carbon turnover per carbon pool
    
  - `diagnostics.c_eco_k_base`: base carbon decomposition rate of the carbon pools
    
  - `diagnostics.ηA`: scalar of autotrophic carbon pool for steady state guess
    
  - `diagnostics.ηH`: scalar of heterotrophic carbon pool for steady state guess
    
  - `states.c_remain`: amount of carbon to keep in the ecosystem vegetation pools in case of disturbances
    
  

`compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cCycleBase_GSI_PlantForm_LargeKReserve.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; &amp; S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite &amp; surface data.  Global Biogeochemical Cycles. 7: 811-841.
  

_Versions_
- 1.0 on 28.02.2020 [skoirala | @dr-ko]  
  

_Created by_
- skoirala based on cCycleBase_GSI_PlantForm.jl from ncarvalhais
  

</details>


== cCycleBase_simple
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycleBase_simple' href='#Sindbad.Models.cCycleBase_simple'><span class="jlbinding">Sindbad.Models.cCycleBase_simple</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Compute carbon to nitrogen ratio &amp; annual turnover rates

**Parameters**
- **Fields**
  - `annk`: [1.0, 0.03, 0.03, 1.0, 14.8, 3.9, 18.5, 4.8, 0.2424, 0.2424, 6.0, 7.3, 0.2, 0.0045] ∈ [[0.05, 0.002, 0.002, 0.05, 1.48, 0.39, 1.85, 0.48, 0.02424, 0.02424, 0.6, 0.73, 0.02, 0.0045], [3.3, 0.5, 0.5, 3.3, 148.0, 39.0, 185.0, 48.0, 2.424, 2.424, 60.0, 73.0, 2.0, 0.045]] =&gt; turnover rate of ecosystem carbon pools (units: `year-1` @ `all` timescales)
    
  - `c_flow_A_array`: [-1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.54 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.46 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.54 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.46 0.0 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 -1.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.4 0.15 0.0 0.0 0.24 0.0 -1.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.45 0.17 0.0 0.24 0.0 -1.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.43 0.0 0.43 0.28 0.28 0.4 0.43 -1.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.005 0.0026 -1.0] ∈ [-Inf, Inf] =&gt; Transfer matrix for carbon at ecosystem level (`unitless` @ `all` timescales)
    
  - `p_C_to_N_cVeg`: [25.0, 260.0, 260.0, 25.0] ∈ [-Inf, Inf] =&gt; carbon to nitrogen ratio in vegetation pools (units: `gC/gN` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.c_flow_A_array`: an array indicating the flow direction and connections across different pools, with elements larger than 0 indicating flow from column pool to row pool
    
  

`compute`:
- **Inputs**
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.C_to_N_cVeg`: carbon to nitrogen ratio in the vegetation pools
    
  - `diagnostics.c_eco_k_base`: base carbon decomposition rate of the carbon pools
    
  - `diagnostics.c_flow_A_array`: an array indicating the flow direction and connections across different pools, with elements larger than 0 indicating flow from column pool to row pool
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cCycleBase_simple.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; &amp; S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite &amp; surface data.  Global Biogeochemical Cycles. 7: 811-841.
  

_Versions_
- 1.0.0 on 28.02.2020.0 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


:::


---


### cCycleConsistency {#cCycleConsistency}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycleConsistency' href='#Sindbad.Models.cCycleConsistency'><span class="jlbinding">Sindbad.Models.cCycleConsistency</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Consistency checks on the c allocation and transfers between pools
```



---


**Approaches**
- `cCycleConsistency_simple`: check consistency in cCycle vector: c_allocation; cFlow
  

</details>


:::details cCycleConsistency approaches

:::tabs

== cCycleConsistency_simple
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycleConsistency_simple' href='#Sindbad.Models.cCycleConsistency_simple'><span class="jlbinding">Sindbad.Models.cCycleConsistency_simple</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



check consistency in cCycle vector: c_allocation; cFlow

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `diagnostics.c_flow_A_array`: an array indicating the flow direction and connections across different pools, with elements larger than 0 indicating flow from column pool to row pool
    
  - `constants.c_giver`: index of the source carbon pool for a given flow
    
  
- **Outputs**
  - `cCycleConsistency.giver_lower_unique`: unique indices of carbon pools whose flow is &gt;0 below the diagonal in carbon flow matrix
    
  - `cCycleConsistency.giver_lower_indices`: indices of carbon pools whose flow is &gt;0 below the diagonal in carbon flow matrix
    
  - `cCycleConsistency.giver_upper_unique`: unique indices of carbon pools whose flow is &gt;0 above the diagonal in carbon flow matrix
    
  - `cCycleConsistency.giver_upper_indices`: indices of carbon pools whose flow is &gt;0 above the diagonal in carbon flow matrix
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cCycleConsistency_simple.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 12.05.2022: skoirala: julia implementation  
  

_Created by_
- sbesnard
  

</details>


:::


---


### cCycleDisturbance {#cCycleDisturbance}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycleDisturbance' href='#Sindbad.Models.cCycleDisturbance'><span class="jlbinding">Sindbad.Models.cCycleDisturbance</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Disturb the carbon cycle pools
```



---


**Approaches**
- `cCycleDisturbance_WROASTED`: move all vegetation carbon pools except reserve to respective flow target when there is disturbance
  
- `cCycleDisturbance_cFlow`: move all vegetation carbon pools except reserve to respective flow target when there is disturbance
  

</details>


:::details cCycleDisturbance approaches

:::tabs

== cCycleDisturbance_WROASTED
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycleDisturbance_WROASTED' href='#Sindbad.Models.cCycleDisturbance_WROASTED'><span class="jlbinding">Sindbad.Models.cCycleDisturbance_WROASTED</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



move all vegetation carbon pools except reserve to respective flow target when there is disturbance

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.c_giver`: index of the source carbon pool for a given flow
    
  - `constants.c_taker`: index of the source carbon pool for a given flow
    
  - `pools.cVeg`: carbon content of cVeg pool(s)
    
  
- **Outputs**
  - `cCycleDisturbance.zix_veg_all`: zix_veg_all_cCycleDisturbance
    
  - `cCycleDisturbance.c_lose_to_zix_vec`: c_lose_to_zix_vec_cCycleDisturbance
    
  

`compute`:
- **Inputs**
  - `forcing.f_dist_intensity`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_dist_intensity)` for information on how to add the variable to the catalog.
    
  - `cCycleDisturbance.zix_veg_all`: zix_veg_all_cCycleDisturbance
    
  - `cCycleDisturbance.c_lose_to_zix_vec`: c_lose_to_zix_vec_cCycleDisturbance
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `constants.c_giver`: index of the source carbon pool for a given flow
    
  - `constants.c_taker`: index of the source carbon pool for a given flow
    
  - `states.c_remain`: amount of carbon to keep in the ecosystem vegetation pools in case of disturbances
    
  - `models.c_model`: a base carbon cycle model to loop through the pools and fill the main or component pools needed for using static arrays. A mandatory field for every carbon model realization
    
  
- **Outputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cCycleDisturbance_WROASTED.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  &amp; Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance &amp; inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
  

_Versions_
- 1.0 on 23.04.2021 [skoirala | @dr-ko]
  
- 1.0 on 23.04.2021 [skoirala | @dr-ko]  
  
- 1.1 on 29.11.2021 [skoirala | @dr-ko]: moved the scaling parameters to  ccyclebase_gsi [land.diagnostics.ηA &amp; land.diagnostics.ηH]  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== cCycleDisturbance_cFlow
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cCycleDisturbance_cFlow' href='#Sindbad.Models.cCycleDisturbance_cFlow'><span class="jlbinding">Sindbad.Models.cCycleDisturbance_cFlow</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



move all vegetation carbon pools except reserve to respective flow target when there is disturbance

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.c_giver`: index of the source carbon pool for a given flow
    
  - `constants.c_taker`: index of the source carbon pool for a given flow
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  - `pools.cVeg`: carbon content of cVeg pool(s)
    
  
- **Outputs**
  - `cCycleDisturbance.zix_veg_all`: zix_veg_all_cCycleDisturbance
    
  - `cCycleDisturbance.c_lose_to_zix_vec`: c_lose_to_zix_vec_cCycleDisturbance
    
  

`compute`:
- **Inputs**
  - `forcing.f_dist_intensity`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_dist_intensity)` for information on how to add the variable to the catalog.
    
  - `cCycleDisturbance.zix_veg_all`: zix_veg_all_cCycleDisturbance
    
  - `cCycleDisturbance.c_lose_to_zix_vec`: c_lose_to_zix_vec_cCycleDisturbance
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `constants.c_giver`: index of the source carbon pool for a given flow
    
  - `constants.c_taker`: index of the source carbon pool for a given flow
    
  - `models.c_model`: a base carbon cycle model to loop through the pools and fill the main or component pools needed for using static arrays. A mandatory field for every carbon model realization
    
  - `states.c_remain`: amount of carbon to keep in the ecosystem vegetation pools in case of disturbances
    
  
- **Outputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cCycleDisturbance_cFlow.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  &amp; Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance &amp; inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
  

_Versions_
- 1.0 on 23.04.2021 [skoirala | @dr-ko]
  
- 1.0 on 23.04.2021 [skoirala | @dr-ko]  
  
- 1.1 on 29.11.2021 [skoirala | @dr-ko]: moved the scaling parameters to  ccyclebase_gsi [land.diagnostics.ηA &amp; land.diagnostics.ηH]  
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### cFlow {#cFlow}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cFlow' href='#Sindbad.Models.cFlow'><span class="jlbinding">Sindbad.Models.cFlow</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Actual transfers of c between pools (of diagonal components)
```



---


**Approaches**
- `cFlow_CASA`: combine all the effects that change the transfers between carbon pools
  
- `cFlow_GSI`: compute the flow rates between the different pools. The flow rates are based on the GSI approach. The flow rates are computed based on the stressors (soil moisture, temperature, and light) and the slope of the stressors. The flow rates are computed for the following pools: leaf, root, reserve, and litter. The flow rates are computed for the following processes: leaf to reserve, root to reserve, reserve to leaf, reserve to root, shedding from leaf, and shedding from root.
  
- `cFlow_none`: set transfer between pools to 0 [i.e. nothing is transfered] set c_giver &amp; c_taker matrices to [] get the transfer matrix transfers
  
- `cFlow_simple`: combine all the effects that change the transfers between carbon pools
  

</details>


:::details cFlow approaches

:::tabs

== cFlow_CASA
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cFlow_CASA' href='#Sindbad.Models.cFlow_CASA'><span class="jlbinding">Sindbad.Models.cFlow_CASA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



combine all the effects that change the transfers between carbon pools

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `cFlowVegProperties.p_E_vec`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlowVegProperties, :p_E_vec)` for information on how to add the variable to the catalog.
    
  - `cFlowVegProperties.p_F_vec`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlowVegProperties, :p_F_vec)` for information on how to add the variable to the catalog.
    
  - `diagnostics.p_E_vec`: carbon flow efficiency
    
  - `diagnostics.p_F_vec`: carbon flow efficiency fraction
    
  - `diagnostics.c_flow_E_array`: an array containing the efficiency of each flow in the c_flow_A_array
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `constants.c_flow_order`: order of pooling while calculating the carbon flow
    
  - `cFlow.c_flow_A_vec`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlow, :c_flow_A_vec)` for information on how to add the variable to the catalog.
    
  - `cFlow.p_E_vec`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlow, :p_E_vec)` for information on how to add the variable to the catalog.
    
  - `cFlow.p_F_vec`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlow, :p_F_vec)` for information on how to add the variable to the catalog.
    
  - `cFlow.p_giver`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlow, :p_giver)` for information on how to add the variable to the catalog.
    
  - `cFlow.p_taker`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlow, :p_taker)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cFlow_CASA.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  &amp; Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance &amp; inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
  
- Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., &amp; Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data &amp; ecosystem  modeling 1982–1998. Global &amp; Planetary Change, 39[3-4], 201-213.
  
- Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  &amp; Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite &amp; surface data. Global Biogeochemical Cycles, 7[4], 811-841.
  

_Versions_
- 1.0 on 13.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


== cFlow_GSI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cFlow_GSI' href='#Sindbad.Models.cFlow_GSI'><span class="jlbinding">Sindbad.Models.cFlow_GSI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



compute the flow rates between the different pools. The flow rates are based on the GSI approach. The flow rates are computed based on the stressors (soil moisture, temperature, and light) and the slope of the stressors. The flow rates are computed for the following pools: leaf, root, reserve, and litter. The flow rates are computed for the following processes: leaf to reserve, root to reserve, reserve to leaf, reserve to root, shedding from leaf, and shedding from root.

**Parameters**
- **Fields**
  - `slope_leaf_root_to_reserve`: 0.14 ∈ [0.033, 0.33] =&gt; Leaf-Root to Reserve (units: `fraction` @ `day` timescale)
    
  - `slope_reserve_to_leaf_root`: 0.14 ∈ [0.033, 0.33] =&gt; Reserve to Leaf-Root (units: `fraction` @ `day` timescale)
    
  - `k_shedding`: 0.14 ∈ [0.033, 0.33] =&gt; rate of shedding (units: `fraction` @ `day` timescale)
    
  - `f_τ`: 0.03 ∈ [0.01, 0.1] =&gt; contribution factor for current stressor (units: `fraction` @ `day` timescale)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `constants.c_giver`: index of the source carbon pool for a given flow
    
  - `constants.c_taker`: index of the source carbon pool for a given flow
    
  - `properties.∑w_sat`: total amount of water in the soil at saturation
    
  
- **Outputs**
  - `cFlow.c_flow_A_vec_ind`: indices of flow from giver to taker for carbon flow vector
    
  - `diagnostics.eco_stressor_prev`: ecosystem stress on carbon flow in the previous time step
    
  - `diagnostics.slope_eco_stressor_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :slope_eco_stressor_prev)` for information on how to add the variable to the catalog.
    
  - `diagnostics.c_flow_A_vec`: fraction of the carbon loss fron a (giver) pool that flows to a (taker) pool
    
  

`compute`:
- **Inputs**
  - `cFlow.c_flow_A_vec_ind`: indices of flow from giver to taker for carbon flow vector
    
  - `diagnostics.c_allocation_f_soilW`: effect of soil moisture on carbon allocation. 1: no stress, 0: complete stress
    
  - `diagnostics.c_allocation_f_soilT`: effect of soil temperature on carbon allocation. 1: no stress, 0: complete stress
    
  - `diagnostics.c_allocation_f_cloud`: effect of cloud on carbon allocation. 1: no stress, 0: complete stress
    
  - `diagnostics.eco_stressor_prev`: ecosystem stress on carbon flow in the previous time step
    
  - `diagnostics.slope_eco_stressor_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :slope_eco_stressor_prev)` for information on how to add the variable to the catalog.
    
  - `diagnostics.c_eco_k`: decomposition rate of carbon per pool
    
  - `diagnostics.c_flow_A_vec`: fraction of the carbon loss fron a (giver) pool that flows to a (taker) pool
    
  
- **Outputs**
  - `diagnostics.leaf_to_reserve`: loss rate of carbon flow from leaf to reserve
    
  - `diagnostics.leaf_to_reserve_frac`: fraction of carbon loss from leaf that flows to leaf
    
  - `diagnostics.root_to_reserve`: loss rate of carbon flow from root to reserve
    
  - `diagnostics.root_to_reserve_frac`: fraction of carbon loss from root that flows to reserve
    
  - `diagnostics.reserve_to_leaf`: loss rate of carbon flow from reserve to root
    
  - `diagnostics.reserve_to_leaf_frac`: fraction of carbon loss from reserve that flows to leaf
    
  - `diagnostics.reserve_to_root`: loss rate of carbon flow from reserve to root
    
  - `diagnostics.reserve_to_root_frac`: fraction of carbon loss from reserve that flows to root
    
  - `diagnostics.eco_stressor`: ecosystem stress on carbon flow
    
  - `diagnostics.k_shedding_leaf`: loss rate of carbon flow from leaf to litter
    
  - `diagnostics.k_shedding_leaf_frac`: fraction of carbon loss from leaf that flows to litter pool
    
  - `diagnostics.k_shedding_root`: loss rate of carbon flow from root to litter
    
  - `diagnostics.k_shedding_root_frac`: fraction of carbon loss from root that flows to litter pool
    
  - `diagnostics.slope_eco_stressor`: potential rate of change in ecosystem stress on carbon flow
    
  - `diagnostics.eco_stressor_prev`: ecosystem stress on carbon flow in the previous time step
    
  - `diagnostics.slope_eco_stressor_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :slope_eco_stressor_prev)` for information on how to add the variable to the catalog.
    
  - `diagnostics.c_eco_k`: decomposition rate of carbon per pool
    
  - `diagnostics.c_flow_A_vec`: fraction of the carbon loss fron a (giver) pool that flows to a (taker) pool
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cFlow_GSI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 13.01.2020 [sbesnard]
  
- 1.1 on 05.02.2021 [skoirala | @dr-ko]: changes with stressors &amp; smoothing as well as handling the activation of leaf/root to reserve | reserve to leaf/root switches. Adjustment of total flow rates [cTau] of relevant pools  
  
- 1.1 on 05.02.2021 [skoirala | @dr-ko]: move code from dyna. Add table etc.  
  

_Created by_
- ncarvalhais, sbesnard, skoirala
  

_Notes_

</details>


== cFlow_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cFlow_none' href='#Sindbad.Models.cFlow_none'><span class="jlbinding">Sindbad.Models.cFlow_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



set transfer between pools to 0 [i.e. nothing is transfered] set c_giver &amp; c_taker matrices to [] get the transfer matrix transfers

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_flow_A_vec`: fraction of the carbon loss fron a (giver) pool that flows to a (taker) pool
    
  - `diagnostics.p_E_vec`: carbon flow efficiency
    
  - `diagnostics.p_F_vec`: carbon flow efficiency fraction
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cFlow_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


== cFlow_simple
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cFlow_simple' href='#Sindbad.Models.cFlow_simple'><span class="jlbinding">Sindbad.Models.cFlow_simple</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



combine all the effects that change the transfers between carbon pools

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `diagnostics.c_flow_A_array`: an array indicating the flow direction and connections across different pools, with elements larger than 0 indicating flow from column pool to row pool
    
  
- **Outputs**
  - `constants.c_flow_order`: order of pooling while calculating the carbon flow
    
  - `cFlow.c_flow_A_vec`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlow, :c_flow_A_vec)` for information on how to add the variable to the catalog.
    
  - `cFlow.p_giver`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlow, :p_giver)` for information on how to add the variable to the catalog.
    
  - `cFlow.p_taker`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlow, :p_taker)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cFlow_simple.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 13.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


:::


---


### cFlowSoilProperties {#cFlowSoilProperties}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cFlowSoilProperties' href='#Sindbad.Models.cFlowSoilProperties'><span class="jlbinding">Sindbad.Models.cFlowSoilProperties</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Effect of soil properties on the c transfers between pools
```



---


**Approaches**
- `cFlowSoilProperties_CASA`: effects of soil that change the transfers between carbon pools
  
- `cFlowSoilProperties_none`: set transfer between pools to 0 [i.e. nothing is transfered]
  

</details>


:::details cFlowSoilProperties approaches

:::tabs

== cFlowSoilProperties_CASA
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cFlowSoilProperties_CASA' href='#Sindbad.Models.cFlowSoilProperties_CASA'><span class="jlbinding">Sindbad.Models.cFlowSoilProperties_CASA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



effects of soil that change the transfers between carbon pools

**Parameters**
- **Fields**
  - `effA`: 0.85 ∈ [-Inf, Inf] =&gt;  (`unitless` @ `all` timescales)
    
  - `effB`: 0.68 ∈ [-Inf, Inf] =&gt;  (`unitless` @ `all` timescales)
    
  - `effclay_cMicSoil_A`: 0.003 ∈ [-Inf, Inf] =&gt;  (`unitless` @ `all` timescales)
    
  - `effclay_cMicSoil_B`: 0.032 ∈ [-Inf, Inf] =&gt;  (`unitless` @ `all` timescales)
    
  - `effclay_cSoilSlow_A`: 0.003 ∈ [-Inf, Inf] =&gt;  (`unitless` @ `all` timescales)
    
  - `effclay_cSoilSlow_B`: 0.009 ∈ [-Inf, Inf] =&gt;  (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.p_E_vec`: carbon flow efficiency
    
  

`compute`:
- **Inputs**
  - `diagnostics.p_E_vec`: carbon flow efficiency
    
  - `properties.st_clay`: fraction of clay content in the soil
    
  - `properties.st_silt`: fraction of silt content in the soil per layer
    
  
- **Outputs**
  - `diagnostics.p_E_vec`: carbon flow efficiency
    
  - `diagnostics.p_F_vec`: carbon flow efficiency fraction
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cFlowSoilProperties_CASA.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  &amp; Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance &amp; inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
  
- Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., &amp; Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data &amp; ecosystem  modeling 1982–1998. Global &amp; Planetary Change, 39[3-4], 201-213.
  
- Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  &amp; Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite &amp; surface data. Global Biogeochemical Cycles, 7[4], 811-841.
  

_Versions_
- 1.0 on 13.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


== cFlowSoilProperties_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cFlowSoilProperties_none' href='#Sindbad.Models.cFlowSoilProperties_none'><span class="jlbinding">Sindbad.Models.cFlowSoilProperties_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



set transfer between pools to 0 [i.e. nothing is transfered]

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.c_taker`: index of the source carbon pool for a given flow
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.p_E_vec`: carbon flow efficiency
    
  - `diagnostics.p_F_vec`: carbon flow efficiency fraction
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cFlowSoilProperties_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cFlowVegProperties {#cFlowVegProperties}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cFlowVegProperties' href='#Sindbad.Models.cFlowVegProperties'><span class="jlbinding">Sindbad.Models.cFlowVegProperties</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Effect of vegetation properties on the c transfers between pools
```



---


**Approaches**
- `cFlowVegProperties_CASA`: effects of vegetation that change the transfers between carbon pools
  
- `cFlowVegProperties_none`: set transfer between pools to 0 [i.e. nothing is transfered]
  

</details>


:::details cFlowVegProperties approaches

:::tabs

== cFlowVegProperties_CASA
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cFlowVegProperties_CASA' href='#Sindbad.Models.cFlowVegProperties_CASA'><span class="jlbinding">Sindbad.Models.cFlowVegProperties_CASA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



effects of vegetation that change the transfers between carbon pools

**Parameters**
- **Fields**
  - `frac_lignin_wood`: 0.4 ∈ [-Inf, Inf] =&gt; fraction of wood that is lignin (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `constants.c_taker`: index of the source carbon pool for a given flow
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `cFlowVegProperties.p_F_vec`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlowVegProperties, :p_F_vec)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `cFlowVegProperties.p_F_vec`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlowVegProperties, :p_F_vec)` for information on how to add the variable to the catalog.
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `cFlowVegProperties.p_E_vec`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlowVegProperties, :p_E_vec)` for information on how to add the variable to the catalog.
    
  - `cFlowVegProperties.p_F_vec`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlowVegProperties, :p_F_vec)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cFlowVegProperties_CASA.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  &amp; Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance &amp; inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
  
- Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., &amp; Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data &amp; ecosystem  modeling 1982–1998. Global &amp; Planetary Change, 39[3-4], 201-213.
  
- Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  &amp; Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite &amp; surface data. Global Biogeochemical Cycles, 7[4], 811-841.
  

_Versions_
- 1.0 on 13.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


== cFlowVegProperties_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cFlowVegProperties_none' href='#Sindbad.Models.cFlowVegProperties_none'><span class="jlbinding">Sindbad.Models.cFlowVegProperties_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



set transfer between pools to 0 [i.e. nothing is transfered]

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `constants.c_taker`: index of the source carbon pool for a given flow
    
  
- **Outputs**
  - `cFlowVegProperties.p_E_vec`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlowVegProperties, :p_E_vec)` for information on how to add the variable to the catalog.
    
  - `cFlowVegProperties.p_F_vec`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:cFlowVegProperties, :p_F_vec)` for information on how to add the variable to the catalog.
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cFlowVegProperties_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cTau {#cTau}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTau' href='#Sindbad.Models.cTau'><span class="jlbinding">Sindbad.Models.cTau</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Combine effects of different factors on decomposition rates
```



---


**Approaches**
- `cTau_mult`: multiply all effects that change the turnover rates [k]
  
- `cTau_none`: set the actual τ to ones
  

</details>


:::details cTau approaches

:::tabs

== cTau_mult
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTau_mult' href='#Sindbad.Models.cTau_mult'><span class="jlbinding">Sindbad.Models.cTau_mult</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



multiply all effects that change the turnover rates [k]

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_eco_k`: decomposition rate of carbon per pool
    
  

`compute`:
- **Inputs**
  - `diagnostics.c_eco_k_f_veg_props`: effect of veg_props on carbon decomposition rate. 1: no stress, 0: complete stress
    
  - `diagnostics.c_eco_k_f_soilW`: effect of soil moisture on carbon decomposition rate. 1: no stress, 0: complete stress
    
  - `diagnostics.c_eco_k_f_soilT`: effect of soil temperature on heterotrophic respiration respiration. 0: no decomposition, &gt;1 increase in decomposition
    
  - `diagnostics.c_eco_k_f_soil_props`: effect of soil_props on carbon decomposition rate. 1: no stress, 0: complete stress
    
  - `diagnostics.c_eco_k_f_LAI`: effect of LAI on carbon decomposition rate. 1: no stress, 0: complete stress
    
  - `diagnostics.c_eco_k_base`: base carbon decomposition rate of the carbon pools
    
  - `diagnostics.c_eco_k`: decomposition rate of carbon per pool
    
  
- **Outputs**
  - `diagnostics.c_eco_k`: decomposition rate of carbon per pool
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cTau_mult.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

_Notes:_

</details>


== cTau_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTau_none' href='#Sindbad.Models.cTau_none'><span class="jlbinding">Sindbad.Models.cTau_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



set the actual τ to ones

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_eco_k`: decomposition rate of carbon per pool
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cTau_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cTauLAI {#cTauLAI}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauLAI' href='#Sindbad.Models.cTauLAI'><span class="jlbinding">Sindbad.Models.cTauLAI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Calculate litterfall scalars (that affect the changes in the vegetation k)
```



---


**Approaches**
- `cTauLAI_CASA`: calc LAI stressor on τ. Compute the seasonal cycle of litter fall &amp; root litterfall based on LAI variations. Necessarily in precomputation mode
  
- `cTauLAI_none`: set values to ones
  

</details>


:::details cTauLAI approaches

:::tabs

== cTauLAI_CASA
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauLAI_CASA' href='#Sindbad.Models.cTauLAI_CASA'><span class="jlbinding">Sindbad.Models.cTauLAI_CASA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calc LAI stressor on τ. Compute the seasonal cycle of litter fall &amp; root litterfall based on LAI variations. Necessarily in precomputation mode

**Parameters**
- **Fields**
  - `max_min_LAI`: 12.0 ∈ [11.0, 13.0] =&gt; maximum value for the minimum LAI for litter scalars (units: `m2/m2` @ `all` timescales)
    
  - `k_root_LAI`: 0.3 ∈ [0.0, 1.0] =&gt; constant fraction of root litter inputs (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_eco_k_f_LAI`: effect of LAI on carbon decomposition rate. 1: no stress, 0: complete stress
    
  

`compute`:
- **Inputs**
  - `diagnostics.c_eco_k_f_LAI`: effect of LAI on carbon decomposition rate. 1: no stress, 0: complete stress
    
  - `states.LAI`: leaf area index
    
  - `diagnostics.c_eco_τ`: number of years needed for carbon turnover per carbon pool
    
  - `diagnostics.c_eco_k`: decomposition rate of carbon per pool
    
  
- **Outputs**
  - `diagnostics.p_LAI13`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :p_LAI13)` for information on how to add the variable to the catalog.
    
  - `diagnostics.p_cVegLeafZix`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :p_cVegLeafZix)` for information on how to add the variable to the catalog.
    
  - `diagnostics.p_cVegRootZix`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :p_cVegRootZix)` for information on how to add the variable to the catalog.
    
  - `diagnostics.c_eco_k_f_LAI`: effect of LAI on carbon decomposition rate. 1: no stress, 0: complete stress
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cTauLAI_CASA.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  &amp; Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance &amp; inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
  
- Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., &amp; Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data &amp; ecosystem  modeling 1982–1998. Global &amp; Planetary Change, 39[3-4], 201-213.
  
- Potter; C. S.; J. T. Randerson; C. B. Field; P. A. Matson; P. M.  Vitousek; H. A. Mooney; &amp; S. A. Klooster. 1993. Terrestrial ecosystem  production: A process model based on global satellite &amp; surface data.  Global Biogeochemical Cycles. 7: 811-841.
  
- Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  &amp; Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite &amp; surface data. Global Biogeochemical Cycles, 7[4], 811-841.
  

_Versions_
- 1.0 on 12.01.2020 [sbesnard]
  
- 1.0 on 12.01.2020 [sbesnard]  
  
- 1.1 on 05.11.2020 [skoirala | @dr-ko]: speedup  
  

_Created by_
- ncarvalhais
  

</details>


== cTauLAI_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauLAI_none' href='#Sindbad.Models.cTauLAI_none'><span class="jlbinding">Sindbad.Models.cTauLAI_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



set values to ones

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_eco_k_f_LAI`: effect of LAI on carbon decomposition rate. 1: no stress, 0: complete stress
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cTauLAI_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cTauSoilProperties {#cTauSoilProperties}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauSoilProperties' href='#Sindbad.Models.cTauSoilProperties'><span class="jlbinding">Sindbad.Models.cTauSoilProperties</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Effect of soil texture on soil decomposition rates
```



---


**Approaches**
- `cTauSoilProperties_CASA`: Compute soil texture effects on turnover rates [k] of cMicSoil
  
- `cTauSoilProperties_none`: Set soil texture effects to ones (ineficient, should be pix zix_mic)
  

</details>


:::details cTauSoilProperties approaches

:::tabs

== cTauSoilProperties_CASA
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauSoilProperties_CASA' href='#Sindbad.Models.cTauSoilProperties_CASA'><span class="jlbinding">Sindbad.Models.cTauSoilProperties_CASA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Compute soil texture effects on turnover rates [k] of cMicSoil

**Parameters**
- **Fields**
  - `TEXTEFFA`: 0.75 ∈ [0.0, 1.0] =&gt; effect of soil texture on turnove times (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_eco_k_f_soil_props`: effect of soil_props on carbon decomposition rate. 1: no stress, 0: complete stress
    
  

`compute`:
- **Inputs**
  - `diagnostics.c_eco_k_f_soil_props`: effect of soil_props on carbon decomposition rate. 1: no stress, 0: complete stress
    
  - `properties.st_clay`: fraction of clay content in the soil
    
  - `properties.st_silt`: fraction of silt content in the soil per layer
    
  
- **Outputs**
  - `diagnostics.c_eco_k_f_soil_props`: effect of soil_props on carbon decomposition rate. 1: no stress, 0: complete stress
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cTauSoilProperties_CASA.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  &amp; Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance &amp; inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
  
- Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., &amp; Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data &amp; ecosystem  modeling 1982–1998. Global &amp; Planetary Change, 39[3-4], 201-213.
  
- Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  &amp; Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite &amp; surface data. Global Biogeochemical Cycles, 7[4], 811-841.
  

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


== cTauSoilProperties_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauSoilProperties_none' href='#Sindbad.Models.cTauSoilProperties_none'><span class="jlbinding">Sindbad.Models.cTauSoilProperties_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Set soil texture effects to ones (ineficient, should be pix zix_mic)

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_eco_k_f_soil_props`: effect of soil_props on carbon decomposition rate. 1: no stress, 0: complete stress
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cTauSoilProperties_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cTauSoilT {#cTauSoilT}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauSoilT' href='#Sindbad.Models.cTauSoilT'><span class="jlbinding">Sindbad.Models.cTauSoilT</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Effect of soil temperature on decomposition rates
```



---


**Approaches**
- `cTauSoilT_Q10`: Compute effect of temperature on psoil carbon fluxes
  
- `cTauSoilT_none`: set the outputs to ones
  

</details>


:::details cTauSoilT approaches

:::tabs

== cTauSoilT_Q10
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauSoilT_Q10' href='#Sindbad.Models.cTauSoilT_Q10'><span class="jlbinding">Sindbad.Models.cTauSoilT_Q10</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Compute effect of temperature on psoil carbon fluxes

**Parameters**
- **Fields**
  - `Q10`: 1.4 ∈ [1.05, 3.0] =&gt;  (`unitless` @ `all` timescales)
    
  - `ref_airT`: 30.0 ∈ [0.01, 40.0] =&gt;  (units: `°C` @ `all` timescales)
    
  - `Q10_base`: 10.0 ∈ [-Inf, Inf] =&gt; base temperature difference (units: `°C` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_airT`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.c_eco_k_f_soilT`: effect of soil temperature on heterotrophic respiration respiration. 0: no decomposition, &gt;1 increase in decomposition
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cTauSoilT_Q10.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

_Notes_

</details>


== cTauSoilT_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauSoilT_none' href='#Sindbad.Models.cTauSoilT_none'><span class="jlbinding">Sindbad.Models.cTauSoilT_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



set the outputs to ones

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_eco_k_f_soilT`: effect of soil temperature on heterotrophic respiration respiration. 0: no decomposition, &gt;1 increase in decomposition
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cTauSoilT_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cTauSoilW {#cTauSoilW}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauSoilW' href='#Sindbad.Models.cTauSoilW'><span class="jlbinding">Sindbad.Models.cTauSoilW</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Effect of soil moisture on decomposition rates
```



---


**Approaches**
- `cTauSoilW_CASA`: Compute effect of soil moisture on soil decomposition as modelled in CASA [BGME - below grounf moisture effect]. The below ground moisture effect; taken directly from the century model; uses soil moisture from the previous month to determine a scalar that is then used to determine the moisture effect on below ground carbon fluxes. BGME is dependent on PET; Rainfall. This approach is designed to work for Rainfall &amp; PET values at the monthly time step &amp; it is necessary to scale it to meet that criterion.
  
- `cTauSoilW_GSI`: calculate the moisture stress for cTau based on temperature stressor function of CASA &amp; Potter
  
- `cTauSoilW_none`: set the moisture stress for all carbon pools to ones
  

</details>


:::details cTauSoilW approaches

:::tabs

== cTauSoilW_CASA
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauSoilW_CASA' href='#Sindbad.Models.cTauSoilW_CASA'><span class="jlbinding">Sindbad.Models.cTauSoilW_CASA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Compute effect of soil moisture on soil decomposition as modelled in CASA [BGME - below grounf moisture effect]. The below ground moisture effect; taken directly from the century model; uses soil moisture from the previous month to determine a scalar that is then used to determine the moisture effect on below ground carbon fluxes. BGME is dependent on PET; Rainfall. This approach is designed to work for Rainfall &amp; PET values at the monthly time step &amp; it is necessary to scale it to meet that criterion.

**Parameters**
- **Fields**
  - `Aws`: 1.0 ∈ [0.001, 1000.0] =&gt; curve (expansion/contraction) controlling parameter (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_eco_k_f_soilW`: effect of soil moisture on carbon decomposition rate. 1: no stress, 0: complete stress
    
  

`compute`:
- **Inputs**
  - `diagnostics.c_eco_k_f_soilW`: effect of soil moisture on carbon decomposition rate. 1: no stress, 0: complete stress
    
  - `fluxes.rain`: amount of precipitation in liquid form
    
  - `pools.soilW_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:pools, :soilW_prev)` for information on how to add the variable to the catalog.
    
  - `diagnostics.fsoilW_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :fsoilW_prev)` for information on how to add the variable to the catalog.
    
  - `fluxes.PET`: potential evapotranspiration
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.fsoilW`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :fsoilW)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cTauSoilW_CASA.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  &amp; Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance &amp; inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
  
- Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., &amp; Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data &amp; ecosystem  modeling 1982–1998. Global &amp; Planetary Change, 39[3-4], 201-213.
  
- Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  &amp; Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite &amp; surface data. Global Biogeochemical Cycles, 7[4], 811-841.
  

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

Notesthe BGME is used as a scalar dependent on soil moisture; as the  sum of soil moisture for all layers. This can be partitioned into  different soil layers in the soil &amp; affect independently the  decomposition processes of pools that are at the surface &amp; deeper in  the soils.

</details>


== cTauSoilW_GSI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauSoilW_GSI' href='#Sindbad.Models.cTauSoilW_GSI'><span class="jlbinding">Sindbad.Models.cTauSoilW_GSI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate the moisture stress for cTau based on temperature stressor function of CASA &amp; Potter

**Parameters**
- **Fields**
  - `opt_soilW`: 90.0 ∈ [60.0, 95.0] =&gt; Optimal moisture for decomposition (units: `percent degree of saturation` @ `all` timescales)
    
  - `opt_soilW_A`: 0.2 ∈ [0.1, 0.3] =&gt; slope of increase (units: `per percent` @ `all` timescales)
    
  - `opt_soilW_B`: 0.3 ∈ [0.15, 0.5] =&gt; slope of decrease (units: `per percent` @ `all` timescales)
    
  - `w_exp`: 10.0 ∈ [-Inf, Inf] =&gt; reference for exponent of sensitivity (units: `per percent` @ `all` timescales)
    
  - `frac_to_perc`: 100.0 ∈ [-Inf, Inf] =&gt; unit converter for fraction to percent (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_eco_k_f_soilW`: effect of soil moisture on carbon decomposition rate. 1: no stress, 0: complete stress
    
  

`compute`:
- **Inputs**
  - `diagnostics.c_eco_k_f_soilW`: effect of soil moisture on carbon decomposition rate. 1: no stress, 0: complete stress
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  - `pools.cLit`: carbon content of cLit pool(s)
    
  - `pools.cSoil`: carbon content of cSoil pool(s)
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `diagnostics.c_eco_k_f_soilW`: effect of soil moisture on carbon decomposition rate. 1: no stress, 0: complete stress
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cTauSoilW_GSI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  &amp; Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance &amp; inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
  
- Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., &amp; Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data &amp; ecosystem  modeling 1982–1998. Global &amp; Planetary Change, 39[3-4], 201-213.
  
- Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  &amp; Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite &amp; surface data. Global Biogeochemical Cycles, 7[4], 811-841.
  

_Versions_
- 1.0 on 12.02.2021 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

_Notes_

</details>


== cTauSoilW_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauSoilW_none' href='#Sindbad.Models.cTauSoilW_none'><span class="jlbinding">Sindbad.Models.cTauSoilW_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



set the moisture stress for all carbon pools to ones

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_eco_k_f_soilW`: effect of soil moisture on carbon decomposition rate. 1: no stress, 0: complete stress
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cTauSoilW_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cTauVegProperties {#cTauVegProperties}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauVegProperties' href='#Sindbad.Models.cTauVegProperties'><span class="jlbinding">Sindbad.Models.cTauVegProperties</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Effect of vegetation properties on soil decomposition rates
```



---


**Approaches**
- `cTauVegProperties_CASA`: Compute effect of vegetation type on turnover rates [k]
  
- `cTauVegProperties_none`: set the outputs to ones
  

</details>


:::details cTauVegProperties approaches

:::tabs

== cTauVegProperties_CASA
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauVegProperties_CASA' href='#Sindbad.Models.cTauVegProperties_CASA'><span class="jlbinding">Sindbad.Models.cTauVegProperties_CASA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Compute effect of vegetation type on turnover rates [k]

**Parameters**
- **Fields**
  - `LIGNIN_per_PFT`: [0.2, 0.2, 0.22, 0.25, 0.2, 0.15, 0.1, 0.0, 0.2, 0.15, 0.15, 0.1] ∈ [-Inf, Inf] =&gt; fraction of litter that is lignin (`unitless` @ `all` timescales)
    
  - `NONSOL2SOLLIGNIN`: 2.22 ∈ [-Inf, Inf] =&gt;  (`unitless` @ `all` timescales)
    
  - `MTFA`: 0.85 ∈ [-Inf, Inf] =&gt;  (`unitless` @ `all` timescales)
    
  - `MTFB`: 0.018 ∈ [-Inf, Inf] =&gt;  (`unitless` @ `all` timescales)
    
  - `C2LIGNIN`: 0.65 ∈ [-Inf, Inf] =&gt;  (`unitless` @ `all` timescales)
    
  - `LIGEFFA`: 3.0 ∈ [-Inf, Inf] =&gt;  (`unitless` @ `all` timescales)
    
  - `LITC2N_per_PFT`: [40.0, 50.0, 65.0, 80.0, 50.0, 50.0, 50.0, 0.0, 65.0, 50.0, 50.0, 40.0] ∈ [-Inf, Inf] =&gt; carbon-to-nitrogen ratio in litter (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `diagnostics.c_eco_k_f_veg_props`: effect of veg_props on carbon decomposition rate. 1: no stress, 0: complete stress
    
  

`compute`:
- **Inputs**
  - `properties.PFT`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:properties, :PFT)` for information on how to add the variable to the catalog.
    
  - `diagnostics.c_eco_k_f_veg_props`: effect of veg_props on carbon decomposition rate. 1: no stress, 0: complete stress
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.c_eco_τ`: number of years needed for carbon turnover per carbon pool
    
  - `properties.C2LIGNIN`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:properties, :C2LIGNIN)` for information on how to add the variable to the catalog.
    
  - `properties.LIGEFF`: LIGEFF_properties
    
  - `properties.LIGNIN`: LIGNIN_properties
    
  - `properties.LITC2N`: LITC2N_properties
    
  - `properties.MTF`: MTF_properties
    
  - `properties.SCLIGNIN`: SCLIGNIN_properties
    
  - `diagnostics.c_eco_k_f_veg_props`: effect of veg_props on carbon decomposition rate. 1: no stress, 0: complete stress
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cTauVegProperties_CASA.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  &amp; Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance &amp; inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
  
- Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., &amp; Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data &amp; ecosystem  modeling 1982–1998. Global &amp; Planetary Change, 39[3-4], 201-213.
  
- Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  &amp; Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite &amp; surface data. Global Biogeochemical Cycles, 7[4], 811-841.
  

_Versions_
- 1.0 on 12.01.2020 [sbesnard]  
  

_Created by_
- ncarvalhais
  

</details>


== cTauVegProperties_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cTauVegProperties_none' href='#Sindbad.Models.cTauVegProperties_none'><span class="jlbinding">Sindbad.Models.cTauVegProperties_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



set the outputs to ones

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  - `pools.cEco`: carbon content of cEco pool(s)
    
  
- **Outputs**
  - `properties.LIGEFF`: LIGEFF_properties
    
  - `properties.LIGNIN`: LIGNIN_properties
    
  - `properties.LITC2N`: LITC2N_properties
    
  - `properties.MTF`: MTF_properties
    
  - `properties.SCLIGNIN`: SCLIGNIN_properties
    
  - `diagnostics.c_eco_k_f_veg_props`: effect of veg_props on carbon decomposition rate. 1: no stress, 0: complete stress
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cTauVegProperties_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### cVegetationDieOff {#cVegetationDieOff}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cVegetationDieOff' href='#Sindbad.Models.cVegetationDieOff'><span class="jlbinding">Sindbad.Models.cVegetationDieOff</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Disturb the carbon cycle pools
```



---


**Approaches**
- `cVegetationDieOff_forcing`: reads and passes along to the land diagnostics the fraction of vegetation pools that die off 
  

</details>


:::details cVegetationDieOff approaches

:::tabs

== cVegetationDieOff_forcing
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.cVegetationDieOff_forcing' href='#Sindbad.Models.cVegetationDieOff_forcing'><span class="jlbinding">Sindbad.Models.cVegetationDieOff_forcing</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



reads and passes along to the land diagnostics the fraction of vegetation pools that die off 

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `forcing.f_dist_intensity`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_dist_intensity)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.c_fVegDieOff`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :c_fVegDieOff)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `forcing.f_dist_intensity`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_dist_intensity)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.c_fVegDieOff`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :c_fVegDieOff)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `cVegetationDieOff_forcing.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  &amp; Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance &amp; inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
  

_Versions_
- 1.0 on summer 2024
  

_Created by:_
- Nuno
  

</details>


:::


---


### capillaryFlow {#capillaryFlow}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.capillaryFlow' href='#Sindbad.Models.capillaryFlow'><span class="jlbinding">Sindbad.Models.capillaryFlow</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Flux of water from lower to upper soil layers (upward soil moisture movement)
```



---


**Approaches**
- `capillaryFlow_VanDijk2010`: computes the upward water flow in the soil layers
  

</details>


:::details capillaryFlow approaches

:::tabs

== capillaryFlow_VanDijk2010
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.capillaryFlow_VanDijk2010' href='#Sindbad.Models.capillaryFlow_VanDijk2010'><span class="jlbinding">Sindbad.Models.capillaryFlow_VanDijk2010</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



computes the upward water flow in the soil layers

**Parameters**
- **Fields**
  - `max_frac`: 0.95 ∈ [0.02, 0.98] =&gt; max fraction of soil moisture that can be lost as capillary flux (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `fluxes.soil_capillary_flux`: soil capillary flux per layer
    
  

`compute`:
- **Inputs**
  - `properties.k_fc`: hydraulic conductivity of soil at field capacity per layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `fluxes.soil_capillary_flux`: soil capillary flux per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.soil_capillary_flux`: soil capillary flux per layer
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `capillaryFlow_VanDijk2010.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- AIJM Van Dijk, 2010, The Australian Water Resources Assessment System Technical Report 3. Landscape Model [version 0.5] Technical Description
  
- http://www.clw.csiro.au/publications/waterforahealthycountry/2010/wfhc-aus-water-resources-assessment-system.pdf
  

_Versions_
- 1.0 on 18.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### constants {#constants}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.constants' href='#Sindbad.Models.constants'><span class="jlbinding">Sindbad.Models.constants</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
define the constants/variables that are independent of model structure
```



---


**Approaches**
- `constants_numbers`: constants of numbers such as 1 to 10
  

</details>


:::details constants approaches

:::tabs

== constants_numbers
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.constants_numbers' href='#Sindbad.Models.constants_numbers'><span class="jlbinding">Sindbad.Models.constants_numbers</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



constants of numbers such as 1 to 10

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  - `constants.t_two`: a type stable 2
    
  - `constants.t_three`: a type stable 3
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `constants_numbers.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 14.05.2025 [skoirala]
  

_Created by_
- skoirala
  

</details>


:::


---


### deriveVariables {#deriveVariables}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.deriveVariables' href='#Sindbad.Models.deriveVariables'><span class="jlbinding">Sindbad.Models.deriveVariables</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Derive extra variables
```



---


**Approaches**
- `deriveVariables_simple`: derives variables from other sindbad models and saves them into land.deriveVariables
  

</details>


:::details deriveVariables approaches

:::tabs

== deriveVariables_simple
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.deriveVariables_simple' href='#Sindbad.Models.deriveVariables_simple'><span class="jlbinding">Sindbad.Models.deriveVariables_simple</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



derives variables from other sindbad models and saves them into land.deriveVariables

**Parameters**
- None
  

**Methods:**

`define, precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `deriveVariables_simple.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 19.07.2023 [skoirala | @dr-ko]:
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### drainage {#drainage}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.drainage' href='#Sindbad.Models.drainage'><span class="jlbinding">Sindbad.Models.drainage</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Recharge the soil
```



---


**Approaches**
- `drainage_dos`: downward flow of moisture [drainage] in soil layers based on exponential function of soil moisture degree of saturation
  
- `drainage_kUnsat`: downward flow of moisture [drainage] in soil layers based on unsaturated hydraulic conductivity
  
- `drainage_wFC`: downward flow of moisture [drainage] in soil layers based on overflow over field capacity
  

</details>


:::details drainage approaches

:::tabs

== drainage_dos
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.drainage_dos' href='#Sindbad.Models.drainage_dos'><span class="jlbinding">Sindbad.Models.drainage_dos</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



downward flow of moisture [drainage] in soil layers based on exponential function of soil moisture degree of saturation

**Parameters**
- **Fields**
  - `dos_exp`: 1.5 ∈ [0.1, 3.0] =&gt; exponent of non-linearity for dos influence on drainage in soil (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  
- **Outputs**
  - `fluxes.drainage`: soil moisture drainage per soil layer
    
  

`compute`:
- **Inputs**
  - `fluxes.drainage`: soil moisture drainage per soil layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.soil_β`: beta parameter of soil per layer
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.drainage`: soil moisture drainage per soil layer
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `drainage_dos.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


== drainage_kUnsat
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.drainage_kUnsat' href='#Sindbad.Models.drainage_kUnsat'><span class="jlbinding">Sindbad.Models.drainage_kUnsat</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



downward flow of moisture [drainage] in soil layers based on unsaturated hydraulic conductivity

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `fluxes.drainage`: soil moisture drainage per soil layer
    
  

`compute`:
- **Inputs**
  - `fluxes.drainage`: soil moisture drainage per soil layer
    
  - `models.unsat_k_model`: name of the model used to calculate unsaturated hydraulic conductivity
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `properties.soil_β`: beta parameter of soil per layer
    
  - `properties.k_fc`: hydraulic conductivity of soil at field capacity per layer
    
  - `properties.k_sat`: hydraulic conductivity of soil at saturation per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - None
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `drainage_kUnsat.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


== drainage_wFC
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.drainage_wFC' href='#Sindbad.Models.drainage_wFC'><span class="jlbinding">Sindbad.Models.drainage_wFC</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



downward flow of moisture [drainage] in soil layers based on overflow over field capacity

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `fluxes.drainage`: soil moisture drainage per soil layer
    
  

`compute`:
- **Inputs**
  - `fluxes.drainage`: soil moisture drainage per soil layer
    
  - `properties.p_nsoilLayers`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:properties, :p_nsoilLayers)` for information on how to add the variable to the catalog.
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - None
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `drainage_wFC.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [skoirala | @dr-ko]: clean up &amp; consistency  
  

_Created by_
- mjung
  
- skoirala | @dr-ko
  

</details>


:::


---


### evaporation {#evaporation}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.evaporation' href='#Sindbad.Models.evaporation'><span class="jlbinding">Sindbad.Models.evaporation</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Soil evaporation
```



---


**Approaches**
- `evaporation_Snyder2000`: calculates the bare soil evaporation using relative drying rate of soil
  
- `evaporation_bareFraction`: calculates the bare soil evaporation from 1-frac_vegetation of the grid &amp; PET_evaporation
  
- `evaporation_demandSupply`: calculates the bare soil evaporation from demand-supply limited approach. 
  
- `evaporation_fAPAR`: calculates the bare soil evaporation from 1-fAPAR &amp; PET soil
  
- `evaporation_none`: sets the soil evaporation to zero
  
- `evaporation_vegFraction`: calculates the bare soil evaporation from 1-frac_vegetation &amp; PET soil
  

</details>


:::details evaporation approaches

:::tabs

== evaporation_Snyder2000
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.evaporation_Snyder2000' href='#Sindbad.Models.evaporation_Snyder2000'><span class="jlbinding">Sindbad.Models.evaporation_Snyder2000</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the bare soil evaporation using relative drying rate of soil

**Parameters**
- **Fields**
  - `α`: 1.0 ∈ [0.5, 1.5] =&gt; scaling factor for PET to account for maximum bare soil evaporation (`unitless` @ `all` timescales)
    
  - `β`: 3.0 ∈ [1.0, 5.0] =&gt; soil moisture resistance factor for soil evapotranspiration (units: `mm^0.5` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.sPET_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :sPET_prev)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `fluxes.PET`: potential evapotranspiration
    
  - `fluxes.sPET_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :sPET_prev)` for information on how to add the variable to the catalog.
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.sET`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :sET)` for information on how to add the variable to the catalog.
    
  - `fluxes.sPET_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :sPET_prev)` for information on how to add the variable to the catalog.
    
  - `fluxes.evaporation`: evaporation from the first soil layer
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `evaporation_Snyder2000.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Snyder, R. L., Bali, K., Ventura, F., &amp; Gomez-MacPherson, H. (2000).  Estimating evaporation from bare - nearly bare soil. Journal of irrigation &amp; drainage engineering, 126[6], 399-403.
  

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: transfer from to accommodate land.states.fAPAR  
  

_Created by_
- mjung
  
- skoirala | @dr-ko
  

</details>


== evaporation_bareFraction
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.evaporation_bareFraction' href='#Sindbad.Models.evaporation_bareFraction'><span class="jlbinding">Sindbad.Models.evaporation_bareFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the bare soil evaporation from 1-frac_vegetation of the grid &amp; PET_evaporation

**Parameters**
- **Fields**
  - `ks`: 0.5 ∈ [0.1, 0.95] =&gt; resistance against soil evaporation (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `fluxes.PET`: potential evapotranspiration
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.PET_evaporation`: potential soil evaporation
    
  - `fluxes.evaporation`: evaporation from the first soil layer
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `evaporation_bareFraction.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: clean up the code &amp; moved from prec to dyna to handle land.states.frac_vegetation  
  

_Created by_
- mjung
  
- skoirala | @dr-ko
  
- ttraut
  

</details>


== evaporation_demandSupply
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.evaporation_demandSupply' href='#Sindbad.Models.evaporation_demandSupply'><span class="jlbinding">Sindbad.Models.evaporation_demandSupply</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the bare soil evaporation from demand-supply limited approach. 

**Parameters**
- **Fields**
  - `α`: 1.0 ∈ [0.1, 3.0] =&gt; α coefficient of Priestley-Taylor formula for soil (`unitless` @ `all` timescales)
    
  - `k_evaporation`: 0.2 ∈ [0.05, 0.98] =&gt; fraction of soil water that can be used for soil evaporation (units: `day-1` @ `day` timescale)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `fluxes.PET`: potential evapotranspiration
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.PET_evaporation`: potential soil evaporation
    
  - `fluxes.evaporationSupply`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :evaporationSupply)` for information on how to add the variable to the catalog.
    
  - `fluxes.evaporation`: evaporation from the first soil layer
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `evaporation_demandSupply.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Teuling et al.
  

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: clean up the code
  
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: clean up the code  
  

_Created by_
- mjung
  
- skoirala | @dr-ko
  
- ttraut
  

_Notes_
- considers that the soil evaporation can occur from the whole grid &amp; not only the  non-vegetated fraction of the grid cell  
  

</details>


== evaporation_fAPAR
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.evaporation_fAPAR' href='#Sindbad.Models.evaporation_fAPAR'><span class="jlbinding">Sindbad.Models.evaporation_fAPAR</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the bare soil evaporation from 1-fAPAR &amp; PET soil

**Parameters**
- **Fields**
  - `α`: 1.0 ∈ [0.1, 3.0] =&gt; α coefficient of Priestley-Taylor formula for soil (`unitless` @ `all` timescales)
    
  - `k_evaporation`: 0.2 ∈ [0.05, 0.95] =&gt; fraction of soil water that can be used for soil evaporation (units: `day-1` @ `day` timescale)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `fluxes.PET`: potential evapotranspiration
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.PET_evaporation`: potential soil evaporation
    
  - `fluxes.evaporation`: evaporation from the first soil layer
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `evaporation_fAPAR.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: clean up the code &amp; moved from prec to dyna to handle land.states.frac_vegetation  
  

_Created by_
- mjung
  
- skoirala | @dr-ko
  

</details>


== evaporation_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.evaporation_none' href='#Sindbad.Models.evaporation_none'><span class="jlbinding">Sindbad.Models.evaporation_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the soil evaporation to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.evaporation`: evaporation from the first soil layer
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `evaporation_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


== evaporation_vegFraction
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.evaporation_vegFraction' href='#Sindbad.Models.evaporation_vegFraction'><span class="jlbinding">Sindbad.Models.evaporation_vegFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the bare soil evaporation from 1-frac_vegetation &amp; PET soil

**Parameters**
- **Fields**
  - `α`: 1.0 ∈ [0.0, 3.0] =&gt; α coefficient of Priestley-Taylor formula for soil (`unitless` @ `all` timescales)
    
  - `k_evaporation`: 0.2 ∈ [0.03, 0.98] =&gt; fraction of soil water that can be used for soil evaporation (units: `day-1` @ `day` timescale)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `fluxes.PET`: potential evapotranspiration
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.PET_evaporation`: potential soil evaporation
    
  - `fluxes.evaporation`: evaporation from the first soil layer
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `evaporation_vegFraction.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: clean up the code &amp; moved from prec to dyna to handle land.states.frac_vegetation  
  

_Created by_
- mjung
  
- skoirala | @dr-ko
  

</details>


:::


---


### evapotranspiration {#evapotranspiration}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.evapotranspiration' href='#Sindbad.Models.evapotranspiration'><span class="jlbinding">Sindbad.Models.evapotranspiration</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Calculate the evapotranspiration as a sum of components
```



---


**Approaches**
- `evapotranspiration_sum`: calculates evapotranspiration as a sum of all potential components
  

</details>


:::details evapotranspiration approaches

:::tabs

== evapotranspiration_sum
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.evapotranspiration_sum' href='#Sindbad.Models.evapotranspiration_sum'><span class="jlbinding">Sindbad.Models.evapotranspiration_sum</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates evapotranspiration as a sum of all potential components

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.evaporation`: evaporation from the first soil layer
    
  - `fluxes.evapotranspiration`: total land evaporation including soil evaporation, vegetation transpiration, snow sublimation, and interception loss
    
  - `fluxes.interception`: interception evaporation loss
    
  - `fluxes.sublimation`: sublimation of the snow
    
  - `fluxes.transpiration`: transpiration
    
  

`compute`:
- **Inputs**
  - `fluxes.evaporation`: evaporation from the first soil layer
    
  - `fluxes.interception`: interception evaporation loss
    
  - `fluxes.sublimation`: sublimation of the snow
    
  - `fluxes.transpiration`: transpiration
    
  
- **Outputs**
  - `fluxes.evapotranspiration`: total land evaporation including soil evaporation, vegetation transpiration, snow sublimation, and interception loss
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `evapotranspiration_sum.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 01.04.2022  
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### fAPAR {#fAPAR}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.fAPAR' href='#Sindbad.Models.fAPAR'><span class="jlbinding">Sindbad.Models.fAPAR</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Fraction of absorbed photosynthetically active radiation
```



---


**Approaches**
- `fAPAR_EVI`: calculates fAPAR as a linear function of EVI
  
- `fAPAR_LAI`: sets fAPAR as a function of LAI
  
- `fAPAR_cVegLeaf`: Compute FAPAR based on carbon pool of the leave; SLA; kLAI
  
- `fAPAR_cVegLeafBareFrac`: Compute FAPAR based on carbon pool of the leaf, but only for the vegetation fraction
  
- `fAPAR_constant`: sets fAPAR as a constant
  
- `fAPAR_forcing`: sets land.states.fAPAR from forcing
  
- `fAPAR_vegFraction`: sets fAPAR as a linear function of vegetation fraction
  

</details>


:::details fAPAR approaches

:::tabs

== fAPAR_EVI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.fAPAR_EVI' href='#Sindbad.Models.fAPAR_EVI'><span class="jlbinding">Sindbad.Models.fAPAR_EVI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates fAPAR as a linear function of EVI

**Parameters**
- **Fields**
  - `EVI_to_fAPAR_c`: 0.0 ∈ [-0.2, 0.3] =&gt; intercept of the linear function (`unitless` @ `all` timescales)
    
  - `EVI_to_fAPAR_m`: 1.0 ∈ [0.5, 5] =&gt; slope of the linear function (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.EVI`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :EVI)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `fAPAR_EVI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== fAPAR_LAI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.fAPAR_LAI' href='#Sindbad.Models.fAPAR_LAI'><span class="jlbinding">Sindbad.Models.fAPAR_LAI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets fAPAR as a function of LAI

**Parameters**
- **Fields**
  - `k_extinction`: 0.5 ∈ [1.0e-5, 0.99] =&gt; effective light extinction coefficient (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.LAI`: leaf area index
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `fAPAR_LAI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 24.02.2021 [skoirala | @dr-ko]  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== fAPAR_cVegLeaf
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.fAPAR_cVegLeaf' href='#Sindbad.Models.fAPAR_cVegLeaf'><span class="jlbinding">Sindbad.Models.fAPAR_cVegLeaf</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Compute FAPAR based on carbon pool of the leave; SLA; kLAI

**Parameters**
- **Fields**
  - `k_extinction`: 0.005 ∈ [0.0005, 0.05] =&gt; effective light extinction coefficient (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.cVegLeaf`: carbon content of cVegLeaf pool(s)
    
  
- **Outputs**
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `fAPAR_cVegLeaf.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 24.04.2021 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


== fAPAR_cVegLeafBareFrac
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.fAPAR_cVegLeafBareFrac' href='#Sindbad.Models.fAPAR_cVegLeafBareFrac'><span class="jlbinding">Sindbad.Models.fAPAR_cVegLeafBareFrac</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



Compute FAPAR based on carbon pool of the leaf, but only for the vegetation fraction

**Parameters**
- **Fields**
  - `k_extinction`: 0.005 ∈ [0.0005, 0.05] =&gt; effective light extinction coefficient (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.cVegLeaf`: carbon content of cVegLeaf pool(s)
    
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  
- **Outputs**
  - `states # TODO: now use fAPAR_bare as the output for the cost function!.fAPAR_bare`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states # TODO: now use fAPAR_bare as the output for the cost function!, :fAPAR_bare)` for information on how to add the variable to the catalog.
    
  - `states # TODO: now use fAPAR_bare as the output for the cost function!.fAPAR`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states # TODO: now use fAPAR_bare as the output for the cost function!, :fAPAR)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `fAPAR_cVegLeafBareFrac.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 24.04.2021 [skoirala | @dr-ko]
  

_Created by:_
- Nuno &amp; skoirala
  

</details>


== fAPAR_constant
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.fAPAR_constant' href='#Sindbad.Models.fAPAR_constant'><span class="jlbinding">Sindbad.Models.fAPAR_constant</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets fAPAR as a constant

**Parameters**
- **Fields**
  - `constant_fAPAR`: 0.2 ∈ [0.0, 1.0] =&gt; a constant fAPAR (`unitless` @ `all` timescales)
    
  

**Methods:**

`precompute`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  

`define, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `fAPAR_constant.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: cleaned up the code  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== fAPAR_forcing
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.fAPAR_forcing' href='#Sindbad.Models.fAPAR_forcing'><span class="jlbinding">Sindbad.Models.fAPAR_forcing</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets land.states.fAPAR from forcing

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_fAPAR`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_fAPAR)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `fAPAR_forcing.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 23.11.2019 [skoirala | @dr-ko]: new approach  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== fAPAR_vegFraction
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.fAPAR_vegFraction' href='#Sindbad.Models.fAPAR_vegFraction'><span class="jlbinding">Sindbad.Models.fAPAR_vegFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets fAPAR as a linear function of vegetation fraction

**Parameters**
- **Fields**
  - `frac_vegetation_to_fAPAR`: 0.989 ∈ [1.0e-5, 0.99] =&gt; linear fraction of fAPAR and frac_vegetation (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  
- **Outputs**
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `fAPAR_vegFraction.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]  
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### getPools {#getPools}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.getPools' href='#Sindbad.Models.getPools'><span class="jlbinding">Sindbad.Models.getPools</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Get the amount of water at the beginning of timestep
```



---


**Approaches**
- `getPools_simple`: gets the amount of water available for the current time step
  

</details>


:::details getPools approaches

:::tabs

== getPools_simple
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.getPools_simple' href='#Sindbad.Models.getPools_simple'><span class="jlbinding">Sindbad.Models.getPools_simple</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



gets the amount of water available for the current time step

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`compute`:
- **Inputs**
  - `fluxes.rain`: amount of precipitation in liquid form
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  
- **Outputs**
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `getPools_simple.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 19.11.2019 [skoirala | @dr-ko]: added the documentation &amp; cleaned the code, added json with development stage
  

_Created by_
- mjung
  
- ncarvalhais
  
- skoirala | @dr-ko
  

</details>


:::


---


### gpp {#gpp}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gpp' href='#Sindbad.Models.gpp'><span class="jlbinding">Sindbad.Models.gpp</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Combine effects as multiplicative or minimum; if coupled, uses transup
```



---


**Approaches**
- `gpp_coupled`: calculate GPP based on transpiration supply &amp; water use efficiency [coupled]
  
- `gpp_min`: compute the actual GPP with potential scaled by minimum stress scalar of demand &amp; supply for uncoupled model structure [no coupling with transpiration]
  
- `gpp_mult`: compute the actual GPP with potential scaled by multiplicative stress scalar of demand &amp; supply for uncoupled model structure [no coupling with transpiration]
  
- `gpp_none`: sets the actual GPP to zero
  
- `gpp_transpirationWUE`: calculate GPP based on transpiration &amp; water use efficiency
  

</details>


:::details gpp approaches

:::tabs

== gpp_coupled
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gpp_coupled' href='#Sindbad.Models.gpp_coupled'><span class="jlbinding">Sindbad.Models.gpp_coupled</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate GPP based on transpiration supply &amp; water use efficiency [coupled]

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `diagnostics.transpiration_supply`: total amount of water available in soil for transpiration
    
  - `diagnostics.gpp_f_soilW`: effect of soil moisture on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.gpp_demand`: demand driven gross primary prorDuctivity
    
  - `diagnostics.WUE`: water use efficiency of the ecosystem
    
  
- **Outputs**
  - `fluxes.gpp`: gross primary prorDcutivity
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gpp_coupled.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]
  

_Created by_
- mjung
  
- skoirala | @dr-ko
  

_Notes_

</details>


== gpp_min
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gpp_min' href='#Sindbad.Models.gpp_min'><span class="jlbinding">Sindbad.Models.gpp_min</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



compute the actual GPP with potential scaled by minimum stress scalar of demand &amp; supply for uncoupled model structure [no coupling with transpiration]

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `diagnostics.gpp_f_climate`: effect of climate on gpp. 1: no stress, 0: complete stress
    
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  - `diagnostics.gpp_potential`: potential gross primary prorDcutivity
    
  - `diagnostics.gpp_f_soilW`: effect of soil moisture on gpp. 1: no stress, 0: complete stress
    
  
- **Outputs**
  - `fluxes.gpp`: gross primary prorDcutivity
    
  - `gpp.AllScGPP`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:gpp, :AllScGPP)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gpp_min.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up  
  

_Created by_
- ncarvalhais
  

_Notes_

</details>


== gpp_mult
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gpp_mult' href='#Sindbad.Models.gpp_mult'><span class="jlbinding">Sindbad.Models.gpp_mult</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



compute the actual GPP with potential scaled by multiplicative stress scalar of demand &amp; supply for uncoupled model structure [no coupling with transpiration]

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `gpp.AllScGPP`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:gpp, :AllScGPP)` for information on how to add the variable to the catalog.
    
  - `fluxes.gpp`: gross primary prorDcutivity
    
  

`compute`:
- **Inputs**
  - `diagnostics.gpp_f_climate`: effect of climate on gpp. 1: no stress, 0: complete stress
    
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  - `diagnostics.gpp_potential`: potential gross primary prorDcutivity
    
  - `diagnostics.gpp_f_soilW`: effect of soil moisture on gpp. 1: no stress, 0: complete stress
    
  
- **Outputs**
  - `fluxes.gpp`: gross primary prorDcutivity
    
  - `gpp.AllScGPP`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:gpp, :AllScGPP)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gpp_mult.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up  
  

_Created by_
- ncarvalhais
  

_Notes_

</details>


== gpp_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gpp_none' href='#Sindbad.Models.gpp_none'><span class="jlbinding">Sindbad.Models.gpp_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the actual GPP to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.gpp`: gross primary prorDcutivity
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gpp_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up 
  

_Created by_
- ncarvalhais
  

</details>


== gpp_transpirationWUE
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gpp_transpirationWUE' href='#Sindbad.Models.gpp_transpirationWUE'><span class="jlbinding">Sindbad.Models.gpp_transpirationWUE</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate GPP based on transpiration &amp; water use efficiency

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `fluxes.transpiration`: transpiration
    
  - `diagnostics.WUE`: water use efficiency of the ecosystem
    
  
- **Outputs**
  - `fluxes.gpp`: gross primary prorDcutivity
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gpp_transpirationWUE.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2023 [skoirala | @dr-ko]
  

_Created by_
- mjung
  
- skoirala | @dr-ko
  

_Notes_

</details>


:::


---


### gppAirT {#gppAirT}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppAirT' href='#Sindbad.Models.gppAirT'><span class="jlbinding">Sindbad.Models.gppAirT</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Quantifies the effect of temperature on GPP: 1 indicates no temperature stress, while 0 indicates complete stress.
```



---


**Approaches**
- `gppAirT_CASA`: temperature stress for gpp_potential based on CASA &amp; Potter
  
- `gppAirT_GSI`: temperature stress on gpp_potential based on GSI implementation of LPJ
  
- `gppAirT_MOD17`: temperature stress on gpp_potential based on GPP - MOD17 model
  
- `gppAirT_Maekelae2008`: temperature stress on gpp_potential based on Maekelae2008 [eqn 3 &amp; 4]
  
- `gppAirT_TEM`: temperature stress for gpp_potential based on TEM
  
- `gppAirT_Wang2014`: temperature stress on gpp_potential based on Wang2014
  
- `gppAirT_none`: sets the temperature stress on gpp_potential to one (no stress)
  

</details>


:::details gppAirT approaches

:::tabs

== gppAirT_CASA
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppAirT_CASA' href='#Sindbad.Models.gppAirT_CASA'><span class="jlbinding">Sindbad.Models.gppAirT_CASA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



temperature stress for gpp_potential based on CASA &amp; Potter

**Parameters**
- **Fields**
  - `opt_airT`: 25.0 ∈ [5.0, 35.0] =&gt; check in CASA code (units: `°C` @ `all` timescales)
    
  - `opt_airT_A`: 0.2 ∈ [0.01, 0.3] =&gt; increasing slope of sensitivity (`unitless` @ `all` timescales)
    
  - `opt_airT_B`: 0.3 ∈ [0.01, 0.5] =&gt; decreasing slope of sensitivity (`unitless` @ `all` timescales)
    
  - `exp_airT`: 10.0 ∈ [9.0, 11.0] =&gt; reference for exponent of sensitivity (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_airT_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT_day)` for information on how to add the variable to the catalog.
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_airT`: effect of air temperature on gpp. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppAirT_CASA.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Carvalhais; N.; Reichstein; M.; Seixas; J.; Collatz; G. J.; Pereira; J. S.; Berbigier; P.  &amp; Rambal, S. (2008). Implications of the carbon cycle steady state assumption for  biogeochemical modeling performance &amp; inverse parameter retrieval. Global Biogeochemical Cycles, 22[2].
  
- Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., &amp; Kumar, V. (2003).  Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data &amp; ecosystem  modeling 1982–1998. Global &amp; Planetary Change, 39[3-4], 201-213.
  
- Potter; C. S.; Randerson; J. T.; Field; C. B.; Matson; P. A.; Vitousek; P. M.; Mooney; H. A.  &amp; Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global  satellite &amp; surface data. Global Biogeochemical Cycles, 7[4], 811-841.
  

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up  
  

_Created by_
- ncarvalhais
  

_Notes_

</details>


== gppAirT_GSI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppAirT_GSI' href='#Sindbad.Models.gppAirT_GSI'><span class="jlbinding">Sindbad.Models.gppAirT_GSI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



temperature stress on gpp_potential based on GSI implementation of LPJ

**Parameters**
- **Fields**
  - `f_airT_c_τ`: 0.2 ∈ [0.01, 1.0] =&gt; contribution factor for current stressor for cold stress (units: `fraction` @ `all` timescales)
    
  - `f_airT_c_slope`: 0.25 ∈ [0.0, 100.0] =&gt; slope of sigmoid for cold stress (units: `fraction` @ `all` timescales)
    
  - `f_airT_c_base`: 7.0 ∈ [1.0, 15.0] =&gt; base of sigmoid for cold stress (units: `fraction` @ `all` timescales)
    
  - `f_airT_h_τ`: 0.2 ∈ [0.01, 1.0] =&gt; contribution factor for current stressor for heat stress (units: `fraction` @ `all` timescales)
    
  - `f_airT_h_slope`: 1.74 ∈ [0.0, 100.0] =&gt; slope of sigmoid for heat stress (units: `fraction` @ `all` timescales)
    
  - `f_airT_h_base`: 41.51 ∈ [25.0, 65.0] =&gt; base of sigmoid for heat stress (units: `fraction` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_airT_c`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_airT_c)` for information on how to add the variable to the catalog.
    
  - `diagnostics.gpp_f_airT_h`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_airT_h)` for information on how to add the variable to the catalog.
    
  - `diagnostics.f_smooth`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :f_smooth)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `forcing.f_airT`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT)` for information on how to add the variable to the catalog.
    
  - `diagnostics.gpp_f_airT_c`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_airT_c)` for information on how to add the variable to the catalog.
    
  - `diagnostics.gpp_f_airT_h`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_airT_h)` for information on how to add the variable to the catalog.
    
  - `diagnostics.f_smooth`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :f_smooth)` for information on how to add the variable to the catalog.
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_airT`: effect of air temperature on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.cScGPP`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :cScGPP)` for information on how to add the variable to the catalog.
    
  - `diagnostics.hScGPP`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :hScGPP)` for information on how to add the variable to the catalog.
    
  - `diagnostics.gpp_f_airT_c`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_airT_c)` for information on how to add the variable to the catalog.
    
  - `diagnostics.gpp_f_airT_h`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_airT_h)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppAirT_GSI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Forkel; M.; Carvalhais; N.; Schaphoff; S.; v. Bloh; W.; Migliavacca; M.  Thurner; M.; &amp; Thonicke; K.: Identifying environmental controls on  vegetation greenness phenology through model–data integration  Biogeosciences; 11; 7025–7050; https://doi.org/10.5194/bg-11-7025-2014;2014.
  

_Versions_
- 1.1 on 22.01.2021 (skoirala
  

_Created by_
- skoirala | @dr-ko
  

_Notes_

</details>


== gppAirT_MOD17
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppAirT_MOD17' href='#Sindbad.Models.gppAirT_MOD17'><span class="jlbinding">Sindbad.Models.gppAirT_MOD17</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



temperature stress on gpp_potential based on GPP - MOD17 model

**Parameters**
- **Fields**
  - `Tmax`: 20.0 ∈ [10.0, 35.0] =&gt; temperature for max GPP (units: `°C` @ `all` timescales)
    
  - `Tmin`: 5.0 ∈ [0.0, 15.0] =&gt; temperature for min GPP (units: `°C` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_airT_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT_day)` for information on how to add the variable to the catalog.
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_airT`: effect of air temperature on gpp. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppAirT_MOD17.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- MOD17 User guide: https://lpdaac.usgs.gov/documents/495/MOD17_User_Guide_V6.pdf
  
- Running; S. W.; Nemani; R. R.; Heinsch; F. A.; Zhao; M.; Reeves; M.  &amp; Hashimoto, H. (2004). A continuous satellite-derived measure of global terrestrial  primary production. Bioscience, 54[6], 547-560.
  
- Zhao, M., Heinsch, F. A., Nemani, R. R., &amp; Running, S. W. (2005). Improvements  of the MODIS terrestrial gross &amp; net primary production global data set. Remote  sensing of Environment, 95[2], 164-176.
  

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up  
  

_Created by_
- ncarvalhais
  

_Notes_

</details>


== gppAirT_Maekelae2008
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppAirT_Maekelae2008' href='#Sindbad.Models.gppAirT_Maekelae2008'><span class="jlbinding">Sindbad.Models.gppAirT_Maekelae2008</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



temperature stress on gpp_potential based on Maekelae2008 [eqn 3 &amp; 4]

**Parameters**
- **Fields**
  - `TimConst`: 5.0 ∈ [1.0, 20.0] =&gt; time constant for temp delay (units: `days` @ `all` timescales)
    
  - `X0`: -5.0 ∈ [-15.0, 1.0] =&gt; threshold of delay temperature (units: `°C` @ `all` timescales)
    
  - `s_max`: 20.0 ∈ [10.0, 30.0] =&gt; temperature at saturation (units: `°C` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `forcing.f_airT_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT_day)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.X_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :X_prev)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `forcing.f_airT_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT_day)` for information on how to add the variable to the catalog.
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  - `diagnostics.X_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :X_prev)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.gpp_f_airT`: effect of air temperature on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.X_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :X_prev)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppAirT_Maekelae2008.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Mäkelä, A., Pulkkinen, M., Kolari, P., et al. (2008).  Developing an empirical model of stand GPP with the LUE approachanalysis of eddy covariance data at five contrasting conifer sites in Europe.  Global change biology, 14[1], 92-108.
  

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up  
  

_Created by_
- ncarvalhais
  

_Notes_
- Tmin &lt; Tmax ALWAYS!!!
  

</details>


== gppAirT_TEM
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppAirT_TEM' href='#Sindbad.Models.gppAirT_TEM'><span class="jlbinding">Sindbad.Models.gppAirT_TEM</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



temperature stress for gpp_potential based on TEM

**Parameters**
- **Fields**
  - `Tmin`: 5.0 ∈ [-10.0, 15.0] =&gt; minimum temperature at which GPP ceases (units: `°C` @ `all` timescales)
    
  - `Tmax`: 20.0 ∈ [10.0, 45.0] =&gt; maximum temperature at which GPP ceases (units: `°C` @ `all` timescales)
    
  - `opt_airT`: 15.0 ∈ [5.0, 30.0] =&gt; optimal temperature for GPP (units: `°C` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_airT_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT_day)` for information on how to add the variable to the catalog.
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  - `constants.t_two`: a type stable 2
    
  
- **Outputs**
  - `diagnostics.gpp_f_airT`: effect of air temperature on gpp. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppAirT_TEM.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up  
  

_Created by_
- ncarvalhais
  

_Notes_

</details>


== gppAirT_Wang2014
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppAirT_Wang2014' href='#Sindbad.Models.gppAirT_Wang2014'><span class="jlbinding">Sindbad.Models.gppAirT_Wang2014</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



temperature stress on gpp_potential based on Wang2014

**Parameters**
- **Fields**
  - `Tmax`: 10.0 ∈ [5.0, 45.0] =&gt; maximum temperature at which GPP ceases (units: `°C` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_airT_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT_day)` for information on how to add the variable to the catalog.
    
  - `diagnostics.z_zero`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :z_zero)` for information on how to add the variable to the catalog.
    
  - `diagnostics.o_one`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :o_one)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.gpp_f_airT`: effect of air temperature on gpp. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppAirT_Wang2014.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Wang, H., Prentice, I. C., &amp; Davis, T. W. (2014). Biophsyical constraints on gross  primary production by the terrestrial biosphere. Biogeosciences, 11[20], 5987.
  

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up  
  

_Created by_
- ncarvalhais
  

</details>


== gppAirT_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppAirT_none' href='#Sindbad.Models.gppAirT_none'><span class="jlbinding">Sindbad.Models.gppAirT_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the temperature stress on gpp_potential to one (no stress)

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_airT`: effect of air temperature on gpp. 1: no stress, 0: complete stress
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppAirT_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up  
  

_Created by_
- ncarvalhais
  

</details>


:::


---


### gppDemand {#gppDemand}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppDemand' href='#Sindbad.Models.gppDemand'><span class="jlbinding">Sindbad.Models.gppDemand</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Quantifies the combined effect of environmental demand on GPP.
```



---


**Approaches**
- `gppDemand_min`: compute the demand GPP as minimum of all stress scalars [most limited]
  
- `gppDemand_mult`: compute the demand GPP as multipicative stress scalars
  
- `gppDemand_none`: sets the scalar for demand GPP to ones &amp; demand GPP to zero
  

</details>


:::details gppDemand approaches

:::tabs

== gppDemand_min
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppDemand_min' href='#Sindbad.Models.gppDemand_min'><span class="jlbinding">Sindbad.Models.gppDemand_min</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



compute the demand GPP as minimum of all stress scalars [most limited]

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `land.land_pools = pools`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:land, :land_pools = pools)` for information on how to add the variable to the catalog.
    
  - `diagnostics.gpp_potential`: potential gross primary prorDcutivity
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `diagnostics.gpp_climate_stressors`: a collection of all gpp climate stressors including light, temperature, radiation, and vpd
    
  

`compute`:
- **Inputs**
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  - `diagnostics.gpp_f_cloud`: effect of cloud on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.gpp_potential`: potential gross primary prorDcutivity
    
  - `diagnostics.gpp_f_light`: effect of light on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.gpp_climate_stressors`: a collection of all gpp climate stressors including light, temperature, radiation, and vpd
    
  - `diagnostics.gpp_f_airT`: effect of air temperature on gpp. 1: no stress, 0: complete stress
    
  
- **Outputs**
  - `diagnostics.gpp_f_climate`: effect of climate on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.gpp_demand`: demand driven gross primary prorDuctivity
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppDemand_min.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up  
  

_Created by_
- ncarvalhais
  

_Notes_

</details>


== gppDemand_mult
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppDemand_mult' href='#Sindbad.Models.gppDemand_mult'><span class="jlbinding">Sindbad.Models.gppDemand_mult</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



compute the demand GPP as multipicative stress scalars

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `forcing.f_VPD_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_VPD_day)` for information on how to add the variable to the catalog.
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `diagnostics.gpp_climate_stressors`: a collection of all gpp climate stressors including light, temperature, radiation, and vpd
    
  

`compute`:
- **Inputs**
  - `diagnostics.gpp_f_cloud`: effect of cloud on gpp. 1: no stress, 0: complete stress
    
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  - `diagnostics.gpp_potential`: potential gross primary prorDcutivity
    
  - `diagnostics.gpp_f_light`: effect of light on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.gpp_climate_stressors`: a collection of all gpp climate stressors including light, temperature, radiation, and vpd
    
  - `diagnostics.gpp_f_airT`: effect of air temperature on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.gpp_f_vpd`: effect of vpd on gpp. 1: no stress, 0: complete stress
    
  
- **Outputs**
  - `diagnostics.gpp_climate_stressors`: a collection of all gpp climate stressors including light, temperature, radiation, and vpd
    
  - `diagnostics.gpp_f_climate`: effect of climate on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.gpp_demand`: demand driven gross primary prorDuctivity
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppDemand_mult.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up  
  

_Created by_
- ncarvalhais
  

_Notes_

</details>


== gppDemand_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppDemand_none' href='#Sindbad.Models.gppDemand_none'><span class="jlbinding">Sindbad.Models.gppDemand_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the scalar for demand GPP to ones &amp; demand GPP to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_climate`: effect of climate on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.gpp_demand`: demand driven gross primary prorDuctivity
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppDemand_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up 
  

_Created by_
- ncarvalhais
  

</details>


:::


---


### gppDiffRadiation {#gppDiffRadiation}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppDiffRadiation' href='#Sindbad.Models.gppDiffRadiation'><span class="jlbinding">Sindbad.Models.gppDiffRadiation</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Quantifies the effect of diffuse radiation on GPP: 1 indicates no diffuse radiation effect, while 0 indicates complete effect.
```



---


**Approaches**
- `gppDiffRadiation_GSI`: cloudiness scalar [radiation diffusion] on gpp_potential based on GSI implementation of LPJ
  
- `gppDiffRadiation_Turner2006`: cloudiness scalar [radiation diffusion] on gpp_potential based on Turner2006
  
- `gppDiffRadiation_Wang2015`: cloudiness scalar [radiation diffusion] on gpp_potential based on Wang2015
  
- `gppDiffRadiation_none`: sets the cloudiness scalar [radiation diffusion] for gpp_potential to one
  

</details>


:::details gppDiffRadiation approaches

:::tabs

== gppDiffRadiation_GSI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppDiffRadiation_GSI' href='#Sindbad.Models.gppDiffRadiation_GSI'><span class="jlbinding">Sindbad.Models.gppDiffRadiation_GSI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



cloudiness scalar [radiation diffusion] on gpp_potential based on GSI implementation of LPJ

**Parameters**
- **Fields**
  - `fR_τ`: 0.2 ∈ [0.01, 1.0] =&gt; contribution factor for current stressor (units: `fraction` @ `all` timescales)
    
  - `fR_slope`: 58.0 ∈ [1.0, 100.0] =&gt; slope of sigmoid (units: `fraction` @ `all` timescales)
    
  - `fR_base`: 59.78 ∈ [1.0, 120.0] =&gt; base of sigmoid (units: `fraction` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `forcing.f_rg`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rg)` for information on how to add the variable to the catalog.
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_cloud`: effect of cloud on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.gpp_f_cloud_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_cloud_prev)` for information on how to add the variable to the catalog.
    
  - `diagnostics.MJ_to_W`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :MJ_to_W)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `forcing.f_rg`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rg)` for information on how to add the variable to the catalog.
    
  - `diagnostics.gpp_f_cloud_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_cloud_prev)` for information on how to add the variable to the catalog.
    
  - `diagnostics.MJ_to_W`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :MJ_to_W)` for information on how to add the variable to the catalog.
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_cloud`: effect of cloud on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.gpp_f_cloud_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_cloud_prev)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppDiffRadiation_GSI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Forkel; M.; Carvalhais; N.; Schaphoff; S.; v. Bloh; W.; Migliavacca; M.  Thurner; M.; &amp; Thonicke; K.: Identifying environmental controls on  vegetation greenness phenology through model–data integration  Biogeosciences; 11; 7025–7050; https://doi.org/10.5194/bg-11-7025-2014;2014.
  

_Versions_
- 1.1 on 22.01.2021 (skoirala
  

_Created by_
- skoirala | @dr-ko
  

_Notes_

</details>


== gppDiffRadiation_Turner2006
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppDiffRadiation_Turner2006' href='#Sindbad.Models.gppDiffRadiation_Turner2006'><span class="jlbinding">Sindbad.Models.gppDiffRadiation_Turner2006</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



cloudiness scalar [radiation diffusion] on gpp_potential based on Turner2006

**Parameters**
- **Fields**
  - `rue_ratio`: 0.5 ∈ [0.0001, 1.0] =&gt; ratio of clear sky LUE to max LUE (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `forcing.f_rg`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rg)` for information on how to add the variable to the catalog.
    
  - `forcing.f_rg_pot`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rg_pot)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.CI_min`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :CI_min)` for information on how to add the variable to the catalog.
    
  - `diagnostics.CI_max`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :CI_max)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `forcing.f_rg`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rg)` for information on how to add the variable to the catalog.
    
  - `forcing.f_rg_pot`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rg_pot)` for information on how to add the variable to the catalog.
    
  - `diagnostics.CI_min`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :CI_min)` for information on how to add the variable to the catalog.
    
  - `diagnostics.CI_max`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :CI_max)` for information on how to add the variable to the catalog.
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_cloud`: effect of cloud on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.CI_min`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :CI_min)` for information on how to add the variable to the catalog.
    
  - `diagnostics.CI_max`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :CI_max)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppDiffRadiation_Turner2006.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Turner, D. P., Ritts, W. D., Styles, J. M., Yang, Z., Cohen, W. B., Law, B. E., &amp; Thornton, P. E. (2006).  A diagnostic carbon flux model to monitor the effects of disturbance &amp; interannual variation in  climate on regional NEP. Tellus B: Chemical &amp; Physical Meteorology, 58[5], 476-490.  DOI: 10.1111/j.1600-0889.2006.00221.x
  

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up 
  

_Created by_
- mjung
  
- ncarvalhais
  

</details>


== gppDiffRadiation_Wang2015
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppDiffRadiation_Wang2015' href='#Sindbad.Models.gppDiffRadiation_Wang2015'><span class="jlbinding">Sindbad.Models.gppDiffRadiation_Wang2015</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



cloudiness scalar [radiation diffusion] on gpp_potential based on Wang2015

**Parameters**
- **Fields**
  - `μ`: 0.46 ∈ [0.0001, 1.0] =&gt;  (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `forcing.f_rg`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rg)` for information on how to add the variable to the catalog.
    
  - `forcing.f_rg_pot`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rg_pot)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `gppDiffRadiation.CI_min`: minimum of cloudiness index until the time step from the beginning of simulation (including spinup)
    
  - `gppDiffRadiation.CI_max`: maximum of cloudiness index until the time step from the beginning of simulation (including spinup)
    
  

`precompute`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `diagnostics.gpp_f_cloud`: effect of cloud on gpp. 1: no stress, 0: complete stress
    
  

`compute`:
- **Inputs**
  - `forcing.f_rg`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rg)` for information on how to add the variable to the catalog.
    
  - `forcing.f_rg_pot`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rg_pot)` for information on how to add the variable to the catalog.
    
  - `gppDiffRadiation.CI_min`: minimum of cloudiness index until the time step from the beginning of simulation (including spinup)
    
  - `gppDiffRadiation.CI_max`: maximum of cloudiness index until the time step from the beginning of simulation (including spinup)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_cloud`: effect of cloud on gpp. 1: no stress, 0: complete stress
    
  - `gppDiffRadiation.CI_min`: minimum of cloudiness index until the time step from the beginning of simulation (including spinup)
    
  - `gppDiffRadiation.CI_max`: maximum of cloudiness index until the time step from the beginning of simulation (including spinup)
    
  

`update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppDiffRadiation_Wang2015.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Turner, D. P., Ritts, W. D., Styles, J. M., Yang, Z., Cohen, W. B., Law, B. E., &amp; Thornton, P. E. (2006).  A diagnostic carbon flux model to monitor the effects of disturbance &amp; interannual variation in  climate on regional NEP. Tellus B: Chemical &amp; Physical Meteorology, 58[5], 476-490.  DOI: 10.1111/j.1600-0889.2006.00221.x
  

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up
  
- 1.1 on 22.01.2021 [skoirala | @dr-ko]: minimum &amp; maximum function had []  missing &amp; were not working  
  

_Created by_
- mjung
  
- ncarvalhais
  

</details>


== gppDiffRadiation_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppDiffRadiation_none' href='#Sindbad.Models.gppDiffRadiation_none'><span class="jlbinding">Sindbad.Models.gppDiffRadiation_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the cloudiness scalar [radiation diffusion] for gpp_potential to one

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_cloud`: effect of cloud on gpp. 1: no stress, 0: complete stress
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppDiffRadiation_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up 
  

_Created by_
- mjung
  
- ncarvalhais
  

</details>


:::


---


### gppDirRadiation {#gppDirRadiation}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppDirRadiation' href='#Sindbad.Models.gppDirRadiation'><span class="jlbinding">Sindbad.Models.gppDirRadiation</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Quantifies the effect of direct radiation on GPP: 1 indicates no direct radiation effect, while 0 indicates complete effect.
```



---


**Approaches**
- `gppDirRadiation_Maekelae2008`: light saturation scalar [light effect] on gpp_potential based on Maekelae2008
  
- `gppDirRadiation_none`: sets the light saturation scalar [light effect] on gpp_potential to one
  

</details>


:::details gppDirRadiation approaches

:::tabs

== gppDirRadiation_Maekelae2008
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppDirRadiation_Maekelae2008' href='#Sindbad.Models.gppDirRadiation_Maekelae2008'><span class="jlbinding">Sindbad.Models.gppDirRadiation_Maekelae2008</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



light saturation scalar [light effect] on gpp_potential based on Maekelae2008

**Parameters**
- **Fields**
  - `γ`: 0.04 ∈ [0.001, 0.1] =&gt; empirical light response parameter (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_PAR`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_PAR)` for information on how to add the variable to the catalog.
    
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  
- **Outputs**
  - `diagnostics.gpp_f_light`: effect of light on gpp. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppDirRadiation_Maekelae2008.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Mäkelä, A., Pulkkinen, M., Kolari, P., et al. (2008).  Developing an empirical model of stand GPP with the LUE approachanalysis of eddy covariance data at five contrasting conifer sites in Europe.  Global change biology, 14[1], 92-108.
  

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up 
  

_Created by_
- mjung
  
- ncarvalhais
  

_Notes_
- γ is between [0.007 0.05], median !0.04 [m2/mol] in Maekelae  et al 2008.
  

</details>


== gppDirRadiation_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppDirRadiation_none' href='#Sindbad.Models.gppDirRadiation_none'><span class="jlbinding">Sindbad.Models.gppDirRadiation_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the light saturation scalar [light effect] on gpp_potential to one

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_light`: effect of light on gpp. 1: no stress, 0: complete stress
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppDirRadiation_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up 
  

_Created by_
- mjung
  
- ncarvalhais
  

</details>


:::


---


### gppPotential {#gppPotential}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppPotential' href='#Sindbad.Models.gppPotential'><span class="jlbinding">Sindbad.Models.gppPotential</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Maximum instantaneous radiation use efficiency
```



---


**Approaches**
- `gppPotential_Monteith`: set the potential GPP based on radiation use efficiency
  

</details>


:::details gppPotential approaches

:::tabs

== gppPotential_Monteith
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppPotential_Monteith' href='#Sindbad.Models.gppPotential_Monteith'><span class="jlbinding">Sindbad.Models.gppPotential_Monteith</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



set the potential GPP based on radiation use efficiency

**Parameters**
- **Fields**
  - `εmax`: 2.0 ∈ [0.1, 5.0] =&gt; Maximum Radiation Use Efficiency (units: `gC/MJ` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_PAR`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_PAR)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.gpp_potential`: potential gross primary prorDcutivity
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppPotential_Monteith.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up
  

_Created by_
- mjung
  
- ncarvalhais
  

_Notes_
- no crontrols for fPAR | meteo factors
  
- set the potential GPP as maxRUE * f_PAR [gC/m2/dat]
  
- usually  GPP = e_max x f[clim] x FAPAR x f_PAR  here  GPP = GPPpot x f[clim] x FAPAR  GPPpot = e_max x f_PAR  f[clim] &amp; FAPAR are [maybe] calculated dynamically
  

</details>


:::


---


### gppSoilW {#gppSoilW}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppSoilW' href='#Sindbad.Models.gppSoilW'><span class="jlbinding">Sindbad.Models.gppSoilW</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Quantifies the effect of soil water on GPP: 1 indicates no soil water stress, while 0 indicates complete stress.
```



---


**Approaches**
- `gppSoilW_CASA`: soil moisture stress on gpp_potential based on base stress and relative ratio of PET and PAW (CASA)
  
- `gppSoilW_GSI`: soil moisture stress on gpp_potential based on GSI implementation of LPJ
  
- `gppSoilW_Keenan2009`: soil moisture stress on gpp_potential based on Keenan2009
  
- `gppSoilW_Stocker2020`: soil moisture stress on gpp_potential based on Stocker2020
  
- `gppSoilW_none`: sets the soil moisture stress on gpp_potential to one (no stress)
  

</details>


:::details gppSoilW approaches

:::tabs

== gppSoilW_CASA
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppSoilW_CASA' href='#Sindbad.Models.gppSoilW_CASA'><span class="jlbinding">Sindbad.Models.gppSoilW_CASA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



soil moisture stress on gpp_potential based on base stress and relative ratio of PET and PAW (CASA)

**Parameters**
- **Fields**
  - `base_f_soilW`: 0.2 ∈ [0, 1] =&gt; base water stress (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_soilW_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_soilW_prev)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `forcing.f_airT`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT)` for information on how to add the variable to the catalog.
    
  - `diagnostics.gpp_f_soilW_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_soilW_prev)` for information on how to add the variable to the catalog.
    
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  - `fluxes.PET`: potential evapotranspiration
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.OmBweOPET`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :OmBweOPET)` for information on how to add the variable to the catalog.
    
  - `diagnostics.gpp_f_soilW`: effect of soil moisture on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.gpp_f_soilW_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_soilW_prev)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppSoilW_CASA.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Forkel; M.; Carvalhais; N.; Schaphoff; S.; v. Bloh; W.; Migliavacca; M.  Thurner; M.; &amp; Thonicke; K.: Identifying environmental controls on  vegetation greenness phenology through model–data integration  Biogeosciences; 11; 7025–7050; https://doi.org/10.5194/bg-11-7025-2014;2014.
  

_Versions_
- 1.1 on 22.01.2021 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

_Notes_

</details>


== gppSoilW_GSI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppSoilW_GSI' href='#Sindbad.Models.gppSoilW_GSI'><span class="jlbinding">Sindbad.Models.gppSoilW_GSI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



soil moisture stress on gpp_potential based on GSI implementation of LPJ

**Parameters**
- **Fields**
  - `f_soilW_τ`: 0.8 ∈ [0.01, 1.0] =&gt; contribution factor for current stressor (units: `fraction` @ `all` timescales)
    
  - `f_soilW_slope`: 5.24 ∈ [1.0, 10.0] =&gt; slope of sigmoid (units: `fraction` @ `all` timescales)
    
  - `f_soilW_slope_mult`: 100.0 ∈ [-Inf, Inf] =&gt; multiplier for the slope of sigmoid (units: `fraction` @ `all` timescales)
    
  - `f_soilW_base`: 0.2096 ∈ [0.1, 0.8] =&gt; base of sigmoid (units: `fraction` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `diagnostics.gpp_f_soilW_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_soilW_prev)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `properties.∑w_awc`: total amount of water available for vegetation/transpiration
    
  - `properties.∑w_wp`: total amount of water in the soil at wiliting point
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `diagnostics.gpp_f_soilW_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_soilW_prev)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `diagnostics.gpp_f_soilW`: effect of soil moisture on gpp. 1: no stress, 0: complete stress
    
  - `diagnostics.gpp_f_soilW_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :gpp_f_soilW_prev)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppSoilW_GSI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Forkel; M.; Carvalhais; N.; Schaphoff; S.; v. Bloh; W.; Migliavacca; M.  Thurner; M.; &amp; Thonicke; K.: Identifying environmental controls on  vegetation greenness phenology through model–data integration  Biogeosciences; 11; 7025–7050; https://doi.org/10.5194/bg-11-7025-2014;2014.
  

_Versions_
- 1.1 on 22.01.2021 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

_Notes_

</details>


== gppSoilW_Keenan2009
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppSoilW_Keenan2009' href='#Sindbad.Models.gppSoilW_Keenan2009'><span class="jlbinding">Sindbad.Models.gppSoilW_Keenan2009</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



soil moisture stress on gpp_potential based on Keenan2009

**Parameters**
- **Fields**
  - `q`: 0.6 ∈ [0.0, 15.0] =&gt; sensitivity of GPP to soil moisture  (`unitless` @ `all` timescales)
    
  - `f_s_max`: 0.7 ∈ [0.2, 1.0] =&gt;  (`unitless` @ `all` timescales)
    
  - `f_s_min`: 0.5 ∈ [0.01, 0.95] =&gt;  (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `properties.∑w_sat`: total amount of water in the soil at saturation
    
  - `properties.∑w_wp`: total amount of water in the soil at wiliting point
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `diagnostics.gpp_f_soilW`: effect of soil moisture on gpp. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppSoilW_Keenan2009.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Keenan; T.; García; R.; Friend; A. D.; Zaehle; S.; Gracia  C.; &amp; Sabate; S.: Improved understanding of drought  controls on seasonal variation in Mediterranean forest  canopy CO2 &amp; water fluxes through combined in situ  measurements &amp; ecosystem modelling; Biogeosciences; 6; 1423–1444
  

_Versions_
- 1.0 on 10.03.2020 [sbesnard]  
  

_Created by_
- ncarvalhais &amp; sbesnard
  

_Notes_

</details>


== gppSoilW_Stocker2020
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppSoilW_Stocker2020' href='#Sindbad.Models.gppSoilW_Stocker2020'><span class="jlbinding">Sindbad.Models.gppSoilW_Stocker2020</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



soil moisture stress on gpp_potential based on Stocker2020

**Parameters**
- **Fields**
  - `q`: 1.0 ∈ [0.01, 4.0] =&gt; sensitivity of GPP to soil moisture  (`unitless` @ `all` timescales)
    
  - `θstar`: 0.6 ∈ [0.1, 1.0] =&gt;  (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `diagnostics.gpp_f_soilW`: effect of soil moisture on gpp. 1: no stress, 0: complete stress
    
  

`compute`:
- **Inputs**
  - `properties.∑w_fc`: total amount of water in the soil at field capacity
    
  - `properties.∑w_wp`: total amount of water in the soil at wiliting point
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  - `constants.t_two`: a type stable 2
    
  
- **Outputs**
  - `diagnostics.gpp_f_soilW`: effect of soil moisture on gpp. 1: no stress, 0: complete stress
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppSoilW_Stocker2020.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Stocker, B. D., Wang, H., Smith, N. G., Harrison, S. P., Keenan, T. F., Sandoval, D., &amp; Prentice, I. C. (2020). P-model v1. 0: an optimality-based light use efficiency model for simulating ecosystem gross primary production. Geoscientific Model Development, 13(3), 1545-1581.
  

_Versions_

_Created by_
- ncarvalhais &amp; Shanning Bao [sbao]
  

_Notes_

</details>


== gppSoilW_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppSoilW_none' href='#Sindbad.Models.gppSoilW_none'><span class="jlbinding">Sindbad.Models.gppSoilW_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the soil moisture stress on gpp_potential to one (no stress)

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_soilW`: effect of soil moisture on gpp. 1: no stress, 0: complete stress
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppSoilW_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up  
  

_Created by_
- ncarvalhais
  

</details>


:::


---


### gppVPD {#gppVPD}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppVPD' href='#Sindbad.Models.gppVPD'><span class="jlbinding">Sindbad.Models.gppVPD</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Quantifies the effect of vapor pressure deficit (VPD) on GPP: 1 indicates no VPD stress, while 0 indicates complete stress.
```



---


**Approaches**
- `gppVPD_MOD17`: VPD stress on gpp_potential based on MOD17 model
  
- `gppVPD_Maekelae2008`: calculate the VPD stress on gpp_potential based on Maekelae2008 [eqn 5]
  
- `gppVPD_PRELES`: VPD stress on gpp_potential based on Maekelae2008 and with co2 effect based on PRELES model
  
- `gppVPD_expco2`: VPD stress on gpp_potential based on Maekelae2008 and with co2 effect
  
- `gppVPD_none`: sets the VPD stress on gpp_potential to one (no stress)
  

</details>


:::details gppVPD approaches

:::tabs

== gppVPD_MOD17
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppVPD_MOD17' href='#Sindbad.Models.gppVPD_MOD17'><span class="jlbinding">Sindbad.Models.gppVPD_MOD17</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



VPD stress on gpp_potential based on MOD17 model

**Parameters**
- **Fields**
  - `VPD_max`: 4.0 ∈ [2.0, 8.0] =&gt; Max VPD with GPP &gt; 0 (units: `kPa` @ `all` timescales)
    
  - `VPD_min`: 0.65 ∈ [0.0, 1.0] =&gt; Min VPD with GPP &gt; 0 (units: `kPa` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_VPD_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_VPD_day)` for information on how to add the variable to the catalog.
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_vpd`: effect of vpd on gpp. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppVPD_MOD17.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- MOD17 User guide: https://lpdaac.usgs.gov/documents/495/MOD17_User_Guide_V6.pdf
  
- Running; S. W.; Nemani; R. R.; Heinsch; F. A.; Zhao; M.; Reeves; M.  &amp; Hashimoto, H. (2004). A continuous satellite-derived measure of  global terrestrial primary production. Bioscience, 54[6], 547-560.
  
- Zhao, M., Heinsch, F. A., Nemani, R. R., &amp; Running, S. W. (2005)  Improvements of the MODIS terrestrial gross &amp; net primary production  global data set. Remote sensing of Environment, 95[2], 164-176.
  

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up  
  

_Created by_
- ncarvalhais
  

_Notes_

</details>


== gppVPD_Maekelae2008
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppVPD_Maekelae2008' href='#Sindbad.Models.gppVPD_Maekelae2008'><span class="jlbinding">Sindbad.Models.gppVPD_Maekelae2008</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate the VPD stress on gpp_potential based on Maekelae2008 [eqn 5]

**Parameters**
- **Fields**
  - `k`: 0.4 ∈ [0.06, 0.7] =&gt; empirical parameter assuming typically negative values (units: `kPa-1` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_VPD_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_VPD_day)` for information on how to add the variable to the catalog.
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_vpd`: effect of vpd on gpp. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppVPD_Maekelae2008.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_

_Created by_
- ncarvalhais
  

_Notes_
- Equation 5. a negative exponent is introduced to have positive parameter  values
  

</details>


== gppVPD_PRELES
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppVPD_PRELES' href='#Sindbad.Models.gppVPD_PRELES'><span class="jlbinding">Sindbad.Models.gppVPD_PRELES</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



VPD stress on gpp_potential based on Maekelae2008 and with co2 effect based on PRELES model

**Parameters**
- **Fields**
  - `κ`: 0.4 ∈ [0.06, 0.7] =&gt;  (units: `kPa-1` @ `all` timescales)
    
  - `c_κ`: 0.4 ∈ [-50.0, 10.0] =&gt;  (`unitless` @ `all` timescales)
    
  - `base_ambient_CO2`: 295.0 ∈ [250.0, 500.0] =&gt;  (units: `ppm` @ `all` timescales)
    
  - `sat_ambient_CO2`: 2000.0 ∈ [400.0, 4000.0] =&gt;  (units: `ppm` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_VPD_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_VPD_day)` for information on how to add the variable to the catalog.
    
  - `states.ambient_CO2`: ambient co2 concentration
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_vpd`: effect of vpd on gpp. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppVPD_PRELES.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Mäkelä, A., Pulkkinen, M., Kolari, P., et al. (2008).  Developing an empirical model of stand GPP with the LUE approachanalysis of eddy covariance data at five contrasting conifer sites in  Europe. Global change biology, 14[1], 92-108.
  
- http://www.metla.fi/julkaisut/workingpapers/2012/mwp247.pdf
  

_Versions_
- 1.1 on 22.11.2020 [skoirala | @dr-ko]: changing units to kpa for vpd &amp; sign of  κ to match with Maekaelae2008  
  

_Created by_
- ncarvalhais
  

_Notes_
- sign of exponent is changed to have κ parameter as positive values
  

</details>


== gppVPD_expco2
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppVPD_expco2' href='#Sindbad.Models.gppVPD_expco2'><span class="jlbinding">Sindbad.Models.gppVPD_expco2</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



VPD stress on gpp_potential based on Maekelae2008 and with co2 effect

**Parameters**
- **Fields**
  - `κ`: 0.4 ∈ [0.06, 0.7] =&gt;  (units: `kPa-1` @ `all` timescales)
    
  - `c_κ`: 0.4 ∈ [-50.0, 10.0] =&gt; exponent of co2 modulation of vpd effect (`unitless` @ `all` timescales)
    
  - `base_ambient_CO2`: 380.0 ∈ [300.0, 500.0] =&gt;  (units: `ppm` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_VPD_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_VPD_day)` for information on how to add the variable to the catalog.
    
  - `states.ambient_CO2`: ambient co2 concentration
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_vpd`: effect of vpd on gpp. 1: no stress, 0: complete stress
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppVPD_expco2.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Mäkelä, A., Pulkkinen, M., Kolari, P., et al. (2008).  Developing an empirical model of stand GPP with the LUE approachanalysis of eddy covariance data at five contrasting conifer sites in  Europe. Global change biology, 14[1], 92-108.
  
- http://www.metla.fi/julkaisut/workingpapers/2012/mwp247.pdf
  

_Versions_
- 1.1 on 22.11.2020 [skoirala | @dr-ko]: changing units to kpa for vpd &amp; sign of  κ to match with Maekaelae2008  
  

_Created by_
- ncarvalhais
  

_Notes_
- sign of exponent is changed to have κ parameter as positive values
  

</details>


== gppVPD_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.gppVPD_none' href='#Sindbad.Models.gppVPD_none'><span class="jlbinding">Sindbad.Models.gppVPD_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the VPD stress on gpp_potential to one (no stress)

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `diagnostics.gpp_f_vpd`: effect of vpd on gpp. 1: no stress, 0: complete stress
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `gppVPD_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: documentation &amp; clean up  
  

_Created by_
- ncarvalhais
  

</details>


:::


---


### groundWRecharge {#groundWRecharge}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.groundWRecharge' href='#Sindbad.Models.groundWRecharge'><span class="jlbinding">Sindbad.Models.groundWRecharge</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Recharge to the groundwater storage
```



---


**Approaches**
- `groundWRecharge_dos`: GW recharge as a exponential functions of the degree of saturation of the lowermost soil layer
  
- `groundWRecharge_fraction`: GW recharge as a fraction of moisture of the lowermost soil layer
  
- `groundWRecharge_kUnsat`: GW recharge as the unsaturated hydraulic conductivity of the lowermost soil layer
  
- `groundWRecharge_none`: sets the GW recharge to zero
  

</details>


:::details groundWRecharge approaches

:::tabs

== groundWRecharge_dos
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.groundWRecharge_dos' href='#Sindbad.Models.groundWRecharge_dos'><span class="jlbinding">Sindbad.Models.groundWRecharge_dos</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



GW recharge as a exponential functions of the degree of saturation of the lowermost soil layer

**Parameters**
- **Fields**
  - `dos_exp`: 1.5 ∈ [1.0, 3.0] =&gt; exponent of non-linearity for dos influence on drainage to groundwater (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.gw_recharge`: net groundwater recharge from the lowermost soil layer, positive =&gt; soil to groundwater
    
  

`compute`:
- **Inputs**
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.soil_β`: beta parameter of soil per layer
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  - `pools.groundW`: water storage in groundW pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.gw_recharge`: net groundwater recharge from the lowermost soil layer, positive =&gt; soil to groundwater
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `groundWRecharge_dos.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: clean up  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== groundWRecharge_fraction
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.groundWRecharge_fraction' href='#Sindbad.Models.groundWRecharge_fraction'><span class="jlbinding">Sindbad.Models.groundWRecharge_fraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



GW recharge as a fraction of moisture of the lowermost soil layer

**Parameters**
- **Fields**
  - `rf`: 0.1 ∈ [0.02, 0.98] =&gt; fraction of land runoff that percolates to groundwater (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  - `pools.groundW`: water storage in groundW pool(s)
    
  
- **Outputs**
  - `fluxes.gw_recharge`: net groundwater recharge from the lowermost soil layer, positive =&gt; soil to groundwater
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `groundWRecharge_fraction.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: clean up  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== groundWRecharge_kUnsat
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.groundWRecharge_kUnsat' href='#Sindbad.Models.groundWRecharge_kUnsat'><span class="jlbinding">Sindbad.Models.groundWRecharge_kUnsat</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



GW recharge as the unsaturated hydraulic conductivity of the lowermost soil layer

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `models.unsat_k_model`: name of the model used to calculate unsaturated hydraulic conductivity
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  - `pools.groundW`: water storage in groundW pool(s)
    
  
- **Outputs**
  - `fluxes.gw_recharge`: net groundwater recharge from the lowermost soil layer, positive =&gt; soil to groundwater
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `groundWRecharge_kUnsat.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: clean up  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== groundWRecharge_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.groundWRecharge_none' href='#Sindbad.Models.groundWRecharge_none'><span class="jlbinding">Sindbad.Models.groundWRecharge_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the GW recharge to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.gw_recharge`: net groundwater recharge from the lowermost soil layer, positive =&gt; soil to groundwater
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `groundWRecharge_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### groundWSoilWInteraction {#groundWSoilWInteraction}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.groundWSoilWInteraction' href='#Sindbad.Models.groundWSoilWInteraction'><span class="jlbinding">Sindbad.Models.groundWSoilWInteraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Groundwater soil moisture interactions (e.g. capilary flux, water
```



---


**Approaches**
- `groundWSoilWInteraction_VanDijk2010`: calculates the upward flow of water from groundwater to lowermost soil layer using VanDijk method
  
- `groundWSoilWInteraction_gradient`: calculates a buffer storage that gives water to the soil when the soil dries up; while the soil gives water to the buffer when the soil is wet but the buffer low
  
- `groundWSoilWInteraction_gradientNeg`: calculates a buffer storage that doesn&#39;t give water to the soil when the soil dries up; while the soil gives water to the groundW when the soil is wet but the groundW low; the groundW is only recharged by soil moisture
  
- `groundWSoilWInteraction_none`: sets the groundwater capillary flux to zero
  

</details>


:::details groundWSoilWInteraction approaches

:::tabs

== groundWSoilWInteraction_VanDijk2010
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.groundWSoilWInteraction_VanDijk2010' href='#Sindbad.Models.groundWSoilWInteraction_VanDijk2010'><span class="jlbinding">Sindbad.Models.groundWSoilWInteraction_VanDijk2010</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the upward flow of water from groundwater to lowermost soil layer using VanDijk method

**Parameters**
- **Fields**
  - `max_fraction`: 0.5 ∈ [0.001, 0.98] =&gt; fraction of groundwater that can be lost to capillary flux (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `fluxes.gw_recharge`: net groundwater recharge from the lowermost soil layer, positive =&gt; soil to groundwater
    
  

`compute`:
- **Inputs**
  - `properties.k_fc`: hydraulic conductivity of soil at field capacity per layer
    
  - `properties.k_sat`: hydraulic conductivity of soil at saturation per layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  - `pools.groundW`: water storage in groundW pool(s)
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `models.unsat_k_model`: name of the model used to calculate unsaturated hydraulic conductivity
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  - `fluxes.gw_recharge`: net groundwater recharge from the lowermost soil layer, positive =&gt; soil to groundwater
    
  
- **Outputs**
  - `fluxes.gw_capillary_flux`: capillary flux from top groundwater layer to the lowermost soil layer
    
  - `fluxes.gw_recharge`: net groundwater recharge from the lowermost soil layer, positive =&gt; soil to groundwater
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `groundWSoilWInteraction_VanDijk2010.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- AIJM Van Dijk, 2010, The Australian Water Resources Assessment System Technical Report 3. Landscape Model [version 0.5] Technical Description
  
- http://www.clw.csiro.au/publications/waterforahealthycountry/2010/wfhc-aus-water-resources-assessment-system.pdf
  

_Versions_
- 1.0 on 18.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


== groundWSoilWInteraction_gradient
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.groundWSoilWInteraction_gradient' href='#Sindbad.Models.groundWSoilWInteraction_gradient'><span class="jlbinding">Sindbad.Models.groundWSoilWInteraction_gradient</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates a buffer storage that gives water to the soil when the soil dries up; while the soil gives water to the buffer when the soil is wet but the buffer low

**Parameters**
- **Fields**
  - `smax_scale`: 0.5 ∈ [0.0, 50.0] =&gt; scale param to yield storage capacity of wGW (`unitless` @ `all` timescales)
    
  - `max_flux`: 10.0 ∈ [0.0, 20.0] =&gt; maximum flux between wGW and wSoil (units: `[mm d]` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.gw_recharge`: net groundwater recharge from the lowermost soil layer, positive =&gt; soil to groundwater
    
  

`compute`:
- **Inputs**
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  - `pools.groundW`: water storage in groundW pool(s)
    
  - `constants.n_groundW`: total number of layers in groundwater pool
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `fluxes.gw_recharge`: net groundwater recharge from the lowermost soil layer, positive =&gt; soil to groundwater
    
  
- **Outputs**
  - `fluxes.gw_capillary_flux`: capillary flux from top groundwater layer to the lowermost soil layer
    
  - `fluxes.gw_recharge`: net groundwater recharge from the lowermost soil layer, positive =&gt; soil to groundwater
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `groundWSoilWInteraction_gradient.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 04.02.2020 [ttraut]
  

_Created by_
- ttraut
  

</details>


== groundWSoilWInteraction_gradientNeg
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.groundWSoilWInteraction_gradientNeg' href='#Sindbad.Models.groundWSoilWInteraction_gradientNeg'><span class="jlbinding">Sindbad.Models.groundWSoilWInteraction_gradientNeg</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates a buffer storage that doesn&#39;t give water to the soil when the soil dries up; while the soil gives water to the groundW when the soil is wet but the groundW low; the groundW is only recharged by soil moisture

**Parameters**
- **Fields**
  - `smax_scale`: 0.5 ∈ [0.0, 50.0] =&gt; scale param to yield storage capacity of wGW (`unitless` @ `all` timescales)
    
  - `max_flux`: 10.0 ∈ [0.0, 20.0] =&gt; maximum flux between wGW and wSoil (units: `[mm d]` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.gw_recharge`: net groundwater recharge from the lowermost soil layer, positive =&gt; soil to groundwater
    
  

`compute`:
- **Inputs**
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  - `pools.groundW`: water storage in groundW pool(s)
    
  - `constants.n_groundW`: total number of layers in groundwater pool
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `fluxes.gw_recharge`: net groundwater recharge from the lowermost soil layer, positive =&gt; soil to groundwater
    
  
- **Outputs**
  - `fluxes.gw_capillary_flux`: capillary flux from top groundwater layer to the lowermost soil layer
    
  - `fluxes.gw_recharge`: net groundwater recharge from the lowermost soil layer, positive =&gt; soil to groundwater
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `groundWSoilWInteraction_gradientNeg.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 04.02.2020 [ttraut]
  
- 1.0 on 23.09.2020 [ttraut]
  

_Created by_
- ttraut
  

</details>


== groundWSoilWInteraction_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.groundWSoilWInteraction_none' href='#Sindbad.Models.groundWSoilWInteraction_none'><span class="jlbinding">Sindbad.Models.groundWSoilWInteraction_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the groundwater capillary flux to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.gw_capillary_flux`: capillary flux from top groundwater layer to the lowermost soil layer
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `groundWSoilWInteraction_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### groundWSurfaceWInteraction {#groundWSurfaceWInteraction}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.groundWSurfaceWInteraction' href='#Sindbad.Models.groundWSurfaceWInteraction'><span class="jlbinding">Sindbad.Models.groundWSurfaceWInteraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Water exchange between surface and groundwater
```



---


**Approaches**
- `groundWSurfaceWInteraction_fracGradient`: calculates the moisture exchange between groundwater &amp; surface water as a fraction of difference between the storages
  
- `groundWSurfaceWInteraction_fracGroundW`: calculates the depletion of groundwater to the surface water as a fraction of groundwater storage
  

</details>


:::details groundWSurfaceWInteraction approaches

:::tabs

== groundWSurfaceWInteraction_fracGradient
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.groundWSurfaceWInteraction_fracGradient' href='#Sindbad.Models.groundWSurfaceWInteraction_fracGradient'><span class="jlbinding">Sindbad.Models.groundWSurfaceWInteraction_fracGradient</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the moisture exchange between groundwater &amp; surface water as a fraction of difference between the storages

**Parameters**
- **Fields**
  - `k_gw_to_suw`: 0.001 ∈ [0.0001, 0.01] =&gt; maximum transfer rate between GW and surface water (units: `/d` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.ΔsurfaceW`: change in water storage in surfaceW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  - `pools.groundW`: water storage in groundW pool(s)
    
  - `pools.surfaceW`: water storage in surfaceW pool(s)
    
  - `constants.n_surfaceW`: total number of layers in surface water pool
    
  - `constants.n_groundW`: total number of layers in groundwater pool
    
  
- **Outputs**
  - `fluxes.gw_to_suw_flux`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :gw_to_suw_flux)` for information on how to add the variable to the catalog.
    
  - `pools.ΔsurfaceW`: change in water storage in surfaceW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `groundWSurfaceWInteraction_fracGradient.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


== groundWSurfaceWInteraction_fracGroundW
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.groundWSurfaceWInteraction_fracGroundW' href='#Sindbad.Models.groundWSurfaceWInteraction_fracGroundW'><span class="jlbinding">Sindbad.Models.groundWSurfaceWInteraction_fracGroundW</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the depletion of groundwater to the surface water as a fraction of groundwater storage

**Parameters**
- **Fields**
  - `k_gw_to_suw`: 0.5 ∈ [0.0001, 0.999] =&gt; scale parameter for drainage from wGW to wSurf (units: `fraction` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.groundW`: water storage in groundW pool(s)
    
  - `pools.surfaceW`: water storage in surfaceW pool(s)
    
  - `pools.ΔsurfaceW`: change in water storage in surfaceW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  - `constants.n_surfaceW`: total number of layers in surface water pool
    
  - `constants.n_groundW`: total number of layers in groundwater pool
    
  
- **Outputs**
  - `fluxes.gw_to_suw_flux`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :gw_to_suw_flux)` for information on how to add the variable to the catalog.
    
  - `pools.ΔsurfaceW`: change in water storage in surfaceW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `groundWSurfaceWInteraction_fracGroundW.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 04.02.2020 [ttraut]
  

_Created by_
- ttraut
  

</details>


:::


---


### interception {#interception}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.interception' href='#Sindbad.Models.interception'><span class="jlbinding">Sindbad.Models.interception</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Interception evaporation
```



---


**Approaches**
- `interception_Miralles2010`: computes canopy interception evaporation according to the Gash model
  
- `interception_fAPAR`: computes canopy interception evaporation as a fraction of fAPAR
  
- `interception_none`: sets the interception evaporation to zero
  
- `interception_vegFraction`: computes canopy interception evaporation as a fraction of vegetation cover
  

</details>


:::details interception approaches

:::tabs

== interception_Miralles2010
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.interception_Miralles2010' href='#Sindbad.Models.interception_Miralles2010'><span class="jlbinding">Sindbad.Models.interception_Miralles2010</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



computes canopy interception evaporation according to the Gash model

**Parameters**
- **Fields**
  - `canopy_storage`: 1.2 ∈ [0.4, 2.0] =&gt; Canopy storage (units: `mm` @ `all` timescales)
    
  - `fte`: 0.02 ∈ [0.02, 0.02] =&gt; fraction of trunk evaporation (`unitless` @ `all` timescales)
    
  - `evap_rate`: 0.3 ∈ [0.1, 0.5] =&gt; mean evaporation rate (units: `mm/hr` @ `all` timescales)
    
  - `trunk_capacity`: 0.02 ∈ [0.02, 0.02] =&gt; trunk capacity (units: `mm` @ `all` timescales)
    
  - `pd`: 0.02 ∈ [0.02, 0.02] =&gt; fraction rain to trunks (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  - `fluxes.rain`: amount of precipitation in liquid form
    
  - `states.rainInt`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :rainInt)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `fluxes.interception`: interception evaporation loss
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `interception_Miralles2010.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Miralles, D. G., Gash, J. H., Holmes, T. R., de Jeu, R. A., &amp; Dolman, A. J. (2010).  Global canopy interception from satellite observations. Journal of Geophysical ResearchAtmospheres, 115[D16].
  

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code
  
- 1.1 on 22.11.2019 [skoirala | @dr-ko]: handle land.states.fAPAR, rainfall intensity &amp; rainfall  
  

_Created by_
- mjung
  

_Notes_

</details>


== interception_fAPAR
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.interception_fAPAR' href='#Sindbad.Models.interception_fAPAR'><span class="jlbinding">Sindbad.Models.interception_fAPAR</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



computes canopy interception evaporation as a fraction of fAPAR

**Parameters**
- **Fields**
  - `isp`: 1.0 ∈ [0.1, 5.0] =&gt; fapar dependent storage (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  - `fluxes.rain`: amount of precipitation in liquid form
    
  
- **Outputs**
  - `fluxes.interception`: interception evaporation loss
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `interception_fAPAR.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code
  
- 1.1 on 29.11.2019 [skoirala | @dr-ko]: land.states.fAPAR  
  

_Created by_
- mjung
  

</details>


== interception_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.interception_none' href='#Sindbad.Models.interception_none'><span class="jlbinding">Sindbad.Models.interception_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the interception evaporation to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.interception`: interception evaporation loss
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `interception_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


== interception_vegFraction
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.interception_vegFraction' href='#Sindbad.Models.interception_vegFraction'><span class="jlbinding">Sindbad.Models.interception_vegFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



computes canopy interception evaporation as a fraction of vegetation cover

**Parameters**
- **Fields**
  - `p_interception`: 1.0 ∈ [0.0001, 5.0] =&gt; maximum interception storage (units: `mm` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  - `fluxes.rain`: amount of precipitation in liquid form
    
  
- **Outputs**
  - `fluxes.interception`: interception evaporation loss
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `interception_vegFraction.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code
  
- 1.1 on 27.11.2019 [skoiralal]: moved contents from prec, handling of frac_vegetation from s.cd  
  

_Created by_
- ttraut
  

</details>


:::


---


### percolation {#percolation}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.percolation' href='#Sindbad.Models.percolation'><span class="jlbinding">Sindbad.Models.percolation</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Calculate the soil percolation = wbp at this point
```



---


**Approaches**
- `percolation_WBP`: computes the percolation into the soil after the surface runoff process
  

</details>


:::details percolation approaches

:::tabs

== percolation_WBP
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.percolation_WBP' href='#Sindbad.Models.percolation_WBP'><span class="jlbinding">Sindbad.Models.percolation_WBP</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



computes the percolation into the soil after the surface runoff process

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.groundW`: water storage in groundW pool(s)
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  
- **Outputs**
  - `fluxes.percolation`: amount of moisture percolating to the top soil layer
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `percolation_WBP.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### plantForm {#plantForm}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.plantForm' href='#Sindbad.Models.plantForm'><span class="jlbinding">Sindbad.Models.plantForm</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
define the plant form of the ecosystem
```



---


**Approaches**
- `plantForm_PFT`: get the plant form based on PFT
  
- `plantForm_fixed`: use a fixed plant form with 1: tree, 2: shrub, 3:herb
  

</details>


:::details plantForm approaches

:::tabs

== plantForm_PFT
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.plantForm_PFT' href='#Sindbad.Models.plantForm_PFT'><span class="jlbinding">Sindbad.Models.plantForm_PFT</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



get the plant form based on PFT

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `plantForm.plant_form_pft`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:plantForm, :plant_form_pft)` for information on how to add the variable to the catalog.
    
  - `plantForm.defined_forms_pft`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:plantForm, :defined_forms_pft)` for information on how to add the variable to the catalog.
    
  

`precompute`:
- **Inputs**
  - `forcing.f_pft`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_pft)` for information on how to add the variable to the catalog.
    
  - `plantForm.plant_form_pft`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:plantForm, :plant_form_pft)` for information on how to add the variable to the catalog.
    
  - `plantForm.defined_forms_pft`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:plantForm, :defined_forms_pft)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.plant_form`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :plant_form)` for information on how to add the variable to the catalog.
    
  

`compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `plantForm_PFT.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 24.04.2025 [skoirala]
  

_Created by_
- skoirala
  

</details>


== plantForm_fixed
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.plantForm_fixed' href='#Sindbad.Models.plantForm_fixed'><span class="jlbinding">Sindbad.Models.plantForm_fixed</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



use a fixed plant form with 1: tree, 2: shrub, 3:herb

**Parameters**
- **Fields**
  - `P1`: Inf ∈ [-Inf, Inf] =&gt; parameter 1 (units: `parameter 1 unit` @ `parameter 1 timescale` timescale)
    
  

**Methods:**

`define, precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `plantForm_fixed.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 24.04.2025 [skoirala]
  

_Created by_
- skoirala
  

</details>


:::


---


### rainIntensity {#rainIntensity}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rainIntensity' href='#Sindbad.Models.rainIntensity'><span class="jlbinding">Sindbad.Models.rainIntensity</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Set rainfall intensity
```



---


**Approaches**
- `rainIntensity_forcing`: stores the time series of rainfall &amp; snowfall from forcing
  
- `rainIntensity_simple`: stores the time series of rainfall intensity
  

</details>


:::details rainIntensity approaches

:::tabs

== rainIntensity_forcing
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rainIntensity_forcing' href='#Sindbad.Models.rainIntensity_forcing'><span class="jlbinding">Sindbad.Models.rainIntensity_forcing</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



stores the time series of rainfall &amp; snowfall from forcing

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_rain_int`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rain_int)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.rain_int`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :rain_int)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `rainIntensity_forcing.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: creation of approach  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== rainIntensity_simple
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rainIntensity_simple' href='#Sindbad.Models.rainIntensity_simple'><span class="jlbinding">Sindbad.Models.rainIntensity_simple</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



stores the time series of rainfall intensity

**Parameters**
- **Fields**
  - `rain_init_factor`: 0.04167 ∈ [0.0, 1.0] =&gt; factor to convert daily rainfall to rainfall intensity (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_rain`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rain)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.rain_int`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :rain_int)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `rainIntensity_simple.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: creation of approach  
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### rainSnow {#rainSnow}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rainSnow' href='#Sindbad.Models.rainSnow'><span class="jlbinding">Sindbad.Models.rainSnow</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Set/get rain and snow
```



---


**Approaches**
- `rainSnow_Tair`: separates the rain &amp; snow based on temperature threshold
  
- `rainSnow_forcing`: stores the time series of rainfall and snowfall from forcing &amp; scale snowfall if snowfall_scalar parameter is optimized
  
- `rainSnow_rain`: set all precip to rain
  

</details>


:::details rainSnow approaches

:::tabs

== rainSnow_Tair
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rainSnow_Tair' href='#Sindbad.Models.rainSnow_Tair'><span class="jlbinding">Sindbad.Models.rainSnow_Tair</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



separates the rain &amp; snow based on temperature threshold

**Parameters**
- **Fields**
  - `airT_thres`: 0.0 ∈ [-5.0, 5.0] =&gt; threshold for separating rain and snow (units: `°C` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_rain`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rain)` for information on how to add the variable to the catalog.
    
  - `forcing.f_airT`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT)` for information on how to add the variable to the catalog.
    
  - `pools.snowW`: water storage in snowW pool(s)
    
  - `pools.ΔsnowW`: change in water storage in snowW pool(s)
    
  
- **Outputs**
  - `fluxes.precip`: total land precipitation including snow and rain
    
  - `fluxes.rain`: amount of precipitation in liquid form
    
  - `fluxes.snow`: amount of precipitation in solid form
    
  - `pools.ΔsnowW`: change in water storage in snowW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `rainSnow_Tair.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: creation of approach  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== rainSnow_forcing
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rainSnow_forcing' href='#Sindbad.Models.rainSnow_forcing'><span class="jlbinding">Sindbad.Models.rainSnow_forcing</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



stores the time series of rainfall and snowfall from forcing &amp; scale snowfall if snowfall_scalar parameter is optimized

**Parameters**
- **Fields**
  - `snowfall_scalar`: 1.0 ∈ [0.0, 3.0] =&gt; scaling factor for snow fall (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_rain`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rain)` for information on how to add the variable to the catalog.
    
  - `forcing.f_snow`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_snow)` for information on how to add the variable to the catalog.
    
  - `pools.snowW`: water storage in snowW pool(s)
    
  - `pools.ΔsnowW`: change in water storage in snowW pool(s)
    
  
- **Outputs**
  - `fluxes.precip`: total land precipitation including snow and rain
    
  - `fluxes.rain`: amount of precipitation in liquid form
    
  - `fluxes.snow`: amount of precipitation in solid form
    
  - `pools.ΔsnowW`: change in water storage in snowW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `rainSnow_forcing.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: creation of approach  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== rainSnow_rain
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rainSnow_rain' href='#Sindbad.Models.rainSnow_rain'><span class="jlbinding">Sindbad.Models.rainSnow_rain</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



set all precip to rain

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `forcing.f_rain`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rain)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `fluxes.precip`: total land precipitation including snow and rain
    
  - `fluxes.rain`: amount of precipitation in liquid form
    
  - `fluxes.snow`: amount of precipitation in solid form
    
  

`compute`:
- **Inputs**
  - `forcing.f_rain`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rain)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `fluxes.precip`: total land precipitation including snow and rain
    
  - `fluxes.rain`: amount of precipitation in liquid form
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `rainSnow_rain.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: creation of approach  
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### rootMaximumDepth {#rootMaximumDepth}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rootMaximumDepth' href='#Sindbad.Models.rootMaximumDepth'><span class="jlbinding">Sindbad.Models.rootMaximumDepth</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Maximum rooting depth
```



---


**Approaches**
- `rootMaximumDepth_fracSoilD`: sets the maximum rooting depth as a fraction of total soil depth. rootMaximumDepth_fracSoilD
  

</details>


:::details rootMaximumDepth approaches

:::tabs

== rootMaximumDepth_fracSoilD
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rootMaximumDepth_fracSoilD' href='#Sindbad.Models.rootMaximumDepth_fracSoilD'><span class="jlbinding">Sindbad.Models.rootMaximumDepth_fracSoilD</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the maximum rooting depth as a fraction of total soil depth. rootMaximumDepth_fracSoilD

**Parameters**
- **Fields**
  - `constant_frac_max_root_depth`: 0.5 ∈ [0.1, 0.8] =&gt; root depth as a fraction of soil depth (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `properties.soil_layer_thickness`: thickness of each soil layer
    
  
- **Outputs**
  - `properties.∑soil_depth`: total depth of soil
    
  

`precompute`:
- **Inputs**
  - `properties.∑soil_depth`: total depth of soil
    
  
- **Outputs**
  - `diagnostics.max_root_depth`: maximum depth of root
    
  

`compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `rootMaximumDepth_fracSoilD.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 21.11.2019  
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### rootWaterEfficiency {#rootWaterEfficiency}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rootWaterEfficiency' href='#Sindbad.Models.rootWaterEfficiency'><span class="jlbinding">Sindbad.Models.rootWaterEfficiency</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Distribution of water uptake fraction/efficiency by root per soil layer
```



---


**Approaches**
- `rootWaterEfficiency_constant`: sets the maximum fraction of water that root can uptake from soil layers as constant
  
- `rootWaterEfficiency_expCvegRoot`: maximum root water fraction that plants can uptake from soil layers according to total carbon in root [cVegRoot]. sets the maximum fraction of water that root can uptake from soil layers according to total carbon in root [cVegRoot]
  
- `rootWaterEfficiency_k2Layer`: sets the maximum fraction of water that root can uptake from soil layers as calibration parameter; hard coded for 2 soil layers
  
- `rootWaterEfficiency_k2fRD`: sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction; &amp; for the second soil layer additional as function of RD
  
- `rootWaterEfficiency_k2fvegFraction`: sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction
  

</details>


:::details rootWaterEfficiency approaches

:::tabs

== rootWaterEfficiency_constant
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rootWaterEfficiency_constant' href='#Sindbad.Models.rootWaterEfficiency_constant'><span class="jlbinding">Sindbad.Models.rootWaterEfficiency_constant</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the maximum fraction of water that root can uptake from soil layers as constant

**Parameters**
- **Fields**
  - `constant_root_water_efficiency`: 0.99 ∈ [0.001, 0.999] =&gt; root fraction (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `properties.soil_layer_thickness`: thickness of each soil layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  - `properties.cumulative_soil_depths`: the depth to the bottom of each soil layer
    
  

`precompute`:
- **Inputs**
  - `properties.cumulative_soil_depths`: the depth to the bottom of each soil layer
    
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `diagnostics.max_root_depth`: maximum depth of root
    
  
- **Outputs**
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  

`compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `rootWaterEfficiency_constant.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 21.11.2019  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== rootWaterEfficiency_expCvegRoot
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rootWaterEfficiency_expCvegRoot' href='#Sindbad.Models.rootWaterEfficiency_expCvegRoot'><span class="jlbinding">Sindbad.Models.rootWaterEfficiency_expCvegRoot</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



maximum root water fraction that plants can uptake from soil layers according to total carbon in root [cVegRoot]. sets the maximum fraction of water that root can uptake from soil layers according to total carbon in root [cVegRoot]

**Parameters**
- **Fields**
  - `k_efficiency_cVegRoot`: 0.02 ∈ [0.001, 0.3] =&gt; rate constant of exponential relationship (units: `m2/gC` @ `all` timescales)
    
  - `max_root_water_efficiency`: 0.95 ∈ [0.7, 0.98] =&gt; maximum root water uptake capacity (`unitless` @ `all` timescales)
    
  - `min_root_water_efficiency`: 0.1 ∈ [0.05, 0.3] =&gt; minimum root water uptake threshold (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `properties.soil_layer_thickness`: thickness of each soil layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `rootWaterEfficiency.root_over`: a boolean indicating if the root is allowed to exract water from a given layer depending on maximum rooting depth
    
  - `properties.cumulative_soil_depths`: the depth to the bottom of each soil layer
    
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  

`precompute`:
- **Inputs**
  - `rootWaterEfficiency.root_over`: a boolean indicating if the root is allowed to exract water from a given layer depending on maximum rooting depth
    
  - `properties.cumulative_soil_depths`: the depth to the bottom of each soil layer
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `diagnostics.max_root_depth`: maximum depth of root
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `rootWaterEfficiency.root_over`: a boolean indicating if the root is allowed to exract water from a given layer depending on maximum rooting depth
    
  

`compute`:
- **Inputs**
  - `rootWaterEfficiency.root_over`: a boolean indicating if the root is allowed to exract water from a given layer depending on maximum rooting depth
    
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  - `pools.cVegRoot`: carbon content of cVegRoot pool(s)
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  

`update` methods are not defined

_End of `getModelDocString`-generated docstring for `rootWaterEfficiency_expCvegRoot.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 28.04.2020  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== rootWaterEfficiency_k2Layer
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rootWaterEfficiency_k2Layer' href='#Sindbad.Models.rootWaterEfficiency_k2Layer'><span class="jlbinding">Sindbad.Models.rootWaterEfficiency_k2Layer</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the maximum fraction of water that root can uptake from soil layers as calibration parameter; hard coded for 2 soil layers

**Parameters**
- **Fields**
  - `k2`: 0.02 ∈ [0.001, 0.2] =&gt; fraction of 2nd soil layer available for transpiration (`unitless` @ `all` timescales)
    
  - `k1`: 0.5 ∈ [0.01, 0.99] =&gt; fraction of 1st soil layer available for transpiration (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  

`compute`:
- **Inputs**
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  
- **Outputs**
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `rootWaterEfficiency_k2Layer.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 09.01.2020  
  

_Created by_
- ttraut
  

</details>


== rootWaterEfficiency_k2fRD
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rootWaterEfficiency_k2fRD' href='#Sindbad.Models.rootWaterEfficiency_k2fRD'><span class="jlbinding">Sindbad.Models.rootWaterEfficiency_k2fRD</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction; &amp; for the second soil layer additional as function of RD

**Parameters**
- **Fields**
  - `k2_scale`: 0.02 ∈ [0.001, 0.2] =&gt; scales vegFrac to define fraction of 2nd soil layer available for transpiration (`unitless` @ `all` timescales)
    
  - `k1_scale`: 0.5 ∈ [0.01, 0.99] =&gt; scales vegFrac to fraction of 1st soil layer available for transpiration (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  

`compute`:
- **Inputs**
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  
- **Outputs**
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `rootWaterEfficiency_k2fRD.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 10.02.2020  
  

_Created by_
- ttraut
  

</details>


== rootWaterEfficiency_k2fvegFraction
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rootWaterEfficiency_k2fvegFraction' href='#Sindbad.Models.rootWaterEfficiency_k2fvegFraction'><span class="jlbinding">Sindbad.Models.rootWaterEfficiency_k2fvegFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction

**Parameters**
- **Fields**
  - `k2_scale`: 0.02 ∈ [0.001, 10.0] =&gt; scales vegFrac to define fraction of 2nd soil layer available for transpiration (`unitless` @ `all` timescales)
    
  - `k1_scale`: 0.5 ∈ [0.001, 10.0] =&gt; scales vegFrac to fraction of 1st soil layer available for transpiration (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  

`compute`:
- **Inputs**
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  
- **Outputs**
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `rootWaterEfficiency_k2fvegFraction.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 10.02.2020  
  

_Created by_
- ttraut
  

</details>


:::


---


### rootWaterUptake {#rootWaterUptake}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rootWaterUptake' href='#Sindbad.Models.rootWaterUptake'><span class="jlbinding">Sindbad.Models.rootWaterUptake</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Root water uptake (extract water from soil)
```



---


**Approaches**
- `rootWaterUptake_proportion`: rootUptake from each soil layer proportional to the relative plant water availability in the layer
  
- `rootWaterUptake_topBottom`: rootUptake from each of the soil layer from top to bottom using all water in each layer
  

</details>


:::details rootWaterUptake approaches

:::tabs

== rootWaterUptake_proportion
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rootWaterUptake_proportion' href='#Sindbad.Models.rootWaterUptake_proportion'><span class="jlbinding">Sindbad.Models.rootWaterUptake_proportion</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



rootUptake from each soil layer proportional to the relative plant water availability in the layer

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `fluxes.root_water_uptake`: amount of water uptaken for transpiration per soil layer
    
  

`compute`:
- **Inputs**
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `fluxes.transpiration`: transpiration
    
  - `fluxes.root_water_uptake`: amount of water uptaken for transpiration per soil layer
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.root_water_uptake`: amount of water uptaken for transpiration per soil layer
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `rootWaterUptake_proportion.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 13.03.2020 [ttraut]
  

_Created by_
- ttraut
  

_Notes_
- assumes that the uptake from each layer remains proportional to the root fraction
  

</details>


== rootWaterUptake_topBottom
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.rootWaterUptake_topBottom' href='#Sindbad.Models.rootWaterUptake_topBottom'><span class="jlbinding">Sindbad.Models.rootWaterUptake_topBottom</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



rootUptake from each of the soil layer from top to bottom using all water in each layer

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `fluxes.root_water_uptake`: amount of water uptaken for transpiration per soil layer
    
  

`compute`:
- **Inputs**
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `states.ΔsoilW`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :ΔsoilW)` for information on how to add the variable to the catalog.
    
  - `states.root_water_uptake`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :root_water_uptake)` for information on how to add the variable to the catalog.
    
  - `fluxes.transpiration`: transpiration
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.root_water_uptake`: amount of water uptaken for transpiration per soil layer
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `rootWaterUptake_topBottom.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

_Notes_
- assumes that the uptake is prioritized from top to bottom; irrespective of root fraction of the layers
  

</details>


:::


---


### runoff {#runoff}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoff' href='#Sindbad.Models.runoff'><span class="jlbinding">Sindbad.Models.runoff</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Calculate the total runoff as a sum of components
```



---


**Approaches**
- `runoff_sum`: calculates runoff as a sum of all potential components
  

</details>


:::details runoff approaches

:::tabs

== runoff_sum
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoff_sum' href='#Sindbad.Models.runoff_sum'><span class="jlbinding">Sindbad.Models.runoff_sum</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates runoff as a sum of all potential components

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.runoff`: total runoff
    
  - `fluxes.base_runoff`: base runoff
    
  - `fluxes.surface_runoff`: total surface runoff
    
  

`compute`:
- **Inputs**
  - `fluxes.base_runoff`: base runoff
    
  - `fluxes.surface_runoff`: total surface runoff
    
  
- **Outputs**
  - `fluxes.runoff`: total runoff
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoff_sum.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 01.04.2022  
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### runoffBase {#runoffBase}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffBase' href='#Sindbad.Models.runoffBase'><span class="jlbinding">Sindbad.Models.runoffBase</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Baseflow
```



---


**Approaches**
- `runoffBase_Zhang2008`: computes baseflow from a linear ground water storage
  
- `runoffBase_none`: sets the base runoff to zero
  

</details>


:::details runoffBase approaches

:::tabs

== runoffBase_Zhang2008
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffBase_Zhang2008' href='#Sindbad.Models.runoffBase_Zhang2008'><span class="jlbinding">Sindbad.Models.runoffBase_Zhang2008</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



computes baseflow from a linear ground water storage

**Parameters**
- **Fields**
  - `k_baseflow`: 0.001 ∈ [1.0e-5, 0.02] =&gt; base flow coefficient (units: `day-1` @ `day` timescale)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.groundW`: water storage in groundW pool(s)
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  
- **Outputs**
  - `fluxes.base_runoff`: base runoff
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffBase_Zhang2008.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Zhang, Y. Q., Chiew, F. H. S., Zhang, L., Leuning, R., &amp; Cleugh, H. A. (2008).  Estimating catchment evaporation and runoff using MODIS leaf area index &amp; the Penman‐Monteith equation.  Water Resources Research, 44[10].
  

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
  

_Created by_
- mjung
  

</details>


== runoffBase_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffBase_none' href='#Sindbad.Models.runoffBase_none'><span class="jlbinding">Sindbad.Models.runoffBase_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the base runoff to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.base_runoff`: base runoff
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffBase_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### runoffInfiltrationExcess {#runoffInfiltrationExcess}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffInfiltrationExcess' href='#Sindbad.Models.runoffInfiltrationExcess'><span class="jlbinding">Sindbad.Models.runoffInfiltrationExcess</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Infiltration excess runoff
```



---


**Approaches**
- `runoffInfiltrationExcess_Jung`: infiltration excess runoff as a function of rainintensity and vegetated fraction
  
- `runoffInfiltrationExcess_kUnsat`: infiltration excess runoff based on unsaτurated hydraulic conductivity
  
- `runoffInfiltrationExcess_none`: sets infiltration excess runoff to zero
  

</details>


:::details runoffInfiltrationExcess approaches

:::tabs

== runoffInfiltrationExcess_Jung
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffInfiltrationExcess_Jung' href='#Sindbad.Models.runoffInfiltrationExcess_Jung'><span class="jlbinding">Sindbad.Models.runoffInfiltrationExcess_Jung</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



infiltration excess runoff as a function of rainintensity and vegetated fraction

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  - `properties.k_sat`: hydraulic conductivity of soil at saturation per layer
    
  - `fluxes.rain`: amount of precipitation in liquid form
    
  - `states.rainInt`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :rainInt)` for information on how to add the variable to the catalog.
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.inf_excess_runoff`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :inf_excess_runoff)` for information on how to add the variable to the catalog.
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffInfiltrationExcess_Jung.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code
  
- 1.1 on 22.11.2019 [skoirala | @dr-ko]: moved from prec to dyna to handle land.states.fAPAR which is nPix, 1  
  

_Created by_
- mjung
  

</details>


== runoffInfiltrationExcess_kUnsat
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffInfiltrationExcess_kUnsat' href='#Sindbad.Models.runoffInfiltrationExcess_kUnsat'><span class="jlbinding">Sindbad.Models.runoffInfiltrationExcess_kUnsat</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



infiltration excess runoff based on unsaτurated hydraulic conductivity

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `models.unsat_k_model`: name of the model used to calculate unsaturated hydraulic conductivity
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.inf_excess_runoff`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :inf_excess_runoff)` for information on how to add the variable to the catalog.
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffInfiltrationExcess_kUnsat.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 23.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


== runoffInfiltrationExcess_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffInfiltrationExcess_none' href='#Sindbad.Models.runoffInfiltrationExcess_none'><span class="jlbinding">Sindbad.Models.runoffInfiltrationExcess_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets infiltration excess runoff to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.inf_excess_runoff`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :inf_excess_runoff)` for information on how to add the variable to the catalog.
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffInfiltrationExcess_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### runoffInterflow {#runoffInterflow}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffInterflow' href='#Sindbad.Models.runoffInterflow'><span class="jlbinding">Sindbad.Models.runoffInterflow</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Interflow
```



---


**Approaches**
- `runoffInterflow_none`: sets interflow runoff to zero
  
- `runoffInterflow_residual`: interflow as a fraction of the available water balance pool
  

</details>


:::details runoffInterflow approaches

:::tabs

== runoffInterflow_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffInterflow_none' href='#Sindbad.Models.runoffInterflow_none'><span class="jlbinding">Sindbad.Models.runoffInterflow_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets interflow runoff to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.interflow_runoff`: runoff loss from interflow in soil layers
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffInterflow_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


== runoffInterflow_residual
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffInterflow_residual' href='#Sindbad.Models.runoffInterflow_residual'><span class="jlbinding">Sindbad.Models.runoffInterflow_residual</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



interflow as a fraction of the available water balance pool

**Parameters**
- **Fields**
  - `rc`: 0.3 ∈ [0.0, 0.9] =&gt; fraction of the available water that flows out as interflow (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  
- **Outputs**
  - `fluxes.interflow_runoff`: runoff loss from interflow in soil layers
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffInterflow_residual.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
  

_Created by_
- mjung
  

</details>


:::


---


### runoffOverland {#runoffOverland}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffOverland' href='#Sindbad.Models.runoffOverland'><span class="jlbinding">Sindbad.Models.runoffOverland</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
calculates total overland runoff that passes to the surface storage
```



---


**Approaches**
- `runoffOverland_Inf`: ## assumes overland flow to be infiltration excess runoff
  
- `runoffOverland_InfIntSat`: assumes overland flow to be sum of infiltration excess, interflow, and saturation excess runoffs
  
- `runoffOverland_Sat`: assumes overland flow to be saturation excess runoff
  
- `runoffOverland_none`: sets overland runoff to zero
  

</details>


:::details runoffOverland approaches

:::tabs

== runoffOverland_Inf
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffOverland_Inf' href='#Sindbad.Models.runoffOverland_Inf'><span class="jlbinding">Sindbad.Models.runoffOverland_Inf</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



**assumes overland flow to be infiltration excess runoff**

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `fluxes.inf_excess_runoff`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :inf_excess_runoff)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `fluxes.overland_runoff`: overland runoff as a fraction of incoming water
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffOverland_Inf.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [skoirala | @dr-ko]  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== runoffOverland_InfIntSat
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffOverland_InfIntSat' href='#Sindbad.Models.runoffOverland_InfIntSat'><span class="jlbinding">Sindbad.Models.runoffOverland_InfIntSat</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



assumes overland flow to be sum of infiltration excess, interflow, and saturation excess runoffs

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `fluxes.inf_excess_runoff`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :inf_excess_runoff)` for information on how to add the variable to the catalog.
    
  - `fluxes.interflow_runoff`: runoff loss from interflow in soil layers
    
  - `fluxes.sat_excess_runoff`: saturation excess runoff
    
  
- **Outputs**
  - `fluxes.overland_runoff`: overland runoff as a fraction of incoming water
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffOverland_InfIntSat.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [skoirala | @dr-ko]  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== runoffOverland_Sat
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffOverland_Sat' href='#Sindbad.Models.runoffOverland_Sat'><span class="jlbinding">Sindbad.Models.runoffOverland_Sat</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



assumes overland flow to be saturation excess runoff

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `fluxes.sat_excess_runoff`: saturation excess runoff
    
  
- **Outputs**
  - `fluxes.overland_runoff`: overland runoff as a fraction of incoming water
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffOverland_Sat.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [skoirala | @dr-ko]  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== runoffOverland_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffOverland_none' href='#Sindbad.Models.runoffOverland_none'><span class="jlbinding">Sindbad.Models.runoffOverland_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets overland runoff to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.overland_runoff`: overland runoff as a fraction of incoming water
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffOverland_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### runoffSaturationExcess {#runoffSaturationExcess}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSaturationExcess' href='#Sindbad.Models.runoffSaturationExcess'><span class="jlbinding">Sindbad.Models.runoffSaturationExcess</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Saturation runoff
```



---


**Approaches**
- `runoffSaturationExcess_Bergstroem1992`: saturation excess runoff using original Bergström method
  
- `runoffSaturationExcess_Bergstroem1992MixedVegFraction`: saturation excess runoff using Bergström method with separate berg parameters for vegetated and non-vegetated fractions
  
- `runoffSaturationExcess_Bergstroem1992VegFraction`: saturation excess runoff using Bergström method with parameter scaled by vegetation fraction
  
- `runoffSaturationExcess_Bergstroem1992VegFractionFroSoil`: saturation excess runoff using Bergström method with parameter scaled by vegetation fraction and frozen soil fraction
  
- `runoffSaturationExcess_Bergstroem1992VegFractionPFT`: saturation excess runoff using Bergström method with parameter scaled by vegetation fraction and PFT
  
- `runoffSaturationExcess_Zhang2008`: saturation excess runoff as a function of incoming water and PET
  
- `runoffSaturationExcess_none`: set the saturation excess runoff to zero
  
- `runoffSaturationExcess_satFraction`: saturation excess runoff as a fraction of saturated fraction of land
  

</details>


:::details runoffSaturationExcess approaches

:::tabs

== runoffSaturationExcess_Bergstroem1992
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSaturationExcess_Bergstroem1992' href='#Sindbad.Models.runoffSaturationExcess_Bergstroem1992'><span class="jlbinding">Sindbad.Models.runoffSaturationExcess_Bergstroem1992</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



saturation excess runoff using original Bergström method

**Parameters**
- **Fields**
  - `β`: 1.1 ∈ [0.1, 5.0] =&gt; berg exponential parameter (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  
- **Outputs**
  - `fluxes.sat_excess_runoff`: saturation excess runoff
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSaturationExcess_Bergstroem1992.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Bergström, S. (1992). The HBV model–its structure &amp; applications. SMHI.
  

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
  
- 1.1 on 27.11.2019 [skoirala | @dr-ko]: changed to handle any number of soil layers
  
- 1.2 on 10.02.2020 [ttraut]: modyfying variable name to match the new SINDBAD version
  

_Created by_
- ttraut
  

</details>


== runoffSaturationExcess_Bergstroem1992MixedVegFraction
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSaturationExcess_Bergstroem1992MixedVegFraction' href='#Sindbad.Models.runoffSaturationExcess_Bergstroem1992MixedVegFraction'><span class="jlbinding">Sindbad.Models.runoffSaturationExcess_Bergstroem1992MixedVegFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



saturation excess runoff using Bergström method with separate berg parameters for vegetated and non-vegetated fractions

**Parameters**
- **Fields**
  - `β_veg`: 5.0 ∈ [0.1, 20.0] =&gt; linear scaling parameter for berg for vegetated fraction (`unitless` @ `all` timescales)
    
  - `β_soil`: 2.0 ∈ [0.1, 20.0] =&gt; linear scaling parameter for berg for non vegetated fraction (`unitless` @ `all` timescales)
    
  - `β_min`: 0.1 ∈ [0.08, 0.12] =&gt; minimum effective β (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  
- **Outputs**
  - `fluxes.sat_excess_runoff`: saturation excess runoff
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSaturationExcess_Bergstroem1992MixedVegFraction.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Bergström, S. (1992). The HBV model–its structure &amp; applications. SMHI.
  

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
  

_Created by_
- 1.1 on 27.11.2019: skoirala: changed to handle any number of soil layers
  
- ttraut
  

</details>


== runoffSaturationExcess_Bergstroem1992VegFraction
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSaturationExcess_Bergstroem1992VegFraction' href='#Sindbad.Models.runoffSaturationExcess_Bergstroem1992VegFraction'><span class="jlbinding">Sindbad.Models.runoffSaturationExcess_Bergstroem1992VegFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



saturation excess runoff using Bergström method with parameter scaled by vegetation fraction

**Parameters**
- **Fields**
  - `β`: 3.0 ∈ [0.1, 10.0] =&gt; linear scaling parameter to get the berg parameter from vegFrac (`unitless` @ `all` timescales)
    
  - `β_min`: 0.1 ∈ [0.08, 0.12] =&gt; minimum effective β (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  
- **Outputs**
  - `fluxes.sat_excess_runoff`: saturation excess runoff
    
  - `runoffSaturationExcess.β_veg`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:runoffSaturationExcess, :β_veg)` for information on how to add the variable to the catalog.
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSaturationExcess_Bergstroem1992VegFraction.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Bergström, S. (1992). The HBV model–its structure &amp; applications. SMHI.
  

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
  
- 1.1 on 27.11.2019 [skoirala | @dr-ko]: changed to handle any number of soil layers
  
- 1.2 on 10.02.2020 [ttraut]: modyfying variable name to match the new SINDBAD version
  

_Created by_
- ttraut
  

</details>


== runoffSaturationExcess_Bergstroem1992VegFractionFroSoil
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSaturationExcess_Bergstroem1992VegFractionFroSoil' href='#Sindbad.Models.runoffSaturationExcess_Bergstroem1992VegFractionFroSoil'><span class="jlbinding">Sindbad.Models.runoffSaturationExcess_Bergstroem1992VegFractionFroSoil</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



saturation excess runoff using Bergström method with parameter scaled by vegetation fraction and frozen soil fraction

**Parameters**
- **Fields**
  - `β`: 3.0 ∈ [0.1, 10.0] =&gt; linear scaling parameter to get the berg parameter from vegFrac (`unitless` @ `all` timescales)
    
  - `frozen_frac_scalar`: 1.0 ∈ [0.1, 3.0] =&gt; linear scaling parameter for frozen Soil fraction (`unitless` @ `all` timescales)
    
  - `β_min`: 0.1 ∈ [0.08, 0.12] =&gt; minimum effective β (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.frac_frozen_soil`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :frac_frozen_soil)` for information on how to add the variable to the catalog.
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.sat_excess_runoff`: saturation excess runoff
    
  - `runoffSaturationExcess.frac_frozen`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:runoffSaturationExcess, :frac_frozen)` for information on how to add the variable to the catalog.
    
  - `runoffSaturationExcess.β_veg`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:runoffSaturationExcess, :β_veg)` for information on how to add the variable to the catalog.
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSaturationExcess_Bergstroem1992VegFractionFroSoil.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Bergstroem, S. (1992). The HBV model–its structure &amp; applications. SMHI.
  

_Versions_
- 1.0 on 18.11.2019 [ttraut]  
  

_Created by_
- ttraut
  

</details>


== runoffSaturationExcess_Bergstroem1992VegFractionPFT
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSaturationExcess_Bergstroem1992VegFractionPFT' href='#Sindbad.Models.runoffSaturationExcess_Bergstroem1992VegFractionPFT'><span class="jlbinding">Sindbad.Models.runoffSaturationExcess_Bergstroem1992VegFractionPFT</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



saturation excess runoff using Bergström method with parameter scaled by vegetation fraction and PFT

**Parameters**
- **Fields**
  - `β_PFT0`: 3.0 ∈ [0.1, 5.0] =&gt; linear scaling parameter of PFT class 0 to get the berg parameter from vegFrac (`unitless` @ `all` timescales)
    
  - `β_PFT1`: 3.0 ∈ [0.1, 5.0] =&gt; linear scaling parameter of PFT class 1 to get the berg parameter from vegFrac (`unitless` @ `all` timescales)
    
  - `β_PFT2`: 3.0 ∈ [0.1, 5.0] =&gt; linear scaling parameter of PFT class 2 to get the berg parameter from vegFrac (`unitless` @ `all` timescales)
    
  - `β_PFT3`: 3.0 ∈ [0.1, 5.0] =&gt; linear scaling parameter of PFT class 3 to get the berg parameter from vegFrac (`unitless` @ `all` timescales)
    
  - `β_PFT4`: 3.0 ∈ [0.1, 5.0] =&gt; linear scaling parameter of PFT class 4 to get the berg parameter from vegFrac (`unitless` @ `all` timescales)
    
  - `β_PFT5`: 3.0 ∈ [0.1, 5.0] =&gt; linear scaling parameter of PFT class 5 to get the berg parameter from vegFrac (`unitless` @ `all` timescales)
    
  - `β_PFT6`: 3.0 ∈ [0.1, 5.0] =&gt; linear scaling parameter of PFT class 6 to get the berg parameter from vegFrac (`unitless` @ `all` timescales)
    
  - `β_PFT7`: 3.0 ∈ [0.1, 5.0] =&gt; linear scaling parameter of PFT class 7 to get the berg parameter from vegFrac (`unitless` @ `all` timescales)
    
  - `β_PFT8`: 3.0 ∈ [0.1, 5.0] =&gt; linear scaling parameter of PFT class 8 to get the berg parameter from vegFrac (`unitless` @ `all` timescales)
    
  - `β_PFT9`: 3.0 ∈ [0.1, 5.0] =&gt; linear scaling parameter of PFT class 9 to get the berg parameter from vegFrac (`unitless` @ `all` timescales)
    
  - `β_PFT10`: 3.0 ∈ [0.1, 5.0] =&gt; linear scaling parameter of PFT class 10 to get the berg parameter from vegFrac (`unitless` @ `all` timescales)
    
  - `β_PFT11`: 3.0 ∈ [0.1, 5.0] =&gt; linear scaling parameter of PFT class 11 to get the berg parameter from vegFrac (`unitless` @ `all` timescales)
    
  - `β_min`: 0.1 ∈ [0.08, 0.12] =&gt; minimum effective β (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `runoffSaturationExcess.β_veg`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:runoffSaturationExcess, :β_veg)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `forcing.PFT`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :PFT)` for information on how to add the variable to the catalog.
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  - `runoffSaturationExcess.β_veg`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:runoffSaturationExcess, :β_veg)` for information on how to add the variable to the catalog.
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  
- **Outputs**
  - `fluxes.sat_excess_runoff`: saturation excess runoff
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSaturationExcess_Bergstroem1992VegFractionPFT.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Bergström, S. (1992). The HBV model–its structure &amp; applications. SMHI.
  

_Versions_
- 1.0 on 10.09.2021 [ttraut]: based on runoffSaturation_BergstroemLinVegFr  
  
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
  
- 1.1 on 27.11.2019 [skoirala | @dr-ko]: changed to handle any number of soil layers
  
- 1.2 on 10.02.2020 [ttraut]: modyfying variable name to match the new SINDBAD version
  

_Created by_
- ttraut
  

</details>


== runoffSaturationExcess_Zhang2008
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSaturationExcess_Zhang2008' href='#Sindbad.Models.runoffSaturationExcess_Zhang2008'><span class="jlbinding">Sindbad.Models.runoffSaturationExcess_Zhang2008</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



saturation excess runoff as a function of incoming water and PET

**Parameters**
- **Fields**
  - `α`: 0.5 ∈ [0.01, 10.0] =&gt; an empirical Budyko parameter (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `fluxes.PET`: potential evapotranspiration
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.sat_excess_runoff`: saturation excess runoff
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSaturationExcess_Zhang2008.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Zhang et al 2008; Water balance modeling over variable time scales  based on the Budyko framework ? Model development &amp; testing; Journal of Hydrology
  
- a combination of eq 14 &amp; eq 15 in zhang et al 2008
  

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: cleaned up the code  
  

_Created by_
- mjung
  
- skoirala | @dr-ko
  

_Notes_
- is supposed to work over multiple time scales. it represents the  &quot;fast&quot; | &quot;direct&quot; runoff &amp; thus it&quot;s conceptually not really  consistent with &quot;saturation runoff&quot;. it basically lumps saturation runoff  &amp; interflow; i.e. if using this approach for saturation runoff it would  be consistent to set interflow to none
  
- supply limit is (land.states.WBP): Zhang et al use precipitation as supply limit. we here use precip +snow  melt - interception - infliltration excess runoff (i.e. the water that  arrives at the ground) - this is more consistent with the budyko logic  than just using precip
  

</details>


== runoffSaturationExcess_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSaturationExcess_none' href='#Sindbad.Models.runoffSaturationExcess_none'><span class="jlbinding">Sindbad.Models.runoffSaturationExcess_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



set the saturation excess runoff to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.sat_excess_runoff`: saturation excess runoff
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSaturationExcess_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


== runoffSaturationExcess_satFraction
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSaturationExcess_satFraction' href='#Sindbad.Models.runoffSaturationExcess_satFraction'><span class="jlbinding">Sindbad.Models.runoffSaturationExcess_satFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



saturation excess runoff as a fraction of saturated fraction of land

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `states.satFrac`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :satFrac)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `fluxes.sat_excess_runoff`: saturation excess runoff
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSaturationExcess_satFraction.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: cleaned up the code  
  

_Created by_
- skoirala | @dr-ko
  

_Notes_
- only works if soilWSatFrac module is activated
  

</details>


:::


---


### runoffSurface {#runoffSurface}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSurface' href='#Sindbad.Models.runoffSurface'><span class="jlbinding">Sindbad.Models.runoffSurface</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Surface runoff generation process
```



---


**Approaches**
- `runoffSurface_Orth2013`: calculates the delay coefficient of first 60 days as a precomputation. calculates the base runoff
  
- `runoffSurface_Trautmann2018`: calculates the delay coefficient of first 60 days as a precomputation based on Orth et al. 2013 &amp; as it is used in Trautmannet al. 2018. calculates the base runoff based on Orth et al. 2013 &amp; as it is used in Trautmannet al. 2018
  
- `runoffSurface_all`: assumes all overland runoff is lost as surface runoff
  
- `runoffSurface_directIndirect`: assumes surface runoff is the sum of direct fraction of overland runoff and indirect fraction of surface water storage
  
- `runoffSurface_directIndirectFroSoil`: assumes surface runoff is the sum of direct fraction of overland runoff and indirect fraction of surface water storage. Direct fraction is additionally dependent on frozen fraction of the grid
  
- `runoffSurface_indirect`: assumes all overland runoff is recharged to surface water first, which then generates surface runoff
  
- `runoffSurface_none`: sets surface runoff [surface_runoff] from the storage to zero
  

</details>


:::details runoffSurface approaches

:::tabs

== runoffSurface_Orth2013
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSurface_Orth2013' href='#Sindbad.Models.runoffSurface_Orth2013'><span class="jlbinding">Sindbad.Models.runoffSurface_Orth2013</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the delay coefficient of first 60 days as a precomputation. calculates the base runoff

**Parameters**
- **Fields**
  - `qt`: 2.0 ∈ [0.5, 100.0] =&gt; delay parameter for land runoff (units: `time` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `surface_runoff.z`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:surface_runoff, :z)` for information on how to add the variable to the catalog.
    
  - `surface_runoff.Rdelay`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:surface_runoff, :Rdelay)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `surface_runoff.z`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:surface_runoff, :z)` for information on how to add the variable to the catalog.
    
  - `surface_runoff.Rdelay`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:surface_runoff, :Rdelay)` for information on how to add the variable to the catalog.
    
  - `pools.surfaceW`: water storage in surfaceW pool(s)
    
  - `fluxes.overland_runoff`: overland runoff as a fraction of incoming water
    
  
- **Outputs**
  - `fluxes.surface_runoff`: total surface runoff
    
  - `surface_runoff.Rdelay`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:surface_runoff, :Rdelay)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSurface_Orth2013.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Orth, R., Koster, R. D., &amp; Seneviratne, S. I. (2013).  Inferring soil moisture memory from streamflow observations using a simple water balance model. Journal of Hydrometeorology, 14[6], 1773-1790.
  
- used in Trautmann et al. 2018
  

_Versions_
- 1.0 on 18.11.2019 [ttraut]  
  

_Created by_
- ttraut
  

_Notes_
- how to handle 60days?!?!
  

</details>


== runoffSurface_Trautmann2018
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSurface_Trautmann2018' href='#Sindbad.Models.runoffSurface_Trautmann2018'><span class="jlbinding">Sindbad.Models.runoffSurface_Trautmann2018</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculates the delay coefficient of first 60 days as a precomputation based on Orth et al. 2013 &amp; as it is used in Trautmannet al. 2018. calculates the base runoff based on Orth et al. 2013 &amp; as it is used in Trautmannet al. 2018

**Parameters**
- **Fields**
  - `qt`: 2.0 ∈ [0.5, 100.0] =&gt; delay parameter for land runoff (units: `time` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `surface_runoff.z`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:surface_runoff, :z)` for information on how to add the variable to the catalog.
    
  - `surface_runoff.Rdelay`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:surface_runoff, :Rdelay)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `surface_runoff.z`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:surface_runoff, :z)` for information on how to add the variable to the catalog.
    
  - `surface_runoff.Rdelay`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:surface_runoff, :Rdelay)` for information on how to add the variable to the catalog.
    
  - `fluxes.rain`: amount of precipitation in liquid form
    
  - `fluxes.snow`: amount of precipitation in solid form
    
  - `pools.snowW`: water storage in snowW pool(s)
    
  - `pools.snowW_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:pools, :snowW_prev)` for information on how to add the variable to the catalog.
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.soilW_prev`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:pools, :soilW_prev)` for information on how to add the variable to the catalog.
    
  - `pools.surfaceW`: water storage in surfaceW pool(s)
    
  - `fluxes.evaporation`: evaporation from the first soil layer
    
  - `fluxes.overland_runoff`: overland runoff as a fraction of incoming water
    
  - `fluxes.sublimation`: sublimation of the snow
    
  
- **Outputs**
  - `fluxes.surface_runoff`: total surface runoff
    
  - `surface_runoff.Rdelay`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:surface_runoff, :Rdelay)` for information on how to add the variable to the catalog.
    
  - `surface_runoff.dSurf`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:surface_runoff, :dSurf)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSurface_Trautmann2018.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Orth, R., Koster, R. D., &amp; Seneviratne, S. I. (2013).  Inferring soil moisture memory from streamflow observations using a simple water balance model. Journal of Hydrometeorology, 14[6], 1773-1790.
  
- used in Trautmann et al. 2018
  

_Versions_
- 1.0 on 18.11.2019 [ttraut]  
  
- 1.1 on 21.01.2020 [ttraut] : calculate surfaceW[1] based on water balance  (1:1 as in TWS Paper)
  

_Created by_
- ttraut
  

_Notes_
- how to handle 60days?!?!
  

</details>


== runoffSurface_all
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSurface_all' href='#Sindbad.Models.runoffSurface_all'><span class="jlbinding">Sindbad.Models.runoffSurface_all</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



assumes all overland runoff is lost as surface runoff

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `fluxes.overland_runoff`: overland runoff as a fraction of incoming water
    
  
- **Outputs**
  - `fluxes.surface_runoff`: total surface runoff
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSurface_all.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 20.11.2019 [skoirala | @dr-ko]: combine surface_runoff_direct, Indir, suw_recharge  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== runoffSurface_directIndirect
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSurface_directIndirect' href='#Sindbad.Models.runoffSurface_directIndirect'><span class="jlbinding">Sindbad.Models.runoffSurface_directIndirect</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



assumes surface runoff is the sum of direct fraction of overland runoff and indirect fraction of surface water storage

**Parameters**
- **Fields**
  - `dc`: 0.01 ∈ [0.0001, 1.0] =&gt; delayed surface runoff coefficient (`unitless` @ `all` timescales)
    
  - `rf`: 0.5 ∈ [0.0001, 1.0] =&gt; fraction of overland runoff that recharges the surface water storage (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.surfaceW`: water storage in surfaceW pool(s)
    
  - `pools.ΔsurfaceW`: change in water storage in surfaceW pool(s)
    
  - `fluxes.overland_runoff`: overland runoff as a fraction of incoming water
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.surface_runoff`: total surface runoff
    
  - `fluxes.surface_runoff_direct`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :surface_runoff_direct)` for information on how to add the variable to the catalog.
    
  - `fluxes.surface_runoff_indirect`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :surface_runoff_indirect)` for information on how to add the variable to the catalog.
    
  - `fluxes.suw_recharge`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :suw_recharge)` for information on how to add the variable to the catalog.
    
  - `pools.ΔsurfaceW`: change in water storage in surfaceW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSurface_directIndirect.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_

_Created by_
- skoirala | @dr-ko
  

</details>


== runoffSurface_directIndirectFroSoil
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSurface_directIndirectFroSoil' href='#Sindbad.Models.runoffSurface_directIndirectFroSoil'><span class="jlbinding">Sindbad.Models.runoffSurface_directIndirectFroSoil</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



assumes surface runoff is the sum of direct fraction of overland runoff and indirect fraction of surface water storage. Direct fraction is additionally dependent on frozen fraction of the grid

**Parameters**
- **Fields**
  - `dc`: 0.01 ∈ [0.0, 1.0] =&gt; delayed surface runoff coefficient (`unitless` @ `all` timescales)
    
  - `rf`: 0.5 ∈ [0.0, 1.0] =&gt; fraction of overland runoff that recharges the surface water storage (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `runoffSaturationExcess.frac_frozen`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:runoffSaturationExcess, :frac_frozen)` for information on how to add the variable to the catalog.
    
  - `pools.surfaceW`: water storage in surfaceW pool(s)
    
  - `pools.ΔsurfaceW`: change in water storage in surfaceW pool(s)
    
  - `fluxes.overland_runoff`: overland runoff as a fraction of incoming water
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.surface_runoff`: total surface runoff
    
  - `fluxes.surface_runoff_direct`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :surface_runoff_direct)` for information on how to add the variable to the catalog.
    
  - `fluxes.surface_runoff_indirect`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :surface_runoff_indirect)` for information on how to add the variable to the catalog.
    
  - `fluxes.suw_recharge`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :suw_recharge)` for information on how to add the variable to the catalog.
    
  - `pools.ΔsurfaceW`: change in water storage in surfaceW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSurface_directIndirectFroSoil.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 03.12.2020 [ttraut]  
  

_Created by_
- ttraut
  

</details>


== runoffSurface_indirect
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSurface_indirect' href='#Sindbad.Models.runoffSurface_indirect'><span class="jlbinding">Sindbad.Models.runoffSurface_indirect</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



assumes all overland runoff is recharged to surface water first, which then generates surface runoff

**Parameters**
- **Fields**
  - `dc`: 0.01 ∈ [0.0, 1.0] =&gt; delayed surface runoff coefficient (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.surfaceW`: water storage in surfaceW pool(s)
    
  - `fluxes.overland_runoff`: overland runoff as a fraction of incoming water
    
  
- **Outputs**
  - `fluxes.surface_runoff`: total surface runoff
    
  - `fluxes.suw_recharge`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :suw_recharge)` for information on how to add the variable to the catalog.
    
  - `pools.ΔsurfaceW`: change in water storage in surfaceW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSurface_indirect.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 20.11.2019 [skoirala | @dr-ko]: combine surface_runoff_direct, Indir, suw_recharge  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== runoffSurface_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.runoffSurface_none' href='#Sindbad.Models.runoffSurface_none'><span class="jlbinding">Sindbad.Models.runoffSurface_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets surface runoff [surface_runoff] from the storage to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.surface_runoff`: total surface runoff
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `runoffSurface_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### saturatedFraction {#saturatedFraction}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.saturatedFraction' href='#Sindbad.Models.saturatedFraction'><span class="jlbinding">Sindbad.Models.saturatedFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Saturated fraction of a grid cell
```



---


**Approaches**
- `saturatedFraction_none`: sets the land.states.soilWSatFrac [saturated soil fraction] to zero
  

</details>


:::details saturatedFraction approaches

:::tabs

== saturatedFraction_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.saturatedFraction_none' href='#Sindbad.Models.saturatedFraction_none'><span class="jlbinding">Sindbad.Models.saturatedFraction_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the land.states.soilWSatFrac [saturated soil fraction] to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `states.satFrac`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :satFrac)` for information on how to add the variable to the catalog.
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `saturatedFraction_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### snowFraction {#snowFraction}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.snowFraction' href='#Sindbad.Models.snowFraction'><span class="jlbinding">Sindbad.Models.snowFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Calculate snow cover fraction
```



---


**Approaches**
- `snowFraction_HTESSEL`: computes the snow pack &amp; fraction of snow cover following the HTESSEL approach
  
- `snowFraction_binary`: compute the fraction of snow cover.
  
- `snowFraction_none`: sets the snow fraction to zero
  

</details>


:::details snowFraction approaches

:::tabs

== snowFraction_HTESSEL
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.snowFraction_HTESSEL' href='#Sindbad.Models.snowFraction_HTESSEL'><span class="jlbinding">Sindbad.Models.snowFraction_HTESSEL</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



computes the snow pack &amp; fraction of snow cover following the HTESSEL approach

**Parameters**
- **Fields**
  - `snow_cover_param`: 15.0 ∈ [1.0, 100.0] =&gt; Snow Cover Parameter (units: `mm` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.snowW`: water storage in snowW pool(s)
    
  - `pools.ΔsnowW`: change in water storage in snowW pool(s)
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `states.frac_snow`: fractional coverage of grid with snow
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `snowFraction_HTESSEL.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- H-TESSEL = land surface scheme of the European Centre for Medium-  Range Weather Forecasts&quot; operational weather forecast system  Balsamo et al.; 2009
  

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
  

_Created by_
- mjung
  

</details>


== snowFraction_binary
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.snowFraction_binary' href='#Sindbad.Models.snowFraction_binary'><span class="jlbinding">Sindbad.Models.snowFraction_binary</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



compute the fraction of snow cover.

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.snowW`: water storage in snowW pool(s)
    
  - `pools.ΔsnowW`: change in water storage in snowW pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `states.frac_snow`: fractional coverage of grid with snow
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `snowFraction_binary.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
  

_Created by_
- mjung
  

</details>


== snowFraction_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.snowFraction_none' href='#Sindbad.Models.snowFraction_none'><span class="jlbinding">Sindbad.Models.snowFraction_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the snow fraction to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `states.frac_snow`: fractional coverage of grid with snow
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `snowFraction_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### snowMelt {#snowMelt}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.snowMelt' href='#Sindbad.Models.snowMelt'><span class="jlbinding">Sindbad.Models.snowMelt</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Calculate snowmelt and update s.w.wsnow
```



---


**Approaches**
- `snowMelt_Tair`: computes the snow melt term as function of air temperature
  
- `snowMelt_TairRn`: instantiate the potential snow melt based on temperature &amp; net radiation on days with f_airT &gt; 0.0°C. instantiate the potential snow melt based on temperature &amp; net radiation on days with f_airT &gt; 0.0 °C
  

</details>


:::details snowMelt approaches

:::tabs

== snowMelt_Tair
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.snowMelt_Tair' href='#Sindbad.Models.snowMelt_Tair'><span class="jlbinding">Sindbad.Models.snowMelt_Tair</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



computes the snow melt term as function of air temperature

**Parameters**
- **Fields**
  - `rate`: 1.0 ∈ [0.1, 10.0] =&gt; snow melt rate (units: `mm/°C` @ `day` timescale)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_airT`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT)` for information on how to add the variable to the catalog.
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `states.frac_snow`: fractional coverage of grid with snow
    
  - `pools.snowW`: water storage in snowW pool(s)
    
  - `pools.ΔsnowW`: change in water storage in snowW pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.snow_melt`: snow melt
    
  - `fluxes.Tterm`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :Tterm)` for information on how to add the variable to the catalog.
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `pools.ΔsnowW`: change in water storage in snowW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `snowMelt_Tair.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code
  
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
  

_Created by_
- mjung
  

_Notes_
- may not be working well for longer time scales (like for weekly |  longer time scales). Warnings needs to be set accordingly.
  
- may not be working well for longer time scales (like for weekly |  longer time scales). Warnings needs to be set accordingly.  
  

</details>


== snowMelt_TairRn
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.snowMelt_TairRn' href='#Sindbad.Models.snowMelt_TairRn'><span class="jlbinding">Sindbad.Models.snowMelt_TairRn</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



instantiate the potential snow melt based on temperature &amp; net radiation on days with f_airT &gt; 0.0°C. instantiate the potential snow melt based on temperature &amp; net radiation on days with f_airT &gt; 0.0 °C

**Parameters**
- **Fields**
  - `melt_T`: 3.0 ∈ [0.01, 10.0] =&gt; melt factor for temperature (units: `mm/°C` @ `all` timescales)
    
  - `melt_Rn`: 2.0 ∈ [0.01, 3.0] =&gt; melt factor for radiation (units: `mm/MJ/m2` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_rn`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rn)` for information on how to add the variable to the catalog.
    
  - `forcing.f_airT`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT)` for information on how to add the variable to the catalog.
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `states.frac_snow`: fractional coverage of grid with snow
    
  - `pools.snowW`: water storage in snowW pool(s)
    
  - `pools.ΔsnowW`: change in water storage in snowW pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `fluxes.snow_melt`: snow melt
    
  - `fluxes.potential_snow_melt`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:fluxes, :potential_snow_melt)` for information on how to add the variable to the catalog.
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `pools.ΔsnowW`: change in water storage in snowW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `snowMelt_TairRn.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
  

_Created by_
- ttraut
  

</details>


:::


---


### soilProperties {#soilProperties}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.soilProperties' href='#Sindbad.Models.soilProperties'><span class="jlbinding">Sindbad.Models.soilProperties</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Soil properties (hydraulic properties)
```



---


**Approaches**
- `soilProperties_Saxton1986`: assigns the soil hydraulic properties based on Saxton; 1986
  
- `soilProperties_Saxton2006`: assigns the soil hydraulic properties based on Saxton; 2006 to land.soilProperties.sp_
  

</details>


:::details soilProperties approaches

:::tabs

== soilProperties_Saxton1986
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.soilProperties_Saxton1986' href='#Sindbad.Models.soilProperties_Saxton1986'><span class="jlbinding">Sindbad.Models.soilProperties_Saxton1986</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



assigns the soil hydraulic properties based on Saxton; 1986

**Parameters**
- **Fields**
  - `ψ_fc`: 33.0 ∈ [30.0, 35.0] =&gt; matric potential at field capacity (units: `kPa` @ `all` timescales)
    
  - `ψ_wp`: 1500.0 ∈ [1000.0, 1800.0] =&gt; matric potential at wilting point (units: `kPa` @ `all` timescales)
    
  - `ψ_sat`: 0.0 ∈ [0.0, 5.0] =&gt; matric potential at saturation (units: `kPa` @ `all` timescales)
    
  - `a1`: -4.396 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `a2`: -0.0715 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `a3`: -0.000488 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `a4`: -4.285e-5 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `b1`: -3.14 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `b2`: -0.00222 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `b3`: -3.484e-5 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `c1`: 0.332 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `c2`: -0.0007251 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `c3`: 0.1276 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `d1`: -0.108 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `d2`: 0.341 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `e1`: 2.778e-6 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `e2`: 12.012 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `e3`: -0.0755 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `e4`: -3.895 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `e5`: 0.03671 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `e6`: -0.1103 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `e7`: 0.00087546 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `f1`: 2.302 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `n2`: 2.0 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `n24`: 24.0 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `n10`: 10.0 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `n100`: 100.0 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `n1000`: 1000.0 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `n1500`: 1000.0 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `n3600`: 3600.0 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `properties.sp_k_fc`: calculated/input hydraulic conductivity of soil at field capacity per layer
    
  - `properties.sp_k_sat`: calculated/input hydraulic conductivity of soil at saturation per layer
    
  - `properties.sp_k_wp`: calculated/input hydraulic conductivity of soil at wilting point per layer
    
  - `properties.sp_α`: calculated/input alpha parameter of soil per layer
    
  - `properties.sp_β`: calculated/input beta parameter of soil per layer
    
  - `properties.sp_θ_fc`: calculated/input moisture content of soil at field capacity per layer
    
  - `properties.sp_θ_sat`: calculated/input moisture content of soil at saturation (porosity) per layer
    
  - `properties.sp_θ_wp`: calculated/input moisture content of soil at wilting point per layer
    
  - `properties.sp_ψ_fc`: calculated/input matric potential of soil at field capacity per layer
    
  - `properties.sp_ψ_sat`: calculated/input matric potential of soil at saturation per layer
    
  - `properties.sp_ψ_wp`: calculated/input matric potential of soil at wiliting point per layer
    
  - `soilProperties.n100`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilProperties, :n100)` for information on how to add the variable to the catalog.
    
  - `soilProperties.n1000`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilProperties, :n1000)` for information on how to add the variable to the catalog.
    
  - `soilProperties.n2`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilProperties, :n2)` for information on how to add the variable to the catalog.
    
  - `soilProperties.n24`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilProperties, :n24)` for information on how to add the variable to the catalog.
    
  - `soilProperties.n3600`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilProperties, :n3600)` for information on how to add the variable to the catalog.
    
  - `soilProperties.e1`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilProperties, :e1)` for information on how to add the variable to the catalog.
    
  - `soilProperties.e2`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilProperties, :e2)` for information on how to add the variable to the catalog.
    
  - `soilProperties.e3`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilProperties, :e3)` for information on how to add the variable to the catalog.
    
  - `soilProperties.e4`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilProperties, :e4)` for information on how to add the variable to the catalog.
    
  - `soilProperties.e5`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilProperties, :e5)` for information on how to add the variable to the catalog.
    
  - `soilProperties.e6`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilProperties, :e6)` for information on how to add the variable to the catalog.
    
  - `soilProperties.e7`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilProperties, :e7)` for information on how to add the variable to the catalog.
    
  - `models.unsat_k_model`: name of the model used to calculate unsaturated hydraulic conductivity
    
  

`precompute`:
- **Inputs**
  - `properties.sp_α`: calculated/input alpha parameter of soil per layer
    
  - `properties.sp_β`: calculated/input beta parameter of soil per layer
    
  - `properties.sp_k_fc`: calculated/input hydraulic conductivity of soil at field capacity per layer
    
  - `properties.sp_θ_fc`: calculated/input moisture content of soil at field capacity per layer
    
  - `properties.sp_ψ_fc`: calculated/input matric potential of soil at field capacity per layer
    
  - `properties.sp_k_wp`: calculated/input hydraulic conductivity of soil at wilting point per layer
    
  - `properties.sp_θ_wp`: calculated/input moisture content of soil at wilting point per layer
    
  - `properties.sp_ψ_wp`: calculated/input matric potential of soil at wiliting point per layer
    
  - `properties.sp_k_sat`: calculated/input hydraulic conductivity of soil at saturation per layer
    
  - `properties.sp_θ_sat`: calculated/input moisture content of soil at saturation (porosity) per layer
    
  - `properties.sp_ψ_sat`: calculated/input matric potential of soil at saturation per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `properties.sp_k_fc`: calculated/input hydraulic conductivity of soil at field capacity per layer
    
  - `properties.sp_k_sat`: calculated/input hydraulic conductivity of soil at saturation per layer
    
  - `properties.sp_k_wp`: calculated/input hydraulic conductivity of soil at wilting point per layer
    
  - `properties.sp_α`: calculated/input alpha parameter of soil per layer
    
  - `properties.sp_β`: calculated/input beta parameter of soil per layer
    
  - `properties.sp_θ_fc`: calculated/input moisture content of soil at field capacity per layer
    
  - `properties.sp_θ_sat`: calculated/input moisture content of soil at saturation (porosity) per layer
    
  - `properties.sp_θ_wp`: calculated/input moisture content of soil at wilting point per layer
    
  - `properties.sp_ψ_fc`: calculated/input matric potential of soil at field capacity per layer
    
  - `properties.sp_ψ_sat`: calculated/input matric potential of soil at saturation per layer
    
  - `properties.sp_ψ_wp`: calculated/input matric potential of soil at wiliting point per layer
    
  

`compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `soilProperties_Saxton1986.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Saxton, K. E., Rawls, W., Romberger, J. S., &amp; Papendick, R. I. (1986). Estimating generalized soil‐water characteristics from texture. Soil science society of America Journal, 50(4), 1031-1036.
  

_Versions_
- 1.0 on 21.11.2019
  
- 1.1 on 03.12.2019 [skoirala | @dr-ko]: handling potentail vertical distribution of soil texture  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== soilProperties_Saxton2006
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.soilProperties_Saxton2006' href='#Sindbad.Models.soilProperties_Saxton2006'><span class="jlbinding">Sindbad.Models.soilProperties_Saxton2006</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



assigns the soil hydraulic properties based on Saxton; 2006 to land.soilProperties.sp_

**Parameters**
- **Fields**
  - `DF`: 1.0 ∈ [0.9, 1.3] =&gt; Density correction factor (`unitless` @ `all` timescales)
    
  - `Rw`: 0.0 ∈ [0.0, 1.0] =&gt; Weight fraction of gravel (decimal) (units: `g g-1` @ `all` timescales)
    
  - `matric_soil_density`: 2.65 ∈ [2.5, 3.0] =&gt; Matric soil density (units: `g cm-3` @ `all` timescales)
    
  - `gravel_density`: 2.65 ∈ [2.5, 3.0] =&gt; density of gravel material (units: `g cm-3` @ `all` timescales)
    
  - `EC`: 36.0 ∈ [30.0, 40.0] =&gt; SElectrical conductance of a saturated soil extract (units: `dS m-1 (dS/m = mili-mho cm-1)` @ `all` timescales)
    
  - `a1`: -0.024 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `a2`: 0.487 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `a3`: 0.006 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `a4`: 0.005 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `a5`: 0.013 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `a6`: 0.068 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `a7`: 0.031 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `b1`: 0.14 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `b2`: 0.02 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `c1`: -0.251 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `c2`: 0.195 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `c3`: 0.011 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `c4`: 0.006 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `c5`: 0.027 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `c6`: 0.452 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `c7`: 0.299 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `d1`: 1.283 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `d2`: 0.374 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `d3`: 0.015 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `e1`: 0.278 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `e2`: 0.034 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `e3`: 0.022 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `e4`: 0.018 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `e5`: 0.027 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `e6`: 0.584 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `e7`: 0.078 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `f1`: 0.636 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `f2`: 0.107 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `g1`: -21.67 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `g2`: 27.93 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `g3`: 81.97 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `g4`: 71.12 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `g5`: 8.29 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `g6`: 14.05 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `g7`: 27.16 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `h1`: 0.02 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `h2`: 0.113 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `h3`: 0.7 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `i1`: 0.097 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `i2`: 0.043 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `n02`: 0.2 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `n24`: 24.0 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `n33`: 33.0 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `n36`: 36.0 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `n1500`: 1500.0 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  - `n1930`: 1930.0 ∈ [-Inf, Inf] =&gt; Saxton Parameters (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `properties.sp_k_fc`: calculated/input hydraulic conductivity of soil at field capacity per layer
    
  - `properties.sp_k_sat`: calculated/input hydraulic conductivity of soil at saturation per layer
    
  - `properties.sp_k_wp`: calculated/input hydraulic conductivity of soil at wilting point per layer
    
  - `properties.sp_α`: calculated/input alpha parameter of soil per layer
    
  - `properties.sp_β`: calculated/input beta parameter of soil per layer
    
  - `properties.sp_θ_fc`: calculated/input moisture content of soil at field capacity per layer
    
  - `properties.sp_θ_sat`: calculated/input moisture content of soil at saturation (porosity) per layer
    
  - `properties.sp_θ_wp`: calculated/input moisture content of soil at wilting point per layer
    
  - `properties.sp_ψ_fc`: calculated/input matric potential of soil at field capacity per layer
    
  - `properties.sp_ψ_sat`: calculated/input matric potential of soil at saturation per layer
    
  - `properties.sp_ψ_wp`: calculated/input matric potential of soil at wiliting point per layer
    
  - `models.unsat_k_model`: name of the model used to calculate unsaturated hydraulic conductivity
    
  

`precompute`:
- **Inputs**
  - `properties.sp_k_fc`: calculated/input hydraulic conductivity of soil at field capacity per layer
    
  - `properties.sp_k_sat`: calculated/input hydraulic conductivity of soil at saturation per layer
    
  - `properties.sp_k_wp`: calculated/input hydraulic conductivity of soil at wilting point per layer
    
  - `properties.sp_α`: calculated/input alpha parameter of soil per layer
    
  - `properties.sp_β`: calculated/input beta parameter of soil per layer
    
  - `properties.sp_θ_fc`: calculated/input moisture content of soil at field capacity per layer
    
  - `properties.sp_θ_sat`: calculated/input moisture content of soil at saturation (porosity) per layer
    
  - `properties.sp_θ_wp`: calculated/input moisture content of soil at wilting point per layer
    
  - `properties.sp_ψ_fc`: calculated/input matric potential of soil at field capacity per layer
    
  - `properties.sp_ψ_sat`: calculated/input matric potential of soil at saturation per layer
    
  - `properties.sp_ψ_wp`: calculated/input matric potential of soil at wiliting point per layer
    
  
- **Outputs**
  - `properties.sp_k_fc`: calculated/input hydraulic conductivity of soil at field capacity per layer
    
  - `properties.sp_k_sat`: calculated/input hydraulic conductivity of soil at saturation per layer
    
  - `properties.sp_k_wp`: calculated/input hydraulic conductivity of soil at wilting point per layer
    
  - `properties.sp_α`: calculated/input alpha parameter of soil per layer
    
  - `properties.sp_β`: calculated/input beta parameter of soil per layer
    
  - `properties.sp_θ_fc`: calculated/input moisture content of soil at field capacity per layer
    
  - `properties.sp_θ_sat`: calculated/input moisture content of soil at saturation (porosity) per layer
    
  - `properties.sp_θ_wp`: calculated/input moisture content of soil at wilting point per layer
    
  - `properties.sp_ψ_fc`: calculated/input matric potential of soil at field capacity per layer
    
  - `properties.sp_ψ_sat`: calculated/input matric potential of soil at saturation per layer
    
  - `properties.sp_ψ_wp`: calculated/input matric potential of soil at wiliting point per layer
    
  

`compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `soilProperties_Saxton2006.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Saxton, K. E., &amp; Rawls, W. J. (2006). Soil water characteristic estimates by  texture &amp; organic matter for hydrologic solutions.  Soil science society of America Journal, 70[5], 1569-1578.
  

_Versions_
- 1.0 on 21.11.2019
  
- 1.1 on 03.12.2019 [skoirala | @dr-ko]: handling potentail vertical distribution of soil texture  
  

_Created by_
- Nuno Carvalhais [ncarvalhais]
  
- skoirala | @dr-ko
  

</details>


:::


---


### soilTexture {#soilTexture}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.soilTexture' href='#Sindbad.Models.soilTexture'><span class="jlbinding">Sindbad.Models.soilTexture</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Soil texture (sand,silt,clay, and organic matter fraction)
```



---


**Approaches**
- `soilTexture_constant`: sets the soil texture properties as constant
  
- `soilTexture_forcing`: sets the soil texture properties from input
  

</details>


:::details soilTexture approaches

:::tabs

== soilTexture_constant
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.soilTexture_constant' href='#Sindbad.Models.soilTexture_constant'><span class="jlbinding">Sindbad.Models.soilTexture_constant</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the soil texture properties as constant

**Parameters**
- **Fields**
  - `clay`: 0.2 ∈ [0.0, 1.0] =&gt; Clay content (`unitless` @ `all` timescales)
    
  - `silt`: 0.3 ∈ [0.0, 1.0] =&gt; Silt content (`unitless` @ `all` timescales)
    
  - `sand`: 0.5 ∈ [0.0, 1.0] =&gt; Sand content (`unitless` @ `all` timescales)
    
  - `orgm`: 0.0 ∈ [0.0, 1.0] =&gt; Organic matter content (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `properties.st_clay`: fraction of clay content in the soil
    
  - `properties.st_sand`: fraction of sand content in the soil per layer
    
  - `properties.st_silt`: fraction of silt content in the soil per layer
    
  - `properties.st_orgm`: fraction of organic matter content in the soil per layer
    
  

`precompute`:
- **Inputs**
  - `properties.st_clay`: fraction of clay content in the soil
    
  - `properties.st_sand`: fraction of sand content in the soil per layer
    
  - `properties.st_silt`: fraction of silt content in the soil per layer
    
  - `properties.st_orgm`: fraction of organic matter content in the soil per layer
    
  
- **Outputs**
  - `properties.st_clay`: fraction of clay content in the soil
    
  - `properties.st_sand`: fraction of sand content in the soil per layer
    
  - `properties.st_silt`: fraction of silt content in the soil per layer
    
  - `properties.st_orgm`: fraction of organic matter content in the soil per layer
    
  

`compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `soilTexture_constant.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 21.11.2019  
  

_Created by_
- skoirala | @dr-ko
  

_Notes_
- texture does not change with space &amp; depth
  

</details>


== soilTexture_forcing
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.soilTexture_forcing' href='#Sindbad.Models.soilTexture_forcing'><span class="jlbinding">Sindbad.Models.soilTexture_forcing</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the soil texture properties from input

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `properties.st_clay`: fraction of clay content in the soil
    
  - `properties.st_orgm`: fraction of organic matter content in the soil per layer
    
  - `properties.st_sand`: fraction of sand content in the soil per layer
    
  - `properties.st_silt`: fraction of silt content in the soil per layer
    
  

`precompute`:
- **Inputs**
  - `forcing.f_clay`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_clay)` for information on how to add the variable to the catalog.
    
  - `forcing.f_orgm`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_orgm)` for information on how to add the variable to the catalog.
    
  - `forcing.f_sand`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_sand)` for information on how to add the variable to the catalog.
    
  - `forcing.f_silt`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_silt)` for information on how to add the variable to the catalog.
    
  - `properties.st_clay`: fraction of clay content in the soil
    
  - `properties.st_orgm`: fraction of organic matter content in the soil per layer
    
  - `properties.st_sand`: fraction of sand content in the soil per layer
    
  - `properties.st_silt`: fraction of silt content in the soil per layer
    
  
- **Outputs**
  - `properties.st_clay`: fraction of clay content in the soil
    
  - `properties.st_orgm`: fraction of organic matter content in the soil per layer
    
  - `properties.st_sand`: fraction of sand content in the soil per layer
    
  - `properties.st_silt`: fraction of silt content in the soil per layer
    
  

`compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `soilTexture_forcing.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 21.11.2019  
  

_Created by_
- skoirala | @dr-ko
  

_Notes_
- if not; then sets the average of all as the fixed property of all layers
  
- if the input has same number of layers &amp; soilW; then sets the properties per layer
  

</details>


:::


---


### soilWBase {#soilWBase}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.soilWBase' href='#Sindbad.Models.soilWBase'><span class="jlbinding">Sindbad.Models.soilWBase</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Distribution of soil hydraulic properties over depth
```



---


**Approaches**
- `soilWBase_smax1Layer`: defines the maximum soil water content of 1 soil layer as fraction of the soil depth defined in the model_structure.json based on the TWS model for the Northern Hemisphere
  
- `soilWBase_smax2Layer`: defines the maximum soil water content of 2 soil layers as fraction of the soil depth defined in the model_structure.json based on the older version of the Pre-Tokyo Model
  
- `soilWBase_smax2fRD4`: defines the maximum soil water content of 2 soil layers the first layer is a fraction [i.e. 1] of the soil depth the second layer is a linear combination of scaled rooting depth data from forcing
  
- `soilWBase_uniform`: distributes the soil hydraulic properties for different soil layers assuming an uniform vertical distribution of all soil properties
  

</details>


:::details soilWBase approaches

:::tabs

== soilWBase_smax1Layer
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.soilWBase_smax1Layer' href='#Sindbad.Models.soilWBase_smax1Layer'><span class="jlbinding">Sindbad.Models.soilWBase_smax1Layer</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



defines the maximum soil water content of 1 soil layer as fraction of the soil depth defined in the model_structure.json based on the TWS model for the Northern Hemisphere

**Parameters**
- **Fields**
  - `smax`: 1.0 ∈ [0.001, 10.0] =&gt; maximum soil water holding capacity of 1st soil layer, as % of defined soil depth (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `properties.soil_layer_thickness`: thickness of each soil layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `properties.w_wp`: amount of water in the soil at wiliting point per layer
    
  

`compute`:
- **Inputs**
  - `properties.soil_layer_thickness`: thickness of each soil layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `properties.w_wp`: amount of water in the soil at wiliting point per layer
    
  
- **Outputs**
  - `properties.w_awc`: maximum amount of water available for vegetation/transpiration per soil layer (w_sat-_wp)
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.w_wp`: amount of water in the soil at wiliting point per layer
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `soilWBase_smax1Layer.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Trautmann et al. 2018
  

_Versions_
- 1.0 on 09.01.2020 [ttraut]: clean up &amp; consistency  
  

_Created by_
- ttraut
  

</details>


== soilWBase_smax2Layer
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.soilWBase_smax2Layer' href='#Sindbad.Models.soilWBase_smax2Layer'><span class="jlbinding">Sindbad.Models.soilWBase_smax2Layer</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



defines the maximum soil water content of 2 soil layers as fraction of the soil depth defined in the model_structure.json based on the older version of the Pre-Tokyo Model

**Parameters**
- **Fields**
  - `smax1`: 1.0 ∈ [0.001, 1.0] =&gt; maximum soil water holding capacity of 1st soil layer, as % of defined soil depth (`unitless` @ `all` timescales)
    
  - `smax2`: 0.3 ∈ [0.01, 1.0] =&gt; maximum plant available water in 2nd soil layer, as % of defined soil depth (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `properties.soil_layer_thickness`: thickness of each soil layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `properties.w_wp`: amount of water in the soil at wiliting point per layer
    
  

`compute`:
- **Inputs**
  - `properties.soil_layer_thickness`: thickness of each soil layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `properties.w_wp`: amount of water in the soil at wiliting point per layer
    
  
- **Outputs**
  - `properties.w_awc`: maximum amount of water available for vegetation/transpiration per soil layer (w_sat-_wp)
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.w_wp`: amount of water in the soil at wiliting point per layer
    
  - `properties.soil_layer_thickness`: thickness of each soil layer
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `soilWBase_smax2Layer.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 09.01.2020 [ttraut]: clean up &amp; consistency  
  

_Created by_
- ttraut
  

</details>


== soilWBase_smax2fRD4
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.soilWBase_smax2fRD4' href='#Sindbad.Models.soilWBase_smax2fRD4'><span class="jlbinding">Sindbad.Models.soilWBase_smax2fRD4</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



defines the maximum soil water content of 2 soil layers the first layer is a fraction [i.e. 1] of the soil depth the second layer is a linear combination of scaled rooting depth data from forcing

**Parameters**
- **Fields**
  - `smax1`: 1.0 ∈ [0.001, 1.0] =&gt; maximum soil water holding capacity of 1st soil layer, as % of defined soil depth (`unitless` @ `all` timescales)
    
  - `scalar_Fan`: 0.05 ∈ [0.0, 5.0] =&gt; scaling for rooting depth data to obtain smax2 (units: `fraction` @ `all` timescales)
    
  - `scalar_Yang`: 0.05 ∈ [0.0, 5.0] =&gt; scaling for rooting depth data to obtain smax2 (units: `fraction` @ `all` timescales)
    
  - `scalar_Wang`: 0.05 ∈ [0.0, 5.0] =&gt; scaling for root zone storage capacity data to obtain smax2 (units: `fraction` @ `all` timescales)
    
  - `scalar_Tian`: 0.05 ∈ [0.0, 5.0] =&gt; scaling for plant avaiable water capacity data to obtain smax2 (units: `fraction` @ `all` timescales)
    
  - `smax_Tian`: 50.0 ∈ [0.0, 1000.0] =&gt; value for plant avaiable water capacity data where this is NaN (units: `mm` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `properties.soil_layer_thickness`: thickness of each soil layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `properties.w_wp`: amount of water in the soil at wiliting point per layer
    
  - `soilWBase.rootwater_capacities`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilWBase, :rootwater_capacities)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `forcing.f_AWC`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_AWC)` for information on how to add the variable to the catalog.
    
  - `forcing.f_RDeff`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_RDeff)` for information on how to add the variable to the catalog.
    
  - `forcing.f_RDmax`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_RDmax)` for information on how to add the variable to the catalog.
    
  - `forcing.f_SWCmax`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_SWCmax)` for information on how to add the variable to the catalog.
    
  - `properties.soil_layer_thickness`: thickness of each soil layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `properties.w_wp`: amount of water in the soil at wiliting point per layer
    
  - `soilWBase.rootwater_capacities`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilWBase, :rootwater_capacities)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `properties.w_wp`: amount of water in the soil at wiliting point per layer
    
  - `soilWBase.rootwater_capacities`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:soilWBase, :rootwater_capacities)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `soilWBase_smax2fRD4.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 10.02.2020 [ttraut]
  

_Created by_
- ttraut
  

</details>


== soilWBase_uniform
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.soilWBase_uniform' href='#Sindbad.Models.soilWBase_uniform'><span class="jlbinding">Sindbad.Models.soilWBase_uniform</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



distributes the soil hydraulic properties for different soil layers assuming an uniform vertical distribution of all soil properties

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `properties.k_fc`: hydraulic conductivity of soil at field capacity per layer
    
  - `properties.k_sat`: hydraulic conductivity of soil at saturation per layer
    
  - `properties.k_wp`: hydraulic conductivity of soil at wilting point per layer
    
  - `properties.soil_layer_thickness`: thickness of each soil layer
    
  - `properties.w_awc`: maximum amount of water available for vegetation/transpiration per soil layer (w_sat-_wp)
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.w_wp`: amount of water in the soil at wiliting point per layer
    
  - `properties.∑w_awc`: total amount of water available for vegetation/transpiration
    
  - `properties.∑w_fc`: total amount of water in the soil at field capacity
    
  - `properties.∑w_sat`: total amount of water in the soil at saturation
    
  - `properties.∑w_wp`: total amount of water in the soil at wiliting point
    
  - `properties.soil_α`: alpha parameter of soil per layer
    
  - `properties.soil_β`: beta parameter of soil per layer
    
  - `properties.θ_fc`: moisture content of soil at field capacity per layer
    
  - `properties.θ_sat`: moisture content of soil at saturation (porosity) per layer
    
  - `properties.θ_wp`: moisture content of soil at wilting point per layer
    
  - `properties.ψ_fc`: matric potential of soil at field capacity per layer
    
  - `properties.ψ_sat`: matric potential of soil at saturation per layer
    
  - `properties.ψ_wp`: matric potential of soil at wiliting point per layer
    
  

`precompute`:
- **Inputs**
  - `properties.sp_k_fc`: calculated/input hydraulic conductivity of soil at field capacity per layer
    
  - `properties.sp_k_sat`: calculated/input hydraulic conductivity of soil at saturation per layer
    
  - `properties.sp_k_wp`: calculated/input hydraulic conductivity of soil at wilting point per layer
    
  - `properties.sp_α`: calculated/input alpha parameter of soil per layer
    
  - `properties.sp_β`: calculated/input beta parameter of soil per layer
    
  - `properties.sp_θ_fc`: calculated/input moisture content of soil at field capacity per layer
    
  - `properties.sp_θ_sat`: calculated/input moisture content of soil at saturation (porosity) per layer
    
  - `properties.sp_θ_wp`: calculated/input moisture content of soil at wilting point per layer
    
  - `properties.sp_ψ_fc`: calculated/input matric potential of soil at field capacity per layer
    
  - `properties.sp_ψ_sat`: calculated/input matric potential of soil at saturation per layer
    
  - `properties.sp_ψ_wp`: calculated/input matric potential of soil at wiliting point per layer
    
  - `properties.k_fc`: hydraulic conductivity of soil at field capacity per layer
    
  - `properties.k_sat`: hydraulic conductivity of soil at saturation per layer
    
  - `properties.k_wp`: hydraulic conductivity of soil at wilting point per layer
    
  - `properties.soil_layer_thickness`: thickness of each soil layer
    
  - `properties.w_awc`: maximum amount of water available for vegetation/transpiration per soil layer (w_sat-_wp)
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.w_wp`: amount of water in the soil at wiliting point per layer
    
  - `properties.∑w_awc`: total amount of water available for vegetation/transpiration
    
  - `properties.∑w_fc`: total amount of water in the soil at field capacity
    
  - `properties.∑w_sat`: total amount of water in the soil at saturation
    
  - `properties.∑w_wp`: total amount of water in the soil at wiliting point
    
  - `properties.soil_α`: alpha parameter of soil per layer
    
  - `properties.soil_β`: beta parameter of soil per layer
    
  - `properties.θ_fc`: moisture content of soil at field capacity per layer
    
  - `properties.θ_sat`: moisture content of soil at saturation (porosity) per layer
    
  - `properties.θ_wp`: moisture content of soil at wilting point per layer
    
  - `properties.ψ_fc`: matric potential of soil at field capacity per layer
    
  - `properties.ψ_sat`: matric potential of soil at saturation per layer
    
  - `properties.ψ_wp`: matric potential of soil at wiliting point per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `properties.k_fc`: hydraulic conductivity of soil at field capacity per layer
    
  - `properties.k_sat`: hydraulic conductivity of soil at saturation per layer
    
  - `properties.k_wp`: hydraulic conductivity of soil at wilting point per layer
    
  - `properties.soil_layer_thickness`: thickness of each soil layer
    
  - `properties.w_awc`: maximum amount of water available for vegetation/transpiration per soil layer (w_sat-_wp)
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.w_wp`: amount of water in the soil at wiliting point per layer
    
  - `properties.∑w_awc`: total amount of water available for vegetation/transpiration
    
  - `properties.∑w_fc`: total amount of water in the soil at field capacity
    
  - `properties.∑w_sat`: total amount of water in the soil at saturation
    
  - `properties.∑w_wp`: total amount of water in the soil at wiliting point
    
  - `properties.soil_α`: alpha parameter of soil per layer
    
  - `properties.soil_β`: beta parameter of soil per layer
    
  - `properties.θ_fc`: moisture content of soil at field capacity per layer
    
  - `properties.θ_sat`: moisture content of soil at saturation (porosity) per layer
    
  - `properties.θ_wp`: moisture content of soil at wilting point per layer
    
  - `properties.ψ_fc`: matric potential of soil at field capacity per layer
    
  - `properties.ψ_sat`: matric potential of soil at saturation per layer
    
  - `properties.ψ_wp`: matric potential of soil at wiliting point per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  

`compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `soilWBase_uniform.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [skoirala | @dr-ko]: clean up &amp; consistency
  
- 1.1 on 03.12.2019 [skoirala | @dr-ko]: handling potentail vertical distribution of soil texture  
  

_Created by_
- ncarvalhais
  
- skoirala | @dr-ko
  

</details>


:::


---


### sublimation {#sublimation}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.sublimation' href='#Sindbad.Models.sublimation'><span class="jlbinding">Sindbad.Models.sublimation</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Calculate sublimation and update snow water equivalent
```



---


**Approaches**
- `sublimation_GLEAM`: instantiates the Priestley-Taylor term for sublimation following GLEAM. computes sublimation following GLEAM
  
- `sublimation_none`: sets the snow sublimation to zero
  

</details>


:::details sublimation approaches

:::tabs

== sublimation_GLEAM
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.sublimation_GLEAM' href='#Sindbad.Models.sublimation_GLEAM'><span class="jlbinding">Sindbad.Models.sublimation_GLEAM</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



instantiates the Priestley-Taylor term for sublimation following GLEAM. computes sublimation following GLEAM

**Parameters**
- **Fields**
  - `α`: 0.95 ∈ [0.0, 3.0] =&gt; Priestley Taylor Coefficient for Sublimation (units: `none` @ `all` timescales)
    
  - `deg_to_k`: 273.15 ∈ [-Inf, Inf] =&gt; degree to Kelvin conversion (units: `none` @ `all` timescales)
    
  - `Δ_1`: 5723.265 ∈ [-Inf, Inf] =&gt; first parameter of Δ from Murphy &amp; Koop [2005](units:%20`none`%20@%20`all`%20timescales)
    
  - `Δ_2`: 3.53068 ∈ [-Inf, Inf] =&gt; second parameter of Δ from Murphy &amp; Koop [2005](units:%20`none`%20@%20`all`%20timescales)
    
  - `Δ_3`: 0.00728332 ∈ [-Inf, Inf] =&gt; third parameter of Δ from Murphy &amp; Koop [2005](units:%20`none`%20@%20`all`%20timescales)
    
  - `Δ_4`: 9.550426 ∈ [-Inf, Inf] =&gt; fourth parameter of Δ from Murphy &amp; Koop [2005](units:%20`none`%20@%20`all`%20timescales)
    
  - `pa_to_kpa`: 0.001 ∈ [-Inf, Inf] =&gt; pascal to kilopascal conversion (units: `none` @ `all` timescales)
    
  - `λ_1`: 46782.5 ∈ [-Inf, Inf] =&gt; first parameter of λ from Murphy &amp; Koop [2005](units:%20`none`%20@%20`all`%20timescales)
    
  - `λ_2`: 35.8925 ∈ [-Inf, Inf] =&gt; second parameter of λ from Murphy &amp; Koop [2005](units:%20`none`%20@%20`all`%20timescales)
    
  - `λ_3`: 0.07414 ∈ [-Inf, Inf] =&gt; third parameter of λ from Murphy &amp; Koop [2005](units:%20`none`%20@%20`all`%20timescales)
    
  - `λ_4`: 541.5 ∈ [-Inf, Inf] =&gt; fourth parameter of λ from Murphy &amp; Koop [2005](units:%20`none`%20@%20`all`%20timescales)
    
  - `λ_5`: 123.75 ∈ [-Inf, Inf] =&gt; fifth parameter of λ from Murphy &amp; Koop [2005](units:%20`none`%20@%20`all`%20timescales)
    
  - `j_to_mj`: 1.0e-6 ∈ [-Inf, Inf] =&gt; joule to megajoule conversion (units: `none` @ `all` timescales)
    
  - `g_to_kg`: 0.001 ∈ [-Inf, Inf] =&gt; joule to megajoule conversion (units: `none` @ `all` timescales)
    
  - `mol_mass_water`: 18.01528 ∈ [-Inf, Inf] =&gt; molecular mass of water (units: `gram` @ `all` timescales)
    
  - `sp_heat_air`: 0.001 ∈ [-Inf, Inf] =&gt; specific heat of air (units: `MJ/kg/K` @ `all` timescales)
    
  - `γ_1`: 0.001 ∈ [-Inf, Inf] =&gt; first parameter of γ from Brunt [1952](units:%20`none`%20@%20`all`%20timescales)
    
  - `γ_2`: 0.622 ∈ [-Inf, Inf] =&gt; second parameter of γ from Brunt [1952](units:%20`none`%20@%20`all`%20timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_psurf_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_psurf_day)` for information on how to add the variable to the catalog.
    
  - `forcing.f_rn`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_rn)` for information on how to add the variable to the catalog.
    
  - `forcing.f_airT_day`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_airT_day)` for information on how to add the variable to the catalog.
    
  - `states.frac_snow`: fractional coverage of grid with snow
    
  - `pools.snowW`: water storage in snowW pool(s)
    
  - `pools.ΔsnowW`: change in water storage in snowW pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  - `constants.t_two`: a type stable 2
    
  
- **Outputs**
  - `fluxes.sublimation`: sublimation of the snow
    
  - `sublimation.PTtermSub`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:sublimation, :PTtermSub)` for information on how to add the variable to the catalog.
    
  - `pools.ΔsnowW`: change in water storage in snowW pool(s)
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `sublimation_GLEAM.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Miralles; D. G.; De Jeu; R. A. M.; Gash; J. H.; Holmes; T. R. H.  &amp; Dolman, A. J. (2011). An application of GLEAM to estimating global evaporation.  Hydrology &amp; Earth System Sciences Discussions, 8[1].
  
- Murphy, D. M., &amp; Koop, T. (2005). Review of the vapour pressures of ice and supercooled water for atmospheric applications. Quarterly Journal of the Royal Meteorological Society: A journal of the atmospheric sciences, applied meteorology and physical oceanography, 131(608), 1539-1565. https://patarnott.com/atms360/pdf_atms360/class2017/VaporPressureIce_SupercooledH20_Murphy.pdf
  

_Versions_
- 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
  

_Created by_
- mjung
  

</details>


== sublimation_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.sublimation_none' href='#Sindbad.Models.sublimation_none'><span class="jlbinding">Sindbad.Models.sublimation_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the snow sublimation to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.snowW`: water storage in snowW pool(s)
    
  
- **Outputs**
  - `fluxes.sublimation`: sublimation of the snow
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `sublimation_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### transpiration {#transpiration}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.transpiration' href='#Sindbad.Models.transpiration'><span class="jlbinding">Sindbad.Models.transpiration</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
calclulate the actual transpiration
```



---


**Approaches**
- `transpiration_coupled`: calculate the actual transpiration as function of gpp &amp; WUE
  
- `transpiration_demandSupply`: calculate the actual transpiration as the minimum of the supply &amp; demand
  
- `transpiration_none`: sets the actual transpiration to zero
  

</details>


:::details transpiration approaches

:::tabs

== transpiration_coupled
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.transpiration_coupled' href='#Sindbad.Models.transpiration_coupled'><span class="jlbinding">Sindbad.Models.transpiration_coupled</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate the actual transpiration as function of gpp &amp; WUE

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `fluxes.gpp`: gross primary prorDcutivity
    
  - `diagnostics.WUE`: water use efficiency of the ecosystem
    
  
- **Outputs**
  - `fluxes.transpiration`: transpiration
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `transpiration_coupled.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]
  

_Created by_
- mjung
  
- skoirala | @dr-ko
  

_Notes_

</details>


== transpiration_demandSupply
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.transpiration_demandSupply' href='#Sindbad.Models.transpiration_demandSupply'><span class="jlbinding">Sindbad.Models.transpiration_demandSupply</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate the actual transpiration as the minimum of the supply &amp; demand

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `diagnostics.transpiration_supply`: total amount of water available in soil for transpiration
    
  - `diagnostics.transpiration_demand`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :transpiration_demand)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `fluxes.transpiration`: transpiration
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `transpiration_demandSupply.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

_Notes_
- ignores biological limitation of transpiration demand
  

</details>


== transpiration_none
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.transpiration_none' href='#Sindbad.Models.transpiration_none'><span class="jlbinding">Sindbad.Models.transpiration_none</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the actual transpiration to zero

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  
- **Outputs**
  - `fluxes.transpiration`: transpiration
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `transpiration_none.jl`. Check the Extended help for user-defined information._


---


**Extended help**

</details>


:::


---


### transpirationDemand {#transpirationDemand}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.transpirationDemand' href='#Sindbad.Models.transpirationDemand'><span class="jlbinding">Sindbad.Models.transpirationDemand</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Demand-driven transpiration
```



---


**Approaches**
- `transpirationDemand_CASA`: calculate the supply limited transpiration as function of volumetric soil content &amp; soil properties; as in the CASA model
  
- `transpirationDemand_PET`: calculate the climate driven demand for transpiration as a function of PET &amp; α for vegetation
  
- `transpirationDemand_PETfAPAR`: calculate the climate driven demand for transpiration as a function of PET &amp; fAPAR
  
- `transpirationDemand_PETvegFraction`: calculate the climate driven demand for transpiration as a function of PET &amp; α for vegetation; &amp; vegetation fraction
  

</details>


:::details transpirationDemand approaches

:::tabs

== transpirationDemand_CASA
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.transpirationDemand_CASA' href='#Sindbad.Models.transpirationDemand_CASA'><span class="jlbinding">Sindbad.Models.transpirationDemand_CASA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate the supply limited transpiration as function of volumetric soil content &amp; soil properties; as in the CASA model

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  - `properties.w_awc`: maximum amount of water available for vegetation/transpiration per soil layer (w_sat-_wp)
    
  - `properties.soil_α`: alpha parameter of soil per layer
    
  - `properties.soil_β`: beta parameter of soil per layer
    
  - `fluxes.percolation`: amount of moisture percolating to the top soil layer
    
  - `fluxes.PET`: potential evapotranspiration
    
  
- **Outputs**
  - `diagnostics.transpiration_demand`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :transpiration_demand)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `transpirationDemand_CASA.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: split the original transpiration_supply of CASA into demand supply: actual [minimum] is now just demandSupply approach of transpiration  
  

_Created by_
- ncarvalhais
  
- skoirala | @dr-ko
  

_Notes_
- The supply limit has non-linear relationship with moisture state over the root zone
  

</details>


== transpirationDemand_PET
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.transpirationDemand_PET' href='#Sindbad.Models.transpirationDemand_PET'><span class="jlbinding">Sindbad.Models.transpirationDemand_PET</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate the climate driven demand for transpiration as a function of PET &amp; α for vegetation

**Parameters**
- **Fields**
  - `α`: 1.0 ∈ [0.2, 3.0] =&gt; vegetation specific α coefficient of Priestley Taylor PET (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `fluxes.PET`: potential evapotranspiration
    
  
- **Outputs**
  - `diagnostics.transpiration_demand`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :transpiration_demand)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `transpirationDemand_PET.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


== transpirationDemand_PETfAPAR
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.transpirationDemand_PETfAPAR' href='#Sindbad.Models.transpirationDemand_PETfAPAR'><span class="jlbinding">Sindbad.Models.transpirationDemand_PETfAPAR</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate the climate driven demand for transpiration as a function of PET &amp; fAPAR

**Parameters**
- **Fields**
  - `α`: 1.0 ∈ [0.2, 3.0] =&gt; vegetation specific α coefficient of Priestley Taylor PET (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  - `fluxes.PET`: potential evapotranspiration
    
  
- **Outputs**
  - `diagnostics.transpiration_demand`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :transpiration_demand)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `transpirationDemand_PETfAPAR.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 30.04.2020 [skoirala | @dr-ko]
  

_Created by_
- sbesnard; skoirala; ncarvalhais
  

_Notes_
- Assumes that the transpiration demand scales with vegetated fraction
  

</details>


== transpirationDemand_PETvegFraction
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.transpirationDemand_PETvegFraction' href='#Sindbad.Models.transpirationDemand_PETvegFraction'><span class="jlbinding">Sindbad.Models.transpirationDemand_PETvegFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate the climate driven demand for transpiration as a function of PET &amp; α for vegetation; &amp; vegetation fraction

**Parameters**
- **Fields**
  - `α`: 1.0 ∈ [0.2, 3.0] =&gt; vegetation specific α coefficient of Priestley Taylor PET (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  - `fluxes.PET`: potential evapotranspiration
    
  
- **Outputs**
  - `diagnostics.transpiration_demand`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:diagnostics, :transpiration_demand)` for information on how to add the variable to the catalog.
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `transpirationDemand_PETvegFraction.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

_Notes_
- Assumes that the transpiration demand scales with vegetated fraction
  

</details>


:::


---


### transpirationSupply {#transpirationSupply}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.transpirationSupply' href='#Sindbad.Models.transpirationSupply'><span class="jlbinding">Sindbad.Models.transpirationSupply</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Supply-limited transpiration
```



---


**Approaches**
- `transpirationSupply_CASA`: calculate the supply limited transpiration as function of volumetric soil content &amp; soil properties; as in the CASA model
  
- `transpirationSupply_Federer1982`: calculate the supply limited transpiration as a function of max rate parameter &amp; avaialable water
  
- `transpirationSupply_wAWC`: calculate the supply limited transpiration as the minimum of fraction of total AWC &amp; the actual available moisture
  
- `transpirationSupply_wAWCvegFraction`: calculate the supply limited transpiration as the minimum of fraction of total AWC &amp; the actual available moisture; scaled by vegetated fractions
  

</details>


:::details transpirationSupply approaches

:::tabs

== transpirationSupply_CASA
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.transpirationSupply_CASA' href='#Sindbad.Models.transpirationSupply_CASA'><span class="jlbinding">Sindbad.Models.transpirationSupply_CASA</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate the supply limited transpiration as function of volumetric soil content &amp; soil properties; as in the CASA model

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  
- **Outputs**
  - `diagnostics.transpiration_supply`: total amount of water available in soil for transpiration
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `transpirationSupply_CASA.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]: split the original transpiration_supply of CASA into demand  supply: actual [minimum] is now just demSup approach of transpiration  
  

_Created by_
- ncarvalhais
  
- skoirala | @dr-ko
  

_Notes_
- The supply limit has non-linear relationship with moisture state over the root zone
  

</details>


== transpirationSupply_Federer1982
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.transpirationSupply_Federer1982' href='#Sindbad.Models.transpirationSupply_Federer1982'><span class="jlbinding">Sindbad.Models.transpirationSupply_Federer1982</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate the supply limited transpiration as a function of max rate parameter &amp; avaialable water

**Parameters**
- **Fields**
  - `max_t_loss`: 5.0 ∈ [0.1, 20.0] =&gt; Maximum rate of transpiration in mm/day (units: `mm/day` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  - `properties.∑w_sat`: total amount of water in the soil at saturation
    
  
- **Outputs**
  - `diagnostics.transpiration_supply`: total amount of water available in soil for transpiration
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `transpirationSupply_Federer1982.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


== transpirationSupply_wAWC
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.transpirationSupply_wAWC' href='#Sindbad.Models.transpirationSupply_wAWC'><span class="jlbinding">Sindbad.Models.transpirationSupply_wAWC</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate the supply limited transpiration as the minimum of fraction of total AWC &amp; the actual available moisture

**Parameters**
- **Fields**
  - `k_transpiration`: 0.99 ∈ [0.002, 1.0] =&gt; fraction of total maximum available water that can be transpired (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  
- **Outputs**
  - `diagnostics.transpiration_supply`: total amount of water available in soil for transpiration
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `transpirationSupply_wAWC.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_
- Teuling; 2007 | 2009: Time scales.#
  

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


== transpirationSupply_wAWCvegFraction
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.transpirationSupply_wAWCvegFraction' href='#Sindbad.Models.transpirationSupply_wAWCvegFraction'><span class="jlbinding">Sindbad.Models.transpirationSupply_wAWCvegFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate the supply limited transpiration as the minimum of fraction of total AWC &amp; the actual available moisture; scaled by vegetated fractions

**Parameters**
- **Fields**
  - `k_transpiration`: 1.0 ∈ [0.02, 1.0] =&gt; fraction of total maximum available water that can be transpired (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  
- **Outputs**
  - `diagnostics.transpiration_supply`: total amount of water available in soil for transpiration
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `transpirationSupply_wAWCvegFraction.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 22.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

_Notes_
- Assumes that the transpiration supply scales with vegetated fraction
  

</details>


:::


---


### treeFraction {#treeFraction}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.treeFraction' href='#Sindbad.Models.treeFraction'><span class="jlbinding">Sindbad.Models.treeFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Fractional coverage of trees
```



---


**Approaches**
- `treeFraction_constant`: sets frac_tree as a constant
  
- `treeFraction_forcing`: sets land.states.frac_tree from forcing
  

</details>


:::details treeFraction approaches

:::tabs

== treeFraction_constant
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.treeFraction_constant' href='#Sindbad.Models.treeFraction_constant'><span class="jlbinding">Sindbad.Models.treeFraction_constant</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets frac_tree as a constant

**Parameters**
- **Fields**
  - `constant_frac_tree`: 1.0 ∈ [0.3, 1.0] =&gt; Tree fraction (`unitless` @ `all` timescales)
    
  

**Methods:**

`precompute`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `states.frac_tree`: fractional coverage of grid with trees
    
  

`define, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `treeFraction_constant.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: cleaned up the code  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== treeFraction_forcing
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.treeFraction_forcing' href='#Sindbad.Models.treeFraction_forcing'><span class="jlbinding">Sindbad.Models.treeFraction_forcing</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets land.states.frac_tree from forcing

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_tree_frac`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_tree_frac)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.frac_tree`: fractional coverage of grid with trees
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `treeFraction_forcing.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### vegAvailableWater {#vegAvailableWater}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.vegAvailableWater' href='#Sindbad.Models.vegAvailableWater'><span class="jlbinding">Sindbad.Models.vegAvailableWater</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Plant available water
```



---


**Approaches**
- `vegAvailableWater_rootWaterEfficiency`: sets the maximum fraction of water that root can uptake from soil layers as constant. calculate the actual amount of water that is available for plants
  
- `vegAvailableWater_sigmoid`: calculate the actual amount of water that is available for plants
  

</details>


:::details vegAvailableWater approaches

:::tabs

== vegAvailableWater_rootWaterEfficiency
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.vegAvailableWater_rootWaterEfficiency' href='#Sindbad.Models.vegAvailableWater_rootWaterEfficiency'><span class="jlbinding">Sindbad.Models.vegAvailableWater_rootWaterEfficiency</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets the maximum fraction of water that root can uptake from soil layers as constant. calculate the actual amount of water that is available for plants

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  

`compute`:
- **Inputs**
  - `properties.w_wp`: amount of water in the soil at wiliting point per layer
    
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  
- **Outputs**
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `vegAvailableWater_rootWaterEfficiency.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 21.11.2019  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== vegAvailableWater_sigmoid
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.vegAvailableWater_sigmoid' href='#Sindbad.Models.vegAvailableWater_sigmoid'><span class="jlbinding">Sindbad.Models.vegAvailableWater_sigmoid</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



calculate the actual amount of water that is available for plants

**Parameters**
- **Fields**
  - `exp_factor`: 1.0 ∈ [0.02, 3.0] =&gt; multiplier of B factor of exponential rate (`unitless` @ `all` timescales)
    
  

**Methods:**

`define`:
- **Inputs**
  - `pools.soilW`: water storage in soilW pool(s)
    
  
- **Outputs**
  - `states.θ_dos`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :θ_dos)` for information on how to add the variable to the catalog.
    
  - `states.θ_fc_dos`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :θ_fc_dos)` for information on how to add the variable to the catalog.
    
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  - `states.soilW_stress`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :soilW_stress)` for information on how to add the variable to the catalog.
    
  - `states.max_water`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :max_water)` for information on how to add the variable to the catalog.
    
  

`compute`:
- **Inputs**
  - `properties.w_wp`: amount of water in the soil at wiliting point per layer
    
  - `properties.w_fc`: amount of water in the soil at field capacity per layer
    
  - `properties.w_sat`: amount of water in the soil at saturation per layer
    
  - `properties.soil_β`: beta parameter of soil per layer
    
  - `diagnostics.root_water_efficiency`: a efficiency like number that indicates the ease/fraction of soil water that can extracted by the root per layer
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `states.θ_dos`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :θ_dos)` for information on how to add the variable to the catalog.
    
  - `states.θ_fc_dos`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :θ_fc_dos)` for information on how to add the variable to the catalog.
    
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  - `states.soilW_stress`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :soilW_stress)` for information on how to add the variable to the catalog.
    
  - `states.max_water`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :max_water)` for information on how to add the variable to the catalog.
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `states.PAW`: amount of water available for transpiration per soil layer
    
  - `states.soilW_stress`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :soilW_stress)` for information on how to add the variable to the catalog.
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `vegAvailableWater_sigmoid.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 21.11.2019  
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### vegFraction {#vegFraction}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.vegFraction' href='#Sindbad.Models.vegFraction'><span class="jlbinding">Sindbad.Models.vegFraction</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Fractional coverage of vegetation
```



---


**Approaches**
- `vegFraction_constant`: sets frac_vegetation as a constant
  
- `vegFraction_forcing`: sets land.states.frac_vegetation from forcing
  
- `vegFraction_scaledEVI`: sets frac_vegetation by scaling the EVI value
  
- `vegFraction_scaledLAI`: sets frac_vegetation by scaling the LAI value
  
- `vegFraction_scaledNDVI`: sets frac_vegetation by scaling the NDVI value
  
- `vegFraction_scaledNIRv`: sets frac_vegetation by scaling the NIRv value
  
- `vegFraction_scaledfAPAR`: sets frac_vegetation by scaling the fAPAR value
  

</details>


:::details vegFraction approaches

:::tabs

== vegFraction_constant
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.vegFraction_constant' href='#Sindbad.Models.vegFraction_constant'><span class="jlbinding">Sindbad.Models.vegFraction_constant</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets frac_vegetation as a constant

**Parameters**
- **Fields**
  - `constant_frac_vegetation`: 0.5 ∈ [0.3, 0.9] =&gt; Vegetation fraction (`unitless` @ `all` timescales)
    
  

**Methods:**

`precompute`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  

`define, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `vegFraction_constant.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]: cleaned up the code  
  

_Created by_
- skoirala | @dr-ko
  

</details>


== vegFraction_forcing
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.vegFraction_forcing' href='#Sindbad.Models.vegFraction_forcing'><span class="jlbinding">Sindbad.Models.vegFraction_forcing</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets land.states.frac_vegetation from forcing

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `forcing.f_frac_vegetation`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:forcing, :f_frac_vegetation)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `vegFraction_forcing.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


== vegFraction_scaledEVI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.vegFraction_scaledEVI' href='#Sindbad.Models.vegFraction_scaledEVI'><span class="jlbinding">Sindbad.Models.vegFraction_scaledEVI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets frac_vegetation by scaling the EVI value

**Parameters**
- **Fields**
  - `EVIscale`: 1.0 ∈ [0.0, 5.0] =&gt; scalar for EVI (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.EVI`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :EVI)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `vegFraction_scaledEVI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 06.02.2020 [ttraut]  
  
- 1.1 on 05.03.2020 [ttraut]: apply the min function
  

_Created by_
- ttraut
  

</details>


== vegFraction_scaledLAI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.vegFraction_scaledLAI' href='#Sindbad.Models.vegFraction_scaledLAI'><span class="jlbinding">Sindbad.Models.vegFraction_scaledLAI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets frac_vegetation by scaling the LAI value

**Parameters**
- **Fields**
  - `LAIscale`: 1.0 ∈ [0.0, 5.0] =&gt; scalar for LAI (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.LAI`: leaf area index
    
  
- **Outputs**
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `vegFraction_scaledLAI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.1 on 24.10.2020 [ttraut]: new module  
  

_Created by_
- sbesnard
  

</details>


== vegFraction_scaledNDVI
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.vegFraction_scaledNDVI' href='#Sindbad.Models.vegFraction_scaledNDVI'><span class="jlbinding">Sindbad.Models.vegFraction_scaledNDVI</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets frac_vegetation by scaling the NDVI value

**Parameters**
- **Fields**
  - `NDVIscale`: 1.0 ∈ [0.0, 5.0] =&gt; scalar for NDVI (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.NDVI`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :NDVI)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `vegFraction_scaledNDVI.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.1 on 29.04.2020 [sbesnard]: new module  
  

_Created by_
- sbesnard
  

</details>


== vegFraction_scaledNIRv
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.vegFraction_scaledNIRv' href='#Sindbad.Models.vegFraction_scaledNIRv'><span class="jlbinding">Sindbad.Models.vegFraction_scaledNIRv</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets frac_vegetation by scaling the NIRv value

**Parameters**
- **Fields**
  - `NIRvscale`: 1.0 ∈ [0.0, 5.0] =&gt; scalar for NIRv (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.NIRv`: No description available in `src/sindbadVariableCatalog.jl` catalog. Run `whatIs(:states, :NIRv)` for information on how to add the variable to the catalog.
    
  
- **Outputs**
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `vegFraction_scaledNIRv.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.1 on 29.04.2020 [sbesnard]: new module  
  

_Created by_
- sbesnard
  

</details>


== vegFraction_scaledfAPAR
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.vegFraction_scaledfAPAR' href='#Sindbad.Models.vegFraction_scaledfAPAR'><span class="jlbinding">Sindbad.Models.vegFraction_scaledfAPAR</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



sets frac_vegetation by scaling the fAPAR value

**Parameters**
- **Fields**
  - `fAPAR_scalar`: 10.0 ∈ [0.0, 20.0] =&gt; scalar for fAPAR (`unitless` @ `all` timescales)
    
  

**Methods:**

`compute`:
- **Inputs**
  - `states.fAPAR`: fraction of absorbed photosynthetically active radiation
    
  
- **Outputs**
  - `states.frac_vegetation`: fractional coverage of grid with vegetation
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `vegFraction_scaledfAPAR.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.1 on 24.10.2020 [ttraut]: new module  
  

_Created by_
- sbesnard
  

</details>


:::


---


### wCycle {#wCycle}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.wCycle' href='#Sindbad.Models.wCycle'><span class="jlbinding">Sindbad.Models.wCycle</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Apply the delta storage changes to storage variables
```



---


**Approaches**
- `wCycle_combined`: computes the algebraic sum of storage and delta storage
  
- `wCycle_components`: update the water cycle pools per component
  

</details>


:::details wCycle approaches

:::tabs

== wCycle_combined
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.wCycle_combined' href='#Sindbad.Models.wCycle_combined'><span class="jlbinding">Sindbad.Models.wCycle_combined</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



computes the algebraic sum of storage and delta storage

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - `pools.ΔTWS`: change in water storage in TWS pool(s)
    
  
- **Outputs**
  - `pools.zeroΔTWS`: helper variable to reset ΔTWS to zero in every time step
    
  

`compute`:
- **Inputs**
  - `pools.TWS`: terrestrial water storage including all water pools
    
  - `pools.ΔTWS`: change in water storage in TWS pool(s)
    
  - `pools.zeroΔTWS`: helper variable to reset ΔTWS to zero in every time step
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  
- **Outputs**
  - `pools.ΔTWS`: change in water storage in TWS pool(s)
    
  - `pools.TWS`: terrestrial water storage including all water pools
    
  - `states.total_water`: sum of water storage across all components
    
  - `states.total_water_prev`: sum of water storage across all components in previous time step
    
  

`precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `wCycle_combined.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


== wCycle_components
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.wCycle_components' href='#Sindbad.Models.wCycle_components'><span class="jlbinding">Sindbad.Models.wCycle_components</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



update the water cycle pools per component

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `pools.groundW`: water storage in groundW pool(s)
    
  - `pools.snowW`: water storage in snowW pool(s)
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.surfaceW`: water storage in surfaceW pool(s)
    
  - `pools.TWS`: terrestrial water storage including all water pools
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  - `pools.ΔsnowW`: change in water storage in snowW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.ΔsurfaceW`: change in water storage in surfaceW pool(s)
    
  - `pools.ΔTWS`: change in water storage in TWS pool(s)
    
  - `constants.z_zero`: a helper type stable 0 to be used across all models
    
  - `constants.o_one`: a helper type stable 1 to be used across all models
    
  - `models.w_model`: a base water cycle model to loop through the pools and fill the main or component pools needed for using static arrays. A mandatory field for every water model/pool realization
    
  
- **Outputs**
  - `pools.groundW`: water storage in groundW pool(s)
    
  - `pools.snowW`: water storage in snowW pool(s)
    
  - `pools.soilW`: water storage in soilW pool(s)
    
  - `pools.surfaceW`: water storage in surfaceW pool(s)
    
  - `pools.TWS`: terrestrial water storage including all water pools
    
  - `pools.ΔgroundW`: change in water storage in groundW pool(s)
    
  - `pools.ΔsnowW`: change in water storage in snowW pool(s)
    
  - `pools.ΔsoilW`: change in water storage in soilW pool(s)
    
  - `pools.ΔsurfaceW`: change in water storage in surfaceW pool(s)
    
  - `states.total_water`: sum of water storage across all components
    
  - `states.total_water_prev`: sum of water storage across all components in previous time step
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `wCycle_components.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.11.2019 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### wCycleBase {#wCycleBase}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.wCycleBase' href='#Sindbad.Models.wCycleBase'><span class="jlbinding">Sindbad.Models.wCycleBase</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
set the basics of the water cycle pools
```



---


**Approaches**
- `wCycleBase_simple`: counts the number of layers in each water storage pools
  

</details>


:::details wCycleBase approaches

:::tabs

== wCycleBase_simple
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.wCycleBase_simple' href='#Sindbad.Models.wCycleBase_simple'><span class="jlbinding">Sindbad.Models.wCycleBase_simple</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



counts the number of layers in each water storage pools

**Parameters**
- None
  

**Methods:**

`define`:
- **Inputs**
  - None
    
  
- **Outputs**
  - `models.w_model`: a base water cycle model to loop through the pools and fill the main or component pools needed for using static arrays. A mandatory field for every water model/pool realization
    
  

`precompute, compute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `wCycleBase_simple.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 18.07.2023 [skoirala | @dr-ko]
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


### waterBalance {#waterBalance}
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.waterBalance' href='#Sindbad.Models.waterBalance'><span class="jlbinding">Sindbad.Models.waterBalance</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Calculate the water balance
```



---


**Approaches**
- `waterBalance_simple`: check the water balance in every time step
  

</details>


:::details waterBalance approaches

:::tabs

== waterBalance_simple
<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.waterBalance_simple' href='#Sindbad.Models.waterBalance_simple'><span class="jlbinding">Sindbad.Models.waterBalance_simple</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



check the water balance in every time step

**Parameters**
- None
  

**Methods:**

`compute`:
- **Inputs**
  - `fluxes.precip`: total land precipitation including snow and rain
    
  - `states.total_water_prev`: sum of water storage across all components in previous time step
    
  - `states.total_water`: sum of water storage across all components
    
  - `states.WBP`: water balance tracker pool that starts with rain and ends up with 0 after allocating to soil percolation
    
  - `fluxes.evapotranspiration`: total land evaporation including soil evaporation, vegetation transpiration, snow sublimation, and interception loss
    
  - `fluxes.runoff`: total runoff
    
  
- **Outputs**
  - `diagnostics.water_balance`: misbalance of the water for the given time step calculated as the differences between total input, output and change in storages
    
  

`define, precompute, update` methods are not defined

_End of `getModelDocString`-generated docstring for `waterBalance_simple.jl`. Check the Extended help for user-defined information._


---


**Extended help**

_References_

_Versions_
- 1.0 on 11.11.2019
  
- 1.1 on 20.11.2019 [skoirala | @dr-ko]:
  

_Created by_
- skoirala | @dr-ko
  

</details>


:::


---


## Internal {#Internal}


<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.calcPropsSaxton1986-Tuple{soilProperties_Saxton1986, Vararg{Any, 4}}' href='#Sindbad.Models.calcPropsSaxton1986-Tuple{soilProperties_Saxton1986, Vararg{Any, 4}}'><span class="jlbinding">Sindbad.Models.calcPropsSaxton1986</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



calculates the soil hydraulic properties based on Saxton 1986

**Extended help**

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.calcPropsSaxton2006-Tuple{soilProperties_Saxton2006, Any, Any, Any}' href='#Sindbad.Models.calcPropsSaxton2006-Tuple{soilProperties_Saxton2006, Any, Any, Any}'><span class="jlbinding">Sindbad.Models.calcPropsSaxton2006</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



calculates the soil hydraulic properties based on Saxton 2006

**Inputs:**
- : texture-based parameters
  
- info
  
- land.properties.sp_[clay/sand]: in fraction
  
- sl: soil layer to calculate property for
  

**Outputs:**
- hydraulic conductivity [k], matric potention [ψ] &amp; porosity  (θ) at saturation [Sat], field capacity [_fc], &amp; wilting point  ( w_wp)
  
- properties of moisture-retention curves: (α &amp; β)
  

**Modifies:**

**Extended help**

**References:**
- Saxton, K. E., &amp; Rawls, W. J. (2006). Soil water characteristic estimates by  texture &amp; organic matter for hydrologic solutions.  Soil science society of America Journal, 70[5], 1569-1578.
  

**Versions:**
- 1.0 on 22.11.2019 [skoirala | @dr-ko]:
  

**Created by**
- skoirala | @dr-ko
  

**Notes:**
- _fc: Field Capacity moisture [33 kPa], #v  
  
- PAW: Plant Avail. moisture [33-1500 kPa, matric soil], #v
  
- PAWB: Plant Avail. moisture [33-1500 kPa, bulk soil], #v
  
- SAT: Saturation moisture [0 kPa], #v
  
- w_wp: Wilting point moisture [1500 kPa], #v
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.compute-Tuple{LandEcosystem, Any, Any, Any}' href='#Sindbad.Models.compute-Tuple{LandEcosystem, Any, Any, Any}'><span class="jlbinding">Sindbad.Models.compute</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
compute(params<:LandEcosystem, forcing, land, helpers)
```


Update the model state and variables in time using defined and precomputed objects.

**Description**

The `compute` function is responsible for advancing the state of a SINDBAD model or approach in time. It uses previously defined and precomputed variables, along with updated forcing data, to calculate the time-dependent changes in the land model state. This function ensures that the model evolves dynamically based on the latest inputs and precomputed states.

**Arguments**
- `params`: The parameter structure for the specific SINDBAD model or approach.
  
- `forcing`: External forcing data required for the model or approach.
  
- `land`: The land model state, which includes pools, diagnostics, and properties.
  
- `helpers`: Additional helper functions or data required for computations.
  

**Returns**
- The updated `land` model state with time-dependent changes applied.
  

**Behavior**
- For each SINDBAD model or approach, the `compute` function updates the land model state based on the specific requirements of the model or approach.
  
- It may include operations like updating pools, recalculating fluxes, or modifying diagnostics based on time-dependent forcing and precomputed variables.
  
- This function is typically called iteratively to simulate the temporal evolution of the model.
  

**Example**

```julia
# Example usage for a specific model
land = compute(params::ambientCO2_constant, forcing, land, helpers)
```


**Notes:**

The compute function is essential for SINDBAD models and approaches that require dynamic updates to the land model state over time. It ensures that the model evolves consistently with the defined and precomputed variables, as well as the latest forcing data. This function is a core component of the SINDBAD framework&#39;s time-stepping process

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.define-Tuple{LandEcosystem, Any, Any, Any}' href='#Sindbad.Models.define-Tuple{LandEcosystem, Any, Any, Any}'><span class="jlbinding">Sindbad.Models.define</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
define(params<:LandEcosystem, forcing, land, helpers)
```


Define and initialize arrays and variables for a SINDBAD model or approach.

**Description**

The `define` function is responsible for defining and initializing arrays for variables of pools or states that are required for a SINDBAD model or approach. It is typically called once to set up `memory-allocating` variables whose values can be overwritten during model computations.

**Arguments**
- `params`: The parameter structure for the specific SINDBAD model or approach.
  
- `forcing`: External forcing data required for the model or approach.
  
- `land`: The land model state, which includes pools, diagnostics, and properties.
  
- `helpers`: Additional helper functions or data required for initialization.
  

**Returns**
- The updated `land` model state with defined arrays and variables.
  

**Behavior**
- For each SINDBAD model or approach, the `define` function initializes arrays and variables based on the specific requirements of the model or approach.
  
- It may include operations like unpacking parameters, defining arrays, or setting default values for variables.
  
- This function is typically used to prepare the land model state for subsequent computations.
  
- It is called once at the beginning of the simulation to set up the necessary variables. So, any variable whole values are changing based on model parameters so actually be overwritten in the precompute or compute function.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.getModelDocString' href='#Sindbad.Models.getModelDocString'><span class="jlbinding">Sindbad.Models.getModelDocString</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getModelDocString()
```


Generate a base docstring for a SINDBAD model or approach.

**Description**

This function dynamically generates a base docstring for a SINDBAD model or approach by inspecting its purpose, parameters, methods, and input/output variables. It uses the stack trace to determine the calling context and retrieves the appropriate information for the model or approach.

**Arguments**
- None (uses the stack trace to determine the calling context).
  

**Returns**
- A string containing the generated docstring for the model or approach.
  

**Behavior**
- If the caller is a model, it generates a docstring with the model&#39;s purpose and its subtypes (approaches).
  
- If the caller is an approach, it generates a docstring with the approach&#39;s purpose, parameters, and methods (`define`, `precompute`, `compute`, `update`), including their inputs and outputs.
  

**Methods**
- `getModelDocString()`: Determines the calling context using the stack trace and generates the appropriate docstring.
  
- `getModelDocString(modl_appr)`: Generates a docstring for a specific model or approach.
  
- `getModelDocStringForModel(modl)`: Generates a docstring for a SINDBAD model, including its purpose and subtypes.
  
- `getApproachDocString(appr)`: Generates a docstring for a SINDBAD approach, including its purpose, parameters, and methods.
  
- `getModelDocStringForIO(doc_string, io_list)`: Appends input/output details to the docstring for a given list of variables.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.includeApproaches-Tuple{Any, Any}' href='#Sindbad.Models.includeApproaches-Tuple{Any, Any}'><span class="jlbinding">Sindbad.Models.includeApproaches</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
includeApproaches(modl, dir)
```


Include all approach files for a given SINDBAD model.

**Description**

This function dynamically includes all approach files associated with a specific SINDBAD model. It searches the specified directory for files matching the naming convention `<model_name>_*.jl` and includes them into the current module.

**Arguments**
- `modl`: The SINDBAD model for which approaches are to be included.
  
- `dir`: The directory where the approach files are located.
  

**Behavior**
- The function filters files in the specified directory to find those that match the naming convention `<model_name>_*.jl`.
  
- Each matching file is included using Julia&#39;s `include` function.
  

**Example**

```julia
# Include approaches for the `ambientCO2` model
includeApproaches(ambientCO2, "/path/to/approaches")
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.precompute-Tuple{LandEcosystem, Any, Any, Any}' href='#Sindbad.Models.precompute-Tuple{LandEcosystem, Any, Any, Any}'><span class="jlbinding">Sindbad.Models.precompute</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
precompute(params<:LandEcosystem, forcing, land, helpers)
```


Update defined variables and arrays with new realizations of a SINDBAD model or approach.

**Description**

The `precompute` function is responsible for updating previously defined arrays, variables, or states with new realizations of a SINDBAD model or approach. It uses updated parameters, forcing data, and helper functions to modify the land model state. This function ensures that the model is prepared for subsequent computations with the latest parameter values and external inputs.

**Arguments**
- `params`: The parameter structure for the specific SINDBAD model or approach.
  
- `forcing`: External forcing data required for the model or approach.
  
- `land`: The land model state, which includes pools, diagnostics, and properties.
  
- `helpers`: Additional helper functions or data required for updating variables.
  

**Returns**
- The updated `land` model state with modified arrays and variables.
  

**Behavior**
- For each SINDBAD model or approach, the `precompute` function updates variables and arrays based on the specific requirements of the model or approach.
  
- It may include operations like recalculating variables, applying parameter changes, or modifying arrays to reflect new realizations of the model.
  
- This function is typically used to prepare the land model state for time-dependent computations.
  

**Example**

```julia
# Example usage for a specific model
land = precompute(params::ambientCO2_constant, forcing, land, helpers)
```



---


**Extended help**

The precompute function is essential for SINDBAD models and approaches that require dynamic updates to variables and arrays based on new parameter values or forcing data. It ensures that the land model state is properly updated and ready for further computations, such as compute or update.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.throwError-Tuple{Any, Any}' href='#Sindbad.Models.throwError-Tuple{Any, Any}'><span class="jlbinding">Sindbad.Models.throwError</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



throwError(land, msg) display and error msg and stop when there is inconsistency

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Sindbad.Models.update-Tuple{LandEcosystem, Any, Any, Any}' href='#Sindbad.Models.update-Tuple{LandEcosystem, Any, Any, Any}'><span class="jlbinding">Sindbad.Models.update</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
update(params<:LandEcosystem, forcing, land, helpers)
```


Update the model pools and variables within a single time step when activated via `inline_update` in experiment_json.

**Description**

The `update` function is responsible for modifying the pools of a SINDBAD model or approach within a single time step. It uses the latest forcing data, precomputed variables, and defined parameters to update the pools. This means that the model pools, typically of the water cycle, are updated before the next processes are called.

**Arguments**
- `params`: The parameter structure for the specific SINDBAD model or approach.
  
- `forcing`: External forcing data required for the model or approach.
  
- `land`: The land model state, which includes pools, diagnostics, and properties.
  
- `helpers`: Additional helper functions or data required for computations.
  

**Returns**
- The updated `land` model pool with changes applied for the current time step.
  

**Behavior**
- For each SINDBAD model or approach, the `update` function modifies the pools and state variables based on the specific requirements of the model or approach. 
  
- It may include operations like adjusting carbon or water pools, recalculating fluxes, or updating diagnostics based on the current time step&#39;s inputs and conditions.
  
- This function is typically called iteratively during the simulation to reflect time-dependent changes.
  

**Example**

```julia
# Example usage for a specific model
land = update(params::ambientCO2_constant, forcing, land, helpers)
```


**Notes:**

The update function is essential for SINDBAD models and approaches that require dynamic updates to the land model state within a single time step. It ensures that the model accurately reflects the changes occurring during the current time step, based on the latest forcing data and precomputed variables. This function is a core component of the SINDBAD framework&#39;s time-stepping process.

</details>

