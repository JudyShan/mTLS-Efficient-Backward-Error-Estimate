%% random matrices
addpath('src');
rng(20250727)

m = 3000;
n = 30;
d = 1;
theta = 1;
cond_A = 100;

[A, B, X, backdoor] = random_tls_problem(m, n, cond_A, d=d);

%% Check that solve_tls gives the correct solution
[X_] = solve_tls(A, B);
assert(norm(X - X_, 'fro') / norm(X, 'fro') < 1e-12);

%% Check that calculate_true_eta gives the correct backward error
X_tilde = X + 1e-4 * randn(size(X));
[true_eta, info] = calculate_true_eta(A, B, X_tilde, backdoor, theta=theta);

assert(abs(norm([info.E, info.theta * info.F], 'fro') - true_eta) / true_eta < 1e-7);

%% Check that the perturbed problem is consistent
A_pert = A + info.E;
B_pert = B + info.F;
X_tilde_ = solve_tls(A_pert, B_pert);
assert(norm(X_tilde - X_tilde_, 'fro') / norm(X_tilde, 'fro') < 1e-10);
