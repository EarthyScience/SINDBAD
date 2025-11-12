export mlOptimizer

"""
    mlOptimizer(optimizer_options, ::MLOptimizerType)

Create a ML optimizer from the given options and type.
The optimizer is created using the given options and type. The options are passed to the constructor of the optimizer.

# Arguments:
- `optimizer_options`: A dictionary or NamedTuple containing options for the optimizer.
- `::MLOptimizerType`: The type used to determine which optimizer to create. Supported types include:
  - `OptimisersAdam`: For Adam optimizer.
  - `OptimisersDescent`: For Descent optimizer.
.
# Returns:
- A ML optimizer object that can be used to optimize machine learning models.
"""
function mlOptimizer end

function mlOptimizer(optimizer_options, ::OptimisersAdam)
    return Optimisers.Adam(optimizer_options...)
end
function mlOptimizer(optimizer_options, ::OptimisersDescent)
    return Optimisers.Descent(optimizer_options...)
end

