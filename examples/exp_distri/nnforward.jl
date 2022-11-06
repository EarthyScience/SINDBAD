# using Lux, Zygote, Optimisers
using Revise
using Sindbad
using ForwardSindbad
using HybridSindbad
using YAXArrays
using YAXArrayBase, DimensionalData
using AxisKeys

todimset(ds) = YAXArrayBase.yaxconvert(DimArray, ds)
toyax(dimset) = YAXArrayBase.yaxconvert(YAXArray, dimset)


experiment_json = "./settings_optiSpace/experiment.json"
info = getConfiguration(experiment_json);
info = setupExperiment(info);
# ds = "/Users/lalonso/Documents/SindbadThreads/dev/Sindbad/examples/data/fluxnet_forcing.zarr/"
ds = "/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_forcing.zarr/"
output = setupOutput(info);

forcing = HybridSindbad.getForcing(info, ds, Val{:zarr}());
chunkeddata = setchunks.(forcing.data, ((site=1,),));
forcing = (; forcing..., data = (chunkeddata));

forcing_variables = forcing.variables |> collect;

forcedata = [replace(forcing.data[i].data[:,1], missing=>NaN) for i in 1:15];

#forcing_pair = (; Pair.(forcing_variables, forcedata)...)
#land_init = deepcopy(output.land_init)
#land_prec = runPrecompute(forcetuple, info.tem.models.forward, land_init, info.tem.helpers)

f = map(forcing.data) do v
    extractdata = replace(v.data[:,1], missing=>NaN)
    length(extractdata)>7 ? extractdata[1] : extractdata
end;


forcetuple = (; Pair.(forcing_variables, f)...);

out2=nothing
for x=1:2
    land_init = deepcopy(output.land_init)
    land_prec = runPrecompute(forcetuple, info.tem.models.forward, land_init, info.tem.helpers);
    out = land_prec;
    @time out2 = ForwardSindbad.runModels(forcetuple, info.tem.models.forward, out, info.tem.helpers);
    println("second... second.....................................")
    println("second... second.....................................")
end






out2 = ForwardSindbad.runModels(forcetuple, (info.tem.models.forward[53],), out2, info.tem.helpers);
    

function runit(forcetuple, info::NamedTuple, out::NamedTuple)
    i_forw = info.tem.models.forward;
    i_help = info.tem.helpers;
    otype = typeof(out)
    for i=1:15000
        out = ForwardSindbad.runModels(forcetuple, i_forw, out, i_help)::otype;
        #@show typeof(out)
    end
    out
end
        

@time runit(forcetuple,info,out2);

@profview runit(forcetuple,info,out2);
@time runit(forcetuple, info, out2);


out = ForwardSindbad.runModels(forcetuple, info.tem.models.forward, out, info.tem.helpers);


@code_warntype ForwardSindbad.runModels(forcetuple, info.tem.models.forward, land_prec, info.tem.helpers);









resgpp = zeros(14085)
function prealloc!(resgpp, out)
    for i in 1:1
        out = ForwardSindbad.runModels(forcetuple, info.tem.models.forward, out, info.tem.helpers)
        #resgpp[i] = out.fluxes.gpp
    end
end
@time prealloc!(resgpp, land_prec)


using BenchmarkTools
using Random
Random.seed!(12)

function test_nt(out, nt)
    for t = 1:nt
        b=rand()
        # Sindbad.@pack_land b => out.fluxes
        pack_nt(out)
    end
end

function pack_nt(out)
    out_out = (; out..., fluxes=(; out.fluxes..., b=rand()))
    return out_out
end

function test_dict(out, nt)
    for t = 1:nt
        pack_dict(out)
    end
end

function pack_dict(out)
    out[:fluxes][:b] = rand()
end

out_nt=(;)
out_nt = (; out..., fluxes=(;), pools=(; a=rand(10)))

out_dict = Dict(:fluxes => Dict(:b => 0.2))

ntest=100
@btime test_nt(out_nt, ntest)

