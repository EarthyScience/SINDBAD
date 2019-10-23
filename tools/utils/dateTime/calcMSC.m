function [ seasonOut, meanseasonOut, iavOut, meaniavOut ] = calcMSC(In, tempvec)
% Calculates Mean Seasonal Cycle ignoring NaNs
%   In              - Input data (pix,timesteps)
%   tempvec         - datevector including month for each timestep
%   seasonOut       - MSC for each pixel (pix,12)
%   meanseasonOut   - average MSC (1,12)
%   iavOut          - inter annual variability as difference between In and MSC (pix, timesteps)
%   meaniavOut      - average iavOut (1,12)

pix             =   size(In,1);
seasonOut       =   NaN(pix,12);
meanseasonOut   =   NaN(1,12);

for m=1:12
   seasonOut(:,m)      = nanmean(In(:,tempvec==m),2);
   meanseasonOut(1,m)  = nanmean(seasonOut(:,m),1); 
end

try
years       =   length(find(tempvec==12)); % ONLY  WORKS WITH MONTHLY INPUT!
iav         =   repmat(seasonOut, 1, years);
iav         =   iav(:,tempvec(1):end);
iavOut      =   In - iav;
meaniavOut  =   nanmean(iavOut,1);
end

end

