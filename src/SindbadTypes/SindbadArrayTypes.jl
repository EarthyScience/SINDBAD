
export SindbadArrayType
abstract type SindbadArrayType <: SindbadType end
purpose(::Type{SindbadArrayType}) = "Abstract type for all array types in SINDBAD"

# ------------------------- model array types for internal model variables -------------------------
export SindbadModelArrayType
export ModelArrayArray
export ModelArrayStaticArray
export ModelArrayView

abstract type SindbadModelArrayType <: SindbadArrayType end
purpose(::Type{SindbadModelArrayType}) = "Abstract type for internal model array types in SINDBAD"

struct ModelArrayArray <:SindbadModelArrayType end
purpose(::Type{ModelArrayArray}) = "Use standard Julia arrays for model variables"

struct ModelArrayStaticArray <:SindbadModelArrayType end
purpose(::Type{ModelArrayStaticArray}) = "Use StaticArrays for model variables"

struct ModelArrayView <:SindbadModelArrayType end
purpose(::Type{ModelArrayView}) = "Use array views for model variables"

# ------------------------- output array types preallocated arrays -------------------------
export SindbadOutputArrayType
export OutputArray
export OutputMArray
export OutputSizedArray
export OutputYAXArray

abstract type SindbadOutputArrayType <: SindbadArrayType end
purpose(::Type{SindbadOutputArrayType}) = "Abstract type for output array types in SINDBAD"

struct OutputArray <:SindbadOutputArrayType end
purpose(::Type{OutputArray}) = "Use standard Julia arrays for output"

struct OutputMArray <:SindbadOutputArrayType end
purpose(::Type{OutputMArray}) = "Use MArray for output"

struct OutputSizedArray <:SindbadOutputArrayType end
purpose(::Type{OutputSizedArray}) = "Use SizedArray for output"

struct OutputYAXArray <:SindbadOutputArrayType end
purpose(::Type{OutputYAXArray}) = "Use YAXArray for output"

