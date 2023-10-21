export createNestedDict
export deepMerge
export getConfiguration
export getExperimentConfiguration
export readConfiguration

const path_separator = Sys.iswindows() ? "\\" : "/"

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
    createNestedDict(dict::AbstractDict)

Creates a nested dict from one-depth dict, when string keys are strings separated by a .

dict = Dict("a.b.c" => 2)

nested_dict = createNestedDict(dict)

nested_dict["a"]["b"]["c"]
"""
function createNestedDict(dict::AbstractDict)
    nested_dict = Dict()
    for kii ∈ keys(dict)
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
                    key_dict[subkey_name][key_list[key_index+1]] =
                        key_dict[key_list[key_index+1]*string(key_index +
                                                              1)]
                else
                    tmp = Dict()
                    tmp[subkey_name] = key_dict[key_list[key_index+1]*string(key_index + 1)]
                end
                delete!(key_dict, key_list[key_index+1] * string(key_index + 1))
                delete!(nested_dict, key_list[key_index+1] * string(key_index + 1))
            end
            nested_dict = deepMerge(nested_dict, key_dict)
        end
    end
    return nested_dict
end

"""
    deepMerge(d::AbstractDict...) = merge(deepMerge, d...)

recursively merge nested dictionary fields with priority for the second dictionary
"""
deepMerge(d::AbstractDict...) = merge(deepMerge, d...)
deepMerge(d...) = d[end]

"""
    getRootDirs(info)

a basic function to guesstimate the experiment and sindbad roots
"""
function getRootDirs(local_root, sindbad_experiment)
    sindbad_root = join(split(local_root, path_separator)[1:(end-2)] |> collect, path_separator)
    exp_base_path = dirname(sindbad_experiment)
    root_dir = (; experiment=local_root, sindbad=sindbad_root, settings=exp_base_path)
    return root_dir
end


"""
    getConfiguration(sindbad_experiment::String; replace_info = nothing)

get the experiment info from either json or load the named tuple
"""
function getConfiguration(sindbad_experiment::String; replace_info=Dict())
    local_root = dirname(Base.active_project())
    if !isabspath(sindbad_experiment)
        sindbad_experiment = joinpath(local_root, sindbad_experiment)
    end
    roots = getRootDirs(local_root, sindbad_experiment)
    roots = (; roots..., sindbad_experiment)
    info = nothing
    if endswith(sindbad_experiment, ".json")
        info_exp = getExperimentConfiguration(sindbad_experiment; replace_info=replace_info)
        info = readConfiguration(info_exp, roots.settings)
    elseif endswith(sindbad_experiment, ".jld2")
        #todo running from the jld2 file here still does not work because the loaded info is a named tuple and replacing the fields will not work due to issues with merge and creating a dictionary from nested namedtuple
        # info = Dict(pairs(load(sindbad_experiment)["info"]))
        info = load(sindbad_experiment)["info"]
    else
        error(
            "sindbad can only be run with either a json or a jld2 data file. Provide a correct experiment file"
        )
    end
    if !isempty(replace_info)
        non_exp_dict = filter(x -> !startswith(first(x), "experiment"), replace_info)
        if !isempty(non_exp_dict)
            info = replaceInfoFields(info, non_exp_dict)
        end
    end
    new_info = DataStructures.OrderedDict()
    new_info["settings"] = DataStructures.OrderedDict()
    for (k,v) in info
        new_info["settings"][k] = v
    end
    # @show keys(info)
    if !endswith(sindbad_experiment, ".jld2")
        infoTuple = dictToNamedTuple(new_info)
    end
    infoTuple = (; infoTuple..., temp=(; experiment=(; dirs=roots)))

    @info "\n----------------------------------------------\n"
    return infoTuple
    # return info
end



"""
    getExperimentConfiguration(experiment_json::String; replace_info = nothing)

get the basic configuration from experiment json
"""
function getExperimentConfiguration(experiment_json::String; replace_info=Dict())
    parseFile = parsefile(experiment_json; dicttype=DataStructures.OrderedDict)
    info = DataStructures.OrderedDict()
    info["experiment"] = DataStructures.OrderedDict()
    for (k, v) ∈ parseFile
        info["experiment"][k] = v
    end
    if !isempty(replace_info)
        exp_dict = filter(x -> startswith(first(x), "experiment"), replace_info)
        if !isempty(exp_dict)
            info = replaceInfoFields(info, exp_dict)
        end
    end
    return info
end


"""
    readConfiguration(info_exp::AbstractDict, base_path::String)

read configuration experiment json and return dictionary
"""
function readConfiguration(info_exp::AbstractDict, base_path::String)
    info = DataStructures.OrderedDict()
    for (k, v) ∈ info_exp["experiment"]["basics"]["config_files"]
        config_path = joinpath(base_path, v)
        @info "  readConfiguration:: $(k) ::: $(config_path)"
        info_exp["experiment"]["basics"]["config_files"][k] = config_path
        if endswith(v, ".json")
            tmp = parsefile(config_path; dicttype=DataStructures.OrderedDict)
            info[k] = removeComments(tmp) # remove on first level
        elseif endswith(v, ".csv")
            prm = CSV.File(config_path)
            tmp = Table(prm)
            info[k] = tmp
        end
    end

    # rm second level
    for (k, v) ∈ info
        if typeof(v) <: Dict
            ks = keys(info[k])
            tmpDict = DataStructures.OrderedDict()
            for ki ∈ ks
                tmpDict[ki] = removeComments(info[k][ki])
            end
            info[k] = tmpDict
        end
    end
    info["experiment"] = info_exp["experiment"]
    return info
end


"""
    removeComments(inputDict::AbstractDict)

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
    replaceInfoFields(info::AbstractDict, replace_dict::AbstractDict)

replace the fields of info from json with the values providded in the replace dictionary
"""
function replaceInfoFields(info::AbstractDict, replace_dict::AbstractDict)
    nested_replace_dict = createNestedDict(replace_dict)
    info = deepMerge(Dict(info), nested_replace_dict)
    return info
end

