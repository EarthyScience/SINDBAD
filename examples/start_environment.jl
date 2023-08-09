# run(`module load proxy`)
# run(`cp -f ../base_experiment.toml Project.toml`)
using Pkg
# dev ../../ ../../lib/SindbadTEM ../../lib/SindbadOptimization ../../lib/HybridSindbad/
Pkg.activate(".")
Pkg.develop(; path="../../")
Pkg.develop(; path="../../lib/SindbadTEM")
Pkg.develop(; path="../../lib/SindbadOptimization")
Pkg.instantiate()
Pkg.add("Revise")
