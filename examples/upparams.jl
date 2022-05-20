
approachestest = (soilProperties_Saxton2006(DF=4., Rw=10), cFlow_GSI(), rainSnow_Tair())
toOptim = ["soilProperties.DF", "cFlow.LR2ReSlp", "rainSnow.Tair_thres"]
tblParamstest = getParameters(approachestest, toOptim);
tblParamstest.optim .= rand(3)
tblParamstest

updateParameters(tblParamstest, approachestest)