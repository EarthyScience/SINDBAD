# run(`module load proxy`)
# run(`cp -f ../base_experiment.toml Project.toml`)
using Pkg
# dev ../../ ../../lib/ForwardSindbad ../../lib/OptimizeSindbad ../../lib/HybridSindbad/
Pkg.activate(".")
Pkg.develop(path = "../../")
Pkg.develop(path = "../../lib/ForwardSindbad")
Pkg.develop(path = "../../lib/OptimizeSindbad")
Pkg.instantiate()
Pkg.add("Revise")
