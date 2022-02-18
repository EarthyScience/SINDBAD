
function getConfigurationFiles(; expFile=expFile)
    jsonFile = String(read(expFile))    
    parseFile = JSON.parse(jsonFile)
    newDict = rmComments(; inputDict = parseFile) # filter(x -> !occursin(".c", first(x)), parseFile)
    return newDict
end

function readConfiguration(; configuration=nothing)
    configFiles = getConfigurationFiles(; expFile=configuration)
    info = Dict()
    for jsonFile in configFiles
        nameFile = jsonFile[20:end-5]
        jsonFile = String(read(jsonFile))
        parseFile = JSON.parse(jsonFile)
        newDict = rmComments(; inputDict = parseFile) # filter(x -> !occursin(".c", first(x)), parseFile)
        info[nameFile] = newDict
    end
    return info
end


info = readConfiguration()


function rmComments(; inputDict = inputDict)
    newDict = filter(x -> !occursin(".c", first(x)), inputDict)
    newDict = filter(x -> !occursin("comments", first(x)), newDict)
    newDict = filter(x -> !occursin("comment", first(x)), newDict)
    return newDict
end

function typenarrow!(d::Dict)
    for k in keys(d)
        if d[k] isa Array{Any,1}
            d[k] = [v for v in d[k]]
        elseif d[k] isa Dict
            d[k] = typenarrow!(d[k])
        end
    end
    NamedTuple{Tuple(Symbol.(keys(d)))}(values(d))
end