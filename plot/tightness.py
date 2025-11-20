import numpy as np
from scipy.io import loadmat
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

import mpl_rc

data = loadmat('artifacts/tightness.mat')
d = np.squeeze(data['ds']).flatten()
conds = np.squeeze(data['conds']).flatten()
r_estimate = np.squeeze(data['saved_r_estimate'])
r_sketch = np.squeeze(data['saved_r_sketch'])

# layout: rows = len(d), cols = len(conds) + 1 (last col = boxplots)
nrows = len(d)
ncols = len(conds)

width_in_inch = 370.38374 * 1.5 / 72
fig, axes = plt.subplots(nrows=nrows, ncols=ncols,
                         figsize=(width_in_inch, width_in_inch * nrows / ncols),
                         sharex='col', sharey=False)

# ensure axes is 2D ndarray
axes = np.atleast_2d(axes)

for i, di in enumerate(d):
    for j in range(ncols):
        ax = axes[i, j]

        if j < len(conds):
            cond = conds[j]
            _r_est = np.ravel(r_estimate[i, j, :])
            _r_sk = np.ravel(r_sketch[i, j, :])

            # compute common bins with fixed step 0.01
            step = 0.01
            minv = np.nanmin([_r_est.min() if _r_est.size else np.inf,
                              _r_sk.min() if _r_sk.size else np.inf])
            maxv = np.nanmax([_r_est.max() if _r_est.size else -np.inf,
                              _r_sk.max() if _r_sk.size else -np.inf])
            left = np.floor(minv / step) * step
            right = np.ceil(maxv / step) * step
            bins = np.arange(left, right + step / 2, step)

            sns.histplot(_r_est, bins=bins, kde=False, ax=ax,
                         label=r'Original: $\tau / \widetilde{\tau}$',
                         color='steelblue', stat='density', element='step')
            sns.kdeplot(_r_est, ax=ax, color='steelblue', linewidth=1.5)

            sns.histplot(_r_sk, bins=bins, kde=False, ax=ax,
                         label=r'Sketched: $\tau / \widetilde{\tau}_{sk}$',
                         color='orange', stat='density', element='step')
            sns.kdeplot(_r_sk, ax=ax, color='orange', linewidth=1.5)

            ax.axvline(x=1.0, color='green', linestyle='--', linewidth=0.8)
            ax.axvline(x=np.sqrt(2), color='red', linestyle='--', linewidth=0.8,
                       label=r'Bound ($\sqrt{2}$)')

            ax.set_title(r'$d = {}, \kappa(A) = 10^{{{}}}$'.format(int(di), int(np.log10(cond))))
            if j != 0:
                ax.yaxis.label.set_visible(False)
                ax.yaxis.set_tick_params(labelleft=False)

            if i == len(d) - 1:
                ax.set_xlabel('Ratio', fontsize=14)

            # only show legend in top-left
            if i == 0 and j == 0:
                ax.legend()

            if j == 0:
                label = ax.get_ylabel()
                ax.set_ylabel(label, fontsize=14)

    #     else:
    #         # last column: boxplot comparing methods across all conds for this d
    #         rows = []
    #         for cj, cond in enumerate(conds):
    #             est_vals = np.ravel(r_estimate[i, cj, :])
    #             sk_vals = np.ravel(r_sketch[i, cj, :])

    #             est_vals = est_vals[np.isfinite(est_vals)]
    #             sk_vals = sk_vals[np.isfinite(sk_vals)]

    #             cond_label = '{:.0e}'.format(float(cond)).replace('e+0', 'e').replace('e+', 'e').replace('e-0', 'e-')
    #             rows += [{'cond': cond_label, 'method': 'estimate', 'ratio': float(v)} for v in est_vals]
    #             rows += [{'cond': cond_label, 'method': 'sketch',   'ratio': float(v)} for v in sk_vals]

    #         if len(rows) == 0:
    #             ax.set_visible(False)
    #             continue

    #         df = pd.DataFrame(rows)
    #         order = [('{:.0e}'.format(float(c)).replace('e+0', 'e').replace('e+', 'e').replace('e-0', 'e-')) for c in conds]

    #         sns.boxplot(x='cond', y='ratio', hue='method', data=df,
    #                     order=order, ax=ax, palette=['C0', 'C1'],
    #                     width=0.45, fliersize=1.0, linewidth=0.6,
    #                     boxprops={'linewidth': 0.6},
    #                     whiskerprops={'linewidth': 0.5},
    #                     capprops={'linewidth': 0.5},
    #                     medianprops={'linewidth': 0.8})

    #         ax.axhline(1.0, linestyle='--', color='green', linewidth=0.8)
    #         ax.axhline(np.sqrt(2), linestyle='--', color='red', linewidth=0.8)

    #         ax.set_title(f'Boxplot (d = {int(di)})')
    #         ax.set_xlabel('Condition Number')
    #         if j == len(conds):
    #             ax.legend(loc='upper right', fontsize='small')

    #         ax.tick_params(axis='x', rotation=30)

    # # align y-limits across the histogram columns only
    # # leave the last column (boxplot) y-axis independent
    # hist_axes = [axes[i, jj] for jj in range(len(conds)) if axes[i, jj].get_visible()]
    # if hist_axes:
    #     y_mins = []
    #     y_maxs = []
    #     for ha in hist_axes:
    #         ymin, ymax = ha.get_ylim()
    #         y_mins.append(ymin)
    #         y_maxs.append(ymax)
    #     new_ylim = (min(y_mins), max(y_maxs))
    #     for ha in hist_axes:
    #         ha.set_ylim(new_ylim)

# fig.suptitle('Tightness of Backward Error Estimates for (m)TLS')

plt.tight_layout()
plt.savefig('figures/tightness.pdf')
plt.close(fig)
