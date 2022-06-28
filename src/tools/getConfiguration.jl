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
        if endswith(v, ".json")
            tmp = parsefile(joinpath(base_path,v); dicttype=DataStructures.OrderedDict)
            info[k] = removeComments(tmp) # remove on first level
        elseif endswith(v, ".csv")
            prm = CSV.File(joinpath(base_path,v));
            tmp = Table(prm)
            info[k] = tmp
        end
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
    @show keys(infoTuple)
    outpath = infoTuple[:modelRun][:output][:path]
    if !isabspath(outpath)
        outpath = joinpath(@__DIR__(), outpath)
    end
    infoTuple = (;infoTuple..., output_root=outpath)

    infoTuple = (;infoTuple..., settings_root=exp_base_path)
    return infoTuple
    # return info
end
