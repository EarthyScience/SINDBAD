
export SindbadMetricsType
abstract type SindbadMetricsType <: SindbadType end
purpose(::Type{SindbadMetricsType}) = "Abstract type for performance metrics and cost calculation methods in SINDBAD"

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


abstract type SindbadMetric <: SindbadMetricsType end
purpose(::Type{SindbadMetric}) = "Abstract type for performance metrics in SINDBAD"

struct MSE <: SindbadMetric end
purpose(::Type{MSE}) = "Mean Squared Error: Measures the average squared difference between predicted and observed values"

struct NAME1R <: SindbadMetric end
purpose(::Type{NAME1R}) = "Normalized Absolute Mean Error with 1/R scaling: Measures the absolute difference between means normalized by the range of observations"

struct NMAE1R <: SindbadMetric end
purpose(::Type{NMAE1R}) = "Normalized Mean Absolute Error with 1/R scaling: Measures the average absolute error normalized by the range of observations"

struct NNSE <: SindbadMetric end
purpose(::Type{NNSE}) = "Normalized Nash-Sutcliffe Efficiency: Measures model performance relative to the mean of observations, normalized to [0,1] range"

struct NNSEInv <: SindbadMetric end
purpose(::Type{NNSEInv}) = "Inverse Normalized Nash-Sutcliffe Efficiency: Inverse of NNSE for minimization problems, normalized to [0,1] range"

struct NNSEσ <: SindbadMetric end
purpose(::Type{NNSEσ}) = "Normalized Nash-Sutcliffe Efficiency with uncertainty: Incorporates observation uncertainty in the normalized performance measure"

struct NNSEσInv <: SindbadMetric end
purpose(::Type{NNSEσInv}) = "Inverse Normalized Nash-Sutcliffe Efficiency with uncertainty: Inverse of NNSEσ for minimization problems"

struct NSE <: SindbadMetric end
purpose(::Type{NSE}) = "Nash-Sutcliffe Efficiency: Measures model performance relative to the mean of observations"

struct NSEInv <: SindbadMetric end
purpose(::Type{NSEInv}) = "Inverse Nash-Sutcliffe Efficiency: Inverse of NSE for minimization problems"

struct NSEσ <: SindbadMetric end
purpose(::Type{NSEσ}) = "Nash-Sutcliffe Efficiency with uncertainty: Incorporates observation uncertainty in the performance measure"

struct NSEσInv <: SindbadMetric end
purpose(::Type{NSEσInv}) = "Inverse Nash-Sutcliffe Efficiency with uncertainty: Inverse of NSEσ for minimization problems"

struct NPcor <: SindbadMetric end
purpose(::Type{NPcor}) = "Normalized Pearson Correlation: Measures linear correlation between predictions and observations, normalized to [0,1] range"

struct NPcorInv <: SindbadMetric end
purpose(::Type{NPcorInv}) = "Inverse Normalized Pearson Correlation: Inverse of NPcor for minimization problems"

struct Pcor <: SindbadMetric end
purpose(::Type{Pcor}) = "Pearson Correlation: Measures linear correlation between predictions and observations"

struct PcorInv <: SindbadMetric end
purpose(::Type{PcorInv}) = "Inverse Pearson Correlation: Inverse of Pcor for minimization problems"

struct Pcor2 <: SindbadMetric end
purpose(::Type{Pcor2}) = "Squared Pearson Correlation: Measures the strength of linear relationship between predictions and observations"

struct Pcor2Inv <: SindbadMetric end
purpose(::Type{Pcor2Inv}) = "Inverse Squared Pearson Correlation: Inverse of Pcor2 for minimization problems"

struct NScor <: SindbadMetric end
purpose(::Type{NScor}) = "Normalized Spearman Correlation: Measures monotonic relationship between predictions and observations, normalized to [0,1] range"

struct NScorInv <: SindbadMetric end
purpose(::Type{NScorInv}) = "Inverse Normalized Spearman Correlation: Inverse of NScor for minimization problems"

struct Scor <: SindbadMetric end
purpose(::Type{Scor}) = "Spearman Correlation: Measures monotonic relationship between predictions and observations"

struct ScorInv <: SindbadMetric end
purpose(::Type{ScorInv}) = "Inverse Spearman Correlation: Inverse of Scor for minimization problems"

struct Scor2 <: SindbadMetric end
purpose(::Type{Scor2}) = "Squared Spearman Correlation: Measures the strength of monotonic relationship between predictions and observations"

struct Scor2Inv <: SindbadMetric end
purpose(::Type{Scor2Inv}) = "Inverse Squared Spearman Correlation: Inverse of Scor2 for minimization problems"

# ------------------------- data aggregation for metric calculation -------------------------

export SindbadDataAggrOrder
export SpaceTime
export TimeSpace

abstract type SindbadDataAggrOrder <: SindbadMetricsType end
purpose(::Type{SindbadDataAggrOrder}) = "Abstract type for data aggregation order in SINDBAD"

struct SpaceTime <: SindbadDataAggrOrder end
purpose(::Type{SpaceTime}) = "Aggregate data first over space, then over time"

struct TimeSpace <: SindbadDataAggrOrder end
purpose(::Type{TimeSpace}) = "Aggregate data first over time, then over space"

export DoAggrObs
export DoNotAggrObs

export DoSpatialWeight
export DoNotSpatialWeight

struct DoAggrObs end
purpose(::Type{DoAggrObs}) = "Apply aggregation to observations"

struct DoNotAggrObs end
purpose(::Type{DoNotAggrObs}) = "Do not apply aggregation to observations"

struct DoSpatialWeight end
purpose(::Type{DoSpatialWeight}) = "Apply spatial weighting to metrics"

struct DoNotSpatialWeight end
purpose(::Type{DoNotSpatialWeight}) = "Do not apply spatial weighting to metrics"

export SindbadSpatialDataAggr
export ConcatData

abstract type SindbadSpatialDataAggr <: SindbadMetricsType end
purpose(::Type{SindbadSpatialDataAggr}) = "Abstract type for spatial data aggregation methods in SINDBAD"

struct ConcatData end
purpose(::Type{ConcatData}) = "Concatenate data arrays for aggregation"

# ------------------------- spatial metric aggregation -------------------------

export SindbadSpatialMetricAggr
export MetricMaximum
export MetricMinimum
export MetricSum
export MetricSpatial

abstract type SindbadSpatialMetricAggr <: SindbadMetricsType end
purpose(::Type{SindbadSpatialMetricAggr}) = "Abstract type for spatial metric aggregation methods in SINDBAD"

struct MetricMaximum <: SindbadSpatialMetricAggr end
purpose(::Type{MetricMaximum}) = "Take maximum value across spatial dimensions"

struct MetricMinimum <: SindbadSpatialMetricAggr end
purpose(::Type{MetricMinimum}) = "Take minimum value across spatial dimensions"

struct MetricSum <: SindbadSpatialMetricAggr end
purpose(::Type{MetricSum}) = "Sum values across spatial dimensions"

struct MetricSpatial <: SindbadSpatialMetricAggr end
purpose(::Type{MetricSpatial}) = "Apply spatial aggregation to metrics"

