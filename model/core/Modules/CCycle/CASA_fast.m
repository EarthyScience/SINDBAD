function [fx,s,d] = CASA_fast(f,fe,fx,s,d,p,info)

%{
% NEEDS 
WE NEED TESTS ON EQUILIBRIUM SIMULATIONS... EMPIRICAL VERSUS ANALYTICAL

TSPY - or should be the length of the forcing...
fe.CCycle.DecayRate - AS LONG AS THE TIMESERIES OF npp
%}
% #########################################################################

% the input datasets [f,fe,fx,s,d] have to have a full year (or cycle of
% years) that will be used as the recycling dataset for the determination
% of C pools at equilibrium

% NUMBER OF ITERATIONS UNTIL POOLS IN EQUILIBRIUM
NI2E	= info.spinUp.cPools;

% PARAMETERS
BGME = d.SoilMoistEffectRH.BGME;
MTF	= fe.CCycle.MTF;

% START fCt
fCt	= struct('value', repmat({zeros(info.forcing.size(1),info.forcing.size(2))},1,numel(s.cPools)));

% helpers...
sT  = s;
fxT = fx;

% ORDER OF CALCULATIONS
j_vec   = [1:11 13 12 14];
% SOLVE FOR EQUILIBRIUM
for j = j_vec
    % CALCULATE LOSSES AND GAINS
    switch j
%%      % VEGETATION POOLS
        case{1,2,3,4}
            % LOSSES IN THE VEGETATION POOL
            LtX             = fe.CCycle.DecayRate(j).value;
            LtX(LtX > 1)	= 1;
            % EXTRA LOSSES THAT DO NOT GO TO THE LITTER SOIL POOLS (RA)
            LtX_extra                   = 1 - fe.AutoResp.km4su(j).value;
            LtX_extra(LtX_extra > 1)	= 1;
            % GAINS IN THE SAME POOL FROM NPP
            GtX	= d.CAllocationVeg.c2pool(j).value .* fx.gpp .* p.AutoResp.YG;
                        
            % ATTRIBUTE
            eval(['Lt' num2str(j) '         = LtX;'])
            eval(['Lt' num2str(j) '_extra	= LtX_extra;'])
            eval(['Gt' num2str(j) '         = GtX;'])
        
%%      % LITTER POOLS
        case 5
            % CARBON EXCHANGE IN THE METABOLIC LEAF POOL
            % TRANSFER TO THE MICROBIAL LEAF POOL
            xtrEFFvalue = fe.CCycle.ctransfer(11).xtrEFF;
            % LOSS
            Lt5             = fe.CCycle.kfEnvTs(5).value .* BGME;
            Lt5(Lt5 > 1)	= 1;
            Lt5_11          = Lt5 .* fe.CCycle.ctransfer(11).xtrEFF;
            Lt5             = Lt5 .* xtrEFFvalue;
            % GAIN
            Gt5	= (fCt(4).value ./ (1 - Lt4)) .* Lt4 .* MTF;
            
        case 6
            % CARBON EXCHANGE IN THE STRUCTURAL LEAF POOL
            % TRANSFER TO THE SLOW AND LEAF MICROBIAL POOL
            xtrEFFvalue = fe.CCycle.ctransfer(2).xtrEFF + fe.CCycle.ctransfer(1).xtrEFF;
            % LOSS
            Lt6             = fe.CCycle.kfEnvTs(6).value .* BGME;
            Lt6(Lt6 > 1)    = 1;
            Lt6_11          = Lt6 .* fe.CCycle.ctransfer(2).xtrEFF;
            Lt6_13          = Lt6 .* fe.CCycle.ctransfer(1).xtrEFF;
            Lt6             = Lt6 .* xtrEFFvalue;
            % GAIN
            Gt6     = (fCt(4).value ./ (1 - Lt4)) .* Lt4 .* (1 - MTF);
            
        case 7
            % CARBON EXCHANGE IN THE METABOLIC ROOT POOL
            % TRANSFER TO THE MICROBIAL SOIL POOL
            xtrEFFvalue = fe.CCycle.ctransfer(12).xtrEFF;
            % LOSS
            Lt7             = fe.CCycle.kfEnvTs(7).value .* BGME;
            Lt7(Lt7 > 1)    = 1;
            Lt7_12          = Lt7 .* fe.CCycle.ctransfer(12).xtrEFF;
            Lt7             = Lt7 .* xtrEFFvalue;
            % GAIN
            Gt7     = (fCt(1).value ./ (1 - Lt1)) .* Lt1 .* MTF;
            
        case 8
            % CARBON EXCHANGE IN THE STRUCTURAL ROOT POOL
            % TRANSFER TO THE MICROBIAL SOIL POOL AND THE SLOW
            xtrEFFvalue = fe.CCycle.ctransfer(4).xtrEFF + fe.CCycle.ctransfer(3).xtrEFF;
            % LOSS
            Lt8             = fe.CCycle.kfEnvTs(8).value .* BGME;
            Lt8(Lt8 > 1)	= 1;
            Lt8_12          = Lt8 .* fe.CCycle.ctransfer(4).xtrEFF;
            Lt8_13          = Lt8 .* fe.CCycle.ctransfer(3).xtrEFF;
            Lt8             = Lt8 .* xtrEFFvalue;
            % GAIN
            Gt8	= (fCt(1).value ./ (1 - Lt1)) .* Lt1 .* (1 - MTF);
            
        case 9
            % CARBON EXCHANGE IN THE WOODY LITTER POOLS
            % TRANSFER TO THE LEAF AND SOIL MICROBIAL POOLS
            xtrEFFvalue = fe.CCycle.ctransfer(6).xtrEFF + fe.CCycle.ctransfer(5).xtrEFF;
            % LOSS
            Lt9             = fe.CCycle.kfEnvTs(9).value .* BGME;
            Lt9(Lt9 > 1)    = 1;
            Lt9_11          = Lt9 .* fe.CCycle.ctransfer(6).xtrEFF;
            Lt9_13          = Lt9 .* fe.CCycle.ctransfer(5).xtrEFF;
            Lt9             = Lt9 .* xtrEFFvalue;
            % GAIN
            Gt9     = (fCt(3).value ./ (1 - Lt3)) .* Lt3;
            
        case 10
            % CARBON EXCHANGE IN THE ROOTY LITTER POOLS
            xtrEFFvalue = fe.CCycle.ctransfer(16).xtrEFF + fe.CCycle.ctransfer(15).xtrEFF;
            % LOSS
            Lt10            = fe.CCycle.kfEnvTs(10).value .* BGME;
            Lt10(Lt10 > 1)  = 1;
            Lt10_12         = Lt10 .* fe.CCycle.ctransfer(16).xtrEFF;
            Lt10_13         = Lt10 .* fe.CCycle.ctransfer(15).xtrEFF;
            Lt10            = Lt10 .* xtrEFFvalue;
            % GAIN
            Gt10	= (fCt(2).value ./ (1 - Lt2)) .* Lt2;
            
%%      % SOIL POOLS
        case 11
            % CARBON EXCHANGE IN THE LEAF MICROBIAL POOLS
            % TRANSFER TO THE SLOW POOL
            xtrEFFvalue     = fe.CCycle.ctransfer(7).xtrEFF;
            % LOSS
            Lt11            = fe.CCycle.kfEnvTs(11).value .* BGME;
            Lt11(Lt11 > 1)	= 1;
            Lt11_13         = Lt11 .* fe.CCycle.ctransfer(7).xtrEFF;
            Lt11            = Lt11 .* xtrEFFvalue;
            
            % RECEIVE FROM THE METABOLIC LEAF, STRUCTURAL LEAF AND WOODY
            % LITTER POLLS
            Gt5_11  = ((fCt(5).value ./ (1 - Lt5))) .* Lt5_11 .* fe.CCycle.ctransfer(11).effFLUX;
            Gt6_11  = ((fCt(6).value ./ (1 - Lt6))) .* Lt6_11 .* fe.CCycle.ctransfer(2).effFLUX;
            Gt9_11  = ((fCt(9).value ./ (1 - Lt9))) .* Lt9_11 .* fe.CCycle.ctransfer(6).effFLUX;
            % TOTAL GAINS
            Gt11	= Gt5_11 + Gt6_11 + Gt9_11;
            
        case 12
            % CARBON EXCHANGE IN THE SOIL MICROBIAL POOLS
            % TRANSFER TO THE SLOW AND OLD POOLS
            xtrEFFvalue = fe.CCycle.ctransfer(13).xtrEFF + fe.CCycle.ctransfer(14).xtrEFF;
            % LOSS
            Lt12            = fe.CCycle.kfEnvTs(12).value .* BGME;
            Lt12(Lt12 > 1)  = 1;
            Lt12_13         = Lt12 .* fe.CCycle.ctransfer(13).xtrEFF;
            Lt12_14         = Lt12 .* fe.CCycle.ctransfer(14).xtrEFF;
            Lt12            = Lt12 .* xtrEFFvalue;
            % LOSSES FROM 13 AND 14 TO 12##################################
            Lt13            = fe.CCycle.kfEnvTs(13).value .* BGME;
            Lt13(Lt13 > 1)  = 1;
            Lt13_12         = Lt13 .* fe.CCycle.ctransfer(8).xtrEFF;
            
            Lt14            = fe.CCycle.kfEnvTs(14).value .* BGME;
            Lt14(Lt14 > 1)  = 1;
            Lt14_12         = Lt14 .* fe.CCycle.ctransfer(10).xtrEFF;
            % LOSSES FROM 13 AND 14 TO 12##################################
            % RECEIVE FROM THE METABOLIC ROOT, STRUCTURAL ROOT, SLOW AND
            % OLD POOLS
            Gt7_12  = ((fCt(7).value) ./ (1 - Lt7)) .* Lt7_12 .* fe.CCycle.ctransfer(12).effFLUX;
            Gt8_12  = ((fCt(8).value) ./ (1 - Lt8)) .* Lt8_12 .* fe.CCycle.ctransfer(4).effFLUX;
            Gt10_12 = ((fCt(10).value) ./ (1 - Lt10)) .* Lt10_12 .* fe.CCycle.ctransfer(16).effFLUX;
            Gt13_12 = ((fCt(13).value ./ (1 - Lt13))) .* Lt13_12 .* fe.CCycle.ctransfer(8).effFLUX;
            % THIS IS NOT THE ANALYTICAL SOLUTION... BUT VERY APPROXIMATE...
            Gt14_12 = fCt(14).value .* Lt14_12 .* fe.CCycle.ctransfer(10).effFLUX;
            % TOTAL GAINS
            Gt12	= Gt7_12 + Gt8_12 + Gt10_12 + Gt13_12 + Gt14_12;
            
        case 13
            % CARBON EXCHANGE IN THE SLOW POOLS
            % TRANSFER TO THE SOIL MICROBIAL AND OLD POOLS
            xtrEFFvalue = fe.CCycle.ctransfer(8).xtrEFF + fe.CCycle.ctransfer(9).xtrEFF;
            
            % LOSS
            Lt13            = fe.CCycle.kfEnvTs(13).value .* BGME;
            Lt13(Lt13 > 1)  = 1;
            Lt13_12         = Lt13 .* fe.CCycle.ctransfer(8).xtrEFF;
            Lt13_14         = Lt13 .* fe.CCycle.ctransfer(9).xtrEFF;
            Lt13            = Lt13 .* xtrEFFvalue;
            
            % LOSSES FROM 12 TO 13 ########################################
            Lt12            = fe.CCycle.kfEnvTs(12).value .* BGME;
            Lt12(Lt12 > 1)  = 1;
            Lt12_13         = Lt12 .* fe.CCycle.ctransfer(13).xtrEFF;
            % LOSSES FROM 12 TO 13 ########################################
            
            % RECEIVE FROM THE STRUCTURAL LEAF, STRUCTURAL ROOT, LITTER
            % WOOD, LEAF MICROBIAL AND SLOW POOLS
            Gt6_13  = ((fCt(6).value ./ (1 - Lt6))) .* Lt6_13 .* fe.CCycle.ctransfer(1).effFLUX;
            Gt8_13  = ((fCt(8).value ./ (1 - Lt8))) .* Lt8_13 .* fe.CCycle.ctransfer(3).effFLUX;
            Gt9_13  = ((fCt(9).value ./ (1 - Lt9))) .* Lt9_13 .* fe.CCycle.ctransfer(5).effFLUX;
            Gt10_13 = ((fCt(10).value) ./ (1 - Lt10)) .* Lt10_13 .* fe.CCycle.ctransfer(15).effFLUX;
            Gt11_13	= ((fCt(11).value ./ (1 - Lt11))) .* Lt11_13 .* fe.CCycle.ctransfer(7).effFLUX;
            
            % THIS IN NOT THE ANALYTICAL SOLUTION... BUT VERY APPROXIMATE...
            Gt12_13 = ((fCt(12).value )) .* Lt12_13 .* fe.CCycle.ctransfer(13).effFLUX;
            % TOTAL GAINS
            Gt13    = Gt6_13 + Gt8_13 + Gt9_13 + Gt10_13 + Gt11_13 + Gt12_13;
            
        case 14
            % CARBON EXCHANGE IN THE OLD POOLS
            % TRANSFER TO THE SOIL MICROBIAL POOLS
            xtrEFFvalue = fe.CCycle.ctransfer(10).xtrEFF;
            % LOSS
            Lt14            = fe.CCycle.kfEnvTs(14).value .* BGME;
            Lt14(Lt14 > 1)  = 1;
            Lt14_12         = Lt14 .* fe.CCycle.ctransfer(10).xtrEFF;
            Lt14            = Lt14 .* xtrEFFvalue;
            % RECEIVE FROM THE STRUCTURAL LEAF, STRUCTURAL ROOT, LITTER
            % WOOD, LEAF MICROBIAL AND SLOW POOLS
            Gt12_14 = ((fCt(12).value ./ (1 - Lt12))) .* Lt12_14 .* fe.CCycle.ctransfer(14).effFLUX;
            Gt13_14 = ((fCt(13).value ./ (1 - Lt13))) .* Lt13_14 .* fe.CCycle.ctransfer(9).effFLUX;
            % TOTAL GAINS
            Gt14    = Gt12_14 + Gt13_14;
    end
    
%%  % GET THE POOLS GAINS (Gt) AND LOSSES (Lt)
    eval(['Lt   = Lt' num2str(j) ';'])
    eval(['Gt   = Gt' num2str(j) ';'])
    if j <= 4
        eval(['Lt_extra	= Lt' num2str(j) '_extra;'])
    else
        Lt_extra    = 1;
    end
    
    % CALCULATE At = 1 - Lt
    At	= (1 - Lt) .* Lt_extra; % check this!!!
    
    % DEPENDING ON THE FLUX TYPE Bt IS CALCULATED IN A DIFFERENT WAY
    if j <= 10
        % FOR VEGETATION AND LITTER POOLS CALCULATIONS
        Bt  = Gt .* At;
    else
        % FOR SOIL POOLS CALCULATIONS
        Bt  = Gt;
    end
    
    % CARBON AT THE END FOR THE FIRST SPINUP PHASE, NPP IN EQUILIBRIUM
    Co	= s.cPools(j).value;
    
    % THE NEXT LINES REPRESENT THE ANALYTICAL SOLUTION FOR THE SPIN UP;
    % EXCEPT FOR THE LAST 3 POOLS: SOIL MICROBIAL, SLOW AND OLD. IN THIS
    % CASE SIGNIFICANT APPROXIMATION IS CALCULATED (CHECK NOTEBOOKS).
    piA1        = (prod(At,2)) .^ (NI2E);
    At2         = [At ones(size(At,1),1)];
    sumB_piA    = NaN(size(f.Tair));
    for ii = 1:info.forcing.size(2)
        sumB_piA(:,ii) = Bt(:,ii) .* prod(At2(:,ii+1:info.forcing.size(2)+1),2);
    end
    sumB_piA    = sum(sumB_piA,2);
    T2          = 0:1:NI2E - 1;
    piA2        = (prod(At,2)*ones(1,numel(T2))).^(ones(size(At,1),1)*T2);
    piA2        = sum(piA2, 2);
    
    % FINAL CARBON AT POOL j
    Ct                  = Co .* piA1 + sumB_piA .* piA2;
    s.cPools(j).value	= Ct;
%     sT.cPools(j).value	= s.cPools(j).value;
    sT.cPools	= s.cPools;
    
    % CREATE A YEARLY TIME SERIES OF THE POOLS EXCHANGE TO USE IN THE NEXT
    % POOLS CALCULATIONS
    for ii = 1:info.forcing.size(2)

        % CALCULATE CARBON FLUXES
        [fxT,sT]    = info.code.ms.AutoResp.fun(f,fe,fxT,sT,d,p,info,ii);
        [fxT,sT]    = info.code.ms.CCycle.fun(f,fe,fxT,sT,d,p,info,ii);
        
        
        % CHECK CARBON POOLS
        
        % FEED fCt
        fCt(j).value(:,ii)	= sT.cPools(j).value;
    end
end

% make the fx consistent with the pools
for ii = 1:info.forcing.size(2)
    [fx,s,d]    = info.code.ms.AutoResp.fun(f,fe,fx,s,d,p,info,ii);
    [fx,s,d]    = info.code.ms.CCycle.fun(f,fe,fx,s,d,p,info,ii);
end


end % function