function X = solve_tls(A, B)
%SOLVE_TLS Solve Total Least Squares (TLS) solution.
%   X = SOLVE_TLS(A, B) computes the TLS solution for the linear system
%   A*X = B by forming the augmented matrix [A, B], computing its SVD,
%   and extracting the solution from the right singular vectors. The
%   implementation follows the standard TLS approach.
%
%   Syntax
%       X = solve_tls(A, B)
%
%   Inputs
%       A  - m-by-n data matrix.
%       B  - m-by-k right-hand side matrix (number of rows must equal m).
%
%   Outputs
%       X  - n-by-k TLS solution matrix.
%
%   Notes
%       The function constructs the augmented matrix [A, B] and uses its
%       SVD. For large-scale problems this method is inefficient and a
%       specialized solver or iterative method is recommended.

assert(ismatrix(A) && ismatrix(B), 'solve_tls:InvalidInput', 'Inputs A and B must be matrices.');
[m, n] = size(A);
[m_, ~] = size(B);
assert(m_ == m, 'solve_tls:RowMismatch', 'Number of rows of A and B must match.');

A_aug_B = [A, B];
[~, ~, V] = svd(A_aug_B);
X = -V(1:n, n+1:end) / V(n+1:end, n+1:end);
end