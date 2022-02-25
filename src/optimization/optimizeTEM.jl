using Sinbad
using Optim
using Setfield
using Statistics

function perfMetric(info, out, obs)
    varnames = Symbol.(info.opti.variables2constrain);
    cost = 0.0
    for v in varnames
        vinfo = getproperty(info.opti.constraints.variables, v)
        modVar = Symbol(vinfo.modelFullVar)
        @eval (obsData = $obs.$v) 
        @eval (modData = $out.$modVar)
        # bias = sum(skipmissing((obsData - modData) ^ 2.0))
        bias = sum(collect(skipmissing(modData))) - sum(collect(skipmissing(obsData)))
        # corr = cor(skipmissing(obsData), skipmissing(modData))
        # mO = mean(skipmissing(obsData));
        # OmO = sum(skipmissing((obsData - mO) .^ 2));
        # PsO = sum(skipmissing((modData - obsData) .^ 2));
        # mefinv = PsO ./ OmO
        # cost = cost + 
        cost = cost + bias
    end
    return cost
end

function getDefaultParameters(info)
    approaches = getfield(info.tem.models, Symbol("forward") )
    optiparams = info.opti.params2opti
    global params = (; evapSoil = (α = [0.051,3], supLim = [0.01, 0.99]), snowMelt = (melt_T= [0.01, 10], melt_Rn=[0.01, 3])); 
    def_params = []
    lb_params = []
    ub_params = []
    for (prI, pr) in enumerate(optiparams)
        modelName_p = split(pr, ".")[1]
        paramName = split(pr, ".")[2]
        for (apprI, appr) in enumerate(approaches)
            apprName = split(String(Symbol(appr)),"{")[1]
            modelName_m = split(apprName,"_")[1]
            if modelName_m == modelName_p
                modelNameSymbol=Symbol(modelName_m)
                paramSymbol = Symbol(paramName)    
                @eval (x = $appr.$paramSymbol)
                # @show x, modelName_m, paramName, appr
                @eval (xb = params.$modelNameSymbol.$paramSymbol)
                # @show xb
                push!(def_params, x)
                push!(lb_params, xb[1])
                push!(ub_params, xb[2])
            end
        end
    end
    params=(; default=Float64.(def_params), lower=Float64.(lb_params), upper=Float64.(ub_params))
    return params
end


function updateModelParameters(pVector, info)
    # pVector=[1.0, 2.0, 3.0, 4.0, 5.0] * 1000
    # model_mode = "spinup"
    optiparams = info.opti.params2opti
    model_modes = ["forward", "spinup"]
    for model_mode in model_modes
        model_mode_symbol = Symbol(model_mode)
        approaches = getfield(info.tem.models, model_mode_symbol )
        global updated_appr = []
        for (apprI, appr) in enumerate(approaches)
            apprName = split(String(Symbol(appr)),"{")[1]
            modelName_m = split(apprName,"_")[1]
            global appr2=appr
            for (prI, pr) in enumerate(optiparams)
                modelName_p = split(pr, ".")[1]
                paramName = split(pr, ".")[2]
                if modelName_m == modelName_p
                    paramSymbol = Symbol(paramName)
                    paramValue = pVector[prI]
                    @eval (@set! appr2.$paramSymbol = $paramValue)
                end
            end
            push!(updated_appr, appr2)
        end
        @eval (@set! info.tem.models.$model_mode_symbol = updated_appr);
    end
    return info
end

function calcCost(pVector, info, forcing, observation)
    # update the parameters with pVector
    info = updateModelParameters(pVector, info)
    # runSpinupTEM : runspinup
    out = runSpinupTEM(info, forcing)
    # runForwardTEM: use the output of spinup to do forward run
    outTab = runForwardTEM(info, forcing, out)
    cost = perfMetric(info, outTab, observation)
    # cost= Statistics.mean(outTab.roTotal)
    @show pVector, cost
    return cost
end

function optimizeTEM(info, forcing, observation)
    funcCalc = (x -> calCost(x, info, forcing, observation))
    defParams = getDefaultParameters(info)
    @show defParams
    # x = defParams
    inner_optimizer = GradientDescent()
    results = optimize(x -> calcCost(x, info, forcing, observation), defParams.lower, defParams.upper, defParams.default, Fminbox(inner_optimizer))
    # results = optimize(x -> calcCost(x, info, forcing, observation), defParams.default)
    return results
end




