f = rand(1000,1);
N = 10000;
tic 
for i = 1:N
    if find(f<0.5,1,'first')
        t=1;
    else
        t=2;
    end
end
toc

tic 
for i = 1:N
    if any(f<0.5)
        t=1;
    else
        t=2;
    end
end
toc

%%
clc
y = ones(1000,1);
n = 10;
tic
for i = 1:n*10
A = y(:,ones(1,n)); 
end
toc
tic
for i = 1:n*10
A = repmat(y,1,n);
end
toc
tic
for i = 1:n*10
A = y*ones(1,n);
end
toc