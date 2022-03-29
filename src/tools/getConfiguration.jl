"""
getConfigurationFiles(expFile)
get the basic configuration from experiment json
"""
function getExperimentConfiguration(expFile)
    jsonFile = String(jsread(expFile))
    parseFile = jsparse(jsonFile)
    info = Dict()
    for (k, v) in parseFile
        info[k] = v
    end
    return info
end

"""
readConfiguration(configFiles)
read configuration experiment json and return dictionary
"""
function readConfiguration(info_exp)
    info = Dict()
    info["experiment"] = info_exp
    for (k, v) in info_exp["configFiles"]
        info[k] = jsparse(String(jsread(v)))
    end
    info_nocomments = removeComments(info)
    return info_nocomments
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
convertToAbsolutePath(; inputDict = inputDict)
find all variables with path and convert them to absolute path assuming all non-absolute path values are relative to the sindbad root
"""
function convertToAbsolutePath(; inputDict = inputDict)
    #### NOT DONE YET
    newDict = filter(x -> !occursin("path", first(x)), inputDict)
    return newDict
end

"""
getConfiguration(sindbad_experiment)
get the experiment info from either json or load the named tuple
"""
function getConfiguration(sindbad_experiment)
    if typeof(sindbad_experiment) == String
        info_exp = getExperimentConfiguration(sindbad_experiment)
        info = readConfiguration(info_exp)
    end
    infoTuple = typenarrow!(info)
    return infoTuple
    # return info
end
