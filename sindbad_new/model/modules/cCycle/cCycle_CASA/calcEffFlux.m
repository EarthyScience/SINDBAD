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
% 
% OUTPUT
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
% #########################################################################

% GET PARAMETERS
LITC2N              = p.cCycle.LITC2N;
LIGNIN              = p.cCycle.LIGNIN;
MTFA                = p.cCycle.MTFA;
MTFB                = p.cCycle.MTFB;
LIGEFFA             = p.cCycle.LIGEFFA;
effA                = p.cCycle.effA;
effB                = p.cCycle.effB;
CLAY                = p.psoil.CLAY;
SILT                = p.psoil.SILT;
WOODLIGFRAC         = p.cCycle.WOODLIGFRAC;
C2LIGNIN            = p.cCycle.C2LIGNIN;
effCLAYpsoil_MICA	= p.cCycle.effCLAYpsoil_MICA;
effCLAYpsoil_MICB	= p.cCycle.effCLAYpsoil_MICB;
effCLAYSLOWA        = p.cCycle.effCLAYSLOWA;
effCLAYSLOWB        = p.cCycle.effCLAYSLOWB;
NONSOL2SOLLIGNIN	= p.cCycle.NONSOL2SOLLIGNIN;
TEXTEFFA            = p.cCycle.TEXTEFFA;

% CALCULATE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
% CALCULATE LIGNIN 2 NITROGEN SCALAR
L2N     = (LITC2N .* LIGNIN) .* NONSOL2SOLLIGNIN;

% DETERMINE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
MTF             = MTFA - (MTFB .* L2N);
MTF(MTF < 0)    = 0;

% DETERMINE FRACTION OF C IN STRUCTURAL LITTER POOLS FROM LIGNIN
SCLIGNIN    = (LIGNIN .* C2LIGNIN .* NONSOL2SOLLIGNIN) ./ (1 - MTF);

% DETERMINE EFFECT OF LIGNIN CONTENT ON DECOMPOSITION RATES
fe.cCycle.LIGEFF      = exp(-LIGEFFA .* SCLIGNIN);

% CALCULATE MICROBIAL CARBON FLUX PARTICULAR EFFICIENCIES
p.cCycle.effpsoil_MIC2SLOW    = effA - (effB .* (SILT + CLAY));
p.cCycle.effpsoil_MIC2OLD     = effA - (effB .* (SILT + CLAY)); 

% CREATE STRUCTURE ARRAY
% effFLUX   - microbial efficiency for each particular c transfer
% xrtEFF	- extra respiration transfer efficiencies for each particular c transfer
ctransfer(1).donor    = 6;  ctransfer(1).receiver   = 13;	ctransfer(1).effFLUX    = p.cCycle.effS_LEAF2SLOW;      ctransfer(1).xtrEFF     = SCLIGNIN;
ctransfer(2).donor    = 6;  ctransfer(2).receiver   = 11;   ctransfer(2).effFLUX    = p.cCycle.effS_LEAF2LEAF_MIC;	ctransfer(2).xtrEFF     = 1 - SCLIGNIN;
ctransfer(3).donor    = 8;  ctransfer(3).receiver   = 13;   ctransfer(3).effFLUX    = p.cCycle.effS_ROOT2SLOW;      ctransfer(3).xtrEFF     = SCLIGNIN;
ctransfer(4).donor    = 8;  ctransfer(4).receiver   = 12;   ctransfer(4).effFLUX    = p.cCycle.effS_ROOT2psoil_MIC;  ctransfer(4).xtrEFF     = 1 - SCLIGNIN;
ctransfer(5).donor    = 9;  ctransfer(5).receiver   = 13;   ctransfer(5).effFLUX    = p.cCycle.effLiWOOD2SLOW;      ctransfer(5).xtrEFF     = WOODLIGFRAC;
ctransfer(6).donor    = 9;  ctransfer(6).receiver   = 11;   ctransfer(6).effFLUX    = p.cCycle.effLiWOOD2LEAF_MIC;  ctransfer(6).xtrEFF     = 1 - WOODLIGFRAC;
ctransfer(7).donor    = 11; ctransfer(7).receiver   = 13;	ctransfer(7).effFLUX    = p.cCycle.effLEAF_MIC2SLOW;    ctransfer(7).xtrEFF     = 1;
ctransfer(8).donor    = 13;	ctransfer(8).receiver   = 12;   ctransfer(8).effFLUX    = p.cCycle.effSLOW2psoil_MIC;    ctransfer(8).xtrEFF     = 1 - (effCLAYSLOWA + (effCLAYSLOWB .* CLAY));
ctransfer(9).donor    = 13;	ctransfer(9).receiver   = 14;   ctransfer(9).effFLUX    = p.cCycle.effSLOW2OLD;         ctransfer(9).xtrEFF     = effCLAYSLOWA + (effCLAYSLOWB .* CLAY);
ctransfer(10).donor   = 14;	ctransfer(10).receiver  = 12;   ctransfer(10).effFLUX   = p.cCycle.effOLD2psoil_MIC;     ctransfer(10).xtrEFF    = 1;
ctransfer(11).donor   = 5;  ctransfer(11).receiver  = 11;   ctransfer(11).effFLUX   = p.cCycle.effM_LEAF2LEAF_MIC;  ctransfer(11).xtrEFF    = 1;
ctransfer(12).donor   = 7;  ctransfer(12).receiver  = 12;   ctransfer(12).effFLUX   = p.cCycle.effM_ROOT2psoil_MIC;  ctransfer(12).xtrEFF    = 1;
ctransfer(13).donor   = 12;	ctransfer(13).receiver  = 13;   ctransfer(13).effFLUX   = p.cCycle.effpsoil_MIC2SLOW;    ctransfer(13).xtrEFF    = 1 - (effCLAYpsoil_MICA + (effCLAYpsoil_MICB .* CLAY));
ctransfer(14).donor   = 12;	ctransfer(14).receiver  = 14;   ctransfer(14).effFLUX   = p.cCycle.effpsoil_MIC2OLD;     ctransfer(14).xtrEFF    = effCLAYpsoil_MICA + (effCLAYpsoil_MICB .* CLAY);
ctransfer(15).donor   = 10;	ctransfer(15).receiver  = 13;   ctransfer(15).effFLUX   = p.cCycle.effLiROOT2SLOW;      ctransfer(15).xtrEFF    = WOODLIGFRAC;
ctransfer(16).donor   = 10;	ctransfer(16).receiver	= 12;   ctransfer(16).effFLUX   = p.cCycle.effLiROOT2psoil_MIC;  ctransfer(16).xtrEFF    = 1 - WOODLIGFRAC;

for ii = 1:numel(ctransfer)
    ctransfer(ii).xtrEFF = max(min(ctransfer(ii).xtrEFF,1),0);
end

% TEXTURE EFFECT
fe.cCycle.TEXTEFF	= (1 - (TEXTEFFA .* (SILT + CLAY)));

% FEED DATA INTO fe
fe.cCycle.ctransfer	= ctransfer;
fe.cCycle.MTF       = MTF;

end % function
