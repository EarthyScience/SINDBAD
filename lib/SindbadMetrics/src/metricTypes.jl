# ------------------------- metric -------------------------

export MSE
export NMAE1R
export NNSE
export NNSEInv
export NNSEσ
export NNSEσInv
export NSE
export NSEInv
export NSEσ
export NSEσInv
export Pcor
export Pcor2
export Pcor2Inv
export Scor
export Scor2
export Scor2Inv

struct MSE end
struct NMAE1R end
struct NNSE end
struct NNSEInv end
struct NNSEσ end
struct NNSEσInv end
struct NSE end
struct NSEInv end
struct NSEσ end
struct NSEσInv end
struct Pcor end
struct Pcor2 end
struct Pcor2Inv end
struct Scor end
struct Scor2 end
struct Scor2Inv end

# ------------------------- loss calculation -------------------------

export SpaceTime
export TimeSpace

struct SpaceTime end
struct TimeSpace end

export DoAggrObs
export DoNotAggrObs
export DoSpatialWeight
export DoNotSpatialWeight

struct DoAggrObs end
struct DoNotAggrObs end
struct DoSpatialWeight end
struct DoNotSpatialWeight end

export ConcatData
export CostMaximum
export CostMinimum
export CostSum
export SpatiallyVariable

struct ConcatData end
struct CostMaximum end
struct CostMinimum end
struct CostSum end
struct SpatiallyVariable end
