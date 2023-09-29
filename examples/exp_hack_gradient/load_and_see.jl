
for e=1:2
    for b=1:6
        fname = "seq_training_output/seq_training_output_batch_$(b)_epoch_$(e).jld2"
        println("epoch: $(e), batch:$(b), file: $(fname)")

        scaled_params_batch = load(fname, "scaled_params_batch")
        flat = load(fname, "flat")
        println("flat: $(sum(flat))")
        grads_batch = load(fname, "grads_batch")
        println("grads_batch: $(sum(grads_batch, dims=1))")
        println("----------------------------------------------------")
    end
end