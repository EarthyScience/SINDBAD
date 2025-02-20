# -------------------------------- forcing backend --------------------------------
export SindbadInputBackend
export BackendNetcdf
export BackendZarr

abstract type SindbadInputBackend end
struct BackendNetcdf <: SindbadInputBackend end
struct BackendZarr  <: SindbadInputBackend end

# -------------------------------- input array type in named tuple --------------------------------
export SindbadInputDataType
export InputArray
export InputKeyedArray
export InputNamedDimsArray
export InputYaxArray

abstract type SindbadInputDataType end
struct InputArray <: SindbadInputDataType end
struct InputKeyedArray <: SindbadInputDataType end
struct InputNamedDimsArray <: SindbadInputDataType end
struct InputYaxArray <: SindbadInputDataType end