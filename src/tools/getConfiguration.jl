export createNestedDict
export deepMerge
export getConfiguration
export getExperimentConfiguration
export readConfiguration


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
    getConfiguration(sindbad_experiment::String; replace_info = nothing)

get the experiment info from either json or load the named tuple

"""
function getConfiguration(sindbad_experiment::String; replace_info=nothing)
    local_root = dirname(Base.active_project())
    if !isabspath(sindbad_experiment)
        sindbad_experiment = joinpath(local_root, sindbad_experiment)
    end
    exp_base_path = dirname(sindbad_experiment)
    if endswith(sindbad_experiment, ".json")
        info_exp = getExperimentConfiguration(sindbad_experiment; replace_info=replace_info)
        info = readConfiguration(info_exp, exp_base_path)
    elseif endswith(sindbad_experiment, ".jld2")
        #todo running from the jld2 file here still does not work because the loaded info is a named tuple and replacing the fields will not work due to issues with merge and creating a dictionary from nested namedtuple
        # info = Dict(pairs(load(sindbad_experiment)["info"]))
        info = load(sindbad_experiment)["info"]
    else
        error(
            "sindbad can only be run with either a json or a jld2 data file. Provide a correct experiment file"
        )
    end
    if !isnothing(replace_info)
        non_exp_dict = filter(x -> !startswith(first(x), "experiment"), replace_info)
        if !isempty(non_exp_dict)
            info = replaceInfoFields(info, non_exp_dict)
        end
    end
    infoTuple = info
    if !endswith(sindbad_experiment, ".jld2")
        infoTuple = dictToNamedTuple(info)
    end
    infoTuple = (; infoTuple..., experiment_root=local_root)
    sindbad_root = join(split(infoTuple.experiment_root, "/")[1:(end-2)], "/")
    infoTuple = (; infoTuple..., sindbad_root=sindbad_root)
    infoTuple = (; infoTuple..., settings_root=exp_base_path)
    infoTuple = setupOutputDirectory(infoTuple)
    @info "Setup output directories in: $(infoTuple.output.root)"
    @info "Saving a copy of json settings to: $(infoTuple.output.settings)"
    cp(sindbad_experiment,
        joinpath(infoTuple.output.settings, split(sindbad_experiment, "/")[end]);
        force=true)
    for k ∈ keys(infoTuple.experiment.basics.config_files)
        v = getfield(infoTuple.experiment.basics.config_files, k)
        cp(v, joinpath(infoTuple.output.settings, split(v, "/")[end]); force=true)
    end
    @info "\n----------------------------------------------\n"
    return infoTuple
    # return info
end



"""
    getExperimentConfiguration(experiment_json::String; replace_info = nothing)

get the basic configuration from experiment json
"""
function getExperimentConfiguration(experiment_json::String; replace_info=nothing)
    parseFile = parsefile(experiment_json; dicttype=DataStructures.OrderedDict)
    info = DataStructures.OrderedDict()
    info["experiment"] = DataStructures.OrderedDict()
    for (k, v) ∈ parseFile
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
    readConfiguration(info_exp::AbstractDict, base_path::String)

read configuration experiment json and return dictionary
"""
function readConfiguration(info_exp::AbstractDict, base_path::String)
    info = DataStructures.OrderedDict()
    for (k, v) ∈ info_exp["experiment"]["basics"]["config_files"]
        config_path = joinpath(base_path, v)
        @info "getConfiguration: readConfiguration:: $(k) ::: $(config_path)"
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
    removeComments(; inputDict = inputDict)

remove unnecessary comment files starting with certain expressions from the dictionary keys
"""

"""
    removeComments(inputDict::AbstractDict)

DOCSTRING
"""
function removeComments(inputDict::AbstractDict)
    newDict = filter(x -> !occursin(".c", first(x)), inputDict)
    newDict = filter(x -> !occursin("comments", first(x)), newDict)
    newDict = filter(x -> !occursin("comment", first(x)), newDict)
    return newDict
end
removeComments(input) = input


"""
    setupOutputDirectory(infoTuple::NamedTuple)

sets up and creates output directory for the model simulation
"""
function setupOutputDirectory(infoTuple::NamedTuple)
    path_output = infoTuple[:experiment][:model_output][:path]
    if isnothing(path_output)
        path_output_new = "output_"
        path_output_new = joinpath(join(split(infoTuple.settings_root, "/")[1:(end-1)], "/"),
            path_output_new)
    elseif !isabspath(path_output)
        if !occursin("/", path_output)
            path_output_new = "output_" * path_output
        else
            path_output_new = "output_" * replace(path_output, "/" => "_")
        end
        path_output_new = joinpath(join(split(infoTuple.settings_root, "/")[1:(end-1)], "/"),
            path_output_new)
    else
        sindbad_root = join(split(infoTuple.experiment_root, "/")[1:(end-1)], "/")
        if occursin(sindbad_root, path_output)
            error(
                "You cannot specify output.path: $(path_output) in model_run.json as the absolute path within the sindbad_root: $(sindbad_root). Change it to null or a relative path or set output directory outside sindbad."
            )
        else
            path_output_new = path_output
            if !endswith(path_output_new, "/")
                path_output_new = path_output_new * "/"
            end
        end
    end
    path_output_new = path_output_new * infoTuple.experiment.basics.domain * "_" * infoTuple.experiment.basics.name

    # create output and subdirectories
    infoTuple = setTupleField(infoTuple, (:output, (;)))
    sub_output = ["code", "data", "figure", "root", "settings"]
    if infoTuple.experiment.flags.run_optimization || infoTuple.experiment.flags.calc_cost
        push!(sub_output, "optim")
    end
    if infoTuple.experiment.flags.spinup.save_spinup
        push!(sub_output, "spinup")
    end
    for s_o ∈ sub_output
        if s_o == "root"
            infoTuple = setTupleSubfield(infoTuple, :output, (Symbol(s_o), path_output_new))
        else
            infoTuple = setTupleSubfield(infoTuple, :output,
                (Symbol(s_o), joinpath(path_output_new, s_o)))
            mkpath(getfield(getfield(infoTuple, :output), Symbol(s_o)))
        end
    end
    return infoTuple
end

"""
    replaceInfoFields(info::AbstractDict, replace_dict::AbstractDict)

replace the fields of info from json with the values providded in the replace dictionary
"""
function replaceInfoFields(info::AbstractDict, replace_dict::AbstractDict)
    nested_replace_dict = createNestedDict(replace_dict)
    info = deepMerge(Dict(info), nested_replace_dict)
    return info
end