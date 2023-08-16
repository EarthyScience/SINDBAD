export saveOutCubes
export getGlobalAttributesForOutCubes
export getOutputFileInfo


"""
    getGlobalAttributesForOutCubes(info)


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
    getModelDataArray(model_data::AbstractArray{T, 2})

return model data with 1 sized dimension removed in case of 2-dimensional matrix
"""
function getModelDataArray(model_data::AbstractArray{T,2}) where {T}
    return model_data[:, 1]
end

"""
    getModelDataArray(model_data::AbstractArray{T, 3})

return model data with 1 sized dimension removed in case of 3-dimensional matrix
"""
function getModelDataArray(model_data::AbstractArray{T,3}) where {T}
    return model_data[:, 1, :]
end

"""
    getModelDataArray(model_data::AbstractArray{T, 4})

return model data with 1 sized dimension removed in case of 4-dimensional matrix
"""
function getModelDataArray(model_data::AbstractArray{T,4}) where {T}
    return model_data[:, 1, :, :]
end

"""
    getOutputFileInfo(info)


"""
function getOutputFileInfo(info)
    global_metadata = getGlobalAttributesForOutCubes(info)
    file_prefix = joinpath(info.output.data, info.experiment.basics.name * "_" * info.experiment.basics.domain)
    out_file_info = (; global_metadata=global_metadata, file_prefix=file_prefix)
    return out_file_info
end


"""
    getUniqueVarNames(var_pairs)

return the list of variable names to be used to write model outputs to a field. - checks if the variable name is duplicated across different fields of SINDBAD land
- uses field__variablename in case of duplicates, else uses the actual model variable name
"""
function getUniqueVarNames(var_pairs)
    pure_vars = getVarName.(var_pairs)
    fields = getVarField.(var_pairs)
    uniq_vars = Symbol[]
    for i in eachindex(pure_vars)
        n_occur = sum(pure_vars .== pure_vars[i])
        var_i = pure_vars[i]
        if n_occur > 1
            var_i = Symbol(String(fields[i]) * "__" * String(pure_vars[i]))
        end
        push!(uniq_vars, var_i)
    end
    return uniq_vars
end




"""
    getYaxForVariable(data_out, data_dim, variable_name, catalog_name, t_step)



# Arguments:
- `data_out`: DESCRIPTION
- `data_dim`: DESCRIPTION
- `variable_name`: DESCRIPTION
- `catalog_name`: DESCRIPTION
- `t_step`: a string for time step of the model run to be used in the units attribute of variables
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
    saveOutCubes(data_path_base, global_metadata, var_pairs, data, data_dims, out_format, t_step, ::DoSaveSingleFile)

saves the output variables from the run as one file

# Arguments:
- `data_path_base`: base path of the output file including the directory and file prefix
- `global_metadata`: a collection of  global metadata information to write to the output file
- `data`: data to be written to file
- `data_dims`: a vector of dimension of data for each variable to be written to a file
- `var_pairs`: a tuple of pairs of sindbad variables to write including the field and subfield of land as the first and last element
- `out_format`: format of the output file
- `t_step`: a string for time step of the model run to be used in the units attribute of variables
- `::DoSaveSingleFile`: DESCRIPTION
"""
function saveOutCubes(data_path_base, global_metadata, data, data_dims, var_pairs, out_format, t_step, ::DoSaveSingleFile)
    @info "saving one file for all variables"
    catalog_names = getVarFull.(var_pairs)
    variable_names = getUniqueVarNames(var_pairs)
    all_yax = Tuple(getYaxForVariable.(data, data_dims, variable_names, catalog_names, Ref(t_step)))
    data_path = data_path_base * "_all_variables.$(out_format)"
    @info data_path
    ds_new = YAXArrays.Dataset(; (; zip(variable_names, all_yax)...)..., properties=global_metadata)
    savedataset(ds_new, path=data_path, append=true, overwrite=true)
    return nothing
end

"""
    saveOutCubes(data_path_base, global_metadata, var_pairs, data, data_dims, out_format, t_step, ::DoNotSaveSingleFile)

saves the output variables from the run as one file per variable

# Arguments:
- `data_path_base`: base path of the output file including the directory and file prefix
- `global_metadata`: a collection of  global metadata information to write to the output file
- `data`: data to be written to file
- `data_dims`: a vector of dimension of data for each variable to be written to a file
- `var_pairs`: a tuple of pairs of sindbad variables to write including the field and subfield of land as the first and last element
- `out_format`: format of the output file
- `t_step`: a string for time step of the model run to be used in the units attribute of variables
- `::DoNotSaveSingleFile`: DESCRIPTION
"""
function saveOutCubes(data_path_base, global_metadata, data, data_dims, var_pairs, out_format, t_step, ::DoNotSaveSingleFile)
    @info "saving one file per variable"
    catalog_names = getVarFull.(var_pairs)
    variable_names = getUniqueVarNames(var_pairs)
    for vn ∈ eachindex(var_pairs)
        catalog_name = catalog_names[vn]
        variable_name = variable_names[vn]
        data_yax = getYaxForVariable(data[vn], data_dims[vn], variable_name, catalog_name, t_step)
        data_path = data_path_base * "_$(variable_name).$(out_format)"
        @info "saving $(data_path)"
        ds_new = YAXArrays.Dataset(; (variable_name => data_yax,)..., properties=global_metadata)
        savedataset(ds_new, path=data_path, overwrite=true)
    end
    return nothing
end


"""
    saveOutCubes(info, out_cubes, output)

saves the output variables from the run from the information in info

# Arguments:
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
- `out_cubes`: a collection of output data to be written to file
- `out_dims`: output dimensions with list of dimensions for each variable pair
- `out_vars`: output variable name pairs with field and subfield
"""
function saveOutCubes(info, out_cubes, out_dims, out_vars)
    out_file_info = getOutputFileInfo(info)
    saveOutCubes(out_file_info.file_prefix, out_file_info.global_metadata, out_cubes, out_dims, out_vars, info.experiment.model_output.format, info.experiment.basics.time.temporal_resolution, info.tem.helpers.run.save_single_file)
end