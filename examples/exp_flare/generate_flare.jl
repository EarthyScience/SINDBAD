
using Sindbad

info = getExperimentInfo("../exp_flare/settings_flare/experiment.json"); 


flare_json = namedTupleToFlareJSON(info)

open(joinpath(@__DIR__,"sindbad_info.json"), "w") do f
    SindbadSetup.json_print(f, flare_json)
end