# -------------------------------- forcing backend --------------------------------
export BackendNetcdf
export BackendZarr

struct BackendNetcdf end
struct BackendZarr end

# -------------------------------- input array type in named tuple --------------------------------

export InputArray
export InputKeyedArray
export InputNamedDimsArray
export InputYaxArray

struct InputArray end
struct InputKeyedArray end
struct InputNamedDimsArray end
struct InputYaxArray end