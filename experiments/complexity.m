%% Complexity experiment for the sketched estimator
addpath('src');
rng(20251109)

%% Parameters
m_list = [5000, 10000, 20000];
n_list = 20:10:60;
d_list = [1, 4, 16];
nsample = 100;

runtime_samples = zeros(length(m_list), length(n_list), length(d_list), nsample);

%% Run experiments
for l = 1:length(m_list)
    m = m_list(l);
    for i = 1:length(n_list)
        n = n_list(i);
        for j = 1:length(d_list)
            d = d_list(j);
    
            for k = -5:nsample
                [A,b,x, backdoor] = random_tls_problem(m,n,10^6);
                err_vec = randn(size(x));
                err_vec = err_vec ./ norm(err_vec,'fro');
                x_tilde = x + err_vec .* norm(x,'fro');
    
                tic;
                estimate_eta(A,b,x_tilde, 'sketch');
                if k < 1 % warm up
                    runtime_samples(l, i, j, 1) = toc;
                else
                    runtime_samples(l, i, j, k) = toc;
                end
            end
    
            fprintf("m=%d, n=%d, d=%d: mean=%.6f sec (std=%.6f)\n", ...
                m, n, d, mean(runtime_samples(l,i,j,:)), std(runtime_samples(l,i,j,:)));
        end
    end
end

%% Save all sample data
save('artifacts/complexity.mat', 'm_list', 'n_list', 'd_list', 'nsample', 'runtime_samples');
