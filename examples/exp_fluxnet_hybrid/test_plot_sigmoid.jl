using Plots

# Sigmoid function
sigmoid(x, K) = 1 / (1 + exp(-K * x))

# Define the range for x
x = -10:0.1:10

# Define different values of K
K_values = [0.25, 0.5, 1, 2, 4]

# Initialize the plot
f=plot(title="Sigmoid Curves for Different Values of K", xlabel="x", ylabel="Sigmoid(x, K)", legend=:topright) 

# Plot sigmoid curves for each K
for K in K_values
    plot!(x, sigmoid.(x, K), label="K = $K")
end
f
