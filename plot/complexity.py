import matplotlib.pyplot as plt
import scipy.io as sio

import mpl_rc

data = sio.loadmat('artifacts/complexity.mat')

m_list = data['m_list'].flatten()
n_list = data['n_list'].flatten()
d_list = data['d_list'].flatten()
runtime_samples = data['runtime_samples']

width_in_inch = 370.38374 * 1.5 / 72
fig, axes = plt.subplots(nrows=1, ncols=len(d_list),
                         figsize=(width_in_inch, width_in_inch * 1 / len(d_list)),
                         sharex='col', sharey=True)

for i, d in enumerate(d_list):
    ax = axes[i] if len(d_list) > 1 else axes

    ax.set_xticks(n_list)

    for j, m in enumerate(m_list):
        samples = runtime_samples[j, :, i, :]

        mean_t = samples.mean(axis=1)
        ax.plot(
            n_list, mean_t,
            marker='o', markersize=2, label=r'$m={}$'.format(m)
        )

    ax.set_xlabel("$n$", fontsize=14)
    ax.set_title(r"$d = {}$".format(d), fontsize=14)
    ax.grid(True, linestyle='--', alpha=0.6)

    if i == 0:
        ax.legend(loc='upper left')
        ax.set_ylabel("Runtime (seconds)", fontsize=14)

plt.tight_layout()
plt.savefig('figures/complexity_runtime.pdf', bbox_inches='tight')
