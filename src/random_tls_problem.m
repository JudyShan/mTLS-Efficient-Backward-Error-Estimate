function [A, B, X, backdoor] = random_tls_problem(m, n, cond, varargin)
%RANDOM_TLS_PROBLEM Generate a random TLS problem with controlled conditioning.
%   [A,B,X] = RANDOM_TLS_PROBLEM(m,n,cond) returns matrices A (m-by-n),
%   B (m-by-d) and X (n-by-d) forming an augmented TLS problem [A, B] with
%   singular values of the augmented matrix spanning the interval
%   [10^{-log10(cond)}, 1]. By default d = 1 (single right-hand side).
%
%   Syntax
%       [A,B,X] = random_tls_problem(m,n,cond)
%       [A,B,X] = random_tls_problem(m,n,cond,d=3)
%       [A,B,X,backdoor] = random_tls_problem(m,n,cond,d=3)
%
%   Inputs
%       m      - number of rows (m >= n + d)
%       n      - number of columns of A
%       cond - desired condition number (>= 1) for the augmented matrix
%       d      - (optional) number of right-hand sides (default: 1). Can be
%                supplied positionally or as a name-value 'd', value pair.
%
%   Outputs
%       A  - m-by-n data matrix
%       B  - m-by-d right-hand side matrix
%       X  - n-by-d TLS solution matrix (constructed from right singular vectors)
%       backdoor - (optional) struct with internal data used to generate
%
%   Example
%       [A,B,X] = random_tls_problem(50,5,1e6);

% Parse name-value pairs (supports 'd')
p = inputParser;
addParameter(p, 'd', 1, @(x) isnumeric(x) && isscalar(x) && x >= 1);
parse(p, varargin{:});

d = p.Results.d;

% Ensure d is integer
d = max(1, round(d));

assert(cond >= 1 && m >= n + d, 'random_tls_problem:InvalidDims', ...
    'Require cond >= 1 and m >= n + d.');

% Construct orthonormal bases via Haar-like random orthogonals
U = haarorth(m, n + d);
V = haarorth(n + d, n + d);

% the singular values range from 10^{-log10(cond)} to 10^{0} = 1
S = diag(logspace(0, -log10(cond), n + d));

A_aug_B = U * S * V';
A = A_aug_B(:, 1:n);
B = A_aug_B(:, (n+1):end);

% TLS solution from right singular vectors of the augmented matrix
X = -V(1:n, n+1:end) / V(n+1:end, n+1:end);

backdoor = struct();
backdoor.m = m;
backdoor.n = n;
backdoor.d = d;

backdoor.U = U;
backdoor.S = S;
backdoor.V = V;
end

%% helper function: haarorth
function Q = haarorth(m, n)
[Q,R] = qr(randn(m,n),"econ");
Q = Q*diag(sign(diag(R)));
end