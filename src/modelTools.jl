
export getInOutModel
export getInOutModels
export getTypedModel
export modelParameter
export modelParameters


"""
    getInOutModel(model::LandEcosystem)

helper/wrapper function to parse all the input/output/parameter of a given SINDBAD model and ALL functions

# Arguments:
- `model`: a SINDBAD model instance
"""
function getInOutModel(model::LandEcosystem)
    mo_in_out=Sindbad.DataStructures.OrderedDict()
    println("   collecting I/O/P of: $(nameof(typeof(model))).jl")
    for func in (:parameters, :compute, :define, :precompute, :update)
        println("   ...$(func)...")
        io_func = getInOutModel(model, func)
        mo_in_out[func] = io_func
    end
    return mo_in_out
end


"""
    getInOutModel(model::LandEcosystem, model_funcs::Tuple)

helper/wrapper function to parse the input/output/parameter of a given SINDBAD model and a tuple of functions

# Arguments:
- `model`: a SINDBAD model instance
- `model_funcs`: a tuple of symbol for the model functions, e.g. (:precompute, :parameters) , to parse
"""
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

"""
    getInOutModel(model, model_func::Symbol)

parse the input/output/parameter of a given SINDBAD model function

# Arguments:
- `model`: a SINDBAD model instance
- `model_func`: a symbol for the model function, e.g. :precompute or :parameters, to parse
"""
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
        mod_code = @code_string Sindbad.Models.compute(model, nothing, nothing, nothing)
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
    getInOutModels(ind_range=1:10000::UnitRange{Int64})

parse the input and output of ALL SINDBAD models

# Arguments:
- `ind_range`: a range to select the models from all possible SINDBAD models. By default, all models are parsed, but a subset can be parsed by passing a range, e.g., 1:10
"""
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


"""
    getInOutModels(models::Tuple)

parse the input and output of SINDBAD model compute functions and parameters

# Arguments:
- `models`: a list/collection of instantiated SINDBAD models
"""
function getInOutModels(models::Tuple)
    mod_vars = Sindbad.DataStructures.OrderedDict()
    for (mi, _mod) in enumerate(models)
        mod_name = string(nameof(supertype(typeof(_mod))))
        mod_name_sym=Symbol(mod_name)
        mod_vars[mod_name_sym] = getInOutModel(_mod, (:compute, :parameters))
    end
    return mod_vars
end


"""
    getInOutModels(models, model_funcs::Tuple)

parse the input and output of SINDBAD model functions

# Arguments:
- `models`: a list/collection of instantiated SINDBAD models
- `model_funcs`: a tuple of symbols for the model functions, e.g. (:precompute, :compute, ), to parse
"""
function getInOutModels(models, model_funcs::Tuple)
    mod_vars = Sindbad.DataStructures.OrderedDict()
    for (mi, _mod) in enumerate(models)
        mod_name = string(nameof(supertype(typeof(_mod))))
        mod_name_sym=Symbol(mod_name)
        mod_vars[mod_name_sym] = getInOutModel(_mod, model_funcs)
    end
    return mod_vars
end


"""
    getInOutModels(models, model_func::Symbol)

parse the input and output of SINDBAD model functions

# Arguments:
- `models`: a list/collection of instantiated SINDBAD models
- `model_func`: a symbol for the model function, e.g. :precompute, to parse
"""
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
    getTypedModel(model::String, num_type=Float64)

get SINDBAD model, and instatiate it with the given datatype

# Arguments:
- `model`: a string SINDBAD model name
- `num_type`: a number type to use for model parameters
"""
function getTypedModel(model::String, num_type=Float64)
    getTypedModel(Symbol(model), num_type)
end


"""
    getTypedModel(model::Symbol, num_type=Float64)

get SINDBAD model, and instatiate it with the given datatype

# Arguments:
- `model::Symbol`: a SINDBAD model name
- `num_type`: a number type to use for model parameters
"""
function getTypedModel(model::Symbol, num_type=Float64)
    model_obj = getfield(Sindbad.Models, model)
    model_instance = model_obj()
    param_names = fieldnames(model_obj)
    if length(param_names) > 0
        param_vals = []
        for pn ∈ param_names
            param = getfield(model_obj(), pn)
            param_typed = if typeof(param) <: Array
                num_type.(param)
            else
                num_type(param)
            end
            push!(param_vals, param_typed)
        end
        model_instance = model_obj(param_vals...)
    end
    return model_instance
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

returns/shows the current parameters of a given model (Symbol) [NOT APPRAOCH] from the list of models provided

# Arguments:
- `models`: a list/collection of SINDBAD models
- `model`: a SINDBAD model name
"""
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
            println("   $fn => $(getproperty(mod, fn))")
        end
    end
    return p_dict
end


"""
    modelParameter(model::LandEcosystem, show=true)

returns and shows the current parameters of a given model instance of type LandEcosystem

# Arguments:
- `model`: a SINDBAD model instance
- `show`: a flag to print parameter in the screen
"""
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
            Pair(fn, getproperty(model, fn))
        end
    end
    return p_vec
end