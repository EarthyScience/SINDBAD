using Revise
using Sinbad
# using ProfileView
using BenchmarkTools
#using GLMakie


expFile = "sandbox/test_json/settings_minimal/experiment.json"
info = getConfiguration(expFile);
info = setupModel!(info);

