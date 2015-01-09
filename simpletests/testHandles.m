% test how to hand handles ;)

a	= 2;
b	= 3;

fun             = @(a,x)a*x;
ms.fun.handle   = fun;

% result should be 10
tmp = ms.fun.handle(2,5);
disp(['result should be 10 : ' num2str(tmp)])

% result should be 15, if is 10 is wrong!!
tmp = ms.fun.handle(3,5);
disp(['result should be 15, if is 10 is wrong!! : ' num2str(tmp)])


% now a handle goes to a written function
ms.fun2.handle = @(s,d,h)myFun2Test(s,d,h);

s=ms.fun2.handle(1,2,3)
[s,d]=ms.fun2.handle(1,2,3)



p = mfilename('fullpath');
g = dbstack('-completenames');