abstract type TerEcosystem end

function runEcosystem(forcing, models, out)
    for m in models
        out = run(m, forcing, out)
    end
    return out
end

function initiateStates(wSnow, wSoil)
    out = NamedTuple()
    out = (; out..., wSnow, wSoil) 
    return out
end

out = initiateStates(0.0, 0.0)
keys(out)

# ForwadDiff ?
function evolveEcosystem(forcing, models, timesteps)
    out = initiateStates(0.01,0.01)
    out = runEcosystem(forcing[1], models, out) # just tuples ?
    outTime = zeros(timesteps, length(out))
    outTime[1, :] .= values(out)
    for t in 1:timesteps
        out = runEcosystem(forcing[t], models, out)
        outTime[t, :] .= values(out)
    end
    namesOut = keys(out)
    valuesOut = [outTime[:, i] for i in 1:length(namesOut)]
    outTable = Table((; zip(namesOut, valuesOut)...))
    return outTable
end