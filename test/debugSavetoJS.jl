using Revise
using Sinbad
# using ProfileView
using BenchmarkTools
using JSONTables, CSV
import JSON3
expFile = "sandbox/test_json/settings_minimal/experiment.json"

info = getConfiguration(expFile);

prm = CSV.File("./data/optimized_Params_FLUXNET_pcmaes_FLUXNET2015_daily_BE-Vie.csv");
prmt = Table(prm)


info = setupModel!(info);
out = createInitOut(info);
forcing = getForcing(info);
obsvars, modelvars, optimvars = getConstraintNames(info);
observations = getObservation(info); # target observation!!

optimParams = info.opti.params2opti;
approaches = info.tem.models.forward;
tblParams = getParameters(info.tem.models.forward, info.opti.params2opti);

originTable = getParameters(info.tem.models.forward)
upoTable = copy(originTable)

upoptim = upoTable.optim
for i in 1:length(prmt)
    subtbl = filter(row -> row.names == Symbol(prmt[i].names) && row.models == Symbol(prmt[i].models), originTable)
    if isempty(subtbl)
        println("model $(prmt[i].names) and model $(prmt[i].models) not found")
    else
        println("hurra!!")
        posmodel = findall(x -> x == Symbol(prmt[i].models), upoTable.models)
        posvar = findall(x -> x == Symbol(prmt[i].names), upoTable.names)
        @show posmodel
        @show posvar
        #@show idxtrue
        #upoptim[posvar[1]] = subtbl.optim[1]
    end
end

idxtrue = posmodel .== posvar

posvar[idxtrue]

function filtervar(var, modelName, tblParams, approachx)
    subtbl = filter(row -> row.names == var && row.modelsApproach == modelName, tblParams)
    if isempty(subtbl)
        return getproperty(approachx, var)
    else
        return subtbl.optim[1]
    end
end


outparams, outdata = optimizeModel(forcing, out, observations, approaches, optimParams,
    obsvars, modelvars, optimvars, info.tem, info.opti; maxfevals=10, lossym=(:mse, :cor));

CSV.write("./data/outparams.csv", outparams)

#readin back!
rdback = CSV.File("./data/outparams.csv")
rdbackparams = Table(rdback)


jsformat = JSONTables.objecttable(outparams)
open("./data/test_table.json", "w") do io
    JSON3.pretty(io, jsformat)
end
json_string = read("./data/test_table.json", String)
rdjs = JSON3.read(json_string)
tableback = Table((; zip(keys(rdjs), values(rdjs))...))