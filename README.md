# UMBRA

# Deep Learning Detection of Exoplanet Transits in PSLS-Simulated PLATO Light Curves

[![MASS-UBMATF](https://img.shields.io/badge/MASS--UBMATF-Computational_Astrobiology_2026-blue)](https://master-mass.eu/)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.19715574.svg)](https://doi.org/10.5281/zenodo.19715574)

## Summary

When astronomers hunt for planets around other stars, they look for tiny, periodic
dips in brightness — a planet passing in front of its star blocks a fraction of the
light. ESA's upcoming PLATO mission will produce thousands of such "light curves,"
each with nearly a million measurements per star. Finding planets in this flood of
data is like searching for a needle in a haystack the size of a stadium.

This project compares two approaches: the classical **Box Least Squares (BLS)**
algorithm, which fits a box-shaped transit model at every possible orbital period,
and a **ResNet-1D convolutional neural network (CNN)** that learns transit patterns
directly from 1000 simulated PLATO light curves. The CNN correctly identifies
transits 96.7% of the time, outperforming BLS at 91.3%. Both methods are limited by
long-period planets where only one or two transits occur within the 267-day
observational window.

## Repo Contents

| File | What it is |
|---|---|
| `demo_bls.ipynb` | BLS pipeline on 100-file demo subset (runs ~1 minute) |
| `demo_cnn.ipynb` | CNN pipeline on 100-file demo subset (runs ~2 minutes) |
| `full_bls_results.ipynb` | BLS on full 1000-file dataset (outputs saved, do not re-run) |
| `full_cnn_results.ipynb` | CNN on full 1000-file dataset (outputs saved, do not re-run) |
| `dataset/` | 100-file demo subset with `metadata.csv` |
| `metadata.csv` | Full 1000-sample metadata (for reference) |
| `script/` | Bash scripts that generated the full dataset |
| `docs/` | Project report + student guide documents |

## Running the Demos

```bash
pip install -r requirements.txt
```

Then open `demo_bls.ipynb` or `demo_cnn.ipynb` in Jupyter and run
**Kernel → Restart & Run All**. Both notebooks complete in a few minutes on a
standard laptop CPU. The CNN demo trains a network from scratch on 80 samples;
no GPU required.
NOTE: Make sure to point the notebooks where the dataset is located.

## Full Dataset

The 1000-light-curve dataset (~33 GB, archived as ~11 GB zip) is available on
Zenodo:

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.19715574.svg)](https://doi.org/10.5281/zenodo.19715574)

Generated via `script/script.sh` using the PLATO Solar-like Light-curve
Simulator (PSLS). The `dataset/` folder in this repo contains a 100-file subset
identical to the first 50 transit and last 50 non-transit entries of the full
set — sufficient to run the demos end-to-end.

## Citation

If you use the dataset or code, please cite:

> Ul Abideen, Z. (2026). *PSLS-based computations for exoplanet transits*
> [Dataset]. Zenodo. https://doi.org/10.5281/zenodo.19715574
