A = rand(3,2);
B = rand(3,10);
N = 10000000;
tic
for i = 1:N
    C = horzcat(A,B);
end
toc

tic
for i = 1:N
    C = [A B];
end
toc
