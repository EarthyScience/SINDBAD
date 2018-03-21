function [fe,fx,d,p] = prec_spinupWccycle_CASA(f,fe,fx,s,d,p,info)
% #########################################################################
% FUNCTION	: prec_spinupWccycle_CASA
% 
% PURPOSE	: pre compute the time step scalars that control carbon flows
%           between vegetation and soil and within the soil that depend on
%           parameters and model forcing.
% 
% REFERENCES:
% Potter, C. S., J. T. Randerson, C. B. Field, P. A. Matson, P. M.
% Vitousek, H. A. Mooney, and S. A. Klooster. 1993.  Terrestrial ecosystem
% production: A process model based on global satellite and surface data. 
% Global Biogeochemical Cycles. 7: 811-841. 
% 
% CONTACT	: Nuno
% 
% INPUT
% for calcKcpools
% annk?     : annual turnover rates of carbon for the different soil carbon
%           pools (yr-1). ? is the name of the pool
%           (p.spinupWccycle.annk?)
%           example
%           p.spinupWccycle.annkSLOW is the annual turnover rate of the slow pool
% ?_AGE     : average age of vegetation pools (yr). ? is the name of the
%           pool
%           (p.spinupWccycle.?_AGE)
%           example
%           p.spinupWccycle.ROOT_AGE is the mean age of the fine roots
% 
% for calcEffFlux
% LITC2N            :carbon-to-nitrogen ratio in litter (gC/gN)
%                   (p.spinupWccycle.LITC2N)
% LIGNIN            : fraction of litter that is lignin ([])
%                   (p.spinupWccycle.LIGNIN)
% MTFA              : parameter A - offset - to determine the MTF as a
%                   function of lignin to nitrogen ratios ([])
%                   (p.spinupWccycle.MTFA)
% MTFB              : parameter B - negative slope - to determine the MTF
%                   as a function of lignin to nitrogen ratios ([])
%                   (p.spinupWccycle.MTFB)
% LIGEFFA           : parameter to determine the effect of lignin content
%                   on decomposition rates ([])
%                   (p.spinupWccycle.LIGEFFA)
% effA              : parameter A - offset - on the decomposeability of
%                   soil microbial pools. ([])
%                   (p.spinupWccycle.effA)
% effB              : parameter A - negative slope - on the
%                   decomposeability of soil microbial pools. ([])
%                   (p.spinupWccycle.effB)
% CLAY              : fraction of clay in soil
%                   (p.psoilR.CLAY)
% SILT              : fraction of silt in soil
%                   (p.psoilR.SILT)
% WOODLIGFRAC       : fraction of wood that is lignin ([])
%                   (p.spinupWccycle.WOODLIGFRAC)
% C2LIGNIN          : carbon to lignin ratio (massC/massLignin)
%                   (p.spinupWccycle.C2LIGNIN)
% effCLAYpsoilR_MICA	: 
%                   (p.spinupWccycle.effCLAYpsoilR_MICA)
% effCLAYpsoilR_MICB	: 
%                   (p.spinupWccycle.effCLAYpsoilR_MICB)
% effCLAYSLOWA      : 
%                   (p.spinupWccycle.effCLAYSLOWA)
% effCLAYSLOWB      : 
%                   (p.spinupWccycle.effCLAYSLOWB)
% NONSOL2SOLLIGNIN	: 
%                   (p.spinupWccycle.NONSOL2SOLLIGNIN)
% TEXTEFFA          : 
%                   (p.spinupWccycle.TEXTEFFA)
% 
% for calcLisc
% lai           : leaf area index (m2/m2)
%               (f.LAI)
% maxMinLAI     : parameter for the maximum value for the minimum LAI
%               (m2/m2)
%               (p.spinupWccycle.maxMinLAI)
% kRTLAI        : parameter for the constant fraction of root litter imputs
%               to the soil ([])
%               (p.spinupWccycle.kRTLAI)
% stepsPerYear	: number of time steps per year
%               (info.timeScale.stepsPerYear)
% NYears        : number of years of simulations
%               (info.timeScale.nYears)
% 
% 
% OUTPUT
% DecayRate     : decay rates of vegetation carbon pools (deltaT-1)
%               (fe.spinupWccycle.DecayRate)
%               example
%               fe.spinupWccycle.DecayRate(1).value - decay rate of fine roots
% kfEnvTs       : turnover rates of soil carbon pools including the
%               compounded effects of temperature, soil texture, litter
%               properties
%               (fe.spinupWccycle.kfEnvTs)
%               example
%               fe.spinupWccycle.kfEnvTs(5).value - turnover rates of metabolic
%               leaf litter pools.
% 
% from calcEffFlux
% effFLUX           : microbial efficiency for each particular c transfer
%                   ([])
%                   example 
%                   fe.spinupWccycle.ctransfer(1).effFLUX is the microbial
%                   efficiency for the transfer of carbon from S_LEAF to
%                   the SLOW c pools
% xrtEFF            : extra respiration transfer efficiencies for each
%                   particular c transfer ([])
%                   example 
%                   fe.spinupWccycle.ctransfer(1).xrtEFF is the extra respiration
%                   transfer efficiency for the transfer of carbon from
%                   S_LEAF to the SLOW c pools
% donor             : pool ID of the donor of carbon
%                   fe.spinupWccycle.ctransfer.donor
% receiver          : pool ID of the receiver of carbon
%                   fe.spinupWccycle.ctransfer.receiver
% ctransfer         : structure array with all of the above information
%                   (fe.spinupWccycle.ctransfer)
% LIGEFF            : lignin effect on decomposition processes ([])
%                   (fe.spinupWccycle.LIGEFF)
% MTF               : metabolic fraction of residue
%                   (fe.spinupWccycle.MTF)
% TEXTEFF           : effect of texture on decomposition processes
%                   (fe.spinupWccycle.TEXTEFF)
% 
% #########################################################################

% CALCULATE THE TURNOVER RATES OF EACH POOL AT ANNUAL AND TIME STEP SCALES
[fe] = calcKcpools(f,fe,fx,s,d,p,info);

% CREATE CARBON POOL FLUX EFFICIENCIES STRUCTURE ARRAY FOR EVERY FLOW
[fe] = calcEffFlux(f,fe,fx,s,d,p,info);

% DISTRIBUTE LITTERFALL AND ROOT"FALL" THROUGHOUT THE YEAR
[fe] = calcLisc(f,fe,fx,s,d,p,info);

% ADJUST THE DECAYRATES PER TIME STEP ACCORDINGLY
fe.spinupWccycle.DecayRate(1).value	= max(min(fe.spinupWccycle.annkpool(1).value .* fe.spinupWccycle.RTLAI,1),0);
fe.spinupWccycle.DecayRate(2).value	= max(min(fe.spinupWccycle.kpool(2).value,1),0) * ones(1,info.forcing.size(2));
fe.spinupWccycle.DecayRate(3).value	= max(min(fe.spinupWccycle.kpool(3).value,1),0) * ones(1,info.forcing.size(2));
fe.spinupWccycle.DecayRate(4).value	= max(min(fe.spinupWccycle.annkpool(4).value .* fe.spinupWccycle.RTLAI,1),0);

% combine the different intrinsic turnover rates (kpools) with the
% decomposition rates scalars depending on environmental conditions
% (lignin, textures) and temperature.
fe.spinupWccycle.kfEnvTs(5).value  = fe.spinupWccycle.kpool(5).value  .* fe.rhFtemp.fT;
fe.spinupWccycle.kfEnvTs(6).value  = fe.spinupWccycle.kpool(6).value  .* fe.rhFtemp.fT	.* fe.spinupWccycle.LIGEFF;
fe.spinupWccycle.kfEnvTs(7).value  = fe.spinupWccycle.kpool(7).value  .* fe.rhFtemp.fT;
fe.spinupWccycle.kfEnvTs(8).value  = fe.spinupWccycle.kpool(8).value  .* fe.rhFtemp.fT   .* fe.spinupWccycle.LIGEFF;
fe.spinupWccycle.kfEnvTs(9).value  = fe.spinupWccycle.kpool(9).value  .* fe.rhFtemp.fT;
fe.spinupWccycle.kfEnvTs(10).value	= fe.spinupWccycle.kpool(10).value .* fe.rhFtemp.fT;
fe.spinupWccycle.kfEnvTs(11).value	= fe.spinupWccycle.kpool(11).value .* fe.rhFtemp.fT;
fe.spinupWccycle.kfEnvTs(12).value	= fe.spinupWccycle.kpool(12).value .* fe.rhFtemp.fT	.* fe.spinupWccycle.TEXTEFF;
fe.spinupWccycle.kfEnvTs(13).value	= fe.spinupWccycle.kpool(13).value .* fe.rhFtemp.fT;
fe.spinupWccycle.kfEnvTs(14).value	= fe.spinupWccycle.kpool(14).value	.* fe.rhFtemp.fT;

for ii = 5:14
    fe.spinupWccycle.kfEnvTs(ii).value	= max(min(fe.spinupWccycle.kfEnvTs(ii).value,1),0);
end

end % function
