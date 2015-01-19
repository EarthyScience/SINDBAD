%%
time_res    = .5:.5:730;
TSPY        = 365.25./time_res;
annP        = .75;
npM         = (1-(1-P).^time_res);
npN         = 1 - (exp(-annP) .^ (1 ./ TSPY));
figure,hold on
plot(time_res,npM,'b-')
plot(time_res,npN,'r-')
% plot(time_res,P./time_res,'r-.')
