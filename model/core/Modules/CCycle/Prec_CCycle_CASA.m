function [fe,fx,d,p] = Prec_CCycle_CASA(f,fe,fx,s,d,p,info)
% #########################################################################
% FUNCTION	: Prec_CCycle_CASA
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
% for calc_kcpools
% annk?     : annual turnover rates of carbon for the different soil carbon
%           pools (yr-1). ? is the name of the pool
%           (p.CCycle.annk?)
%           example
%           p.CCycle.annkSLOW is the annual turnover rate of the slow pool
% ?_AGE     : average age of vegetation pools (yr). ? is the name of the
%           pool
%           (p.CCycle.?_AGE)
%           example
%           p.CCycle.ROOT_AGE is the mean age of the fine roots
% 
% for calc_effflux
% LITC2N            :carbon-to-nitrogen ratio in litter (gC/gN)
%                   (p.CCycle.LITC2N)
% LIGNIN            : fraction of litter that is lignin ([])
%                   (p.CCycle.LIGNIN)
% MTFA              : parameter A - offset - to determine the MTF as a
%                   function of lignin to nitrogen ratios ([])
%                   (p.CCycle.MTFA)
% MTFB              : parameter B - negative slope - to determine the MTF
%                   as a function of lignin to nitrogen ratios ([])
%                   (p.CCycle.MTFB)
% LIGEFFA           : parameter to determine the effect of lignin content
%                   on decomposition rates ([])
%                   (p.CCycle.LIGEFFA)
% effA              : parameter A - offset - on the decomposeability of
%                   soil microbial pools. ([])
%                   (p.CCycle.effA)
% effB              : parameter A - negative slope - on the
%                   decomposeability of soil microbial pools. ([])
%                   (p.CCycle.effB)
% CLAY              : fraction of clay in soil
%                   (p.SOIL.CLAY)
% SILT              : fraction of silt in soil
%                   (p.SOIL.SILT)
% WOODLIGFRAC       : fraction of wood that is lignin ([])
%                   (p.CCycle.WOODLIGFRAC)
% C2LIGNIN          : carbon to lignin ratio (massC/massLignin)
%                   (p.CCycle.C2LIGNIN)
% effCLAYSOIL_MICA	: 
%                   (p.CCycle.effCLAYSOIL_MICA)
% effCLAYSOIL_MICB	: 
%                   (p.CCycle.effCLAYSOIL_MICB)
% effCLAYSLOWA      : 
%                   (p.CCycle.effCLAYSLOWA)
% effCLAYSLOWB      : 
%                   (p.CCycle.effCLAYSLOWB)
% NONSOL2SOLLIGNIN	: 
%                   (p.CCycle.NONSOL2SOLLIGNIN)
% TEXTEFFA          : 
%                   (p.CCycle.TEXTEFFA)
% 
% for calc_lisc
% lai           : leaf area index (m2/m2)
%               (f.LAI)
% maxMinLAI     : parameter for the maximum value for the minimum LAI
%               (m2/m2)
%               (p.CCycle.maxMinLAI)
% kRTLAI        : parameter for the constant fraction of root litter imputs
%               to the soil ([])
%               (p.CCycle.kRTLAI)
% stepsPerYear	: number of time steps per year
%               (info.timeScale.stepsPerYear)
% NYears        : number of years of simulations
%               (info.timeScale.nYears)
% 
% 
% OUTPUT
% DecayRate     : decay rates of vegetation carbon pools (deltaT-1)
%               (fe.CCycle.DecayRate)
%               example
%               fe.CCycle.DecayRate(1).value - decay rate of fine roots
% kfEnvTs       : turnover rates of soil carbon pools including the
%               compounded effects of temperature, soil texture, litter
%               properties
%               (fe.CCycle.kfEnvTs)
%               example
%               fe.CCycle.kfEnvTs(5).value - turnover rates of metabolic
%               leaf litter pools.
% 
% from calc_effflux
% effFLUX           : microbial efficiency for each particular c transfer
%                   ([])
%                   example 
%                   fe.CCycle.ctransfer(1).effFLUX is the microbial
%                   efficiency for the transfer of carbon from S_LEAF to
%                   the SLOW c pools
% xrtEFF            : extra respiration transfer efficiencies for each
%                   particular c transfer ([])
%                   example 
%                   fe.CCycle.ctransfer(1).xrtEFF is the extra respiration
%                   transfer efficiency for the transfer of carbon from
%                   S_LEAF to the SLOW c pools
% donor             : pool ID of the donor of carbon
%                   fe.CCycle.ctransfer.donor
% receiver          : pool ID of the receiver of carbon
%                   fe.CCycle.ctransfer.receiver
% ctransfer         : structure array with all of the above information
%                   (fe.CCycle.ctransfer)
% LIGEFF            : lignin effect on decomposition processes ([])
%                   (fe.CCycle.LIGEFF)
% MTF               : metabolic fraction of residue
%                   (fe.CCycle.MTF)
% TEXTEFF           : effect of texture on decomposition processes
%                   (fe.CCycle.TEXTEFF)
% 
% #########################################################################

% CALCULATE THE TURNOVER RATES OF EACH POOL AT ANNUAL AND TIME STEP SCALES
[fe] = calc_kcpools(f,fe,fx,s,d,p,info);

% CREATE CARBON POOL FLUX EFFICIENCIES STRUCTURE ARRAY FOR EVERY FLOW
[fe] = calc_effflux(f,fe,fx,s,d,p,info);

% DISTRIBUTE LITTERFALL AND ROOT"FALL" THROUGHOUT THE YEAR
[fe] = calc_lisc(f,fe,fx,s,d,p,info);

% ADJUST THE DECAYRATES PER TIME STEP ACCORDINGLY
fe.CCycle.DecayRate(1).value	= max(min(fe.CCycle.annkpool(1).value .* fe.CCycle.RTLAI,1),0);
fe.CCycle.DecayRate(2).value	= max(min(fe.CCycle.kpool(2).value,1),0) * ones(1,info.forcing.size(2));
fe.CCycle.DecayRate(3).value	= max(min(fe.CCycle.kpool(3).value,1),0) * ones(1,info.forcing.size(2));
fe.CCycle.DecayRate(4).value	= max(min(fe.CCycle.annkpool(4).value .* fe.CCycle.RTLAI,1),0);

% combine the different intrinsic turnover rates (kpools) with the
% decomposition rates scalars depending on environmental conditions
% (lignin, textures) and temperature.
fe.CCycle.kfEnvTs(5).value  = fe.CCycle.kpool(5).value  .* fe.TempEffectRH.fT;
fe.CCycle.kfEnvTs(6).value  = fe.CCycle.kpool(6).value  .* fe.TempEffectRH.fT	.* fe.CCycle.LIGEFF;
fe.CCycle.kfEnvTs(7).value  = fe.CCycle.kpool(7).value  .* fe.TempEffectRH.fT;
fe.CCycle.kfEnvTs(8).value  = fe.CCycle.kpool(8).value  .* fe.TempEffectRH.fT   .* fe.CCycle.LIGEFF;
fe.CCycle.kfEnvTs(9).value  = fe.CCycle.kpool(9).value  .* fe.TempEffectRH.fT;
fe.CCycle.kfEnvTs(10).value	= fe.CCycle.kpool(10).value .* fe.TempEffectRH.fT;
fe.CCycle.kfEnvTs(11).value	= fe.CCycle.kpool(11).value .* fe.TempEffectRH.fT;
fe.CCycle.kfEnvTs(12).value	= fe.CCycle.kpool(12).value .* fe.TempEffectRH.fT	.* fe.CCycle.TEXTEFF;
fe.CCycle.kfEnvTs(13).value	= fe.CCycle.kpool(13).value .* fe.TempEffectRH.fT;
fe.CCycle.kfEnvTs(14).value	= fe.CCycle.kpool(14).value	.* fe.TempEffectRH.fT;

for ii = 5:13
    fe.CCycle.kfEnvTs(5).value	= max(min(fe.CCycle.kfEnvTs(ii).value,1),0);
end

end % function
