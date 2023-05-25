using Zygote
using Optimisers
using Flux
using Random
using AxisKeys: KeyedArray as KA
using HybridSindbad: nn_model, test_gradient

function full_eco(forcing, Tair_thres)
    Rains, Tairs = forcing
    ΔsnowW = [0.0f0]
    ΔsnowW_buff = Zygote.Buffer(ΔsnowW)
    full_buff = Zygote.Buffer([0.0f0],1,100)
    copyto!(ΔsnowW_buff, ΔsnowW)
    for t in 1:100 # time loop (simple)
        Rain = Rains[t]
        Tair = Tairs[t]

        precip, rain = 0f0, 0f0
        if Tair < Tair_thres
            snow = Rain
            rain = 0f0
        else
            rain = Rain
            snow = 0f0
        end
        snowFrac = 1 - 1/(1+exp(1*(-Tair + Tair_thres)))
        snow = rain * snowFrac
        rain = rain - snow
        precip = rain + snow
        # add snowfall to snowpack of the first layer
        ΔsnowW_buff[1] = ΔsnowW_buff[1] + snow
        full_buff[1,t] =  snow
    end
    return copy(full_buff)
end

forcing = (;
    Rain =KA(rand(2.0:20.0,100);  time=1:100),
    Tair = KA(rand(-2.0:10.0,100); time=1:100),
    )

snow = full_eco(forcing, 0.0f0)

function sos_loss(m, data)
    x, y = data
    opt_param = m(x)
    ŷ = full_eco(forcing, opt_param[1])
    return Flux.mse(ŷ,y)
end

data = (; x=rand(Float32,4), y = snow)

model = nn_model(4, 5, 2; seed = 13)
sos_loss(model, data)

test_gradient(model, data, sos_loss; opt=Optimisers.Adam())
