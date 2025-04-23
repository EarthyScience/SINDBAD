using GLMakie
using Flux
using Statistics
using JLD2

# Load the training history
checkpoint_path = joinpath(@__DIR__, "training_f_pft/")
checkpoint_path_all = joinpath(@__DIR__, "training_all_fixed/")

checkpoint_path_all = "/Net/Groups/BGI/scratch/skoirala/RnD/SINDBAD-RnD-SK/examples/exp_fluxnet_hybrid/output_FLUXNET_HyK/data/HyALL_ALL_kσ_2.0_fold_5_nlayers_3_n_neurons_32_200epochs_batch_size_32/"

function load_losses(checkpoint_path, nepochs)
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

function load_losses_vec(checkpoint_path, nepoch)
    losses = JLD2.load(joinpath(checkpoint_path, "checkpoint_epoch_$nepoch.jld2"))
    train_vec = losses["loss_training"]
    val_vec = losses["loss_validation"]
    test_vec =losses["loss_testing"]
    return train_vec, val_vec, test_vec
end



train_pft, val_pft, test_pft = load_losses_vec(checkpoint_path, 300)
train_all, val_all, test_all = load_losses_vec(checkpoint_path_all, 135)

with_theme(theme_light()) do
    strokecolor1 = :orangered
    strokecolor2 = :black
    outliercolor1= strokecolor1
    outliercolor2= strokecolor2

    mediancolor1 = strokecolor1
    mediancolor2 = strokecolor2

    whiskercolor1 = strokecolor1
    whiskercolor2 = strokecolor2

    strokewidth = 0.85
    width= 0.5
    color=:transparent

    fig = Figure(; size = (1200, 400))
    ax_train = Axis(fig[1,1]; title="training")
    ax_valid = Axis(fig[1,2];  title="validation")
    ax_test = Axis(fig[1,3];  title="test")
    boxplot!(ax_train, fill(1, length(train_pft)), train_pft; label = "PFT",
        color, strokecolor = strokecolor1, strokewidth,
        outliercolor= outliercolor1, mediancolor = mediancolor1, width)

    boxplot!(ax_train, fill(1, length(train_all)), train_all; label = "ALL",
        color, strokecolor = strokecolor2, strokewidth,
        outliercolor= outliercolor2, mediancolor = mediancolor2, width)

    boxplot!(ax_valid, fill(1, length(val_pft)), val_pft; color, strokecolor = strokecolor1, strokewidth,
    outliercolor= outliercolor1, mediancolor = mediancolor1, width)
    boxplot!(ax_valid, fill(1, length(val_all)), val_all; color, strokecolor = strokecolor2, strokewidth,
    outliercolor= outliercolor2, mediancolor = mediancolor2, width)

    boxplot!(ax_test, fill(1, length(test_pft)), test_pft; color, strokecolor = strokecolor1, strokewidth,
    outliercolor= outliercolor1, mediancolor = mediancolor1, width)
    boxplot!(ax_test, fill(1, length(test_all)), test_all; color, strokecolor = strokecolor2, strokewidth,
    outliercolor= outliercolor2, mediancolor = mediancolor2, width)
    axislegend(ax_train, "Covariates")
    xlims!.([ax_train, ax_valid, ax_test], 0.5,1.5)
    Label(fig[0,1:3], "Total loss: Hybrid modelling approaches")
    fig
end
save("total_loss.png", current_figure())

function plot_training_history(μtrain, μval, μtest)
    fig = Figure(; size = (600, 400))
    ax = Axis(fig[1, 1], xlabel = "Epoch", ylabel = "Loss", title = "Losses History")
    lines!(ax, μtrain, color = :dodgerblue, linewidth = 1.25, label = "training")
    lines!(ax, μval, color = :orangered, linewidth = 1.25, label = "validation")
    lines!(ax, μtest, color = :olive, linewidth = 1.25, label = "test")
    # ylims!(ax, 3, 4)
    axislegend(ax, position = :rt)
    fig
end

μtrain, μval, μtest = load_losses(checkpoint_path_all, 300)


with_theme(theme_light()) do
    display(GLMakie.Screen(), plot_training_history(μtrain, μval, μtest))
end
