export getCacheFromOutput
export getOutputFromCache

function getCacheFromOutput(loc_output, ::GradType)
    return loc_output
end

function getCacheFromOutput(loc_output, ::ForwardDiffGrad)
    return DiffCache.(loc_output)
end

function getCacheFromOutput(loc_output, ::PolyesterForwardDiffGrad)
    return getCacheFromOutput(loc_output, ForwardDiffGrad())
end

"""
    getCacheFromOutput(loc_output, ::GradType)
    getCacheFromOutput(loc_output, ::ForwardDiffGrad)
    getCacheFromOutput(loc_output, ::PolyesterForwardDiffGrad)

Returns the appropriate Cache type based on the automatic differentiation or finite differences package being used.

# Arguments
- `loc_output`: The local output
- Second argument specifies the differentiation method:
    * `ForwardDiffGrad`: Uses ForwardDiff.jl for automatic differentiation
    * `GradType`: All other libraries, e.g., FiniteDiff.jl,FiniteDifferences.jl, etc.  for gradient calculations
    * `PolyesterForwardDiffGrad`: Uses PolyesterForwardDiff.jl for automatic differentiation
  
"""
function getCacheFromOutput end


function getOutputFromCache(loc_output, _, ::GradType)
    return loc_output
end

function getOutputFromCache(loc_output, new_params, ::ForwardDiffGrad)
    return get_tmp.(loc_output, (new_params,))
end

function getOutputFromCache(loc_output, new_params, ::PolyesterForwardDiffGrad)
    return getOutputFromCache(loc_output, new_params, ForwardDiffGrad())
end


"""
    getOutputFromCache(loc_output, _, ::GradType)
    getOutputFromCache(loc_output, new_params, ::ForwardDiffGrad)
    getOutputFromCache(loc_output, new_params, ::PolyesterForwardDiffGrad)

Retrieves output values from `Cache` based on the differentiation method being used.

# Arguments
- `loc_output`: The cached output values
- `_` or `new_params`: Additional parameters (only used with ForwardDiff)
- Third argument specifies the differentiation method:
  * `GradType`: Returns cached output directly when using other libraries, e.g., FiniteDiff.jl, FiniteDifferences.jl, etc.
  * `ForwardDiffGrad`: Processes cached output with new parameters when using ForwardDiff.jl, returns `get_tmp.(loc_output, (new_params,))`
  * `PolyesterForwardDiffGrad`: Calls cached output with new parameters using ForwardDiff.jl

"""
function getOutputFromCache end