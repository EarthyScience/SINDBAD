# ------------------------- metric -------------------------
export SindbadMetric
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

abstract type SindbadMetric end
struct MSE <: SindbadMetric end
struct NAME1R <: SindbadMetric end
struct NMAE1R <: SindbadMetric end
struct NNSE <: SindbadMetric end
struct NNSEInv <: SindbadMetric end
struct NNSEσ <: SindbadMetric end
struct NNSEσInv <: SindbadMetric end
struct NSE <: SindbadMetric end
struct NSEInv <: SindbadMetric end
struct NSEσ <: SindbadMetric end
struct NSEσInv <: SindbadMetric end
struct NPcor <: SindbadMetric end
struct NPcorInv <: SindbadMetric end
struct Pcor <: SindbadMetric end
struct PcorInv <: SindbadMetric end
struct Pcor2 <: SindbadMetric end
struct Pcor2Inv <: SindbadMetric end
struct NScor <: SindbadMetric end
struct NScorInv <: SindbadMetric end
struct Scor <: SindbadMetric end
struct ScorInv <: SindbadMetric end
struct Scor2 <: SindbadMetric end
struct Scor2Inv <: SindbadMetric end

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

export SindbadSpatialMetricAggr
export MetricMaximum
export MetricMinimum
export MetricSum
export MetricSpatial

abstract type SindbadSpatialMetricAggr end
struct MetricMaximum <: SindbadSpatialMetricAggr end
struct MetricMinimum <: SindbadSpatialMetricAggr end
struct MetricSum <: SindbadSpatialMetricAggr end
struct MetricSpatial <: SindbadSpatialMetricAggr end

export SindbadParameterScaling
export DoNotScale
export ScaleToDefault
export ScaleToBounds

abstract type SindbadParameterScaling end
struct DoNotScale <: SindbadParameterScaling end
struct ScaleDefault <: SindbadParameterScaling end
struct ScaleBounds <: SindbadParameterScaling end
