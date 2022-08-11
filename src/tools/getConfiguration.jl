export getConfiguration, getExperimentConfiguration, readConfiguration
export createNestedDict

"""
    deep_merge(d::AbstractDict...) = merge(deep_merge, d...)
recursively merge nested dictionary fields with priority for the second dictionary
"""
deep_merge(d::AbstractDict...) = merge(deep_merge, d...)
deep_merge(d...) = d[end]


"""
    replaceInfoFields(info::AbstractDict, replace_dict::AbstractDict)
replace the fields of info from json with the values providded in the replace dictionary
"""
function replaceInfoFields(info::AbstractDict, replace_dict::AbstractDict)
    nested_replace_dict = createNestedDict(replace_dict)
    info = deep_merge(Dict(info), nested_replace_dict)
    return info
end


"""
    createNestedDict(dict)
Creates a nested dict from one-depth dict, when string keys are strings separated by a .

dict = Dict("a.b.c" => 2)

nested_dict = createNestedDict(dict)

nested_dict["a"]["b"]["c"]
"""
function createNestedDict(dict::AbstractDict)
    nested_dict = Dict()
    for kii in keys(dict)
        key_list = split(kii, ".")
        key_dict = Dict()
        for key_index ∈ reverse(eachindex(key_list))
            subkey = key_list[key_index]
            if subkey == first(key_list)
                subkey_name = subkey
            else
                subkey_name = subkey * string(key_index)
            end
            if subkey == last(key_list)
                key_dict[subkey_name] = dict[kii]
            else
                if !haskey(key_dict, subkey_name)
                    key_dict[subkey_name] = Dict()
                    key_dict[subkey_name][key_list[key_index+1]] = key_dict[key_list[key_index+1]*string(key_index + 1)]
                else
                    tmp = Dict()
                    tmp[subkey_name] = key_dict[key_list[key_index+1]*string(key_index + 1)]
                end
                delete!(key_dict, key_list[key_index+1] * string(key_index + 1))
                delete!(nested_dict, key_list[key_index+1] * string(key_index + 1))
            end
            nested_dict = deep_merge(nested_dict, key_dict)
        end
    end
    return nested_dict
end


"""
    getConfigurationFiles(experiment_json)
get the basic configuration from experiment json
"""
function getExperimentConfiguration(experiment_json::String; replace_info=nothing)
    parseFile = parsefile(experiment_json; dicttype=DataStructures.OrderedDict)
    info = DataStructures.OrderedDict()
    info["experiment"] = DataStructures.OrderedDict()
    for (k, v) in parseFile
        info["experiment"][k] = v
    end
    if !isnothing(replace_info)
        exp_dict = filter(x -> startswith(first(x), "experiment"), replace_info)
        if !isempty(exp_dict)
            info = replaceInfoFields(info, exp_dict)
        end
    end
    return info
end


"""
    readConfiguration(configFiles)
read configuration experiment json and return dictionary
"""
function readConfiguration(info_exp::AbstractDict, base_path::String)
    info = DataStructures.OrderedDict()
    for (k, v) in info_exp["experiment"]["configFiles"]
        config_path = joinpath(base_path, v)
        if endswith(v, ".json")
            tmp = parsefile(config_path; dicttype=DataStructures.OrderedDict)
            info[k] = removeComments(tmp) # remove on first level
        elseif endswith(v, ".csv")
            prm = CSV.File(config_path)
            tmp = Table(prm)
            info[k] = tmp
        end
        @info "getConfiguration: readConfiguration:: $(k) ::: $(config_path)"
    end
    # rm second level
    for (k, v) in info
        if typeof(v) <: Dict
            ks = keys(info[k])
            tmpDict = DataStructures.OrderedDict()
            for ki in ks
                tmpDict[ki] = removeComments(info[k][ki])
            end
            info[k] = tmpDict
        end
    end
    info["experiment"] = info_exp["experiment"]
    return info
end


"""
    removeComments(; inputDict = inputDict)
remove unnecessary comment files starting with certain expressions from the dictionary keys
"""
function removeComments(inputDict::AbstractDict)
    newDict = filter(x -> !occursin(".c", first(x)), inputDict)
    newDict = filter(x -> !occursin("comments", first(x)), newDict)
    newDict = filter(x -> !occursin("comment", first(x)), newDict)
    return newDict
end
removeComments(input) = input


"""
    convertToAbsolutePath(; inputDict = inputDict)
find all variables with path and convert them to absolute path assuming all non-absolute path values are relative to the sindbad root
"""
function convertToAbsolutePath(; inputDict=inputDict)
    #### NOT DONE YET
    newDict = filter(x -> !occursin("path", first(x)), inputDict)
    return newDict
end


"""
    setupOutputDirectory(infoTuple)
sets up and creates output directory for the model simulation
"""
function setupOutputDirectory(infoTuple::NamedTuple)
    outpath = infoTuple[:modelRun][:output][:path]
    if isnothing(outpath)
        out_path_new = "output_"
        out_path_new = joinpath(join(split(infoTuple.settings_root, "/")[1:end-1], "/"), out_path_new)
    elseif !isabspath(outpath)
        if !occursin("/", outpath)
            out_path_new = "output_" * outpath
        else
            out_path_new = "output_" * replace(outpath, "/" => "_")
        end
        out_path_new = joinpath(join(split(infoTuple.settings_root, "/")[1:end-1], "/"), out_path_new)
    else
        sindbad_root = join(split(infoTuple.experiment_root, "/")[1:end-1], "/")
        if occursin(sindbad_root, outpath)
            error("You cannot specify output.path: $(outpath) in modelRun.json as the absolute path within the sindbad_root: $(sindbad_root). Change it to null or a relative path or set output directory outside sindbad.")
        else
            out_path_new = outpath
            if !endswith(out_path_new, "/")
                out_path_new = out_path_new * "/"
            end
        end
    end
    out_path_new = out_path_new * infoTuple.experiment.domain * "_" * infoTuple.experiment.name
    mkpath(out_path_new)
    infoTuple = (; infoTuple..., output_root=out_path_new)
    return infoTuple
end


"""
    getConfiguration(sindbad_experiment)
get the experiment info from either json or load the named tuple
"""
function getConfiguration(sindbad_experiment::String; replace_info=nothing)
    local_root = dirname(Base.active_project())
    if !isabspath(sindbad_experiment)
        sindbad_experiment = joinpath(local_root, sindbad_experiment)
    end
    info_exp = getExperimentConfiguration(sindbad_experiment; replace_info=replace_info)
    exp_base_path = dirname(sindbad_experiment)
    info = readConfiguration(info_exp, exp_base_path)
    if !isnothing(replace_info)
        non_exp_dict = filter(x -> !startswith(first(x), "experiment"), replace_info)
        if !isempty(non_exp_dict)
            info = replaceInfoFields(info, non_exp_dict)
        end
    end
    infoTuple = dictToNamedTuple(info)
    infoTuple = (; infoTuple..., experiment_root=local_root)
    infoTuple = (; infoTuple..., settings_root=exp_base_path)
    infoTuple = setupOutputDirectory(infoTuple)
    @info "Setup output directory: $(infoTuple.output_root)"
    println("----------------------------------------------")
    return infoTuple
    # return info
end
