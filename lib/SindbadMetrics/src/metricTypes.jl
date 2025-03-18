# ------------------------- metric -------------------------
export SindbadCostMetric
export MSE
export NAME1R
export NMAE1R
export NNSE
export NNSEInv
export NNSEσ
export NNSEσInv
export NSE
export NSEInv
export NSEσ
export NSEσInv
export NPcor
export NPcorInv
export Pcor
export PcorInv
export Pcor2
export Pcor2Inv
export NScor
export NScorInv
export Scor
export ScorInv
export Scor2
export Scor2Inv

abstract type SindbadCostMetric end
struct MSE <: SindbadCostMetric end
struct NAME1R <: SindbadCostMetric end
struct NMAE1R <: SindbadCostMetric end
struct NNSE <: SindbadCostMetric end
struct NNSEInv <: SindbadCostMetric end
struct NNSEσ <: SindbadCostMetric end
struct NNSEσInv <: SindbadCostMetric end
struct NSE <: SindbadCostMetric end
struct NSEInv <: SindbadCostMetric end
struct NSEσ <: SindbadCostMetric end
struct NSEσInv <: SindbadCostMetric end
struct NPcor <: SindbadCostMetric end
struct NPcorInv <: SindbadCostMetric end
struct Pcor <: SindbadCostMetric end
struct PcorInv <: SindbadCostMetric end
struct Pcor2 <: SindbadCostMetric end
struct Pcor2Inv <: SindbadCostMetric end
struct NScor <: SindbadCostMetric end
struct NScorInv <: SindbadCostMetric end
struct Scor <: SindbadCostMetric end
struct ScorInv <: SindbadCostMetric end
struct Scor2 <: SindbadCostMetric end
struct Scor2Inv <: SindbadCostMetric end

# ------------------------- loss calculation -------------------------

export SindbadDataAggrOrder
export SpaceTime
export TimeSpace

abstract type SindbadDataAggrOrder end
struct SpaceTime <: SindbadDataAggrOrder end
struct TimeSpace <: SindbadDataAggrOrder end

export DoAggrObs
export DoNotAggrObs

export DoSpatialWeight
export DoNotSpatialWeight

struct DoAggrObs end
struct DoNotAggrObs end
struct DoSpatialWeight end
struct DoNotSpatialWeight end

export SindbadSpatialDataAggr
export ConcatData

abstract type SindbadSpatialDataAggr end
struct ConcatData end

export SindbadSpatialCostAggr
export CostMaximum
export CostMinimum
export CostSum
export SpatiallyVariable

abstract type SindbadSpatialCostAggr end
struct CostMaximum <: SindbadSpatialCostAggr end
struct CostMinimum <: SindbadSpatialCostAggr end
struct CostSum <: SindbadSpatialCostAggr end
struct SpatiallyVariable <: SindbadSpatialCostAggr end

export SindbadParameterScaling
export DoNotScale
export ScaleToDefault
export ScaleToBounds

abstract type SindbadParameterScaling end
struct DoNotScale <: SindbadParameterScaling end
struct ScaleToDefault <: SindbadParameterScaling end
struct ScaleToBounds <: SindbadParameterScaling end