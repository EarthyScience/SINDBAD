export generateSindbadApproach

"""
    generateApproachCode(model_name, appr_name, appr_purpose, n_parameters; methods=(:define, :precompute, :compute, :update))

Generate the code template for a SINDBAD approach. 
    
# Description
The `generateApproachCode` function creates a code template for a SINDBAD approach. It defines the structure, parameters, methods, and documentation for the approach, ensuring consistency with the SINDBAD framework. The generated code includes placeholders for methods (`define`, `precompute`, `compute`, `update`) and automatically generates a docstring for the approach.

# Arguments
- `model_name`: The name of the SINDBAD model to which the approach belongs.
- `appr_name`: The name of the approach to be generated.
- `appr_purpose`: A string describing the purpose of the approach.
- `n_parameters`: The number of parameters required by the approach.
- `methods`: A tuple of method names to include in the approach (default: `(:define, :precompute, :compute, :update)`).

# Returns
- A string containing the generated code template for the approach.

# Behavior
- If `n_parameters` is greater than 0, the function generates a parameterized structure for the approach, including default values and metadata for each parameter.
- For each method in `methods`, the function generates a placeholder implementation with comments and instructions for customization.
- The function also generates a purpose definition and a docstring for the approach, including placeholders for extended help, references, and versioning.

# Example
```julia
# Generate code for an approach with 2 parameters
approach_code = generateApproachCode(:ambientCO2, :ambientCO2_constant, "sets ambient_CO2 as a constant", 2)

println(approach_code)
```
"""
function generateApproachCode(model_name, appr_name, appr_purpose, n_parameters; methods=(:define, :precompute, :compute, :update))
    m_string = "export $(appr_name)\n\n"
    if n_parameters == 0
        m_string *= "\nstruct $(appr_name) <: $(model_name) end\n"
    else
        m_string *= "#! format: off"
        t_string =join("T".*string.(1:n_parameters), ",")
        # m_string *= "\n@bounds @describe @units @timescale @with_kw struct $(appr_name) \n"
            m_string *= "\n@bounds @describe @units @timescale @with_kw struct $(appr_name){$(t_string)} <: $(model_name)\n"
        for i in 1:n_parameters
            m_string *= "\tP$(i)::T$(i) = Inf | (-Inf, Inf) | \"parameter $(i)\" | \"parameter $(i) unit\" | \"parameter $(i) timescale\"\n"
        end
        m_string *= "end\n"
        m_string *= "#! format: on\n"
    end
    for m_t in methods;
        m_string *= "\nfunction $(m_t)(params::$(appr_name), forcing, land, helpers)\n"
        if m_t == :compute
            m_string *= "\t## Automatically generated sample code for basis. Modify, correct, and use. define, precompute, and update methods can use similar coding when needed. When not, they can simply be deleted. \n"
            if n_parameters > 0
                m_string *= "\t@unpack_$(appr_name) params # unpack the model parameters\n"
            end
            m_string *= "\t## unpack NT forcing\n"
            m_string *= "\t# @unpack_nt f_variable ⇐ forcing\n\n"
            m_string *= "\t## unpack NT land\n"
            m_string *= "\t# @unpack_nt begin\n\t\t# flux_variable ⇐ land.fluxes\n\t\t# state_variable ⇐ land.states\n\t# end\n\n"
            m_string *= "\t## Do calculations\n\n"
            m_string *= "\t## pack land variables\n"
            m_string *= "\t# @pack_nt new_diagnostic_variable ⇒ land.diagnostics\n\n"
        end
        m_string *= "\treturn land\n"
        m_string *= "end\n"
    end
    m_string *= "\npurpose(::Type{$(appr_name)}) = \"$(appr_purpose)\"\n\n"
    m_string *= "@doc \"\"\" \n\n"
    m_string *= "\t\$(getModelDocString($(appr_name)))\n\n"

    m_string *= "---\n\n"

    m_string *= "# Extended help\n\n"
    
    m_string *= "*References*\n\n"

    m_string *= "*Versions*\n"

    run(`date +%d.%m.%Y`);
    date = strip(read(`date +%d.%m.%Y`, String));

    m_string *= " - 1.0 on $(date) [$(Sys.username())]\n\n"
    
    m_string *= "*Created by*\n"
    m_string *= " - $(Sys.username())\n\n"
    m_string *= "\"\"\"\n"
    m_string *= "$(appr_name)\n\n"
    return m_string
end

"""
    generateModelCode(model_name, model_purpose)

Generate the code template for a SINDBAD model.

# Description
The `generateModelCode` function creates a code template for a SINDBAD model. It defines the model's structure, purpose, and includes all associated approaches. The generated code ensures consistency with the SINDBAD framework and provides a standardized starting point for defining new models.

# Arguments
- `model_name`: The name of the SINDBAD model to be generated.
- `model_purpose`: A string describing the purpose of the model.

# Returns
- A string containing the generated code template for the model.

# Behavior
- Defines the model as an abstract type that inherits from `LandEcosystem`.
- Sets the purpose of the model using the `purpose` function.
- Includes all approaches associated with the model using the `includeApproaches` function.
- Generates a placeholder docstring for the model, including a reference to `\$(getModelDocString)`.

# Example
```julia
# Generate code for a SINDBAD model
model_code = generateModelCode(:ambientCO2, "Represents the ambient CO2 concentration in the ecosystem.")

println(model_code)
```
"""
function generateModelCode(model_name, model_purpose)
    m_string = "export $(model_name)\n"
    m_string *= "\nabstract type $(model_name) <: LandEcosystem end\n"
    m_string *= "\npurpose(::Type{$(model_name)}) = \"$(model_purpose)\"\n"
    m_string *= "\nincludeApproaches($(model_name), @__DIR__)\n\n"
    m_string *= "@doc \"\"\" \n\t\$(getModelDocString($(model_name)))\n\"\"\"\n"
    m_string *= "$(model_name)\n\n"
    return m_string
end

"""
    generateSindbadApproach(model_name::Symbol, model_purpose::String, appr_name::Symbol, appr_purpose::String, n_parameters::Int; methods=(:define, :precompute, :compute, :update), force_over_write=:none)

Generate a SINDBAD model and/or approach with code templates.

**Due to risk of overwriting code, the function only succeeds if y|Y||Yes|Ya, etc., are given in the confirmation prompt. This function only works if the call is copy-pasted into the REPL and not evaluated from a file/line. See the example below for the syntax.**

# Description
The `generateSindbadApproach` function creates a SINDBAD model and/or approach by generating code templates for their structure, parameters, methods, and documentation. It ensures consistency with the SINDBAD framework and adheres to naming conventions. If the model or approach already exists, it avoids overwriting existing files unless explicitly permitted. The generated code includes placeholders for methods (`define`, `precompute`, `compute`, `update`) and automatically generates docstrings for the model and approach. 
    
*Note that the newly created approaches are tracked by changes in `tmp_precompile_placeholder.jl` in the Sindbad root. The new models/approaches are automatically included ONLY when REPL is restarted.*

# Arguments
- `model_name`: The name of the SINDBAD model to which the approach belongs.
- `model_purpose`: A string describing the purpose of the model.
- `appr_name`: The name of the approach to be generated.
- `appr_purpose`: A string describing the purpose of the approach.
- `n_parameters`: The number of parameters required by the approach.
- `methods`: A tuple of method names to include in the approach (default: `(:define, :precompute, :compute, :update)`).
- `force_over_write`: A symbol indicating whether to overwrite existing files or types. Options are:
  - `:none` (default): Do not overwrite existing files or types.
  - `:model`: Overwrite the model file and type.
  - `:approach`: Overwrite the approach file and type.
  - `:both`: Overwrite both model and approach files and types.

# Returns
- `nothing`: The function generates the required files and writes them to the appropriate directory.

# Behavior
- If the model does not exist, it generates a new model file with the specified `model_name` and `model_purpose`.
- If the approach does not exist, it generates a new approach file with the specified `appr_name`, `appr_purpose`, and `n_parameters`.
- Ensures that the approach name follows the SINDBAD naming convention (`<model_name>_<approach_name>`).
- Prompts the user for confirmation before generating files to avoid accidental overwrites.
- Includes placeholders for methods (`define`, `precompute`, `compute`, `update`) and generates a consistent docstring for the approach.

# Example
```julia
# Generate a new SINDBAD approach for an existing model

generateSindbadApproach(:ambientCO2, "Represents ambient CO2 concentration", :constant, "Sets ambient CO2 as a constant", 1)

# Generate a new SINDBAD model and approach

generateSindbadApproach(:newModel, "Represents a new SINDBAD model", :newApproach, "Implements a new approach for the model", 2)

# Generate a SINDBAD model and approach with force_over_write

generateSindbadApproach(:newModel, "Represents a new SINDBAD model", :newApproach, "Implements a new approach for the model", 2; force_over_write=:both) # overwrite both model and approach

generateSindbadApproach(:newModel, "Represents a new SINDBAD model", :newApproach, "Implements a new approach for the model", 2; force_over_write=:approach) # overwrite just approach approach
```
# Notes
- The function ensures that the generated code adheres to SINDBAD conventions and includes all necessary metadata and documentation.
- If the model or approach already exists, the function does not overwrite the files unless explicitly confirmed by the user.
- The function provides warnings and prompts to ensure safe file generation and minimize the risk of accidental overwrites.
"""
function generateSindbadApproach(model_name::Symbol, model_purpose::String, appr_name::Symbol, appr_purpose::String, n_parameters::Int; methods=(:define, :precompute, :compute, :update), force_over_write=:none)
    was_model_created = false
    was_approach_created = false
    over_write_model = false
    over_write_appr = false
    if force_over_write == :none
        @info "Overwriting of type and file is off. Only new objects will be created"
    elseif force_over_write == :model
        over_write_model = true
        @warn "Overwriting of type and file for Model is permitted. Continue with care."
    elseif force_over_write == :approach
        over_write_appr = true
        @warn "Overwriting of type and file for Approach is permitted. Continue with care."
    elseif force_over_write == :both
        @warn "Overwriting of both type and files for Model and Approach are permitted. Continue with extreme care."
        over_write_model = true
        over_write_appr = true
    else
        error("force_over_write can only be one of (:none, :both, :model, :approach)")
    end    

    if !startswith(string(appr_name), string(model_name)*"_")
        @warn "the name $(appr_name) does not start with $(model_name), which is against the SINDBAD model component convention. Using $(model_name)_$(appr_name) as the name of the approach."
        appr_name = Symbol(string(model_name) *"_"* string(appr_name))
    end
    model_type_exists = model_name in nameof.(subtypes(LandEcosystem)) 
    model_path = joinpath(split(pathof(Sindbad),"/SindbadTEM.jl")[1], "Models", "$(model_name)", "$(model_name).jl")
    model_path_exists = isfile(model_path)
    appr_path = joinpath(split(pathof(Sindbad),"/SindbadTEM.jl")[1], "Models", "$(model_name)", "$(appr_name).jl")
    appr_path_exists = isfile(appr_path)

    model_path_exists = over_write_model ? false : model_path_exists

    model_exists = false
    if model_type_exists && model_path_exists
        @info "both model_path and model_type exist. No need to create the model."
        model_exists = true
    elseif model_type_exists && !model_path_exists
        @warn "model_type exists but (model_path does not exist || force_over_write is enabled with :$(force_over_write)). If force_over_write is not enabled, fix the inconsistency by moving the definition of th type to the file itself."
    elseif !model_type_exists && model_path_exists
        @warn "model_path exists but model_type does not exist. Fix this inconsistency by defining the type in the file."
        model_exists = true
    else
        @info "both model_type and (model_path do not exist || force_over_write is enabled with :$(force_over_write)). Model will be created."
    end

    if model_exists
        @info "Not generating model "
    else
        @info "Generating a new model: $(model_name) at:\n$(appr_path)"
        confirm_ = Base.prompt("Continue: y | n")
        if startswith(confirm_, "y")
            @info "Generating model code:"
            m_string=generateModelCode(model_name, model_purpose)
            mkpath(dirname(model_path))
            @info "Writing model code:"
            open(model_path, "w") do model_file
                write(model_file, m_string)
            end
            @info "success: $(model_path)"
            was_model_created = true
        end
    end

    appr_exists = false
    appr_type_exists = false
    if hasproperty(SindbadTEM.Models, model_name)
        model_type = getproperty(SindbadTEM.Models, model_name)
        appr_types = nameof.(subtypes(model_type))
        appr_type_exists = appr_name in appr_types
    end

    appr_path_exists = over_write_appr ? false : appr_path_exists

    if appr_type_exists && appr_path_exists
        @info "both appr_path and appr_type exist. No need to create the approach."
        appr_exists = true
    elseif appr_type_exists && !appr_path_exists
        @warn "appr_type exists but (appr_path does not exist || force_over_write is enabled with :$(force_over_write))). If force_over_write is not enabled, fix this inconsistency by defining the type in the file itself."
    elseif !appr_type_exists && appr_path_exists
        @warn "appr_path exists but appr_type does not exist. Fix this inconsistency by defining the type in the file."
    else
        @info "both appr_type and (appr_path do not exist || force_over_write is enabled with :$(force_over_write)). Approach will be created."
    end
    
    if appr_exists
        @info "Not generating approach."
    else
        appr_path = joinpath(split(pathof(Sindbad),"/SindbadTEM.jl")[1], "Models", "$(model_name)", "$(appr_name).jl")
        @info "Generating a new approach: $(appr_name) for existing model: $(model_name) at:\n$(appr_path)"
        confirm_ = Base.prompt("Continue: y | n")
        if startswith(confirm_, "y")
            @info "Generating code:"
            appr_string = generateApproachCode(model_name, appr_name, appr_purpose, n_parameters; methods=methods)
            @info "Writing code:"
            open(appr_path, "w") do appr_file
                write(appr_file, appr_string)
            end
            @info "success: $(appr_path)"
            was_approach_created = true
        else
            @info "Not generating approach file due to user input."
        end
    end

    ## append the tmp_precompile_placeholder file so that Sindbad is forced to precompile in the next run_helpers
    if was_model_created || was_approach_created
        # Specify the file path
        file_path = joinpath(@__DIR__, "tmp_precompile_placeholder.jl")

        # The line you want to add
        date = strip(read(`date +%d.%m.%Y`, String));

        new_lines = []
        if was_model_created
            new_line = "# - $(date): created a model $model_path.\n"
            push!(new_lines, new_line)
        end

        if was_approach_created
            new_line = "# - $(date): created an approach $appr_path.\n"
            push!(new_lines, new_line)
        end

        # Open the file in append mode
        open(file_path, "a") do file
            foreach(new_lines) do new_line
                write(file, new_line)
            end
        end  

    end
    return nothing
end
