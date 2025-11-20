function [eta, info] = calculate_true_eta(A, B, X_tilde, backdoor, varargin)
%CALCULATE_TRUE_ETA Calculate the TLS backward-error.
%
%   Syntax
%
%
%   Inputs
%       A       - m-by-n data matrix.
%       B       - m-by-d right-hand side matrix.
%       X_tilde - n-by-d solution/approximation matrix.
%       backdoor -
%       Name-Value options (optional):
%         'theta'       - scalar parameter (default: 1)
%
%   Outputs
%       eta       - scalar estimated value of the indicator (nonnegative).
%       info      - struct with additional information, including extra
%                   fields E and F describing the
%                   exact perturbations.
%
%   See also random_tls_problem, solve_tls, estimate_eta

[m, n] = size(A);
[m_, d] = size(B);
[n_, d_] = size(X_tilde);

assert(m == m_ && n == n_ && d == d_, 'estimate_eta:DimMismatch', ...
    'Matrix dimensions (A,B,X) do not match.');

% Parameter parsing
p = inputParser;
addRequired(p, 'A', @ismatrix);
addRequired(p, 'B', @ismatrix);
addRequired(p, 'X_tilde', @ismatrix);
addRequired(p, 'backdoor');
addParameter(p, 'theta', 1, @(x) isscalar(x) && isreal(x));

parse(p, A, B, X_tilde, backdoor, varargin{:});

theta = p.Results.theta;
X = X_tilde; % for simplification, we use X instead

% use A and B in simplified space span(backdoor.U)
A_aug_B = backdoor.S * backdoor.V';
A = A_aug_B(:, 1:n);
B = A_aug_B(:, n+1:end);

[Ux, Sx, Vx] = svd(X, 'econ');
Sx = diag(Sx);

% Step 1: Compute common intermediate quantities
[tilde_R, tilde_A] = compute_intermediate(A, B, X, Ux, Sx, Vx, theta);
M = tilde_A * tilde_A' - tilde_R * tilde_R';

% Step 2: Compute eta
[V, D] = eig(M);
base = norm(tilde_R, 'fro')^2;
eta = sqrt(base + sum(min(0, diag(D))));

% Step 3: Compute E and F
% [V, ~] = eig(M);
Y = V(:, 1:d);
info = struct();
info.theta = theta;
info.E = - Y * Y' * (A + B * X') / (eye(n) + theta^(-2) * (X * X')) - ...
    (eye(n+d) - Y * Y') * (A * X - B) / (theta^(-2) * eye(d) + X' * X) * X';

info.F = - Y * Y' * (A + B * X') * X / (theta^2 * eye(d) + X' * X) + ...
    (eye(n+d) - Y * Y') * (A * X - B) / (eye(d) + theta^2 * (X' * X));

% return to space span(backdoor.U)
info.E = backdoor.U * info.E;
info.F = backdoor.U * info.F;
end

%% Compute intermediate quantities tilde_R and tilde_A
function [tilde_R, tilde_A] = compute_intermediate(A, B, X, Ux, Sx, Vx, theta)

% \tilde{R} = (B - AX)(\theta^{-2} I + X^TX)^{-1/2}
R_ = B - A * X;
S_ = diag(1 ./ sqrt(theta^2 * Sx.^2 + 1) - 1);
tilde_R = theta * (R_ + R_ * (Vx * S_ * Vx'));

% \tilde{A} = (A + BX^T)(I + \theta^{-2} XX^T)^{-1/2}
A_ = A + B * X';
S_ = diag(1 ./ sqrt(1 + theta^(-2) * Sx.^2) - 1);
tilde_A = A_ + A_ * (Ux * S_ * Ux');
end
