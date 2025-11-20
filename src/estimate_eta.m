function tilde_eta = estimate_eta(A, B, X, method, varargin)
%ESTIMATE_ETA Estimate the TLS backward-error indicator tilde_eta.
%   [tilde_eta, info] = ESTIMATE_ETA(A, B, X, method, ...) computes an
%   estimator of the backward-error-related quantity \tilde{\eta} used in
%   TLS/mTLS analysis. The function supports two computation modes:
%   'estimate' (SVD-based estimate) and 'sketch' (randomized sketching
%   approximation).
%
%   Syntax
%       tilde_eta = estimate_eta(A, B, X, method)
%       tilde_eta = estimate_eta(A, B, X, method, Name, Value...)
%
%   Inputs
%       A      - m-by-n data matrix.
%       B      - m-by-d right-hand side matrix.
%       X      - n-by-d solution/approximation matrix.
%       method - one of:
%                'estimate' : SVD-based estimation
%                'sketch'   : randomized sketching estimation
%       Name-Value options (optional):
%         'theta'       - scalar parameter (default: 1)
%         'sketch_size' - integer sketch size for 'sketch' (default: 12*(n+1))
%         'sparsity'    - sparsity parameter for the sketch (default: 8)
%
%   Outputs
%       tilde_eta - scalar estimated value of the indicator (nonnegative).
%
%   See also random_tls_problem, solve_tls

[m, n] = size(A);
[m_, d] = size(B);
[n_, d_] = size(X);

assert(m == m_ && n == n_ && d == d_, 'estimate_eta:DimMismatch', ...
    'Matrix dimensions (A,B,X) do not match.');

% Parameter parsing
p = inputParser;
addRequired(p, 'A', @ismatrix);
addRequired(p, 'B', @ismatrix);
addRequired(p, 'X', @ismatrix);
addRequired(p, 'method', @(x) ischar(x) || isstring(x));
addParameter(p, 'theta', 1, @(x) isscalar(x) && isreal(x));
addParameter(p, 'sketch_size', 12 * (n + 1), @(x) isscalar(x) && x > 0);
addParameter(p, 'sparsity', 8, @(x) isscalar(x) && x > 0);

parse(p, A, B, X, method, varargin{:});

method = char(method);
theta = p.Results.theta;

% Compute common intermediate quantities
[tilde_R, tilde_A] = compute_intermediate(A, B, X, theta);

% Select computation method
switch lower(method)
    case 'estimate'
        tilde_eta = compute_estimate_method(tilde_A, tilde_R);

    case 'sketch'
        tilde_eta = compute_sketch_method(tilde_A, tilde_R, ...
            p.Results.sketch_size, p.Results.sparsity);

    otherwise
        error('estimate_eta:UnsupportedMethod', ...
            'Unsupported estimation method: %s. Supported methods: estimate, sketch.', method);
end

end

%% Compute intermediate quantities tilde_R and tilde_A
function [tilde_R, tilde_A] = compute_intermediate(A, B, X, theta)

% \tilde{R} = (B - AX)(\theta^{-2} I + X^TX)^{-1/2}
% X_norm_sq = norm(X)^2;
% scaling_factor = 1 / sqrt(1 + theta^2 * X_norm_sq);
% tilde_R = theta * (B - A * X) * scaling_factor;

% \tilde{A} = (A + BX^T)(I + \theta^{-2} XX^T)^{-1/2}
% Be careful when X is (near) zero to avoid division by zero.
% if X_norm_sq > 0
%     alpha = theta / sqrt(theta^2 + X_norm_sq) - 1;
%     tilde_A = (A + B * X') + alpha * ((A * X) * X' + B * (X' * X) * X') / X_norm_sq;
% else
%     tilde_A = (A + B * X');
% end

[Ux, Sx, Vx] = svd(X, 'econ');
Sx = diag(Sx);

% \tilde{R} = (B - AX)(\theta^{-2} I + X^TX)^{-1/2}
R_ = B - A * X;
S_ = diag(1 ./ sqrt(theta^2 * Sx.^2 + 1) - 1);
tilde_R = theta * (R_ + R_ * (Vx * S_ * Vx'));

% \tilde{A} = (A + BX^T)(I + \theta^{-2} XX^T)^{-1/2}
A_ = A + B * X';
S_ = diag(1 ./ sqrt(1 + theta^(-2) * Sx.^2) - 1);
tilde_A = A_ + A_ * (Ux * S_ * Ux');
end

%% Estimation method
function tilde_eta = compute_estimate_method(tilde_A, tilde_R)
[U_A, S_A, ~] = svd(tilde_A, 'econ');
S_A_vec = diag(S_A);
[U_R, S_R, ~] = svd(tilde_R, 'econ');
S_R_vec = diag(S_R);

% Compute estimate
projection = (U_A * S_A)' * (U_R * S_R);
tilde_eta = norm(projection ./ sqrt(S_A_vec.^2 + S_R_vec'.^2), 'fro');
end

%% Sketching method
function tilde_eta = compute_sketch_method(tilde_A, tilde_R, sketch_size, sparsity)
% Generate sparse sign matrix
S = sparsesign(sketch_size, size(tilde_A, 1), sparsity);

% Sketch computation
S_tilde_A = S * tilde_A;
[~, S_svals, V_A] = svd(S_tilde_A, 'econ');
S_svals_vec = diag(S_svals);
[U_R, S_R, ~] = svd(tilde_R, 'econ');
S_R_vec = diag(S_R);

% Compute sketch estimate
projection = V_A' * (tilde_A' * (U_R * S_R));
tilde_eta = norm(projection ./ sqrt(S_svals_vec.^2 + S_R_vec'.^2));
end
