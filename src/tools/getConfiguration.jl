using CSV
export getConfiguration, getExperimentConfiguration, readConfiguration

"""
getConfigurationFiles(expFile)
get the basic configuration from experiment json
"""
function getExperimentConfiguration(expFile)
    jsonFile = String(jsread(expFile))
    parseFile = jsparse(jsonFile; dicttype=DataStructures.OrderedDict)
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
function readConfiguration(info_exp, local_root)
    info = DataStructures.OrderedDict()
    for (k, v) in info_exp["configFiles"]
        if endswith(v, ".json")
            tmp = jsparse(String(jsread(local_root*v)); dicttype=DataStructures.OrderedDict)
            info[k] = rmComment(tmp) # remove on first level
        elseif endswith(v, ".csv")
            prm = CSV.File((local_root*v));
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
                tmpDict[ki] = rmComment(info[k][ki])
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
function removeComments(inputDict)
    newDict = filter(x -> !occursin(".c", first(x)), inputDict)
    newDict = filter(x -> !occursin("comments", first(x)), newDict)
    newDict = filter(x -> !occursin("comment", first(x)), newDict)
    return newDict
end

"""
rmComment(input)
Calling removeComments on Dictionaries.
"""
function rmComment(input)
    if input isa DataStructures.OrderedDict
        return removeComments(input)
    elseif input isa Dict
        return removeComments(input)
    else
        return input
    end
end

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
function getConfiguration(sindbad_experiment, local_root)
    if typeof(sindbad_experiment) == String
        info_exp = getExperimentConfiguration(sindbad_experiment)
        info = readConfiguration(info_exp, local_root)
    end
    infoTuple = typenarrow!(info)
    infoTuple = (;infoTuple..., sinbad_root=local_root)
    return infoTuple
    # return info
end
