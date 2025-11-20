%% Tightness of the estimations
addpath('src');
rng(20251109)

%% Parameters
m = 3000;
n = 20;
ds = [1, 10];
conds = [10^8, 10^12, 10^16];

num_samples = 200;

%% Run experiments

saved_r_estimate = zeros(length(ds), length(conds), num_samples);
saved_r_sketch = zeros(length(ds), length(conds), num_samples);

for i = 1:length(ds)
    group = [];
    for j = 1:length(conds)
        cond_num = conds(j);
        d = ds(i);
        [r_estimate, r_sketch] = simulate_r_dual(m, n, d, cond_num, num_samples);

        for k = 1:num_samples
            [A,B,X, backdoor] = random_tls_problem(m,n,cond_num, d=d);
            err_mat = randn(size(X));
            err_mat = err_mat ./ norm(err_mat,'fro');
            X_tilde = X + err_mat .* norm(X,'fro');
            t_eta = calculate_true_eta(A,B,X_tilde, backdoor);
            tilde_eta = estimate_eta(A,B,X_tilde, 'estimate');
            tilde_eta_sketch = estimate_eta(A,B,X_tilde, 'sketch');

            if k < 1 % warm up
                continue
            end

            saved_r_estimate(i, j, k) = t_eta / tilde_eta;
            saved_r_sketch(i, j, k) = t_eta / tilde_eta_sketch;
            group = [group; j];
        end
    end
end

%% Save data
save('artifacts/tightness.mat', 'conds', 'ds', 'saved_r_estimate', 'saved_r_sketch');

%% Draw boxplots
% figure;
% boxplot(saved_r_estimate(i, :, :), group, 'Labels', cellstr(num2str(conds(:))));
% hold on
% boxplot(saved_r_sketch(i, :, :), group, 'Labels', cellstr(num2str(conds(:))));
% hold off
% ylabel('$\eta / \nu_{sk}$', 'Interpreter','latex');
% xlabel('Condition Number');
% title('Tightness of Backward Error Estimation for mTLS');
% yline(sqrt(2), '--r', 'Bound $\sqrt{2}$','Interpreter','latex');
% yline(1, '--g', 'Ideal','Interpreter','latex');

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
