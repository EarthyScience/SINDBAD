
export getInOutModel
export getInOutModels
export getTypedModel
export getUnitConversionForParameter
export modelParameter
export modelParameters


"""
    getInOutModel(model::LandEcosystem)
    getInOutModel(model::LandEcosystem, model_func::Symbol)
    getInOutModel(model::LandEcosystem, model_funcs::Tuple)

Parses and retrieves the inputs, outputs, and parameters (I/O/P) of SINDBAD models for specified functions or all functions.

# Arguments:
- `model::LandEcosystem`: A SINDBAD model instance. If no additional arguments are provided, parses all inputs, outputs, and parameters for all functions of the model.
- `model_func::Symbol`: (Optional) A single symbol representing a specific model function to parse (e.g., `:precompute`, `:parameters`, `:compute`).
- `model_funcs::Tuple`: (Optional) A tuple of symbols representing multiple model functions to parse (e.g., `(:precompute, :parameters)`).

# Returns:
- An `OrderedDict` containing the parsed inputs, outputs, and parameters for the specified functions or all functions of the model:
    - `:input`: A tuple of input variables for the model function(s).
    - `:output`: A tuple of output variables for the model function(s).
    - `:approach`: The name of the model or function being parsed.

# Notes:
- If `model_func` or `model_funcs` is not provided, the function parses all default SINDBAD model functions (`:parameters`, `:compute`, `:define`, `:precompute`, `:update`).
- For each function:
    - Inputs are extracted from lines containing `⇐`, `land.`, or `forcing.`.
    - Outputs are extracted from lines containing `⇒`.
    - Warnings are issued for unextracted variables from `land` or `forcing` that do not follow the convention of unpacking variables locally using `@unpack_nt`.
- If `:parameters` is included in `model_funcs`, the function directly retrieves model parameters using `modelParameter`.

# Examples:
1. **Parsing all functions of a model**:
```julia
model_io = getInOutModel(my_model)
```

2. **Parsing a specific function of a model**:
```julia
compute_io = getInOutModel(my_model, :compute)
```

3. **Parsing multiple functions of a model**:
```julia
io_data = getInOutModel(my_model, (:precompute, :parameters))
```

4. **Handling warnings for unextracted variables**:
    - If a variable from `land` or `forcing` is not unpacked using `@unpack_nt`, a warning is issued to encourage better coding practices.

"""
function getInOutModel end


function getInOutModel(T::Type{<:LandEcosystem}; verbose=false)
    return getInOutModel(T(), verbose=verbose)
end

function getInOutModel(model::LandEcosystem; verbose=true)
    if verbose
        println("   collecting I/O/P of: $(nameof(typeof(model))).jl")
    end
    mo_in_out=Sindbad.DataStructures.OrderedDict()
    for func in (:parameters, :compute, :define, :precompute, :update)
        if verbose
            println("   ...$(func)...")
        end
        io_func = getInOutModel(model, func)
        mo_in_out[func] = io_func
    end
    return mo_in_out
end


function getInOutModel(model::LandEcosystem, model_funcs::Tuple)
    mo_in_out=Sindbad.DataStructures.OrderedDict()
    println("   collecting I/O/P of: $(nameof(typeof(model))).jl")
    for func in model_funcs
        println("   ...$(func)...")
        io_func = getInOutModel(model, func)
        if length(model_funcs) == 2 && :parameters in model_funcs
            if func !== :parameters
                mo_in_out[:approach] = io_func[:approach]
                mo_in_out[:input] = io_func[:input]
                mo_in_out[:output] = io_func[:output]
            else
                mo_in_out[func] = io_func
            end
        end
    end
    return mo_in_out
end

function getInOutModel(model, model_func::Symbol)
    model_name = string(nameof(typeof(model)))
    mod_vars = Sindbad.DataStructures.OrderedDict{Symbol, Any}()
    mod_vars[:approach] = model_name
    if model_func == :compute
        mod_code = @code_string Sindbad.Models.compute(model, nothing, nothing, nothing)
    elseif model_func == :define
        mod_code = @code_string Sindbad.Models.define(model, nothing, nothing, nothing)
    elseif model_func == :parameters
        # mod_vars = modelParameter(model, false)
        return modelParameter(model, false)
    elseif model_func == :precompute
        mod_code = @code_string Sindbad.Models.precompute(model, nothing, nothing, nothing)
    elseif model_func == :update
        mod_code = @code_string Sindbad.Models.update(model, nothing, nothing, nothing)
    else
        error("can only check consistency in compute, define, params, precompute, and update of SINDBAD models. $(model_func) is not a suggested or recommended method to add to a SINDBAD model struct.")
    end

    mod_code_lines = strip.(split(mod_code, "\n"))

    # get the input vars
    in_lines_index = findall(x -> ((occursin("⇐", x) || occursin("land.", x) || occursin("forcing.", x))&& !occursin("for ", x) && !occursin("helpers.", x) && !startswith(x, "#")), mod_code_lines)
    in_all = map(in_lines_index) do in_in 
        mod_line = mod_code_lines[in_in]
        in_line = ""
        try 
            mod_line = strip(mod_line)
            in_line_src=""
            if occursin("⇐", mod_line)
                in_line = strip(split(mod_line, "⇐")[1])
                in_line_src = strip(split(mod_line, "⇐")[2])
                if occursin("@unpack_nt", in_line)
                    in_line=strip(split(in_line, "@unpack_nt")[2])
                end
                if occursin("@unpack_nt", in_line)
                    in_line=strip(split(in_line, "@unpack_nt")[2])
                end
                if occursin("land.", in_line_src)
                    in_line_src=strip(split(in_line_src, "land.")[2])
                end
                if occursin("forcing.", in_line_src)
                    in_line_src="forcing"
                end
            elseif occursin("land.", mod_line) && occursin("=", mod_line) && !occursin("⇒", mod_line) 
                in_line = strip(mod_line)
                @warn "Using an unextracted variable from land in $model_func function of $(model_name).jl in line $(in_line).\nWhile this is not necessarily a source of error, these variables are NOT used in consistency checks and may be prone to bugs and lead to cluttered code. Follow the convention of unpacking all variables to use locally using @unpack_nt."

                # rhs=strip(split(strip(mod_line), "=")[2])
            elseif occursin("forcing.", mod_line) && occursin("=", mod_line) && !occursin("⇒", mod_line) 
                in_line = strip(mod_line)
                # in_line=strip(split(strip(mod_line), "⇐")[1])
                @warn "Using an unextracted variable from forcing in  $model_func function of $(model_name).jl in line $(in_line).\nWhile this is not necessarily a source of error, these variables are NOT used in consistency checks and may be prone to bugs and lead to cluttered code. Follow the convention of unpacking all variables to use locally using @unpack_nt."
                in_line_src="forcing"
            end
            in_v_str = replace(strip(in_line), "(" => "",  ")" => "")
            in_v_list = [(strip(_v)) for _v in split(in_v_str, ",")[1:end]]
            in_v_list = Symbol.(in_v_list[(!isempty).(in_v_list)])

            in_line_src = Symbol(in_line_src)
            Pair.(Ref(in_line_src), in_v_list)
        catch e
            @error "Error extracting input information from $model_func function of $(model_name).jl in line $(in_line). Possibly due to a line break in call of @unpack_nt macro."
            error(e)
        end
    end
    mod_vars[:input] = Tuple(vcat(in_all...))

    # get the output vars
    out_lines_index = findall(x -> (occursin("⇒", x) && !occursin("_elem", x) && !occursin("@rep_", x) && !startswith(x, "#")), mod_code_lines)
    out_all = map(out_lines_index) do out_in
        out_line = strip(split(mod_code_lines[out_in], "⇒")[1])
        try
        out_line_tar = Symbol(strip(split(split(mod_code_lines[out_in], "⇒")[2], "land.")[2]))
            if occursin("@pack_nt", out_line)
                out_line=strip(split(out_line, "@pack_nt")[2])
            end
            out_v_str = replace(strip(out_line), "(" => "",  ")" => "")
            out_v_list = [(strip(_v)) for _v in split(out_v_str, ",")[1:end]]

            # @show out_v_list, (!isempty).(out_v_list)
            out_v_list = Symbol.(out_v_list[(!isempty).(out_v_list)])
            Pair.(Ref(out_line_tar), out_v_list)
        catch e
            @error "Error extracting output information from $model_func function of $(model_name).jl in line $(out_line). Possibly due to a line break in call of @pack_nt macro."
            error(e)
        end
    end
    mod_vars[:output] = Tuple(vcat(out_all...))
    return mod_vars
end

"""
    getInOutModels(ind_range::UnitRange{Int64}=1:10000)
    getInOutModels(models::Tuple)
    getInOutModels(models, model_funcs::Tuple)
    getInOutModels(models, model_func::Symbol)

Parses and retrieves the inputs, outputs, and parameters (I/O/P) of multiple SINDBAD models with varying levels of specificity.

# Arguments:
1. **For the first variant**:
    - `ind_range::UnitRange{Int64}`: A range to select models from all possible SINDBAD models (default: `1:10000`). 
      This can be set to a smaller range (e.g., `1:10`) to parse a subset of models for testing purposes.

2. **For the second variant**:
    - `models::Tuple`: A tuple of instantiated SINDBAD models. Used when working with specific model instances rather than selecting from all possible models.

3. **For the third variant**:
    - `models`: A tuple of instantiated SINDBAD models.
    - `model_funcs::Tuple`: A tuple of symbols representing model functions to parse (e.g., `(:precompute, :compute)`).
      Allows parsing multiple specific functions of the provided models.

4. **For the fourth variant**:
    - `models`: A tuple of instantiated SINDBAD models.
    - `model_func::Symbol`: A single symbol specifying one model function to parse (e.g., `:precompute`).
      Used when only one function's inputs and outputs need to be analyzed.

# Returns:
- An `OrderedDict` containing the parsed inputs, outputs, and parameters for the specified models and functions:
    - Keys represent the model names.
    - Values are `OrderedDict`s containing the parsed I/O/P for the specified functions.

# Notes:
- **Default Behavior**:
    - If `ind_range` is provided, the function selects models from the global SINDBAD model dictionary using the specified range.
    - If `model_funcs` or `model_func` is not provided, the function parses all default SINDBAD model functions (`:parameters`, `:compute`, `:define`, `:precompute`, `:update`).
- **Input and Output Parsing**:
    - Inputs are extracted from lines containing `⇐`, `land.`, or `forcing.`.
    - Outputs are extracted from lines containing `⇒`.
    - Warnings are issued for unextracted variables from `land` or `forcing` that do not follow the convention of unpacking variables locally using `@unpack_nt`.
- **Integration with `getInOutModel`**:
    - This function internally calls `getInOutModel` for each model and function to retrieve the I/O/P details.

# Examples:
1. **Parsing all models in a range**:
```julia
model_io = getInOutModels(1:10)
```

2. **Parsing specific models**:
```julia
model_io = getInOutModels((model1, model2))
```

3. **Parsing specific functions of models**:
```julia
model_io = getInOutModels((model1, model2), (:precompute, :compute))
```

4. **Parsing a single function of models**:
```julia
model_io = getInOutModels((model1, model2), :compute)
```

5. **Handling warnings for unextracted variables**:
    - If a variable from `land` or `forcing` is not unpacked using `@unpack_nt`, a warning is issued to encourage better coding practices.
"""
function getInOutModels end

function getInOutModels(ind_range=1:10000::UnitRange{Int64})
    sind_m_dict = getSindbadModels();
    sm_list = keys(sind_m_dict) |> collect
    s_ind = max(1, first(ind_range))
    e_ind = min(last(ind_range), length(sm_list))
    sm_io = Sindbad.DataStructures.OrderedDict()
    for s in sm_list[s_ind:e_ind]
        s_apr = sind_m_dict[s]
        if !isempty(s_apr)
            s_apr_s = join(s_apr, ".jl, ") * ".jl"
            sm_io[s]=Sindbad.DataStructures.OrderedDict()
            map(s_apr) do s_a
                s_a_name = Symbol(strip(last(split(string(s_a), string(s) * "_"))))
                s_a_t = getTypedModel(s_a)
                println("Model::: $s")
                io_model = getInOutModel(s_a_t)
                sm_io[s][s_a_name] = io_model
            end
        end
        println("-------------------------------------------")
    end
    return sm_io
end

function getInOutModels(models::Tuple)
    mod_vars = Sindbad.DataStructures.OrderedDict()
    for (mi, _mod) in enumerate(models)
        mod_name = string(nameof(supertype(typeof(_mod))))
        mod_name_sym=Symbol(mod_name)
        mod_vars[mod_name_sym] = getInOutModel(_mod, (:compute, :parameters))
    end
    return mod_vars
end

function getInOutModels(models, model_funcs::Tuple)
    mod_vars = Sindbad.DataStructures.OrderedDict()
    for (mi, _mod) in enumerate(models)
        mod_name = string(nameof(supertype(typeof(_mod))))
        mod_name_sym=Symbol(mod_name)
        mod_vars[mod_name_sym] = getInOutModel(_mod, model_funcs)
    end
    return mod_vars
end

function getInOutModels(models, model_func::Symbol)
    mod_vars = Sindbad.DataStructures.OrderedDict()
    for (mi, _mod) in enumerate(models)
        mod_name = string(nameof(supertype(typeof(_mod))))
        mod_name_sym=Symbol(mod_name)
        dict_key_name = mod_name_sym
        mod_vars[dict_key_name] = getInOutModel(_mod, model_func)
    end
    return mod_vars
end

"""
    getTypedModel(model::String, model_timestep="day", num_type=Float64)
    getTypedModel(model::Symbol, model_timestep="day", num_type=Float64)

Get a SINDBAD model and instantiate it with the given datatype.

# Arguments
- `model::String or Symbol`: A SINDBAD model name.
- `model_timestep`: A time step for the model run (default: `"day"`).
- `num_type`: A number type to use for model parameters (default: Float64).
"""
function getTypedModel end

function getTypedModel(model::String, model_timestep="day", num_type=Float64)
    getTypedModel(Symbol(model), model_timestep, num_type)
end

function getTypedModel(model::Symbol, model_timestep="day", num_type=Float64)
    model_obj = getfield(Sindbad.Models, model)
    model_instance = model_obj()
    parameter_names = fieldnames(model_obj)
    if length(parameter_names) > 0
        parameter_vals = []
        for pn ∈ parameter_names
            param = getParameterValue(model_obj(), pn, model_timestep)
            # param = getfield(model_obj(), pn)
            parameter_typed = if typeof(param) <: Array
                num_type.(param)
            else
                num_type(param)
            end
            push!(parameter_vals, parameter_typed)
        end
        model_instance = model_obj(parameter_vals...)
    end
    return model_instance
end

"""
    getParameterValue(model, parameter_name, model_timestep)

get a value of a given model parameter with units corrected

# Arguments:
- `model`: selected model
- `parameter_name`: name of the parameter
- `model_timestep`: time step of the model run
"""
function getParameterValue(model, parameter_name, model_timestep)
    param = getfield(model, parameter_name)
    p_timescale = Sindbad.Models.timescale(model, parameter_name)
    # return param
    return param * getUnitConversionForParameter(p_timescale, model_timestep)
end

"""
    getUnitConversionForParameter(p_timescale, model_timestep)

helper/wrapper function to get unit conversion factors for model parameters that are timescale dependent

# Arguments:
- `p_timescale`: time scale of a SINDBAD model parameter
- `model_timestep`: time step of the model run
"""
function getUnitConversionForParameter(p_timescale, model_timestep)
    conversion = 1
    time_multiplier = 1
    # time multiplier compared to daily time steps
    if model_timestep == "second"
        time_multiplier = 1/(60* 60 * 24)
    elseif model_timestep == "minute"
        time_multiplier = 1/(60 * 24)
    elseif model_timestep == "halfhour"
        time_multiplier = 1/48
    elseif model_timestep == "hour"
        time_multiplier = 1/24
    elseif model_timestep == "day"
        time_multiplier = 1
    elseif model_timestep == "week"
        time_multiplier = 7
    elseif model_timestep == "month"
        time_multiplier = 30
    elseif model_timestep == "year"
        time_multiplier = 365
    elseif model_timestep == "decade"
        time_multiplier = 365 * 10
    else
        error("running model at $(model_timestep) is not supported")
    end

    # modelling at other time steps
    if p_timescale == "second"
        conversion = 60 * 60 * 24 * time_multiplier
    elseif p_timescale == "minute"
            conversion = 60 * 24 * time_multiplier
    elseif p_timescale == "halfhour"
        conversion = 48 * time_multiplier
    elseif p_timescale == "hour"
        conversion = 24 * time_multiplier
    elseif p_timescale == "day"
        conversion = 1 * time_multiplier
    elseif p_timescale == "week"
        conversion = 1/7 * time_multiplier
    elseif p_timescale == "month"
        conversion = 1/30 * time_multiplier
    elseif p_timescale == "year"
        conversion = 1/365 * time_multiplier
    elseif p_timescale == "decade"
        conversion = 1/(365 * 10) * time_multiplier
    end
    return conversion
end


"""
    modelParameters(models)

shows the current parameters of all given models

# Arguments:
- `models`: a list/collection of SINDBAD models
"""
function modelParameters(models)
    for mn in sort([nameof.(supertype.(typeof.(models)))...])
        modelParameter(models, mn)
        println("------------------------------------------------------------------")
    end
    return nothing
end

"""
    modelParameter(models, model::Symbol)
    modelParameter(model::LandEcosystem, show=true)

Return and optionally display the current parameters of a given SINDBAD model.

# Arguments
- `models`: A list/collection of SINDBAD models, required when `model` is a Symbol.
- `model::Symbol`: A SINDBAD model name.
- `model::LandEcosystem`: A SINDBAD model instance of type LandEcosystem.
- `show::Bool`: A flag to print parameters to the screen (default: true).

"""
function modelParameter end

function modelParameter(models, model::Symbol)
    model_names = Symbol.(supertype.(typeof.(models)))
    approach_names = nameof.(typeof.(models))
    m_index = findall(m -> m == model, model_names)[1]
    mod = models[m_index]
    println("model: $(model_names[m_index])")
    println("approach: $(approach_names[m_index])")
    pnames = fieldnames(typeof(mod))
    p_dict = Sindbad.DataStructures.OrderedDict()
    if length(pnames) == 0
        println("parameters: none")
    else
        println("parameters:")
        foreach(pnames) do fn
            p_dict[fn] = getproperty(mod, fn)
            p_unit = Sindbad.Models.units(mod, fn)
            p_unit_info = p_unit == "" ? "unitless/fraction" : "($p_unit)"
            println("   $fn => $(getproperty(mod, fn)) $p_unit_info")
        end
    end
    return p_dict
end

function modelParameter(model::LandEcosystem, show=true)
    pnames = fieldnames(typeof(model))
    p_vec = []
    if show
        println("parameters:")
    end
    if length(pnames) == 0
        if show
            println("   non-parametric model")
        end
    else
        p_vec = map(pnames) do fn
            if show
                println("   $fn => $(getproperty(mod, fn))")
            end
            p_val = getproperty(model, fn)
            p_describe = Sindbad.Models.describe(model, fn)
            p_unit = Sindbad.Models.units(model, fn)
            p_u = isempty(p_unit) ? "undefined" : "$(p_unit)"
            p_timescale = Sindbad.Models.timescale(model, fn)
            p_t = isempty(p_timescale) ? "timescale independent" : "$(p_timescale) timescale"
            p_bounds = Sindbad.Models.bounds(model, fn)
            p_w = "$(p_val) ∈ [$(p_bounds[1]), $(p_bounds[2])] => $(p_describe) in $(p_u) units; $(p_t)"
            Pair(fn, p_w)
        end
    end
    return p_vec
end