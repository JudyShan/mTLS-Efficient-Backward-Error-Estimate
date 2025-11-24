<!-- # EFFICIENT ESTIMATE FOR THE OPTIMAL BACKWARD ERROR OF THE MULTIDIMENSIONAL TOTAL LEAST SQUARES -->
# Efficient estimate for the optimal backward error of the multidimensional total least squares

This repository contains the code, experiments, and figure plotting scripts for the paper "Efficient estimate for the optimal backward error of the multidimensional total least squares".

The results and figures of the paper can be reproduced by running the scripts in the `experiments` folder in MATLAB, and the plotting scripts in the `plot` folder in Python.

## Running the experiments

### Environment setup

You will need MATLAB installed on your machine, or open the code in [MATLAB Online](https://matlab.mathworks.com/). To run all experiments, simply navigate to the base folder and run the following command to setup the environment in MATLAB command window:

```matlab
mkdir('artifacts'); % create folder to save results
mkdir('figures'); % create folder to save figures
mex src/sparsesign.c; % build the C code for sparse sign function
addpath(genpath(pwd)); % add all folders to path
```

and then setup the Python environment for plotting:

```bash
pip install -r plot/requirements.txt
```

### Running experiments

**Figure 1**: We plot the tightness of our estimate algorithm and efficient computation algorithm respectively. To run the experiments and generate the figure, run the following command in MATLAB command window:

```matlab
tightness;
```

and then run the plotting script in Python command line:

```bash
python plot/tightness.py
```

The figure will be saved as `figures/tightness.pdf`.

**Figure 2**: We compare the running time of the algorithm when varying the problem size, i.e., $m$, $n$, and $d$. To run the experiments and generate the figure, run the following command in MATLAB command window:

```matlab
complexity;
```

and then run the plotting script in Python command line:

```bash
python plot/complexity.py
```

The figure will be saved as `figures/complexity_runtime.pdf`.

**Figure 4**: We compare the tightness of our result and of a simpler estimation commonly used in Least Squares problems. To run the experiments and generate the figure, run the following command in MATLAB command window:

```matlab
performance;
```

and then run the plotting script in Python command line:

```bash
python plot/performance.py
```

The figure will be saved as `figures/accuracy_sketch_vs_simple.pdf`.

## Code explanation

The algorithms are implemented in files in the `src` folder. The main functions are:
- `sparse_sign.c`: C code for efficient computation of the sparse sign function. The code is directly copied from repository for [Iterative-Sketching-Is-Stable](https://github.com/eepperly/Iterative-Sketching-Is-Stable/blob/main/code/sparsesign.c).
- `random_tls_problem.m`: function to generate a random TLS problem instance, with specified dimensions and condition number.
- `solve_tls.m`: naive solution to the multidimensional TLS problem using SVD.
- `calculate_true_eta.m`: function to compute the true optimal backward error $\eta$ (formula (2.10) in the paper). We also calculate the optimized perturbation matrices $E$ and $F$ as provided by formula (2.13) and (2.14) in the paper, with optimized $M^\*$, $N^\*$, and $Y^\*$ plugged in.
- `estimate_eta.m`: function to calculate the estimate $\eta$. To be specific,
    + Estimation (not efficient enough) $\tau_{\theta}$ for TLS (formula (3.1)) and $\mu_{\theta}$ for mTLS (formula (3.3)) can be calculated by passing `'estimate'` to the fourth argument of `estimate_eta`.
    + Efficient sketch computation for TLS (provided by Algorithm 3.1) and mTLS (provided by Algorithm 3.2) can be calculated by passing `'sketch'` to the fourth argument of `estimate_eta`.


