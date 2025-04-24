using GLMakie
using Flux
using Statistics
using JLD2

# Load the training history
checkpoint_path = joinpath(@__DIR__, "training_f_pft/")
checkpoint_path_all = joinpath(@__DIR__, "training_all_fixed/")

using Colors

function generate_distinct_colors(n::Int;lightness=0.8)
    # Generate a color palette with n distinct colors
    base_colors = distinguishable_colors(n)
    # Create darker shades by reducing the lightness
    darker_colors = [RGB(color.r * lightness, color.g * lightness, color.b * lightness) for color in base_colors]
    
    return darker_colors
end

function load_losses_median(checkpoint_path, nepochs)
    μtrain = Float32[]
    μval = Float32[]
    μtest = Float32[]

    for epoch in 1:nepochs
        losses = JLD2.load(joinpath(checkpoint_path, "checkpoint_epoch_$epoch.jld2"))
        push!(μtrain, median(losses["loss_training"]))
        push!(μval, median(losses["loss_validation"]))
        push!(μtest, median(losses["loss_testing"]))

    end
    return μtrain, μval, μtest
end

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



k_σs=Tuple(Float32[1.0, 0.25, 4.0, 0.5, 2, 0.125, 8])
k_colors = generate_distinct_colors(length(k_σs))

n_params = 34;
nlayers = 3 # Base.parse(Int, ARGS[2])
n_neurons = 32 # Base.parse(Int, ARGS[3])
batch_size = 32 # Base.parse(Int, ARGS[4])
batch_seed = 123 * batch_size * 2
n_epochs = 200
_nfold = 5 #Base.parse(Int, ARGS[1]) # select the fold


# checkpoint_path_all = "/Users/skoirala/research/RnD/SINDBAD-RnD-SK/examples/exp_fluxnet_hybrid/output_FLUXNET_HyK/data/HyALL_ALL_kσ_0.5_fold_5_nlayers_3_n_neurons_32_200epochs_batch_size_32/checkpoint/"
fig = Figure(; size = (1200, 400))
ax_train = Axis(fig[1,1]; title="training")
ax_valid = Axis(fig[1,2];  title="validation")
ax_test = Axis(fig[1,3];  title="test")

for ind ∈ eachindex(k_σs)
    k_σ = k_σs[ind]

    checkpoint_path_all = "/Users/skoirala/research/RnD/SINDBAD-RnD-SK/examples/exp_fluxnet_hybrid/output_FLUXNET_HyK/data/HyALL_ALL_kσ_$(k_σ)_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_$(n_epochs)epochs_batch_size_$(batch_size)/checkpoint/"

    train_pft, val_pft, test_pft = load_losses_vec(checkpoint_path_all, 200)
    train_all, val_all, test_all = load_losses_vec(checkpoint_path_all, 200)


    stroke_color = k_colors[ind]
    outlier_color= stroke_color

    median_color = stroke_color;

    whisker_color = stroke_color

    with_theme(theme_light()) do

        strokewidth = 0.85
        width= 0.5
        color=:transparent
        @show ind
        
        boxplot!(ax_train, fill(ind, length(train_all)), train_all; label = "k_σ=$(k_σ)",
            color, strokecolor = stroke_color, strokewidth,
            outliercolor= outlier_color, mediancolor = median_color, width)

        boxplot!(ax_valid, fill(ind, length(val_all)), val_all; color, strokecolor = stroke_color, strokewidth,
        outliercolor= outlier_color, mediancolor = median_color, width)

        boxplot!(ax_test, fill(ind, length(test_all)), test_all; color, strokecolor = stroke_color, strokewidth,
        outliercolor= outlier_color, mediancolor = median_color, width)
        fig
    end
end
xlims!.([ax_train, ax_valid, ax_test], 0.5,10.5)
ylims!.([ax_train, ax_valid, ax_test], 0.5,5)

axislegend(ax_train, "Covariates")
Label(fig[0,1:3], "Total loss: Hybrid modelling approaches")

save("total_loss_HyALL_ALL_kσs_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_$(n_epochs)epochs_batch_size_$(batch_size).png", current_figure())



# Create a figure and axis for the boxplots
fig = Figure(; size = (1200, 600))
ax = Axis(fig[1, 1], title="Boxplots for Training, Validation, and Test", xlabel="Dataset", ylabel="Loss", 
xticks=(collect(eachindex(k_σs)),["k_σ=$(k_σ)" for k_σ in k_σs])
)

# Define positions for the boxplots
train_offset = -0.2
val_offset = 0.0
test_offset = 0.2

# Loop through each k_σ value
for ind ∈ eachindex(k_σs)
    k_σ = k_σs[ind]

    checkpoint_path_all = "/Users/skoirala/research/RnD/SINDBAD-RnD-SK/examples/exp_fluxnet_hybrid/output_FLUXNET_HyK/data/HyALL_ALL_kσ_$(k_σ)_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_$(n_epochs)epochs_batch_size_$(batch_size)/checkpoint/"

    train_all, val_all, test_all = load_losses_vec(checkpoint_path_all, 200)

    stroke_color = k_colors[ind]
    outlier_color = stroke_color
    median_color = stroke_color
    whisker_color = stroke_color

    ind=ind
    with_theme(theme_light()) do
        strokewidth = 0.85
        width = 0.1

        # Create boxplots for training, validation, and test data
        boxplot!(ax, fill(ind + train_offset, length(train_all)), train_all; 
            label = "k_σ=$(k_σ)", color=:transparent, strokecolor=stroke_color, 
            strokewidth=strokewidth, outliercolor=outlier_color, 
            mediancolor=median_color, width=width)

        boxplot!(ax, fill(ind + val_offset, length(val_all)), val_all; 
            color=:transparent, strokecolor=stroke_color, 
            strokewidth=strokewidth, outliercolor=outlier_color, 
            mediancolor=median_color, width=width)

        boxplot!(ax, fill(ind + test_offset, length(test_all)), test_all; 
        color=:transparent, strokecolor=stroke_color, 
            strokewidth=strokewidth, outliercolor=outlier_color, 
            mediancolor=median_color, width=width)

            # for (offset, hatch, data) in zip([train_offset, val_offset, test_offset], hatch_patterns, [train_all, val_all, test_all])
            #     Q1 = quantile(data, 0.25)
            #     Q3 = quantile(data, 0.75)
            #     IQR = Q3 - Q1
    
            #     # Calculate the center of the box
            #     box_center = ind + offset
    
            #     start = (hatch[1][1], hatch[2][1])
            # _end = (hatch[1][2], hatch[2][2])
            # # Draw hatching lines within the box
            #     # for (start, _end) in hatch
            #         lines!(ax, 
            #             [box_center + start[1] * width / 2, box_center + _end[1] * width / 2], 
            #             [Q1 + start[2] * IQR, Q1 + _end[2] * IQR], 
            #             color=stroke_color, linewidth=1.0)
            #     # end
            # end

    end
end

# Add legend
# axislegend(ax, position=:topright)

# xlims!.([ax], 0.5,30.5)
ylims!(ax, 0.5,10)
# xticks!(ax; xtickrange=xtickrange, xticklabels=xticklabels)
# axislegend(ax, "Covariates")
# Label(fig[0,1], "Total loss: Hybrid modelling approaches")

save("total_loss_HyALL_ALL_kσs_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_$(n_epochs)epochs_batch_size_$(batch_size).png", current_figure())

# Display the figure
display(fig)


function plot_training_history(μtrain, μval, μtest; color=:dodgerblue, label="")
    lines!(ax, μtrain, color = color, linestyle=:solid, linewidth = 1.25, label = "TR_$(label)")
    lines!(ax, μval, color = color, linestyle=:dash, linewidth = 1.25, label = "VA_$(label)")
    lines!(ax, μtest, color = color, linestyle=:dot, linewidth = 1.25, label = "TE_$(label)")
    # ylims!(ax, 3, 4)
    fig
end

fig = Figure(; size = (1600, 800))
ax = Axis(fig[1, 1], xlabel = "Epoch", ylabel = "Loss", title = "Losses History")

for ind ∈ eachindex(k_σs)
    k_σ = k_σs[ind]

    checkpoint_path_all = "/Users/skoirala/research/RnD/SINDBAD-RnD-SK/examples/exp_fluxnet_hybrid/output_FLUXNET_HyK/data/HyALL_ALL_kσ_$(k_σ)_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_$(n_epochs)epochs_batch_size_$(batch_size)/checkpoint/"


    stroke_color = k_colors[ind]

    μtrain, μval, μtest = load_losses(checkpoint_path_all, 200)
    plot_training_history(μtrain, μval, μtest, color=stroke_color, label = "$(k_σ)")

end
axislegend(ax, position = :rt, legendcolumns=2)

save("evolution_loss_HyALL_ALL_kσs_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_$(n_epochs)epochs_batch_size_$(batch_size).png", current_figure(), dpi=500)



fig = Figure(; size = (1600, 800))
ax = Axis(fig[1, 1], xlabel = "Epoch", ylabel = "Loss", title = "Losses History")

for ind ∈ eachindex(k_σs)
    k_σ = k_σs[ind]

    checkpoint_path_all = "/Users/skoirala/research/RnD/SINDBAD-RnD-SK/examples/exp_fluxnet_hybrid/output_FLUXNET_HyK/data/HyALL_ALL_kσ_$(k_σ)_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_$(n_epochs)epochs_batch_size_$(batch_size)/checkpoint/"


    stroke_color = k_colors[ind]

    μtrain, μval, μtest = load_losses_median(checkpoint_path_all, 200)
    plot_training_history(μtrain, μval, μtest, color=stroke_color, label = "$(k_σ)")

end
axislegend(ax, position = :rt, legendcolumns=2)

save("evolution_median_loss_HyALL_ALL_kσs_fold_$(_nfold)_nlayers_$(nlayers)_n_neurons_$(n_neurons)_$(n_epochs)epochs_batch_size_$(batch_size).png", current_figure(), dpi=500)

with_theme(theme_light()) do
    display(GLMakie.Screen(), plot_training_history(μtrain, μval, μtest))
end
