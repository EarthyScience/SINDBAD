# ------------------------- metric -------------------------
abstract type SindbadMetric end
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

struct MSE <: SindbadMetric end
struct NMAE1R <: SindbadMetric end
struct NNSE <: SindbadMetric end
struct NNSEInv <: SindbadMetric end
struct NNSEσ <: SindbadMetric end
struct NNSEσInv <: SindbadMetric end
struct NSE <: SindbadMetric end
struct NSEInv <: SindbadMetric end
struct NSEσ <: SindbadMetric end
struct NSEσInv <: SindbadMetric end
struct Pcor <: SindbadMetric end
struct Pcor2 <: SindbadMetric end
struct Pcor2Inv <: SindbadMetric end
struct Scor <: SindbadMetric end
struct Scor2 <: SindbadMetric end
struct Scor2Inv <: SindbadMetric end

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
