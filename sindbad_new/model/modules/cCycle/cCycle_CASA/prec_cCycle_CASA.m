function [fe,fx,d,p] = prec_cCycle_CASA(f,fe,fx,s,d,p,info)
% #########################################################################
% FUNCTION	: prec_cCycle_CASA
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
%           (p.cCycle.annk?)
%           example
%           p.cCycle.annkSLOW is the annual turnover rate of the slow pool
% ?_AGE     : average age of vegetation pools (yr). ? is the name of the
%           pool
%           (p.cCycle.?_AGE)
%           example
%           p.cCycle.ROOT_AGE is the mean age of the fine roots
% 
% for calcEffFlux
% LITC2N            :carbon-to-nitrogen ratio in litter (gC/gN)
%                   (p.cCycle.LITC2N)
% LIGNIN            : fraction of litter that is lignin ([])
%                   (p.cCycle.LIGNIN)
% MTFA              : parameter A - offset - to determine the MTF as a
%                   function of lignin to nitrogen ratios ([])
%                   (p.cCycle.MTFA)
% MTFB              : parameter B - negative slope - to determine the MTF
%                   as a function of lignin to nitrogen ratios ([])
%                   (p.cCycle.MTFB)
% LIGEFFA           : parameter to determine the effect of lignin content
%                   on decomposition rates ([])
%                   (p.cCycle.LIGEFFA)
% effA              : parameter A - offset - on the decomposeability of
%                   soil microbial pools. ([])
%                   (p.cCycle.effA)
% effB              : parameter A - negative slope - on the
%                   decomposeability of soil microbial pools. ([])
%                   (p.cCycle.effB)
% CLAY              : fraction of clay in soil
%                   (p.psoil.CLAY)
% SILT              : fraction of silt in soil
%                   (p.psoil.SILT)
% WOODLIGFRAC       : fraction of wood that is lignin ([])
%                   (p.cCycle.WOODLIGFRAC)
% C2LIGNIN          : carbon to lignin ratio (massC/massLignin)
%                   (p.cCycle.C2LIGNIN)
% effCLAYpsoil_MICA	: 
%                   (p.cCycle.effCLAYpsoil_MICA)
% effCLAYpsoil_MICB	: 
%                   (p.cCycle.effCLAYpsoil_MICB)
% effCLAYSLOWA      : 
%                   (p.cCycle.effCLAYSLOWA)
% effCLAYSLOWB      : 
%                   (p.cCycle.effCLAYSLOWB)
% NONSOL2SOLLIGNIN	: 
%                   (p.cCycle.NONSOL2SOLLIGNIN)
% TEXTEFFA          : 
%                   (p.cCycle.TEXTEFFA)
% 
% for calcLisc
% lai           : leaf area index (m2/m2)
%               (f.LAI)
% maxMinLAI     : parameter for the maximum value for the minimum LAI
%               (m2/m2)
%               (p.cCycle.maxMinLAI)
% kRTLAI        : parameter for the constant fraction of root litter imputs
%               to the soil ([])
%               (p.cCycle.kRTLAI)
% stepsPerYear	: number of time steps per year
%               (info.timeScale.stepsPerYear)
% NYears        : number of years of simulations
%               (info.timeScale.nYears)
% 
% 
% OUTPUT
% DecayRate     : decay rates of vegetation carbon pools (deltaT-1)
%               (fe.cCycle.DecayRate)
%               example
%               fe.cCycle.DecayRate(1).value - decay rate of fine roots
% kfEnvTs       : turnover rates of soil carbon pools including the
%               compounded effects of temperature, soil texture, litter
%               properties
%               (fe.cCycle.kfEnvTs)
%               example
%               fe.cCycle.kfEnvTs(5).value - turnover rates of metabolic
%               leaf litter pools.
% 
% from calcEffFlux
% effFLUX           : microbial efficiency for each particular c transfer
%                   ([])
%                   example 
%                   fe.cCycle.ctransfer(1).effFLUX is the microbial
%                   efficiency for the transfer of carbon from S_LEAF to
%                   the SLOW c pools
% xrtEFF            : extra respiration transfer efficiencies for each
%                   particular c transfer ([])
%                   example 
%                   fe.cCycle.ctransfer(1).xrtEFF is the extra respiration
%                   transfer efficiency for the transfer of carbon from
%                   S_LEAF to the SLOW c pools
% donor             : pool ID of the donor of carbon
%                   fe.cCycle.ctransfer.donor
% receiver          : pool ID of the receiver of carbon
%                   fe.cCycle.ctransfer.receiver
% ctransfer         : structure array with all of the above information
%                   (fe.cCycle.ctransfer)
% LIGEFF            : lignin effect on decomposition processes ([])
%                   (fe.cCycle.LIGEFF)
% MTF               : metabolic fraction of residue
%                   (fe.cCycle.MTF)
% TEXTEFF           : effect of texture on decomposition processes
%                   (fe.cCycle.TEXTEFF)
% 
% #########################################################################

% CALCULATE THE TURNOVER RATES OF EACH POOL AT ANNUAL AND TIME STEP SCALES
[fe] = calcKcpools(f,fe,fx,s,d,p,info);

% CREATE CARBON POOL FLUX EFFICIENCIES STRUCTURE ARRAY FOR EVERY FLOW
[fe] = calcEffFlux(f,fe,fx,s,d,p,info);

% DISTRIBUTE LITTERFALL AND ROOT"FALL" THROUGHOUT THE YEAR
[fe] = calcLisc(f,fe,fx,s,d,p,info);

% ADJUST THE DECAYRATES PER TIME STEP ACCORDINGLY
fe.cCycle.DecayRate(1).value	= max(min(fe.cCycle.annkpool(1).value .* fe.cCycle.RTLAI,1),0);
fe.cCycle.DecayRate(2).value	= max(min(fe.cCycle.kpool(2).value,1),0) * ones(1,info.forcing.size(2));
fe.cCycle.DecayRate(3).value	= max(min(fe.cCycle.kpool(3).value,1),0) * ones(1,info.forcing.size(2));
fe.cCycle.DecayRate(4).value	= max(min(fe.cCycle.annkpool(4).value .* fe.cCycle.RTLAI,1),0);

% combine the different intrinsic turnover rates (kpools) with the
% decomposition rates scalars depending on environmental conditions
% (lignin, textures) and temperature.
fe.cCycle.kfEnvTs(5).value  = fe.cCycle.kpool(5).value  .* fe.RHfTsoil.fT;
fe.cCycle.kfEnvTs(6).value  = fe.cCycle.kpool(6).value  .* fe.RHfTsoil.fT	.* fe.cCycle.LIGEFF;
fe.cCycle.kfEnvTs(7).value  = fe.cCycle.kpool(7).value  .* fe.RHfTsoil.fT;
fe.cCycle.kfEnvTs(8).value  = fe.cCycle.kpool(8).value  .* fe.RHfTsoil.fT   .* fe.cCycle.LIGEFF;
fe.cCycle.kfEnvTs(9).value  = fe.cCycle.kpool(9).value  .* fe.RHfTsoil.fT;
fe.cCycle.kfEnvTs(10).value	= fe.cCycle.kpool(10).value .* fe.RHfTsoil.fT;
fe.cCycle.kfEnvTs(11).value	= fe.cCycle.kpool(11).value .* fe.RHfTsoil.fT;
fe.cCycle.kfEnvTs(12).value	= fe.cCycle.kpool(12).value .* fe.RHfTsoil.fT	.* fe.cCycle.TEXTEFF;
fe.cCycle.kfEnvTs(13).value	= fe.cCycle.kpool(13).value .* fe.RHfTsoil.fT;
fe.cCycle.kfEnvTs(14).value	= fe.cCycle.kpool(14).value	.* fe.RHfTsoil.fT;

for ii = 5:14
    fe.cCycle.kfEnvTs(ii).value	= max(min(fe.cCycle.kfEnvTs(ii).value,1),0);
end

end % function
