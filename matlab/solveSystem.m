function [relerr] = solveSystem(A,n)
%SOLVESYSTEM Summary of this function goes here
%   Detailed explanation goes here
    xe = ones(n, 1);
    b = A * xe;
    x = A \ b;
    relerr = norm(x - xe) / norm(xe);
end