using Revise
using Sindbad
using ForwardSindbad
# using OptimizeSindbad
using Cthulhu
using BenchmarkTools
# noStackTrace()
experiment_json = "../exp_WROASTED/settings_WROASTED/experiment.json"
sYear = "1979"
eYear = "2017"
inpath = "/Net/Groups/BGI/scratch/skoirala/wroasted/fluxNet_0.04_CLIFF/fluxnetBGI2021.BRK15.DD/data/ERAinterim.v2/daily/DE-Hai.1979.2017.daily.nc"
obspath = inpath
forcingConfig = "forcing_erai.json"
optimize_it = false
# optimize_it = true
outpath = nothing

domain = "DE-Hai"
pl = "threads"
replace_info = Dict(
    "modelRun.time.sDate" => sYear * "-01-01",
    "experiment.configFiles.forcing" => forcingConfig,
    "experiment.domain" => domain,
    "modelRun.time.eDate" => eYear * "-12-31",
    "modelRun.flags.runOpti" => optimize_it,
    "modelRun.flags.calcCost" => true,
    "spinup.flags.saveSpinup" => false,
    "modelRun.flags.runSpinup" => true,
    "spinup.flags.doSpinup" => true,
    # "forcing.defaultForcing.dataPath" => inpath,
    "modelRun.output.path" => outpath,
    "modelRun.mapping.parallelization" => pl
    # "opti.constraints.oneDataPath" => obspath
);

# output = setupOutput(info)

run_output=nothing


doitstepwise = true
info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify info
forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)));
# spinup_forcing = getSpinupForcing(forcing, info.tem);
output = setupOutput(info);

# @time runExperimentForward(experiment_json; replace_info=replace_info);
# @time run_output = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache)
forc = getKeyedArrayFromYaxArray(forcing);
# @profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
# @benchmark $runEcosystem!($output.data, $info.tem.models.forward, $forc, $info.tem)
# @btime $runEcosystem!($output.data, $info.tem.models.forward, $forc, $info.tem, land_init);
linit= createLandInit(info.tem);

# tmp=createLandInit(info.tem); #::NamedTuple{NamedTuple{NTuple}};
# for pn in propertynames(tmp)
#     @show pn, typeof(getproperty(tmp, pn))
#     pnn = propertynames(tmp[pn])
#     if length(pnn) > 0
#         for pnnn in pnn
#             @show pn, typeof(getproperty(tmp[pn], pnnn))
#         end
#     end
# end
GC.gc()
Sindbad.eval(:(error_catcher = []))    
# Sindbad.eval(:(error_catcher = []))    
additionaldims, spaceLocs, l_init_threads, dtypes, dtypes_list = prepRunEcosystem(output.data, info.tem.models.forward, forc, info.tem);

@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, additionaldims, spaceLocs, l_init_threads, dtypes, dtypes_list)
@time runEcosystem!(output.data, info.tem.models.forward, forc, info.tem)

@benchmark runEcosystem!(output.data, info.tem.models.forward, forc, info.tem)
@benchmark runEcosystem!(output.data, info.tem.models.forward, forc, info.tem, additionaldims, spaceLocs, l_init_threads, dtypes, dtypes_list)
a=1
@code_warntype runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
@profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);

# @benchmark runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
@descend_code_warntype runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);




@code_warntype test(0.1)
# using BenchmarkTools
# @btime runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
# @benchmark runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);


@profview runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
# @code_warntype runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
# @descend runEcosystem!(output.data, info.tem.models.forward, forc, info.tem);
run_output = runExperimentForward(experiment_json; replace_info=replace_info);
run_output = runExperimentOpti(experiment_json; replace_info=replace_info);
# if doitstepwise
#     info = getExperimentInfo(experiment_json; replace_info=replace_info) # note that this will modify info
#     # info = getExperimentInfo(experiment_json) # note that the modification will not work with this
#     forcing = getForcing(info, Val(Symbol(info.modelRun.rules.data_backend)))
#     # spinup_forcing = getSpinupForcing(forcing, info.tem);
#     output = setupOutput(info)

#     # forward run
#     if optimize_it
#         # optimization
#         observations = getObservation(info, Val(Symbol(info.modelRun.rules.data_backend)))
#         run_output = mapOptimizeModel(forcing, output, info.tem, info.optim, observations,
#             ; spinup_forcing=nothing, max_cache=info.modelRun.rules.yax_max_cache)
#     else
#         run_output = mapRunEcosystem(forcing, output, info.tem, info.tem.models.forward; max_cache=info.modelRun.rules.yax_max_cache)
#     end
# else
#     run_output = runExperiment(experiment_json; replace_info=replace_info);
# end
using AxisKeys
ts=1

@time f = gft(forcing, ts);

b = map(f) do ff
    ff
end

# f2 = @time gft(forcing, ts, f);
nt = (a=rand(10), b=rand(), c=rand(5))
ss=gft(nt, ts)
@btime ss=gft(nt, ts);

@btime gftd(forcing, ts, ss);
function gftd(forcing::NamedTuple, ts::Int64, f_t)
    foreach(keys(forcing)) do v
        # @show v
        if isa(v, Number) 
            f_t = setTupleField(f_t, (v, forcing[v]))
        else
            f_t = setTupleField(f_t, (v, forcing[v][ts]))
        end
   end
   return f_t
end

function gft(forcing::NamedTuple, ts::Int64)
    a = map(forcing) do v
        isa(v, Number) ? v : v[ts]
   end
   return a
end
a

forc_vars = (:ambCO2, :Rain, :Rg, :PAR, :RgPot, :Rn, :isDisturbed, :Tair, :TairDay, :VPD, :VPDDay, :CLAY, :SAND, :SILT, :ORGM)
function getForcingForTimeStep(f, ::Val{forc_vars}, f_t) where forc_vars
    output = quote
    end
    foreach(forc_vars) do forc
            push!(output.args,Expr(:(=),:v,Expr(:.,:forcing,QuoteNode(forc))))
            # push!(output.args, Expr(:(=), :d, Expr(:if, Expr(:call, :in, :time, Expr(:call, Expr(:., :AxisKeys, :(:dimnames)), :v)), Expr(:ref, :v, :($(Expr(:kw, :time, ts)))),:v)))
            push!(output.args,quote
                    d = in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v
                end)
            push!(output.args, Expr(:macrocall, Symbol("@set"), :(#= none:1 =#), Expr(:(=), Expr(:., :f_t, QuoteNode(forc)), :d)))
    end
    output
end


Expr(Symbol("@set"), :(#= none:1 =#), Expr(:., :forcing_t, QuoteNode(forc)),Expr(:if, Expr(:call, :in, :time, Expr(:call, Expr(:., :AxisKeys, :(:dimnames)), :v)), Expr(:ref, :v, :($(Expr(:kw, :time, ts)))),:v))

# @set forcing_t[f_I] = in(:time, AxisKeys.dimnames(v)) ? v[time=ts] : v

Expr(:(=), :d, Expr(:if, Expr(:call, :in, :time, Expr(:call, Expr(:., :AxisKeys, :(:dimnames)), :v)), Expr(:ref, :v, :($(Expr(:kw, :time, :ts)))),:v))
ts=2
f_t = (ambCO2 = 336.01, Rain = 0.0, Rg = 3.13078534197962, PAR = 1.56539267098981, RgPot = 7.575181632, Rn = 0.682237425654876, isDisturbed = 0.0, Tair = -11.3033383251168, TairDay = -11.6130793909429, VPD = 0.0413754746488994, VPDDay = 0.05390312026303, CLAY = [0.17, 0.16, 0.17, 0.17, 0.18, 0.18, 0.18], SAND = [0.37, 0.37, 0.38, 0.39, 0.41000000000000003, 0.43, 0.44], SILT = [0.47000000000000003, 0.47000000000000003, 0.46, 0.44, 0.41000000000000003, 0.39, 0.38], ORGM = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, NaN])
for ts = 1:5
    f=getForcingForTimeStep(forcing, Val(forc_vars), f_t);
    @show f
end
a


ForwardSindbad.getForcingForTimeStep(forcing, 5)

# # @generated 
function setOuputT!(outputs, land, ::Val{TEM}, ts, dtypes, dtypes_list) where TEM
    output = quote
        # var_index = 1
    end
    var_index = 1
        foreach(keys(TEM)) do group
        # push!(output.args,Expr(:(=),:landgroup,Expr(:.,:land,QuoteNode(group))))
        foreach(TEM[group]) do k
            push!(output.args,Expr(:(=),:data_l,Expr(:.,Expr(:.,:land,QuoteNode(group)),QuoteNode(k))))
                # push!(output.args,Expr(:(=),:data_l, Expr(:(::), Expr(:.,Expr(:.,:land,QuoteNode(group)),QuoteNode(k)), Expr(:ref, :dtypes_list, var_index))))
                    push!(output.args,quote
                data_o = outputs[$var_index]
                fill_it!(data_o, data_l, ts)
            end)
            var_index += 1
        end
    end
    output
end



setOuputT!(1,1,Val(tem_variables),1,1,[:a, :b, :c, :d, :e, :f, :g, :h])

tem_variables = (pools = (:snowW, :soilW), waterBalance = (:waterBalance,), fluxes = (:evapotranspiration, :transpiration, :runoff, :runoffSurface, :gpp))

