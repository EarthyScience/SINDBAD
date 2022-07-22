export getConfiguration, getExperimentConfiguration, readConfiguration

"""
getConfigurationFiles(expFile)
get the basic configuration from experiment json
"""
function getExperimentConfiguration(expFile)
    parseFile = parsefile(expFile; dicttype=DataStructures.OrderedDict)
    info = DataStructures.OrderedDict()
    for (k, v) in parseFile
        info[k] = v
    end
    return info
end

"""
readConfiguration(configFiles)
read configuration experiment json and return dictionary
"""
function readConfiguration(info_exp, base_path)
    info = DataStructures.OrderedDict()
    for (k, v) in info_exp["configFiles"]
        config_path = joinpath(base_path,v)
        if endswith(v, ".json")
            tmp = parsefile(config_path; dicttype=DataStructures.OrderedDict)
            info[k] = removeComments(tmp) # remove on first level
        elseif endswith(v, ".csv")
            prm = CSV.File(config_path);
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
    info["experiment"] = info_exp
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
function setupOutputDirectory(infoTuple)
    outpath = infoTuple[:modelRun][:output][:path]
    if !isabspath(outpath)
        if !occursin("/", outpath)
            outfoldername = "output_" * split(outpath,'/')[end]
            base_path = join(split(outpath,"/")[1:end-1], "/")
            out_path_new = joinpath(base_path, outfoldername)
        else
            base_root = "output_" * split(outpath,'/')[1]
            base_path = join(split(outpath,"/")[2:end], "/")
            out_path_new = joinpath(base_root, base_path)
        end
        out_path_new = joinpath(join(split(infoTuple.settings_root,"/")[1:end-1], "/"), out_path_new)
    else
        sindbad_root = join(split(infoTuple.experiment_root,"/")[1:end-1], "/")
        if occursin(sindbad_root, outpath)
            error("You cannot specify output.path: $(outpath) in modelRun.json as the absolute path within the sindbad_root: $(sindbad_root). Change it to a relative path or set output directory outside sindbad.")
        else
            out_path_new = outpath
        end
    end
    mkpath(out_path_new)
    infoTuple = (;infoTuple..., output_root=out_path_new)
    return infoTuple
end

"""
getConfiguration(sindbad_experiment)
get the experiment info from either json or load the named tuple
"""
function getConfiguration(sindbad_experiment)
    local_root = dirname(Base.active_project())
    if typeof(sindbad_experiment) == String
        if !isabspath(sindbad_experiment)
            sindbad_experiment = joinpath(local_root, sindbad_experiment)
        end
        info_exp = getExperimentConfiguration(sindbad_experiment)
        exp_base_path=dirname(sindbad_experiment)
        info = readConfiguration(info_exp, exp_base_path)
    end
    infoTuple = typenarrow!(info)
    infoTuple = (;infoTuple..., experiment_root=local_root)
    infoTuple = (;infoTuple..., settings_root=exp_base_path)
    infoTuple = setupOutputDirectory(infoTuple)
    @info "Setup output directory: $(infoTuple.output_root)"
    println("----------------------------------------------")
    return infoTuple
    # return info
end
