# Dataset

The `sample/` folder contains 100 simulated PLATO light curves: 50 with transits
and 50 without. Each file is a gzipped two-column time series, and
`sample/metadata.csv.gz` lists the parameters used for every run. The sample is
about 1.1 GB and is enough to run both demo notebooks.

The full dataset of 1000 light curves is about 33 GB uncompressed. It is archived
on Zenodo as an 11 GB zip:

- DOI: [10.5281/zenodo.19715574](https://doi.org/10.5281/zenodo.19715574)

The files in this folder reproduce the dataset:

| File | Purpose |
|---|---|
| `psls.yaml` | PSLS configuration |
| `script.sh` | Batch script that generated the runs |

The full metadata table is in [`../Task04/metadata.csv`](../Task04/metadata.csv).

The data are released under [CC BY 4.0](../LICENSE-DATA).
