module SindbadEvolutionaryExt

import SindbadCore.Types: EvolutionaryCMAES

import Evolutionary
import Sindbad

# copied from Optimization/optimizer.jl and modified to include Sindbad namespace
function Sindbad.Optimization.optimizer(cost_function, default_values, lower_bounds, upper_bounds, algo_options, ::EvolutionaryCMAES)
    optim_results = Evolutionary.optimize(cost_function, Evolutionary.BoxConstraints(lower_bounds, upper_bounds), default_values, Evolutionary.CMAES(), Evolutionary.Options(; algo_options...))
    optim_para = Evolutionary.minimizer(optim_results)
    return optim_para
end

end