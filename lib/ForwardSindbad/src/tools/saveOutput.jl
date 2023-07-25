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

function getVarFull(var_pair)
    return Symbol(String(last(var_pair)) * "__" * String(first(var_pair)))
end


function getYaxForVariable(data_out, data_dim, vname, varib_catalog)
    data_prop = getVariableInfo(varib_catalog, String(vname))
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
function saveOutCubes(data_path_base, data_vars, global_info, varib_catalog, data, data_dims, out_format, ::Val{:true})
    @info "saving one file for all variables"
    all_vars = getVarFull.(data_vars)
    all_yax = Tuple(getYaxForVariable.(data, data_dims, all_vars, Ref(varib_catalog)))
    data_path = data_path_base * "_all_variables.$(out_format)"
    @info data_path
    ds_new = YAXArrays.Dataset(; (; zip(all_vars, all_yax)...)..., properties=global_info)
    savedataset(ds_new, path=data_path, append=true, overwrite=true)
    return nothing
end


function saveOutCubes(data_path_base, data_vars, global_info, varib_catalog, data, data_dims, out_format, ::Val{:false})
    @info "saving one file per variable"
    for vn ∈ eachindex(data_vars)
        var_s = data_vars[vn]
        vname = getVarFull(var_s)
        data_yax = getYaxForVariable(data[vn], data_dims[vn], vname, varib_catalog)
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
    varib_catalog = getVariableCatalog(info)
    file_suffix = joinpath(info.output.data, info.experiment.name * "_" * info.experiment.domain)
    saveOutCubes(file_suffix, output.ordered_variables, global_info, varib_catalog, out_cubes, output.dims, info.model_run.output.format, Val(info.model_run.output.save_single_file))
end