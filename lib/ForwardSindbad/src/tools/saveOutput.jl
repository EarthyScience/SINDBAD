export saveOutCubes
export getGlobalAttributesForOutCubes
export getOutputFileInfo
export getVariableInfo

"""
    getVariableInfo(vari_b, t_step = day)

DOCSTRING
"""
function getVariableInfo(vari_b, t_step="day")
    vname = getVarFull(vari_b)
    return getVariableInfo(vname, t_step)
end

"""
    getVariableInfo(vari_b::Symbol, t_step = day)

DOCSTRING
"""
function getVariableInfo(vari_b::Symbol, t_step="day")
    catalog = sindbad_variables
    default_info = defaultVariableInfo(true)
    default_keys = Symbol.(keys(default_info))
    o_varib = copy(default_info)
    if vari_b ∈ keys(catalog)
        var_info = catalog[vari_b]
        var_fields = keys(var_info)
        all_fields = Tuple(unique([default_keys..., var_fields...]))
        for var_field ∈ all_fields
            field_value = nothing
            if haskey(default_info, var_field)
                field_value = default_info[var_field]
            else
                field_value = var_info[var_field]
            end
            if haskey(var_info, var_field)
                var_prop = var_info[var_field]
                if !isnothing(var_prop) && length(var_prop) > 0
                    field_value = var_info[var_field]
                end
            end
            if var_field == :units
                if !isnothing(field_value)
                    field_value = replace(field_value, "time" => t_step)
                else
                    field_value = ""
                end
            end
            var_field_str = string(var_field)
            o_varib[var_field_str] = field_value
        end
    end
    if isnothing(o_varib["standard_name"])
        o_varib["standard_name"] = split(vari_b, "__")[1]
    end
    if isnothing(o_varib["description"])
        o_varib["description"] = ""
    end
    return Dict(o_varib)
end

"""
    getModelDataArray(model_data::AbstractArray{T, 2})

DOCSTRING
"""
function getModelDataArray(model_data::AbstractArray{T,2}) where {T}
    return model_data[:, 1]
end

"""
    getModelDataArray(model_data::AbstractArray{T, 3})

DOCSTRING
"""
function getModelDataArray(model_data::AbstractArray{T,3}) where {T}
    return model_data[:, 1, :]
end

"""
    getModelDataArray(model_data::AbstractArray{T, 4})

DOCSTRING
"""
function getModelDataArray(model_data::AbstractArray{T,4}) where {T}
    return model_data[:, 1, :, :]
end

"""
    getVarName(var_pair)

DOCSTRING
"""
function getVarName(var_pair)
    return last(var_pair)
end

"""
    getVarField(var_pair)

DOCSTRING
"""
function getVarField(var_pair)
    return first(var_pair)
end

"""
    getVarFull(var_pair)

DOCSTRING
"""
function getVarFull(var_pair)
    return Symbol(String(first(var_pair)) * "__" * String(last(var_pair)))
    # return Symbol(String(last(var_pair)) * "__" * String(first(var_pair)))
end

"""
    getUniqueVarNames(data_vars)

DOCSTRING
"""
function getUniqueVarNames(data_vars)
    pure_vars = getVarName.(data_vars)
    fields = getVarField.(data_vars)
    uniq_vars = Symbol[]
    for i in eachindex(pure_vars)
        n_occur = sum(pure_vars .== pure_vars[i])
        var_i = pure_vars[i]
        if n_occur > 1
            var_i = Symbol(String(pure_vars[i]) * "__" * String(fields[i]))
        end
        push!(uniq_vars, var_i)
    end
    return uniq_vars
end

"""
    getYaxForVariable(data_out, data_dim, variable_name, catalog_name, t_step)

DOCSTRING

# Arguments:
- `data_out`: DESCRIPTION
- `data_dim`: DESCRIPTION
- `variable_name`: DESCRIPTION
- `catalog_name`: DESCRIPTION
- `t_step`: DESCRIPTION
"""
function getYaxForVariable(data_out, data_dim, variable_name, catalog_name, t_step)
    data_prop = getVariableInfo(catalog_name, t_step)
    if size(data_out, 2) == 1
        data_out = getModelDataArray(data_out)
    end
    data_yax = YAXArray(data_dim, data_out, data_prop)
    return data_yax
end

"""
    saveOutCubes(data_path_base, global_info, data_vars, data, data_dims, out_format, t_step, ::Val{:true})

saves the output variables from the run as one file
"""

"""
    saveOutCubes(data_path_base, global_info, data_vars, data, data_dims, out_format, t_step, nothing::Val{:(true)})

DOCSTRING

# Arguments:
- `data_path_base`: DESCRIPTION
- `global_info`: DESCRIPTION
- `data_vars`: DESCRIPTION
- `data`: DESCRIPTION
- `data_dims`: DESCRIPTION
- `out_format`: DESCRIPTION
- `t_step`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function saveOutCubes(data_path_base, global_info, data_vars, data, data_dims, out_format, t_step, ::Val{:true})
    @info "saving one file for all variables"
    catalog_names = getVarFull.(data_vars)
    variable_names = getUniqueVarNames(data_vars)
    all_yax = Tuple(getYaxForVariable.(data, data_dims, variable_names, catalog_names, Ref(t_step)))
    data_path = data_path_base * "_all_variables.$(out_format)"
    @info data_path
    ds_new = YAXArrays.Dataset(; (; zip(variable_names, all_yax)...)..., properties=global_info)
    savedataset(ds_new, path=data_path, append=true, overwrite=true)
    return nothing
end

"""
saveOutCubes(data_path_base, global_info, data_vars, data, data_dims, out_format, t_step, ::Val{:false})

saves the output variables from the run as one file per variable
"""

"""
    saveOutCubes(data_path_base, global_info, data_vars, data, data_dims, out_format, t_step, nothing::Val{:(false)})

DOCSTRING

# Arguments:
- `data_path_base`: DESCRIPTION
- `global_info`: DESCRIPTION
- `data_vars`: DESCRIPTION
- `data`: DESCRIPTION
- `data_dims`: DESCRIPTION
- `out_format`: DESCRIPTION
- `t_step`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function saveOutCubes(data_path_base, global_info, data_vars, data, data_dims, out_format, t_step, ::Val{:false})
    @info "saving one file per variable"
    catalog_names = getVarFull.(data_vars)
    variable_names = getUniqueVarNames(data_vars)
    for vn ∈ eachindex(data_vars)
        var_s = data_vars[vn]
        catalog_name = catalog_names[vn]
        variable_name = variable_names[vn]
        data_yax = getYaxForVariable(data[vn], data_dims[vn], variable_name, catalog_name, t_step)
        data_path = data_path_base * "_$(variable_name).$(out_format)"
        @info "saving $(data_path)"
        ds_new = YAXArrays.Dataset(; (variable_name => data_yax,)..., properties=global_info)
        savedataset(ds_new, path=data_path, overwrite=true)
    end
    return nothing
end

"""
    getGlobalAttributesForOutCubes(info)

DOCSTRING
"""
function getGlobalAttributesForOutCubes(info)
    os = Sys.iswindows() ? "Windows" : Sys.isapple() ?
         "macOS" : Sys.islinux() ? "Linux" : "unknown"
    io = IOBuffer()
    versioninfo(io)
    str = String(take!(io))
    julia_info = split(str, "\n")

    io = IOBuffer()
    Pkg.status("Sindbad", io=io)
    sindbad_version = String(take!(io))
    global_attr = Dict(
        "simulation_by" => ENV["USER"],
        "experiment" => info.experiment.basics.name,
        "domain" => info.experiment.basics.domain,
        "date" => string(Date(now())),
        # "SINDBAD" => sindbad_version,
        "machine" => Sys.MACHINE,
        "os" => os,
        "host" => gethostname(),
        "julia" => string(VERSION),
    )
    return global_attr
end

"""
    getOutputFileInfo(info)

DOCSTRING
"""
function getOutputFileInfo(info)
    global_info = getGlobalAttributesForOutCubes(info)
    file_prefix = joinpath(info.output.data, info.experiment.basics.name * "_" * info.experiment.basics.domain)
    out_file_info = (; global_info=global_info, file_prefix=file_prefix)
    return out_file_info
end

"""
saveOutCubes(saveOutCubes(info, out_cubes, output))

saves the output variables from the run from the information in info
"""

"""
    saveOutCubes(info, out_cubes, output)

DOCSTRING

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `out_cubes`: DESCRIPTION
- `output`: DESCRIPTION
"""
function saveOutCubes(info, out_cubes, output)
    out_file_info = getOutputFileInfo(info)
    saveOutCubes(out_file_info.file_prefix, out_file_info.global_info, output.variables, out_cubes, output.dims, info.experiment.model_output.format, info.experiment.basics.time.temporal_resolution, Val(info.experiment.model_output.save_single_file))
end