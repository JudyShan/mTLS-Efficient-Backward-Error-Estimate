import numpy as np
from scipy.io import loadmat
import matplotlib.pyplot as plt
import mpl_rc

data = loadmat('artifacts/performance.mat')

conds            = np.squeeze(data['conds']).astype(float)
ds               = np.squeeze(data['ds']).astype(float)   
saved_r_sketch   = data['saved_r_sketch'] 
saved_r_simpler  = data['saved_r_simpler']

d_target = ds
i = int(np.where(ds == d_target)[0][0])

r_sketch  = saved_r_sketch[i, :, :]
r_simple  = saved_r_simpler[i, :, :]

ratio_sketch = 1.0 / r_sketch
ratio_simple = 1.0 / r_simple

def summarize(arr):
    median = np.median(arr, axis=1)
    q10    = np.percentile(arr, 10, axis=1)
    q90    = np.percentile(arr, 90, axis=1)
    return median, q10, q90

med_sketch, lo_sketch, hi_sketch = summarize(ratio_sketch)
med_simple, lo_simple, hi_simple = summarize(ratio_simple)

width_in_inch = 370.38374 * 1.5 / 72
fig, ax = plt.subplots(figsize=(width_in_inch, width_in_inch * 9/16))

ax.fill_between(conds, lo_sketch, hi_sketch,
                alpha=0.2, linewidth=0, label=None)
ax.plot(conds, med_sketch, '-o', linewidth=1.8,
        markerfacecolor='white', label='Sketch estimator')

ax.fill_between(conds, lo_simple, hi_simple,
                alpha=0.2, linewidth=0, label=None)
ax.plot(conds, med_simple, '-s', linewidth=1.8,
        markerfacecolor='white', label='Simple estimator')

ax.axhline(1.0, linestyle='--', linewidth=1.0, color='k')

ax.set_xscale('log')
ax.set_yscale('log')

ax.set_xticks(conds)
ax.set_xticklabels(
    [rf'$10^{{{int(np.round(np.log10(c)))}}}$' for c in conds], fontsize=14
)
ax.tick_params(axis='both', which='major', labelsize=14)

ax.set_xlabel(r'Condition number $\kappa(A)$', fontsize=14)
ax.set_ylabel('estimator / true value', fontsize=14)

ax.grid(True, which='both', linestyle=':', linewidth=0.5)
ax.legend(loc='upper left', fontsize=14)
fig.tight_layout()

fig.savefig('figures/accuracy_sketch_vs_simple.pdf')
