using Revise
using Sinbad
# using ProfileView
using BenchmarkTools
#using GLMakie

expFile = "sandbox/test_json/settings_minimal/experiment.json"
import JSON
function getExperimentConfiguration(expFile)
    jsonFile = String(JSON.read(expFile))
    parseFile = JSON.parse(jsonFile)
    info = Dict()
    for (k, v) in parseFile
        info[k] = v
    end
    return info
end

function removeComments(inputDict)
    newDict = filter(x -> !occursin(".c", first(x)), inputDict)
    newDict = filter(x -> !occursin("comments", first(x)), newDict)
    newDict = filter(x -> !occursin("comment", first(x)), newDict)
    return newDict
end

function rmComment(input)
    if input isa Dict
        return removeComments(input)
    else
        return input
    end
end


info_exp = getExperimentConfiguration(expFile)
info = Dict()
info["experiment"] = info_exp
for (k, v) in info_exp["configFiles"]
    tmp = JSON.parse(String(JSON.read(v)))

    info[k] = removeComments(tmp)
end

tmp = JSON.parse(String(JSON.read("sandbox/test_json/settings_minimal/spinup.json")))


function readConfiguration(info_exp)
    info = Dict()
    info["experiment"] = info_exp
    for (k, v) in info_exp["configFiles"]
        tmp = JSON.parse(String(JSON.read(v)))
        info[k] = removeComments(tmp)
    end
    return info
end


info = getConfiguration(expFile);
info = setupModel!(info);

forcing = getForcing(info);


obsvars, modelvars = getConstraintNames(info);
observations = getObservation(info); # target observation!!

optimParams = info.opti.params2opti;
approaches = info.tem.models.forward;
# tblParams = getParameters(info.tem.models.forward, info.opti.params2opti);
# info = (; info..., opti = (;));
# info = (;info..., tem = (;));


# initPools = getInitPools(info)
out = getInitOut(info);

outsp = runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=1);
outforw = runForward(approaches, forcing, outsp[1], info.tem.variables, info.tem.helpers);

# outfor = runEcosystem(approaches, forcing, out, info.tem.helpers);
pprint(outsp)




for it in 1:10
    @time runSpinup(approaches, forcing, out, info.tem.helpers, false; nspins=5)
end
outparams, outdata = optimizeModel(forcing, out, observations, approaches, optimParams, obsvars, modelvars, info.tem, info.opti; maxfevals=1);

outparams, outdata = optimizeModel(forcing, out, observations, approaches, optimParams, obsvars, modelvars, info.tem, info.opti; maxfevals=30);
# outf=columntable(outdata.fluxes)
using GLMakie
fig = Figure(resolution=(2200, 900))
lines(outdata.transpiration)
lines!(outdata.evapotranspiration)
lines!(observations.evapotranspiration)


function filterOut(tpl, out)
    outs = (;)
    for (field, vars) in tpl
        s = NamedTuple{vars}(getfield(out, field))
        outs = (; outs..., field=s...)
    end
    return outs
end
