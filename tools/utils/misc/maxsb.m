function [max_val] = maxsb(a,b)
% straight forward way to calculate maximum of two arrays
%
% Inputs:
%    - arrays/floats a and b 
%
% Outputs:
%   - the maximum element wise
%
% Modifies:
%     - None
%
% References:
%    - https://www.maa.org/sites/default/files/0746834259921.di020713.02p0009e.pdf
%   - https://www.maa.org/programs/faculty-and-departments/classroom-capsules-and-notes/
%       the-maximum-and-minimum-of-two-numbers-using-the-quadratic-formula
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 30.11.2019
 max_val=max(a,b);
%max_val=(a+b+abs(a-b))./2;
end

