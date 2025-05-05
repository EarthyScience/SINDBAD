# -------------------------------- forcing backend --------------------------------
export SindbadInputBackend
export BackendNetcdf
export BackendZarr

abstract type SindbadInputBackend end
purpose(::Type{SindbadInputBackend}) = "Abstract type for input data backends in SINDBAD"

struct BackendNetcdf <: SindbadInputBackend end
purpose(::Type{BackendNetcdf}) = "Use NetCDF format for input data"

struct BackendZarr <: SindbadInputBackend end
purpose(::Type{BackendZarr}) = "Use Zarr format for input data"

# -------------------------------- input array type in named tuple --------------------------------
export SindbadInputDataType
export InputArray
export InputKeyedArray
export InputNamedDimsArray
export InputYaxArray

abstract type SindbadInputDataType end
purpose(::Type{SindbadInputDataType}) = "Abstract type for input data array types in SINDBAD"

struct InputArray <: SindbadInputDataType end
purpose(::Type{InputArray}) = "Use standard Julia arrays for input data"

struct InputKeyedArray <: SindbadInputDataType end
purpose(::Type{InputKeyedArray}) = "Use keyed arrays for input data"

struct InputNamedDimsArray <: SindbadInputDataType end
purpose(::Type{InputNamedDimsArray}) = "Use named dimension arrays for input data"

struct InputYaxArray <: SindbadInputDataType end
purpose(::Type{InputYaxArray}) = "Use YAXArray for input data"