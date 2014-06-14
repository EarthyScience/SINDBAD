function [fx,s,d]=RechargeGW_simple(f,fe,fx,s,d,p,info,i);

%simply assume that all remaining (after having subtracted interception evap, infiltration excess runoff, saturation runoff, interflow, soil moisture recharge from (rainfall+snowmelt)) water goes to GW
fx.Qgwrec(:,i) = d.Temp.WBdum(:,i);
s.wGW(:,i) = s.wGW(:,i) + fx.Qgwrec(:,i);
end