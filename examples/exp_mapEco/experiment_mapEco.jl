using Revise
using Sindbad
using ProgressMeter
# Base.show(io::IO,nt::Type{<:LandEcosystem}) = print(io,supertype(nt))
Base.show(io::IO,nt::Type{<:NamedTuple}) = print(io,"NT")

expFile = "exp_mapEco/settings_mapEco/experiment.json"


info = getConfiguration(expFile);

info = setupExperiment(info);

forcing = getForcing(info, Val(:yaxarray));
# spinup_forcing = getSpinupForcing(forcing.data, info.tem);



output = setupOutput(info);
Sindbad.eval(:(debugcatcherr = []))
@time outcubes = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward);
outcubes[2]

# optimization
info = setupOptimization(info);
observations = getObservation(info, Val(:yaxarray_s)); 


info_optim = info.optim;
tem = info.tem;
optimVars = info_optim.variables.optim;
# get the list of observed variables, model variables to compare observation against, 
# obsVars, optimVars, storeVars = getConstraintNames(info);

# get the subset of parameters table that consists of only optimized parameters
tblParams = getParameters(tem.models.forward, info_optim.optimized_paramaters)

# get the defaults and bounds
default_values = tem.helpers.numbers.sNT.(tblParams.defaults)
lower_bounds = tem.helpers.numbers.sNT.(tblParams.lower)
upper_bounds = tem.helpers.numbers.sNT.(tblParams.upper)


initOut = output.init_out;
spinup_forcing = nothing;
cost_function = x -> mapGetLoss(x, forcing, spinup_forcing, initOut,
observations, tblParams, optimVars, tem, info_optim)

# run the optimizer
optim_para = optimizer(cost_function, default_values, lower_bounds, upper_bounds, info_optim.algorithm.options, Val(info_optim.algorithm.method))


tmp = observations.data[1]
outparams, outsmodel = optimizeModel(forcing, output, info.tem, info.optim, observations);  


"""
getLoss(pVector, approaches, initOut, forcing, observations, tblParams, obsVariables, modelVariables)
"""
function mapGetLoss(pVector, forcing, spinup_forcing, initOut,
    observations, tblParams, optimVars, tem, info_optim)
    # tblParams.optim .= pVector # update the parameters with pVector
    # @show pVector, typeof(pVector)
    if eltype(pVector) <: ForwardDiff.Dual
        tblParams.optim .= [tem.helpers.numbers.sNT(ForwardDiff.value(v)) for v ∈ pVector] # update the parameters with pVector
    else
        tblParams.optim .= pVector # update the parameters with pVector
    end

    newApproaches = updateParameters(tblParams, tem.models.forward)
    outevolution = mapRunEcosystem(forcing, output, info.tem, newApproaches); 
    # mapRunEcosystem(newApproaches, forcing, initOut, tem; spinup_forcing=spinup_forcing) # spinup + forward run!
    lossVec=[]
    cost_options=info_optim.costOptions;
    for var_row in cost_options
        obsV = var_row.variable
        lossMetric = var_row.costMetric
        mod_variable = getfield(optimVars, obsV)
        (y, yσ, ŷ) = getData(outevolution, observations, obsV, mod_variable)
        metr = loss(y, yσ, ŷ, Val(lossMetric))
        if isnan(metr)            
            pprint(tblParams.optim)
            pprint(y)
            pprint(mean(y))
            push!(lossVec, 1.0E19)
        else
            push!(lossVec, metr)
        end
        @info "$(obsV) => $(lossMetric): $(metr)"
    end
    @info "-------------------"

    return combineLoss(lossVec, Val(info_optim.multiConstraintMethod))
end