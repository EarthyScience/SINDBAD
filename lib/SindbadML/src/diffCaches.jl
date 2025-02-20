export FiniteDifferencesGrad
export FiniteDiffGrad
export ForwardDiffGrad

struct FiniteDifferencesGrad end
struct FiniteDiffGrad end
struct ForwardDiffGrad end

"""
    getCacheFromOutput(loc_output, ::ForwardDiffGrad)

Returns the appropriate `Cache` type when `using ForwardDiff.jl`. 
"""
function getCacheFromOutput(loc_output, ::ForwardDiffGrad)
    return DiffCache.(loc_output)
end

"""
    getCacheFromOutput(loc_output, ::FiniteDiff)

Returns the appropriate `Cache` type when `using FiniteDiff.jl`. 
"""
function getCacheFromOutput(loc_output, ::FiniteDiffGrad)
    return loc_output
end

"""
    getCacheFromOutput(loc_output, ::FiniteDifferences)

Returns the appropriate `Cache` type when `using FiniteDifferences.jl`. 
"""
function getCacheFromOutput(loc_output, ::FiniteDifferencesGrad)
    return loc_output
end

"""
    getOutputFromCache(loc_output, _, ::FiniteDiffGrad)

Returns output values from `Cache` when `using FiniteDiff.jl`. 
"""
function getOutputFromCache(loc_output, _, ::FiniteDiffGrad)
    return loc_output
end

"""
    getOutputFromCache(loc_output, _, ::FiniteDifferencesGrad)

Returns output values from `Cache` when `using FiniteDifferences.jl`. 
"""
function getOutputFromCache(loc_output, _, ::FiniteDifferencesGrad)
    return loc_output
end

"""
    getOutputFromCache(loc_output, new_params, ::ForwardDiffGrad)

Returns output values from `Cache` when `using ForwardDiff.jl`. 
"""
function getOutputFromCache(loc_output, new_params, ::ForwardDiffGrad)
    return get_tmp.(loc_output, (new_params,))
end
