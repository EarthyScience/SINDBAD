@with_kw struct getStates{type} <: TerEcosystem
    updateState::type = true
    # wSoil::type = 0.0
    # wSnow::type = 0.0
end

function run(o::getStates, forcing, out)
    @unpack_getStates o
    (; wSoil, wSnow) = out
    return (; out..., wSoil, wSnow)
end