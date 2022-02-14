abstract type EarthEcosystem end

function runEcosystem(forcing, models)
    out = NamedTuple()
    for m in models
        out = run(m, forcing, out)
    end
    return out
end
# ForwadDiff ?
function evolveEcosystem(forcing, models, timesteps)
    out = runEcosystem(forcing[1], models) # just tuples ?
    outTime = zeros(timesteps, length(out))
    outTime[1, :] .= values(out)
    for t in 2:timesteps
        out = runEcosystem(forcing[t], models)
        outTime[t, :] .= values(out)
    end
    outTime
end