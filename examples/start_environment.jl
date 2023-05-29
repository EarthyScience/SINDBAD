# run(`module load proxy`)
run(`cp -f ../base_experiment.toml Project.toml`)
using Pkg
Pkg.activate(".")
Pkg.develop(path="../../")
Pkg.develop(path="../../lib/ForwardSindbad")
Pkg.develop(path="../../lib/OptimizeSindbad")
Pkg.develop(path="../../lib/HybridSindbad")
Pkg.instantiate()