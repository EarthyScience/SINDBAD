using Revise

using Sindbad
using ForwardSindbad
using ForwardSindbad: timeLoopForward
using HybridSindbad
using AxisKeys: KeyedArray as KA
using Flux, Zygote, Optimisers
using Random
Random.seed!(13)

experiment_json = "./settings_distri/experiment.json"

info = getConfiguration(experiment_json);
info = setupExperiment(info);
forcing = getForcing(info, Val{:zarr}());
forc = getKeyedArrayFromYaxArray(forcing);

forcing = (; Tair = forc.Tair, Rain = forc.Rain)

#forcing = (;
#    Rain =KA([5.0f0, 10.0f0, 7.0f0, 10.0f0, 2.0f0];  time=1:5),
#    Tair = KA([-2.0f0, 0.1f0, -1.0f0, 3.0f0, 10.0f0]; time=1:5),
#    )
#pprint(forcing)

# Instantiate land components
land = createLandInit(info.tem)
helpers = info.tem.helpers; 
tem = info.tem;
# helpers = (; numbers =(; 𝟘 = 0.0f0),  # type that zero with \bbzero [TAB]
#     dates = (; nStepsDay=1),
#     run = (; output_all=true, runSpinup=false),
#     );
# tem = (;
#     helpers,
#     variables = (;),
#     );

function o_models(p1, p2)
    return (rainSnow_Tair_buffer(p1), snowFraction_HTESSEL(1.0f0),  snowMelt_Tair_buffer(p2), wCycle_components())
end

#f = getForcingForTimeStep(forcing, 1)
#f = getForcingForTimeStep(forcing, 1)
f = ForwardSindbad.get_force_at_time_t(forcing, 1)

omods = o_models(0.0f0, 0.0f0)
land = runPrecompute(f, omods, land, helpers)

function sloss(m, data)
    x, y = data
    opt_ps = m(x)
    omods = o_models(opt_ps[1], opt_ps[2])

    out_land = timeLoopForward(omods, forcing, land, (; ), helpers, 10)
    ŷ = [getproperty(getproperty(o, :rainSnow), :snow) for o in out_land]

    #out_land = out_land |> landWrapper
    #ŷ = #out_land[:rainSnow][:snow]
    return Flux.mse(ŷ,y)
end



function floss(p)
    omods = o_models(p[1], p[2])
    out_land = timeLoopForward(omods, forcing, land, (; ), helpers, 10000)
    ŷ = [getproperty(getproperty(o, :rainSnow), :snow) for o in out_land]
    sum((ŷ.-y).^2)
end
y = rand(10000)

floss((0.5,0.5))


using ForwardDiff

@time ForwardDiff.gradient(floss, [1.0,1000.0])



test_gradient(model, data, sloss; opt=Optimisers.Adam())

# https://github.com/mcabbott/AxisKeys.jl/issues/140

# training machine

# generate fake target parameters

function get_target(m, x)
    target_param = m(x)
    omods = o_models(target_param[1], target_param[2])
    out_land = timeLoopForward(omods, forcing, land, (; ), helpers, 100)
    y = [getproperty(getproperty(o, :rainSnow), :snow) for o in out_land]
    return (y, target_param)
end

Random.seed!(122)
d = [rand(Float32,4) for i in 1:50]
nn_mod_d = nn_model(4, 5, 2; seed = 5234)

y, target_param = get_target(nn_mod_d, d[1]) # get an initial target
trainloader = [(di, y) for di in d]

# my awful loss
function loss(nn_mod, trainloader)
    l = 0f0
    for data in trainloader
        l += sloss(nn_mod, data)
    end
    return l/size(trainloader,1)
end

new_model = nn_model(4, 5, 2; seed = 534)

loss(new_model, trainloader)

machine(trainloader, target_param, loss, sloss, new_model; is_logging=true)

# TODO, x -> batched

# i.e. Input x  now should be 

x = rand(Float32, 4, 10)
opt_p = new_model(x)

# omods -> ?
# ŷ -> 

function sloss(m, data)
    x, y = data
    opt_ps = m(x)
    omods = o_models(opt_ps[1], opt_ps[2])

    out_land = timeLoopForward(omods, forcing, land, (; ), helpers, 5)
    ŷ = [getproperty(getproperty(o, :rainSnow), :snow) for o in out_land]
    #out_land = out_land |> landWrapper
    #ŷ = #out_land[:rainSnow][:snow]
    return Flux.mse(ŷ,y)
end