export saveOutCubes

function getModelDataArray(model_data::AbstractArray{T,2}) where {T}
    return model_data[:, 1]
end

function getModelDataArray(model_data::AbstractArray{T,3}) where {T}
    return model_data[:, 1, :]
end

function getModelDataArray(model_data::AbstractArray{T,4}) where {T}
    return model_data[:, 1, :, :]
end

function getVarName(var_pair)
    return last(var_pair)
end

function getVarField(var_pair)
    return first(var_pair)
end

function getVarFull(var_pair)
    return String(first(var_pair)) * "__" * String(last(var_pair))
    # return Symbol(String(last(var_pair)) * "__" * String(first(var_pair)))
end

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

function getYaxForVariable(data_out, data_dim, variable_name, catalogue_name, varib_catalog, t_step)
    data_prop = getVariableInfo(varib_catalog, catalogue_name, t_step)
    if size(data_out, 2) == 1
        data_out = getModelDataArray(data_out)
    end
    data_yax = YAXArray(data_dim, data_out, data_prop)
    return data_yax
end

"""
    saveOutCubes(data_vars::Tuple, data_dims::Vector)

saves the output varibles from the forward run
"""
function saveOutCubes(data_path_base, data_vars, global_info, varib_catalog, data, data_dims, out_format, t_step, ::Val{:true})
    @info "saving one file for all variables"
    catalogue_names = getVarFull.(data_vars)
    variable_names = getUniqueVarNames(data_vars)
    all_yax = Tuple(getYaxForVariable.(data, data_dims, variable_names, catalogue_names, Ref(varib_catalog), Ref(t_step)))
    data_path = data_path_base * "_all_variables.$(out_format)"
    @info data_path
    ds_new = YAXArrays.Dataset(; (; zip(variable_names, all_yax)...)..., properties=global_info)
    savedataset(ds_new, path=data_path, append=true, overwrite=true)
    return nothing
end


function saveOutCubes(data_path_base, data_vars, global_info, varib_catalog, data, data_dims, out_format, t_step, ::Val{:false})
    @info "saving one file per variable"
    catalogue_names = getVarFull.(data_vars)
    variable_names = getUniqueVarNames(data_vars)
    for vn ∈ eachindex(data_vars)
        var_s = data_vars[vn]
        catalogue_name = catalogue_names[vn]
        variable_name = variable_names[vn]
        data_yax = getYaxForVariable(data[vn], data_dims[vn], variable_name, catalogue_name, varib_catalog, t_step)
        data_path = data_path_base * "_$(vname).$(out_format)"
        @info "saving $(data_path)"
        ds_new = YAXArrays.Dataset(; (vname => data_yax,)..., properties=global_info)
        savedataset(ds_new, path=data_path, overwrite=true)
    end
    return nothing
end

function getGlobalAttributes(info)
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
        "experiment" => info.experiment.name,
        "domain" => info.experiment.domain,
        "date" => string(Date(now())),
        # "SINDBAD" => sindbad_version,
        "machine" => Sys.MACHINE,
        "os" => os,
        "host" => gethostname(),
        "julia" => string(VERSION),
    )
    return global_attr
end

function saveOutCubes(info, out_cubes, output)
    global_info = getGlobalAttributes(info)
    varib_catalog = getStandardVariableCatalog(info)
    file_suffix = joinpath(info.output.data, info.experiment.name * "_" * info.experiment.domain)
    t_step = info.model_run.time.model_time_step
    saveOutCubes(file_suffix, output.ordered_variables, global_info, varib_catalog, out_cubes, output.dims, info.model_run.output.format, t_step, Val(info.model_run.output.save_single_file))
end