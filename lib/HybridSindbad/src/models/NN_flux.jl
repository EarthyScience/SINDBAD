export nn_model, machine, test_gradient

"""
nn_model(n_features, neurons, n_out; seed = 123)
"""
function nn_model(n_features, neurons, n_out; seed=123)
    Random.seed!(seed)
    model = Flux.Chain(Flux.Dense(n_features, neurons, Flux.relu), Flux.Dense(neurons, n_out))
    return model
end

"""
machine(trainloader, target_param, loss, nn_mod;
nepochs=100, opt=Optimisers.Adam(), is_logging=false, rseed=534)
"""
function machine(trainloader,
    target_param,
    loss,
    sloss,
    nn_mod;
    nepochs=100,
    opt=Optimisers.Adam(),
    is_logging=false,
    rseed=534)
    opt_state = Optimisers.setup(opt, nn_mod)
    init_loss = loss(nn_mod, trainloader)

    p = Progress(nepochs; barglyphs=BarGlyphs("[=> ]"), color=:yellow, enabled=is_logging)
    for epoch ∈ 1:nepochs
        for data ∈ trainloader
            # TODO : trainloader needs to also include different forcing inputs, which is comming from a YAXArray
            ∇model, _ = Zygote.gradient(nn_mod, data) do model, data
                return sloss(model, data)
            end
            opt_state, nn_mod = Optimisers.update(opt_state, nn_mod, ∇model)
        end

        train_loss = loss(nn_mod, trainloader)
        opt_param = [nn_mod(s[1]) for s ∈ trainloader]

        next!(p;
            showvalues=[(:epoch, epoch),
                (:Model_seed, rseed),
                (:initial_loss, init_loss),
                (:training_loss, train_loss),
                (:target_parameter, target_param),
                (:optimise_parameter, opt_param[1])])
    end
    train_loss = loss(nn_mod, trainloader)
    opt_param = nn_mod(trainloader[1][1])
    return nn_mod
end

"""
test_gradient(nn_mod, data, loss; opt=Optimisers.Adam())
"""
function test_gradient(nn_mod, data, loss; opt=Optimisers.Adam())
    println("initial loss: ", loss(nn_mod, data))

    opt_state = Optimisers.setup(opt, nn_mod)
    ∇model, _ = Zygote.gradient(nn_mod, data) do model, data
        return loss(model, data)
    end
    opt_state, nn_mod = Optimisers.update(opt_state, nn_mod, ∇model)

    return println("Loss after update: ", loss(nn_mod, data))
end
