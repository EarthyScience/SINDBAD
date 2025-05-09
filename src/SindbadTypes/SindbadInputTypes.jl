
export SindbadInputType
abstract type SindbadInputType <: SindbadType end
purpose(::Type{SindbadInputType}) = "Abstract type for input data and processing related options in SINDBAD"

# -------------------------------- forcing backend --------------------------------
export SindbadInputBackend
export BackendNetcdf
export BackendZarr

abstract type SindbadInputBackend <: SindbadInputType end
purpose(::Type{SindbadInputBackend}) = "Abstract type for input data backends in SINDBAD"

struct BackendNetcdf <: SindbadInputBackend end
purpose(::Type{BackendNetcdf}) = "Use NetCDF format for input data"

struct BackendZarr <: SindbadInputBackend end
purpose(::Type{BackendZarr}) = "Use Zarr format for input data"

# -------------------------------- input array type in named tuple --------------------------------
export SindbadInputArrayType
export InputArray
export InputKeyedArray
export InputNamedDimsArray
export InputYaxArray

abstract type SindbadInputArrayType <: SindbadInputType end
purpose(::Type{SindbadInputArrayType}) = "Abstract type for input data array types in SINDBAD"

struct InputArray <: SindbadInputArrayType end
purpose(::Type{InputArray}) = "Use standard Julia arrays for input data"

struct InputKeyedArray <: SindbadInputArrayType end
purpose(::Type{InputKeyedArray}) = "Use keyed arrays for input data"

struct InputNamedDimsArray <: SindbadInputArrayType end
purpose(::Type{InputNamedDimsArray}) = "Use named dimension arrays for input data"

struct InputYaxArray <: SindbadInputArrayType end
purpose(::Type{InputYaxArray}) = "Use YAXArray for input data"


# -------------------------------- forcing variable type --------------------------------
export ForcingWithTime
export ForcingWithoutTime

abstract type SindbadForcingType <: SindbadInputType end
purpose(::Type{SindbadForcingType}) = "Abstract type for forcing variable types in SINDBAD"

struct ForcingWithTime <: SindbadForcingType end
purpose(::Type{ForcingWithTime}) = "Forcing variable with time dimension"

struct ForcingWithoutTime <: SindbadForcingType end
purpose(::Type{ForcingWithoutTime}) = "Forcing variable without time dimension"


# -------------------------------- spatial subset --------------------------------
export Spaceid
export SpaceId
export SpaceID
export Spacelat
export Spacelatitude
export Spacelongitude
export Spacelon
export Spacesite
export SindbadSpatialSubsetter

abstract type SindbadSpatialSubsetter <: SindbadInputType end
purpose(::Type{SindbadSpatialSubsetter}) = "Abstract type for spatial subsetting methods in SINDBAD"

struct Spaceid <: SindbadSpatialSubsetter end
purpose(::Type{Spaceid}) = "Use site ID for spatial subsetting"

struct SpaceId <: SindbadSpatialSubsetter end
purpose(::Type{SpaceId}) = "Use site ID (capitalized) for spatial subsetting"

struct SpaceID <: SindbadSpatialSubsetter end
purpose(::Type{SpaceID}) = "Use site ID (all caps) for spatial subsetting"

struct Spacelat <: SindbadSpatialSubsetter end
purpose(::Type{Spacelat}) = "Use latitude for spatial subsetting"

struct Spacelatitude <: SindbadSpatialSubsetter end
purpose(::Type{Spacelatitude}) = "Use full latitude for spatial subsetting"

struct Spacelongitude <: SindbadSpatialSubsetter end
purpose(::Type{Spacelongitude}) = "Use full longitude for spatial subsetting"

struct Spacelon <: SindbadSpatialSubsetter end
purpose(::Type{Spacelon}) = "Use longitude for spatial subsetting"

struct Spacesite <: SindbadSpatialSubsetter end
purpose(::Type{Spacesite}) = "Use site location for spatial subsetting"

