
export ArrayType
abstract type ArrayType <: SindbadType end
purpose(::Type{ArrayType}) = "Abstract type for all array types in SINDBAD"

# ------------------------- model array types for internal model variables -------------------------
export ModelArrayType
export ModelArrayArray
export ModelArrayStaticArray
export ModelArrayView


abstract type ModelArrayType <: ArrayType end
purpose(::Type{ModelArrayType}) = "Abstract type for internal model array types in SINDBAD"

struct ModelArrayArray <: ModelArrayType end
purpose(::Type{ModelArrayArray}) = "Use standard Julia arrays for model variables"

struct ModelArrayStaticArray <: ModelArrayType end
purpose(::Type{ModelArrayStaticArray}) = "Use StaticArrays for model variables"

struct ModelArrayView <: ModelArrayType end
purpose(::Type{ModelArrayView}) = "Use array views for model variables"

# ------------------------- output array types preallocated arrays -------------------------
export OutputArrayType
export OutputArray
export OutputMArray
export OutputSizedArray
export OutputYAXArray

abstract type OutputArrayType <: ArrayType end
purpose(::Type{OutputArrayType}) = "Abstract type for output array types in SINDBAD"

struct OutputArray <: OutputArrayType end
purpose(::Type{OutputArray}) = "Use standard Julia arrays for output"

struct OutputMArray <: OutputArrayType end
purpose(::Type{OutputMArray}) = "Use MArray for output"

struct OutputSizedArray <: OutputArrayType end
purpose(::Type{OutputSizedArray}) = "Use SizedArray for output"

struct OutputYAXArray <: OutputArrayType end
purpose(::Type{OutputYAXArray}) = "Use YAXArray for output"

