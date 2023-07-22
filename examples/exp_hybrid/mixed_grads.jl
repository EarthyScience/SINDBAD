using Revise

using Sindbad
using ForwardSindbad
using ForwardSindbad: timeLoopForward
using HybridSindbad
using AxisKeys: KeyedArray as KA
using Flux, Zygote, Optimisers
using Random
Random.seed!(13)

# Sindbad.noStackTrace()
experiment_json = "./settings_distri/experiment.json"
info = getConfiguration(experiment_json)
info = setupExperiment(info);
forcing = getForcing(info);
forc = getKeyedArrayFromYaxArray(forcing);

forcing = (; Tair=forc.Tair, Rain=forc.Rain)

#forcing = (;
#    Rain =KA([5.0f0, 10.0f0, 7.0f0, 10.0f0, 2.0f0];  time=1:5),
#    Tair = KA([-2.0f0, 0.1f0, -1.0f0, 3.0f0, 10.0f0]; time=1:5),
#    )
#pprint(forcing)

# Instantiate land components
land = (;
    pools=(; snowW=[0.0f0]),
    states=(; ΔsnowW=[0.1f0], WBP=0.01f0, frac_snow=0.1f0),
    fluxes=(; snow_melt=0.2f0),
    rainSnow=(;),
    snowMelt=(;))
helpers = (;
    numbers=(; 𝟘=0.0f0),  # type that zero with \bbzero [TAB]
    dates=(; timesteps_in_day=1),
    run=(; output_all=true, runSpinup=false));
tem = (; helpers, variables=(;));

function o_models(p1, p2)
    return (rainSnow_Tair_smooth(p1), snowMelt_Tair(p2))
end

f = getForcingForTimeStep(forcing, 1)
f = ForwardSindbad.get_force_at_time_t(forcing, 1)
omods = o_models(0.0f0, 0.0f0)
land = runPrecompute(f, omods, land, helpers)

function sloss(m, data)
    x, y = data
    opt_ps = m(x)
    omods = o_models(opt_ps[1], opt_ps[2])

    out_land = timeLoopForward(omods, forcing, land, (;), helpers, length(forcing.Tair))
    ŷ = [getproperty(getproperty(o, :rainSnow), :snow) for o ∈ out_land]
    #out_land = out_land |> landWrapper
    #ŷ = #out_land[:rainSnow][:snow]
    return Flux.mse(ŷ, y)
end

# training data
x = rand(Float32, 4)
# Fake ground truth
y = rand(Float32, length(forcing.Tair)) #[5f0, 0f0, 1f0, 0f0, 1f0]
data = (x, y)

model = nn_model(4, 5, 2; seed=13)

@show sloss(model, data) # initial loss

test_gradient(model, data, sloss; opt=Optimisers.Adam())

# TODO: To be worked on
# Do your our test_gradient function 

"""
test_mixed_gradient(nn_mod, data, loss; opt=Optimisers.Adam())
"""
function test_mixed_gradients(nn_mod, data, loss; opt=Optimisers.Adam())
    println("initial loss: ", loss(nn_mod, data))

    opt_state = Optimisers.setup(opt, nn_mod)
    ∇model, _ = Zygote.gradient(nn_mod, data) do model, data
        return loss(model, data)
    end
    opt_state, nn_mod = Optimisers.update(opt_state, nn_mod, ∇model)

    return println("Loss after update: ", loss(nn_mod, data))
end

# https://github.com/mcabbott/AxisKeys.jl/issues/140

# training machine
