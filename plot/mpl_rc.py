"""
Import this module to apply the style at import time:

    import mpl_rc
"""
import matplotlib as mpl

_rc = {
    # Text / LaTeX
    'text.usetex': True,
    # 'text.latex.preamble' historically expects a list of preamble lines
    'text.latex.preamble': r'\usepackage{amsmath, amsfonts, amssymb}',

    # Font
    'font.family': 'serif',
    'font.serif': ['Computer Modern'],

    # Savefig
    'savefig.bbox': 'tight',
    'savefig.format': 'pdf',

    # Lines
    'lines.linewidth': 1.0,

    # Axes
    'axes.linewidth': 0.5,
    'axes.labelsize': 14,
    'axes.labelpad': 3.0,
    # 'axes.labelweight': 'normal',
    'axes.grid': True,
    'axes.grid.axis': 'y',
    'axes.titlesize': 14,
    'figure.titlesize': 20, # suptitle size

    # Grid
    'grid.linewidth': 0.2,

    # Ticks (x)
    'xtick.top': True,
    # 'xtick.bottom': True,
    # 'xtick.labeltop': False,
    # 'xtick.labelbottom': True,
    # 'xtick.major.size': 3,
    # 'xtick.minor.size': 1.5,
    'xtick.major.width': 0.3,
    # 'xtick.minor.width': 0.3,
    # 'xtick.major.pad': 2,
    # 'xtick.minor.pad': 2,
    # 'xtick.color': 'black',
    # 'xtick.labelcolor': 'inherit',
    'xtick.labelsize': 8,
    'xtick.direction': 'in',
    # 'xtick.minor.visible': True,
    # 'xtick.major.top': True,
    # 'xtick.major.bottom': True,
    # 'xtick.minor.top': False,
    # 'xtick.minor.bottom': False,
    # 'xtick.alignment': 'center',

    # Ticks (y)
    # 'ytick.left': True,
    'ytick.right': True,
    # 'ytick.labelleft': True,
    # 'ytick.labelright': False,
    # 'ytick.major.size': 3,
    # 'ytick.minor.size': 1.5,
    # 'ytick.major.width': 0.3,
    # 'ytick.minor.width': 0.3,
    # 'ytick.major.pad': 2,
    # 'ytick.minor.pad': 2,
    # 'ytick.color': 'black',
    # 'ytick.labelcolor': 'inherit',
    'ytick.labelsize': 8,
    'ytick.direction': 'in',
    # 'ytick.minor.visible': True,
    # 'ytick.major.left': True,
    # 'ytick.major.right': True,
    # 'ytick.minor.left': True,
    # 'ytick.minor.right': True,
    # 'ytick.alignment': 'center_baseline',

    # Legend
    'legend.loc': 'upper right',
    'legend.frameon': False,
    # 'legend.framealpha': 0.8,
    # 'legend.fancybox': True,
    # 'legend.markerscale': 1.0,
    'legend.fontsize': 10,

    # Figure
    # 'figure.figsize': (3.4, 2.55),
    'figure.dpi': 300,
    # 'figure.frameon': True,
}

mpl.rcParams.update(_rc)
