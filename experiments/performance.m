%% Simpler estimator is not acceptable
addpath('src');
rng(20251109)

%% Parameters
m = 4000;
n = 50;
ds = [1];
conds = [10^2,10^4,10^6,10^8,10^10,10^12,10^14,10^16];

num_samples = 100;

%% Run experiments

saved_r_estimate = zeros(length(ds), length(conds), num_samples);
saved_r_sketch = zeros(length(ds), length(conds), num_samples);
saved_r_simpler = zeros(length(ds), length(conds), num_samples);

for i = 1:length(ds)
    for j = 1:length(conds)
        cond_num = conds(j);
        d = ds(i);
        [r_estimate, r_sketch] = simulate_r_dual(m, n, d, cond_num, num_samples);

        for k = 1:num_samples
            [A,B,X, backdoor] = random_tls_problem(m,n,cond_num, d=d);
            err_mat = randn(size(X));
            err_mat = err_mat ./ norm(err_mat,'fro');
            X_tilde = X + err_mat .* norm(X,'fro')*10^-6;
            t_eta = calculate_true_eta(A,B,X_tilde, backdoor);
            tilde_eta = estimate_eta(A,B,X_tilde, 'estimate');
            tilde_eta_sketch = estimate_eta(A,B,X_tilde, 'sketch');
            simplerEstimate = SimplerEstimator(A,B,X_tilde);


            if k < 1 % warm up
                continue
            end

            saved_r_estimate(i, j, k) = t_eta / tilde_eta;
            saved_r_sketch(i, j, k) = t_eta / tilde_eta_sketch;
            saved_r_simpler(i, j, k) = t_eta / simplerEstimate;
        end
    end
end

%% Save data
save('artifacts/performance.mat', 'conds', 'ds', 'saved_r_estimate', 'saved_r_sketch', 'saved_r_simpler');
%%
function [r_estimate, r_sketch] = simulate_r_dual(m, n, d, cond_num, num_samples)
    r_estimate = zeros(num_samples, 1);
    r_sketch = zeros(num_samples, 1);
    for i = 1:num_samples
        [A,B,X, backdoor] = random_tls_problem(m,n,cond_num, d=d);
        err_mat = randn(size(X));
        err_mat = err_mat ./ norm(err_mat,'fro');
        X_tilde = X + err_mat .* norm(X,'fro');

        t_eta = calculate_true_eta(A,B,X_tilde, backdoor);
        tilde_eta = estimate_eta(A,B,X_tilde, 'estimate');
        tilde_eta_sketch = estimate_eta(A,B,X_tilde, 'sketch');

        r_estimate(i) = t_eta / tilde_eta;
        r_sketch(i) = t_eta / tilde_eta_sketch;
    end
end


function r_simpler = SimplerEstimator(A, B, X_tilde)
    A_tilde = A + B*X_tilde';
    r = B - A*X_tilde;
    r_simpler = norm(A_tilde'*r)/norm(r);
end