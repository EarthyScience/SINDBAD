export rainSnow_Tair

@bounds @describe @units @with_kw struct rainSnow_Tair{T} <: rainSnow
    Tair_thres::T = 0.5 | (-5.0, 5.0) | "Temperature threshold for rain-snow separation" | "°C"
end

function compute(o::rainSnow_Tair, forcing, out, modelInfo)
    @unpack_rainSnow_Tair o

    @unpack_land begin
        (Tair, rain) ∈ forcing
        # (T, R) = (Tair, rain) ∈ forcing
    end

    snow = Tair < Tair_thres ? rain : 0.0
    rain = Tair >= Tair_thres ? rain : 0.0
    precip = rain + snow

    @pack_land begin
        (rain, snow, precip) ∋ out.fluxes
    end
    return out
end

function update(o::rainSnow_Tair, forcing, out, modelInfo)
    return out
end

