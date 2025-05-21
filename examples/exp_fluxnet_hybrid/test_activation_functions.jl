export CustomSigmoid
export sigmoid_2
export sigmoid_3
export sigmoid_k

## Build ML method
# Define a custom sigmoid type with an iterate method
struct CustomSigmoid
    k::Float64
end

# Callable method for the sigmoid function
function (cs::CustomSigmoid)(x)
    1 / (1 + exp(-cs.k * x))
end

# Implement iterate method
function Base.iterate(cs::CustomSigmoid, x::Float64)
    value = cs(x)  # Apply the sigmoid
    return (value, nothing)  # Return the value and end iteration
end

sigmoid_k(x, K) = one(x) / (one(x) + exp(-K * x))


function sigmoid_2(x)
    1 / (1 + exp(-2 * x))
end


function sigmoid_3(x)
    1 / (1 + exp(-3 * x))
end