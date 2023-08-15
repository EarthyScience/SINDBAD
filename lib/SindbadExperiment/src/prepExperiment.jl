export prepExperimentForward
export prepExperimentOpti

"""
    prepExperimentForward(sindbad_experiment::String; replace_info = nothing)

prepares info, forcing and output NT for the forward experiment
"""
function prepExperimentForward(sindbad_experiment::String; replace_info=nothing)
    @info "\n----------------------------------------------\n"

    @info "prepExperimentForward: getting experiment info..."
    info = getExperimentInfo(sindbad_experiment; replace_info=replace_info)


    @info "\n----------------------------------------------\n"
    @info "prepExperimentForward: get forcing data..."
    forcing = getForcing(info)

    @info "\n----------------------------------------------\n"

    @info "prepExperimentForward: setup output..."
    @info "\n----------------------------------------------\n"
    output = prepTEMOut(info, forcing.helpers)
    return info, forcing, output
end

"""
    prepExperimentOpti(sindbad_experiment::String; replace_info = nothing)

prepares info, forcing, output, and observation NT for the forward experiment
"""
function prepExperimentOpti(sindbad_experiment::String; replace_info=nothing)
    @info "\n----------------------------------------------\n"

    info, forcing, output = prepExperimentForward(sindbad_experiment; replace_info=replace_info)

    @info "runExperiment: get observations..."
    @info "\n----------------------------------------------\n"
    observations = getObservation(info, forcing.helpers)
    return info, forcing, output, observations
end
