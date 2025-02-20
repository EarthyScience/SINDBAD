export FiniteDifferencesGrad
export FiniteDiffGrad
export ForwardDiffGrad

struct FiniteDifferencesGrad end
struct FiniteDiffGrad end
struct ForwardDiffGrad end

function getCacheFromOutput(loc_output, ::ForwardDiffGrad)
    return DiffCache.(loc_output)
end

function getCacheFromOutput(loc_output, ::FiniteDiffGrad)
    return loc_output
end
function getCacheFromOutput(loc_output, ::FiniteDifferencesGrad)
    return loc_output
end

"""
    getCacheFromOutput(loc_output, ::ForwardDiffGrad)
    getCacheFromOutput(loc_output, ::FiniteDiff)
    getCacheFromOutput(loc_output, ::FiniteDifferences)

Returns the appropriate Cache type based on the automatic differentiation or finite differences package being used.

# Arguments
- `loc_output`: The local output
- Second argument specifies the differentiation method:
    * `ForwardDiffGrad`: Uses ForwardDiff.jl for automatic differentiation
    * `FiniteDiff`: Uses FiniteDiff.jl for finite difference calculations
    * `FiniteDifferences`: Uses FiniteDifferences.jl for finite difference calculations
  
"""
function getCacheFromOutput end

function getOutputFromCache(loc_output, _, ::FiniteDiffGrad)
    return loc_output
end

function getOutputFromCache(loc_output, _, ::FiniteDifferencesGrad)
    return loc_output
end

function getOutputFromCache(loc_output, new_params, ::ForwardDiffGrad)
    return get_tmp.(loc_output, (new_params,))
end

"""
    getOutputFromCache(loc_output, _, ::FiniteDiffGrad)
    getOutputFromCache(loc_output, _, ::FiniteDifferencesGrad)
    getOutputFromCache(loc_output, new_params, ::ForwardDiffGrad)

Retrieves output values from `Cache` based on the differentiation method being used.

# Arguments
- `loc_output`: The cached output values
- `_` or `new_params`: Additional parameters (only used with ForwardDiff)
- Third argument specifies the differentiation method:
  * `FiniteDiffGrad`: Returns cached output directly when using FiniteDiff.jl
  * `FiniteDifferencesGrad`: Returns cached output directly when using FiniteDifferences.jl
  * `ForwardDiffGrad`: Processes cached output with new parameters when using ForwardDiff.jl, returns `get_tmp.(loc_output, (new_params,))`

"""
function getOutputFromCache end