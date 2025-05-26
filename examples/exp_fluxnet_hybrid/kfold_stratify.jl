using MLUtils
using SindbadData.YAXArrays
using SindbadData.Zarr

c_read = Cube("examples/data/CovariatesFLUXNET_3.zarr");

ds = open_dataset(joinpath(@__DIR__, "../data/FLUXNET_v2023_12_1D.zarr"))
ds.properties["PFT"][[98, 99, 100, 137, 138]] .= ["WET", "WET", "GRA", "WET", "SNO"]
updatePFTs = ds.properties["PFT"]

# ? kfolds

function splitobs_stratified(;at, y::Array, shuffle::Bool=true)
	n_splits = length(at) + 1
	the_splits = [Int[] for s = 1:n_splits]
	for label in unique(y)
		ids_this_label = filter(i -> y[i] == label, 1:length(y))
		if shuffle
			ids_this_label = shuffleobs(ids_this_label)
		end
		split_this_label = splitobs(ids_this_label, at=at)
		for s = 1:n_splits
			the_splits[s] = vcat(the_splits[s], split_this_label[s])
		end
	end
	return the_splits
end



# remove sites (with NaNs and duplicates)
to_remove = [
    "CA-NS3",
    # "CA-NS4",
    "IT-CA1",
    # "IT-CA2",
    "IT-SR2",
    # "IT-SRo",
    "US-ARb",
    # "US-ARc",
    "US-GBT",
    # "US-GLE",
    "US-Tw1",
    # "US-Tw2"
    ]
not_these = ["RU-Tks", "US-Atq", "US-UMd"]
not_these = vcat(not_these, to_remove)
new_sites = setdiff(c_read.site, not_these)

o_sites = [string(s) for s in c_read.site.val]
new_sites_index = [findfirst(x->x==s_name, o_sites) for s_name in new_sites]

setPFT = updatePFTs[new_sites_index]

x, y, z = splitobs_stratified(at=(0.1,0.82),  y=setPFT)
# map back to original site names and indices
using StatsBase
function countmapPFTs(x)
    x_counts = countmap(x)
    x_keys = collect(keys(x_counts))
    x_vals = collect(values(x_counts))
    return x_counts, x_keys, x_vals
end

x_counts, x_keys, x_vals = countmapPFTs(setPFT[y])
z_counts, z_keys, z_vals = countmapPFTs(setPFT[z])
y_counts, y_keys, y_vals = countmapPFTs(setPFT[x])

px = sortperm(x_keys)
pz = sortperm(z_keys)
py = sortperm(y_keys)

with_theme(theme_light()) do 
    fig = Figure(; size=(600, 600))
    ax1 = Axis(fig[1,1]; title = "training")
    ax2 = Axis(fig[3,1]; title = "test")
    ax3 = Axis(fig[2,1]; title = "validation")

    barplot!(ax1, x_vals[px]; color = 1:13, colormap = :Hiroshige)
    barplot!(ax2, z_vals[pz]; color = 1:length(z_vals), colorrange=(1,13), colormap = :Hiroshige)
    barplot!(ax3, y_vals[py]; color = 1:length(y_vals), colorrange=(1,13), colormap = :Hiroshige)

    ax1.xticks = (1:length(x_keys), x_keys[px])
    ax2.xticks = (1:length(z_keys), z_keys[pz])
    ax3.xticks = (1:length(y_keys), y_keys[py])
    fig 
end

all_counts, all_keys, all_vals = countmapPFTs(setPFT)

with_theme(theme_light()) do 
    px = sortperm(all_keys)
    fig = Figure(; size=(600, 600))
    ax = Axis(fig[1,1]; title = "all")
    barplot!(ax, all_vals[px]; color = 1:13, colormap = :Hiroshige)
    hlines!(ax, 5)
    ax.xticks = (1:length(all_keys), all_keys[px])
    # ax.yticks = 1:10
    fig 
end


# custom rules
# validation samples (get them from the training split), the validation split coming from kfolds goes to test!

function split_to_validation(k)
    if k == "GRA" || k == "ENF"
        return 3
    elseif k == "WET" || k == "DBF" || k == "CRO"
        return 2
    else # ? Do 1 for all others!
        return 1
    end
end

# collect 5-fold indices
using Random
Random.seed!(213)
all_counts, all_keys, all_vals = countmapPFTs(setPFT)
n_folds = 5
test_folds = []
training_folds = []
validation_folds = []
for (k, v) in all_counts # to folds for each PFT
    if v>=5
        # find all indices for this PFT
        original_indices = findall(x->x==k, setPFT) # ? still needs to go back to 1-205 sites
        site_indices = new_sites_index[original_indices]
        site_indices = shuffleobs(site_indices)
        train_idx, val_idx = kfolds(v, n_folds)
        original_validation = [site_indices[v] for v in val_idx]
        original_training = [site_indices[t] for t in train_idx]
        # push!(test_folds, named_validation)
        push!(test_folds,  original_validation)
        # get some for validation during training
        n_indices = split_to_validation(k)
        
        to_val = []
        to_train = []
        for i in 1:n_folds
            to_split = shuffleobs(original_training[i])
            val_indices = to_split[1:n_indices]
            train_indices = to_split[n_indices+1:end]
            push!(to_val, val_indices)
            push!(to_train, train_indices)
        end
        push!(training_folds, to_train)
        push!(validation_folds, to_val)
    end
end

# prepare folds with all categories # test_folds
_fold_i = [test_folds[i][f] for i in 1:10, f in 1:5]
unfold_tests = [vcat(_fold_i[:, f]...) for f in 1:5]

# now traininig and validation split folds
_fold_t_i = [training_folds[i][f] for i in 1:10, f in 1:5]
unfold_training = [vcat(_fold_t_i[:, f]...) for f in 1:5]

# unfold validation
_fold_v_i = [validation_folds[i][f] for i in 1:10, f in 1:5]
unfold_validation = [vcat(_fold_v_i[:, f]...) for f in 1:5]

using JLD2
jldsave("nfolds_sites_indices.jld2"; unfold_training=unfold_training, unfold_validation=unfold_validation, unfold_tests=unfold_tests)

_nfold = 1
xtrain, xval, xtest = unfold_training[_nfold], unfold_validation[_nfold], unfold_tests[_nfold]
