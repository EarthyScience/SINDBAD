using CairoMakie
using SwarmMakie
using Flux
using Statistics
using TypedTables
using JLD2

path_ptmp = "/ptmp/lalonso/HybridOutput/"

experiment = "$(exp_name)_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_batch_size_$(bs)/checkpoint"
checkpoint_path = joinpath(path_ptmp, experiment)
losses = JLD2.load(joinpath(checkpoint_path, "checkpoint_epoch_500.jld2"))

losses["loss_split_testing"]

# Load the training history
function load_losses(exp_name, _nfold, nlayers, n_neurons, bs, nepochs)
    path_ptmp = "/ptmp/lalonso/HybridOutput/"
    if exp_name == "HyFixK_PFT"
        bs = bs * 123
    end
    experiment = "$(exp_name)_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_batch_size_$(bs)/checkpoint"
    checkpoint_path = joinpath(path_ptmp, experiment)

    μtrain = Float32[]
    μval = Float32[]
    μtest = Float32[]

    for epoch in 1:nepochs
        losses = JLD2.load(joinpath(checkpoint_path, "checkpoint_epoch_$epoch.jld2"))
        push!(μtrain, mean(losses["loss_training"]))
        push!(μval, mean(losses["loss_validation"]))
        push!(μtest, mean(losses["loss_testing"]))

    end
    return μtrain, μval, μtest
end

function plot_training_history(μtrain, μval, μtest)
    with_theme(theme_light()) do
        fig = Figure(; size = (600, 400))
        ax = Axis(fig[1, 1], xlabel = "epoch", ylabel = "loss", title = "history")
        lines!(ax, μtrain, color = :dodgerblue, linewidth = 1.25, label = "training")
        lines!(ax, μval, color = :orangered, linewidth = 1.25, label = "validation")
        lines!(ax, μtest, color = :olive, linewidth = 1.25, label = "test")
        # ylims!(ax, 3, 4)
        axislegend(ax, position = :rt)
        save("history_losses_5.png", fig)
    end
end

# ? load n-fold history
nepochs=500
_nfold = 5
nlayers= 2
n_neurons = 32
bs = 32
exp_name = "HyFixK_ALL"

μtrain, μval, μtest = load_losses(exp_name, _nfold, nlayers, n_neurons, bs, 500)
plot_training_history(μtrain, μval, μtest)


function plot_training_history_folds(exp_name, nlayers, n_neurons, bs, nepochs)
    with_theme(theme_light()) do
        fig = Figure(; size = (400, 900))
        axs = [Axis(fig[row, 1]) for row in 1:5]
        for (_nfold, ax) in enumerate(axs)
            μtrain, μval, μtest = load_losses(exp_name, _nfold, nlayers, n_neurons, bs, nepochs)

            lines!(ax, μtrain, color = :dodgerblue, linewidth = 1.25, label = "training")
            lines!(ax, μval, color = :orangered, linewidth = 1.25, label = "validation")
            lines!(ax, μtest, color = :olive, linewidth = 1.25, label = "test")
            ax.title = "fold $(_nfold)"
        end
        axislegend(axs[1], position = :rt, nbanks=3)
        hidexdecorations!.(axs[1:4], ticks=false, grid=false)
        linkaxes!.(axs)
        limits!.(axs, 0, nepochs, 2.7, 4.5)
        rowgap!(fig.layout, 0)
        save("$(exp_name)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_bs_$(bs)_history.png", fig)
    end
end

# ? load n-fold history
nepochs=500
_nfold = 5
nlayers= 2
n_neurons = 32
bs = 32
exp_name = "HyFixK_ALL" # HyFixK_PFT
plot_training_history_folds(exp_name, nlayers, n_neurons, bs, nepochs)

exp_name = "HyFixK_PFT" #
plot_training_history_folds(exp_name, nlayers, n_neurons, bs, nepochs)

exp_name = "HyALL_ALL"
nepochs = 150
plot_training_history_folds(exp_name, nlayers, n_neurons, bs, nepochs)

exp_name = "HyALL_PFT"
nepochs = 100
plot_training_history_folds(exp_name, 3, n_neurons, bs, nepochs)

# do per variable

function collect_per_fold(exp_name="HyFixK_ALL", _nfold=1, nepochs=500, bs = 32, nlayers=2, n_neurons=32)
    if exp_name == "HyFixK_PFT"
        bs = bs * 123
    end
    experiment = "$(exp_name)_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_batch_size_$(bs)/checkpoint"
    checkpoint_path = joinpath(path_ptmp, experiment)
    losses = JLD2.load(joinpath(checkpoint_path, "checkpoint_epoch_$(nepochs).jld2"))
    split_testing = losses["loss_split_testing"]
    split_tested = replace(x -> iszero(x) ? NaN : x, split_testing)
    return split_tested
end

function collect_folds(exp_name="HyFixK_ALL", nepochs=500, bs = 32, nlayers=2, n_neurons=32)
    _nfold = 1
    if exp_name == "HyFixK_PFT"
        bs = bs * 123
    end
    experiment = "$(exp_name)_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_batch_size_$(bs)/checkpoint"
    checkpoint_path = joinpath(path_ptmp, experiment)
    losses = JLD2.load(joinpath(checkpoint_path, "checkpoint_epoch_$(nepochs).jld2"))
    split_testing = losses["loss_split_testing"]
    split_tested = replace(x -> iszero(x) ? NaN : x, split_testing)
    
    # ? collect all folds
    for _nfold in 2:5
        experiment = "$(exp_name)_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_batch_size_$(bs)/checkpoint"
        checkpoint_path = joinpath(path_ptmp, experiment)
        losses = JLD2.load(joinpath(checkpoint_path, "checkpoint_epoch_$(nepochs).jld2"))
    
        split_testing = losses["loss_split_testing"]
        split_testing = replace(x -> iszero(x) ? NaN : x, split_testing)
    
        split_tested = vcat(split_tested, split_testing)
    end
    return split_tested
end

split_tested = collect_folds()


function plot_box_split(split_m)
    _constraints = ["gpp", "nee", "reco", "transpiration", "evapotranspiration", "agb", "ndvi"]
    _colors = ["#4CAF50", "#1565C0", "#D32F2F", "#00ACC1", "#00897B", "#8D6E63", "#CDDC39"]
    with_theme() do
        fig = Figure(; size = (1200, 300))
        axs = [Axis(fig[1, i]) for i in 1:7]
        for (i, ax) in enumerate(axs)
            tmp_vec = filter(!isnan, split_m[:,i])

            boxplot!(ax, fill(1, length(tmp_vec)), tmp_vec; width=0.35, color = (_colors[i],0.5))
            # ax.xticks=([0.75, 1, 1.25], ["", rich("$(_constraints[i])", color=:grey15, font=:bold), ""])
            ax.title= rich("$(_constraints[i])", color=:grey15, font=:bold)
            ax.yticks=[0, 0.25, 0.5, 0.75, 1.0]
        end
        axs[1].ylabel = "Loss"
        ylims!.(axs, 0, 1)
        xlims!.(axs, 0.5, 1.5)
        hideydecorations!.(axs[2:end], ticks=true, grid=false)
        # hidexdecorations!.(axs, grid=false, label=false, ticklabels=false, ticks=true)
        hidexdecorations!.(axs, grid=false, label=false, ticklabels=true)
        hidespines!.(axs)
        save("$(exp_name)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_bs_$(bs)_box_test.png", fig)
    end
end

plot_box_split(split_tested)


function plot_violin_split(split_m)
    _constraints = ["gpp", "nee", "reco", "transpiration", "evapotranspiration", "agb", "ndvi"]
    _colors = ["#4CAF50", "#1565C0", "#D32F2F", "#00ACC1", "#00897B", "#8D6E63", "#CDDC39"]
    with_theme() do
        fig = Figure(; size = (1200, 300))
        axs = [Axis(fig[1, i]) for i in 1:7]
        for (i, ax) in enumerate(axs)
            tmp_vec = filter(!isnan, split_m[:,i])

            violin!(ax, fill(1, length(tmp_vec)), tmp_vec; color = (_colors[i],0.65))
            boxplot!(ax, fill(1, length(tmp_vec)), tmp_vec; width=0.35, strokecolor = :white,
                strokewidth=1.5, whiskercolor=:white, mediancolor=:white,
                color = :transparent)
            ax.title= rich("$(_constraints[i])", color=:grey15, font=:bold)
            ax.yticks=[0, 0.25, 0.5, 0.75, 1.0]
        end
        axs[1].ylabel = "Loss"
        ylims!.(axs, 0, 1)
        xlims!.(axs, 0.5, 1.5)
        hideydecorations!.(axs[2:end], ticks=true, grid=false)
        # hidexdecorations!.(axs, grid=false, label=false, ticklabels=false, ticks=true)
        hidexdecorations!.(axs, grid=false, label=false, ticklabels=true)
        hidespines!.(axs)
        save("$(exp_name)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_bs_$(bs)_violin_test.png", fig)
    end
end

plot_violin_split(split_tested)


# ! Collect all experiments
# "HyFixK_ALL", "HyFixK_PFT", "HyALL_ALL", "HyALL_PFT"
split_tested_HyALL_ALL = collect_folds("HyALL_ALL", 400, 32, 2, 32)
split_tested_HyALL_PFT = collect_folds("HyALL_PFT", 300,  32, 2, 32)
split_tested_HyFixK_ALL = collect_folds("HyFixK_ALL", 500, 32, 2, 32)
split_tested_HyFixK_PFT = collect_folds("HyFixK_PFT", 500, 32, 2, 32)

function plot_box_split_all(split_m1, split_m2, split_m3, split_m4)
    _constraints = ["gpp", "nee", "reco", "transpiration", "evapotranspiration", "agb", "ndvi"]
    _colors = ["#4CAF50", "#1565C0", "#D32F2F", "#00ACC1", "#00897B", "#8D6E63", "#CDDC39"]
    with_theme() do
        fig = Figure(; size = (1200, 500))
        axs = [Axis(fig[row, col]) for col in 1:4 for row in 1:2]
        for (i, ax) in enumerate(axs[1:end-1])
            tmp_vec1 = filter(!isnan, split_m1[:,i])
            tmp_vec2 = filter(!isnan, split_m2[:,i])
            tmp_vec3 = filter(!isnan, split_m3[:,i])
            tmp_vec4 = filter(!isnan, split_m4[:,i])

            boxplot!(ax, fill(1, length(tmp_vec1)), tmp_vec1; width=0.35, color = (_colors[i], 0.25),
                strokecolor = _colors[i], strokewidth=1.5, whiskercolor=_colors[i], mediancolor=_colors[i],)

            boxplot!(ax, fill(2, length(tmp_vec2)), tmp_vec2; width=0.35, color = (_colors[i], 0.25),
                strokecolor = _colors[i], strokewidth=1.5, whiskercolor=_colors[i], mediancolor=_colors[i],)
            boxplot!(ax, fill(3, length(tmp_vec3)), tmp_vec3; width=0.35, color = (_colors[i], 0.25),
                strokecolor = _colors[i], strokewidth=1.5, whiskercolor=_colors[i], mediancolor=_colors[i],)
            boxplot!(ax, fill(4, length(tmp_vec4)), tmp_vec4; width=0.35, color = (_colors[i], 0.25),
                strokecolor = _colors[i], strokewidth=1.5, whiskercolor=_colors[i], mediancolor=_colors[i],)

            ax.title= rich("$(_constraints[i])", color=:grey15, font=:bold)
            ax.xticks = ([1,2,3,4], [rich("ALL_ALL"; font=:regular, color=:grey25),
                rich("FixK_ALL"; font=:bold, color=:grey15),
                rich("ALL_PFT"; font=:regular, color=:grey25),
                rich("FixK_PFT"; font=:bold, color=:grey15)])

            ax.yticks=[0, 0.25, 0.5, 0.75, 1.0]
        end
        axs[1].ylabel = "Loss"
        axs[2].ylabel = "Loss"
        ylims!.(axs, 0, 1)
        xlims!.(axs, 0.5, 4.5)
        hideydecorations!.(axs[3:end], ticks=true, grid=false)
        # hideydecorations!.(axs[5:end], ticks=true, grid=false)
        delete!(axs[end])
        # hidexdecorations!.(axs, grid=false, label=false, ticklabels=false, ticks=true)
        hidexdecorations!.(axs, grid=false, label=false, ticklabels=false)
        hidespines!.(axs)
        save("ALL_nlayers_$(nlayers)_n_neurons_$(n_neurons)_bs_$(bs)_box_test.png", fig)
    end
end

plot_box_split_all(split_tested_HyALL_ALL, split_tested_HyFixK_ALL, split_tested_HyALL_PFT, split_tested_HyFixK_PFT)

# TODO: also per fold!

function plot_box_split_all(split_m1, split_m2, split_m3, split_m4, _nfold)
    _constraints = ["gpp", "nee", "reco", "transpiration", "evapotranspiration", "agb", "ndvi"]
    _colors = ["#4CAF50", "#1565C0", "#D32F2F", "#00ACC1", "#00897B", "#8D6E63", "#CDDC39"]
    with_theme() do
        fig = Figure(; size = (1200, 500))
        axs = [Axis(fig[row, col]) for col in 1:4 for row in 1:2]
        for (i, ax) in enumerate(axs[1:end-1])
            tmp_vec1 = filter(!isnan, split_m1[:,i])
            tmp_vec2 = filter(!isnan, split_m2[:,i])
            tmp_vec3 = filter(!isnan, split_m3[:,i])
            tmp_vec4 = filter(!isnan, split_m4[:,i])

            boxplot!(ax, fill(1, length(tmp_vec1)), tmp_vec1; width=0.35, color = (_colors[i], 0.25),
                strokecolor = _colors[i], strokewidth=1.5, whiskercolor=_colors[i], mediancolor=_colors[i],)

            boxplot!(ax, fill(2, length(tmp_vec2)), tmp_vec2; width=0.35, color = (_colors[i], 0.25),
                strokecolor = _colors[i], strokewidth=1.5, whiskercolor=_colors[i], mediancolor=_colors[i],)
            boxplot!(ax, fill(3, length(tmp_vec3)), tmp_vec3; width=0.35, color = (_colors[i], 0.25),
                strokecolor = _colors[i], strokewidth=1.5, whiskercolor=_colors[i], mediancolor=_colors[i],)
            boxplot!(ax, fill(4, length(tmp_vec4)), tmp_vec4; width=0.35, color = (_colors[i], 0.25),
                strokecolor = _colors[i], strokewidth=1.5, whiskercolor=_colors[i], mediancolor=_colors[i],)

            ax.title= rich("$(_constraints[i])", color=:grey15, font=:bold)
            ax.xticks = ([1,2,3,4], [rich("ALL_ALL"; font=:regular, color=:grey25),
                rich("FixK_ALL"; font=:bold, color=:grey15),
                rich("ALL_PFT"; font=:regular, color=:grey25),
                rich("FixK_PFT"; font=:bold, color=:grey15)])

            ax.yticks=[0, 0.25, 0.5, 0.75, 1.0]
        end
        axs[1].ylabel = "Loss"
        axs[2].ylabel = "Loss"
        ylims!.(axs, 0, 1)
        xlims!.(axs, 0.5, 4.5)
        hideydecorations!.(axs[3:end], ticks=true, grid=false)
        # hideydecorations!.(axs[5:end], ticks=true, grid=false)
        delete!(axs[end])
        # hidexdecorations!.(axs, grid=false, label=false, ticklabels=false, ticks=true)
        hidexdecorations!.(axs, grid=false, label=false, ticklabels=false)
        hidespines!.(axs)
        save("Fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_bs_$(bs)_box_test.png", fig)
    end
end

for _nfold in 1:5
    split_tested_HyALL_ALL = collect_per_fold("HyALL_ALL", _nfold, 400, 32, 2, 32)
    split_tested_HyALL_PFT = collect_per_fold("HyALL_PFT", _nfold, 300,  32, 2, 32)
    split_tested_HyFixK_ALL = collect_per_fold("HyFixK_ALL", _nfold, 500, 32, 2, 32)
    split_tested_HyFixK_PFT = collect_per_fold("HyFixK_PFT", _nfold, 500, 32, 2, 32)
    plot_box_split_all(split_tested_HyALL_ALL, split_tested_HyFixK_ALL, split_tested_HyALL_PFT, split_tested_HyFixK_PFT, _nfold)
end


# split_testing_nan = replace(x -> iszero(x) ? NaN : x, split_testing)


# ? avail
# plot_training_history_folds(exp_name, 3, n_neurons, bs, nepochs)
# plot_training_history_folds(exp_name, 3, 16, bs, nepochs)

# plot_training_history_folds(exp_name, 2, 16, bs, nepochs)

# plot_training_history_folds(exp_name, 2, n_neurons, 16, 400)






# function load_losses_vec(checkpoint_path, nepoch)
#     losses = JLD2.load(joinpath(checkpoint_path, "checkpoint_epoch_$nepoch.jld2"))
#     train_vec = losses["loss_training"]
#     val_vec = losses["loss_validation"]
#     test_vec =losses["loss_testing"]
#     return train_vec, val_vec, test_vec
# end



# train_all, val_all, test_all = load_losses_vec(checkpoint_path, 300)
