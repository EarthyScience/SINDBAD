function [fe] = calcEffFlux(f,fe,fx,s,d,p,info)
% #########################################################################
% FUNCTION	: calcEffFlux
% 
% PURPOSE	: compute the carbon pool fluxes efficiencies and build the
%           structure array of carbon cycle in the soils.
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
% 
% OUTPUT
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
% #########################################################################

% GET PARAMETERS
LITC2N              = p.spinupWccycle.LITC2N;
LIGNIN              = p.spinupWccycle.LIGNIN;
MTFA                = p.spinupWccycle.MTFA;
MTFB                = p.spinupWccycle.MTFB;
LIGEFFA             = p.spinupWccycle.LIGEFFA;
effA                = p.spinupWccycle.effA;
effB                = p.spinupWccycle.effB;
CLAY                = p.psoilR.CLAY;
SILT                = p.psoilR.SILT;
WOODLIGFRAC         = p.spinupWccycle.WOODLIGFRAC;
C2LIGNIN            = p.spinupWccycle.C2LIGNIN;
effCLAYpsoilR_MICA	= p.spinupWccycle.effCLAYpsoilR_MICA;
effCLAYpsoilR_MICB	= p.spinupWccycle.effCLAYpsoilR_MICB;
effCLAYSLOWA        = p.spinupWccycle.effCLAYSLOWA;
effCLAYSLOWB        = p.spinupWccycle.effCLAYSLOWB;
NONSOL2SOLLIGNIN	= p.spinupWccycle.NONSOL2SOLLIGNIN;
TEXTEFFA            = p.spinupWccycle.TEXTEFFA;

% CALCULATE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
% CALCULATE LIGNIN 2 NITROGEN SCALAR
L2N     = (LITC2N .* LIGNIN) .* NONSOL2SOLLIGNIN;

% DETERMINE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
MTF             = MTFA - (MTFB .* L2N);
MTF(MTF < 0)    = 0;

% DETERMINE FRACTION OF C IN STRUCTURAL LITTER POOLS FROM LIGNIN
SCLIGNIN    = (LIGNIN .* C2LIGNIN .* NONSOL2SOLLIGNIN) ./ (1 - MTF);

% DETERMINE EFFECT OF LIGNIN CONTENT ON DECOMPOSITION RATES
fe.spinupWccycle.LIGEFF      = exp(-LIGEFFA .* SCLIGNIN);

% CALCULATE MICROBIAL CARBON FLUX PARTICULAR EFFICIENCIES
p.spinupWccycle.effpsoilR_MIC2SLOW    = effA - (effB .* (SILT + CLAY));
p.spinupWccycle.effpsoilR_MIC2OLD     = effA - (effB .* (SILT + CLAY)); 

% CREATE STRUCTURE ARRAY
% effFLUX   - microbial efficiency for each particular c transfer
% xrtEFF	- extra respiration transfer efficiencies for each particular c transfer
ctransfer(1).donor    = 6;  ctransfer(1).receiver   = 13;	ctransfer(1).effFLUX    = p.spinupWccycle.effS_LEAF2SLOW;      ctransfer(1).xtrEFF     = SCLIGNIN;
ctransfer(2).donor    = 6;  ctransfer(2).receiver   = 11;   ctransfer(2).effFLUX    = p.spinupWccycle.effS_LEAF2LEAF_MIC;	ctransfer(2).xtrEFF     = 1 - SCLIGNIN;
ctransfer(3).donor    = 8;  ctransfer(3).receiver   = 13;   ctransfer(3).effFLUX    = p.spinupWccycle.effS_ROOT2SLOW;      ctransfer(3).xtrEFF     = SCLIGNIN;
ctransfer(4).donor    = 8;  ctransfer(4).receiver   = 12;   ctransfer(4).effFLUX    = p.spinupWccycle.effS_ROOT2psoilR_MIC;  ctransfer(4).xtrEFF     = 1 - SCLIGNIN;
ctransfer(5).donor    = 9;  ctransfer(5).receiver   = 13;   ctransfer(5).effFLUX    = p.spinupWccycle.effLiWOOD2SLOW;      ctransfer(5).xtrEFF     = WOODLIGFRAC;
ctransfer(6).donor    = 9;  ctransfer(6).receiver   = 11;   ctransfer(6).effFLUX    = p.spinupWccycle.effLiWOOD2LEAF_MIC;  ctransfer(6).xtrEFF     = 1 - WOODLIGFRAC;
ctransfer(7).donor    = 11; ctransfer(7).receiver   = 13;	ctransfer(7).effFLUX    = p.spinupWccycle.effLEAF_MIC2SLOW;    ctransfer(7).xtrEFF     = 1;
ctransfer(8).donor    = 13;	ctransfer(8).receiver   = 12;   ctransfer(8).effFLUX    = p.spinupWccycle.effSLOW2psoilR_MIC;    ctransfer(8).xtrEFF     = 1 - (effCLAYSLOWA + (effCLAYSLOWB .* CLAY));
ctransfer(9).donor    = 13;	ctransfer(9).receiver   = 14;   ctransfer(9).effFLUX    = p.spinupWccycle.effSLOW2OLD;         ctransfer(9).xtrEFF     = effCLAYSLOWA + (effCLAYSLOWB .* CLAY);
ctransfer(10).donor   = 14;	ctransfer(10).receiver  = 12;   ctransfer(10).effFLUX   = p.spinupWccycle.effOLD2psoilR_MIC;     ctransfer(10).xtrEFF    = 1;
ctransfer(11).donor   = 5;  ctransfer(11).receiver  = 11;   ctransfer(11).effFLUX   = p.spinupWccycle.effM_LEAF2LEAF_MIC;  ctransfer(11).xtrEFF    = 1;
ctransfer(12).donor   = 7;  ctransfer(12).receiver  = 12;   ctransfer(12).effFLUX   = p.spinupWccycle.effM_ROOT2psoilR_MIC;  ctransfer(12).xtrEFF    = 1;
ctransfer(13).donor   = 12;	ctransfer(13).receiver  = 13;   ctransfer(13).effFLUX   = p.spinupWccycle.effpsoilR_MIC2SLOW;    ctransfer(13).xtrEFF    = 1 - (effCLAYpsoilR_MICA + (effCLAYpsoilR_MICB .* CLAY));
ctransfer(14).donor   = 12;	ctransfer(14).receiver  = 14;   ctransfer(14).effFLUX   = p.spinupWccycle.effpsoilR_MIC2OLD;     ctransfer(14).xtrEFF    = effCLAYpsoilR_MICA + (effCLAYpsoilR_MICB .* CLAY);
ctransfer(15).donor   = 10;	ctransfer(15).receiver  = 13;   ctransfer(15).effFLUX   = p.spinupWccycle.effLiROOT2SLOW;      ctransfer(15).xtrEFF    = WOODLIGFRAC;
ctransfer(16).donor   = 10;	ctransfer(16).receiver	= 12;   ctransfer(16).effFLUX   = p.spinupWccycle.effLiROOT2psoilR_MIC;  ctransfer(16).xtrEFF    = 1 - WOODLIGFRAC;

for ii = 1:numel(ctransfer)
    ctransfer(ii).xtrEFF = max(min(ctransfer(ii).xtrEFF,1),0);
end

% TEXTURE EFFECT
fe.spinupWccycle.TEXTEFF	= (1 - (TEXTEFFA .* (SILT + CLAY)));

% FEED DATA INTO fe
fe.spinupWccycle.ctransfer	= ctransfer;
fe.spinupWccycle.MTF       = MTF;

end % function
