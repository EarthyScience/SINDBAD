
function optimizer()
    # run the optimizer
    adtype = Optimization.AutoZygote()
    optf = Optimization.OptimizationFunction(cost_function, adtype)
    optprob = Optimization.OptimizationProblem(optf, ps_new)
    return optim_para = solve(optprob, Optim.BFGS(; initial_stepnorm=0.1))
end
