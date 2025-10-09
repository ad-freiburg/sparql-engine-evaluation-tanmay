# SPARQL Engine Evaluation — Reproducibility Materials

This repository contains configuration and experiment files for reproducing results using [`qlever-control`](https://github.com/tanmay-9/qlever-control/tree/all-new-engines), a Python-based CLI tool.  
QLever-control is included as a **Git submodule** and pinned to a specific commit for reproducibility.

## 1. Clone the repository and initialize submodules

```bash
git clone https://github.com/ad-freiburg/sparql-engine-evaluation-tanmay.git
cd sparql-engine-evaluation-tanmay

# Initialize and checkout the submodule at the pinned commit
git submodule update --init --recursive
```

## 2. Install qlever-control using pipx

Download and install `pipx` from the [pipx website](https://pipx.pypa.io/latest/installation/) if not already installed on the system.

Then, install qlever-control from the submodule in editable mode:

```bash
pipx install -e ./qlever-control
```

This will install the following engine-specific wrapper scripts on the system:

```bash
qlever           # QLever
qvirtuoso        # Virtuoso
qmdb             # MillenniumDB
qgraphdb         # GraphDB
qblazegraph      # Blazegraph
qjena            # Apache Jena Fuseki
qoxigraph        # Oxigraph
```

From here on out, these engine-specific scripts would be collectively denoted as `<qengine>`.

## 3. Pre-Experiment Setup

Before running any experiments, the following setup steps are required to ensure all dependencies and datasets are correctly prepared.

### 3.1 Ontotext GraphDB License

If you intend to run experiments with **Ontotext GraphDB**, you need a free license:

1. Visit the [GraphDB Free License page](https://www.ontotext.com/products/graphdb/) and generate a license file.
2. Download the license file. This license file is needed when starting the server for GraphDB.

### 3.2 Build the SP²Bench Docker Image

The SP2Bench dataset generator requires a Docker image to run. The `Dockerfile` and `entrypoint.sh` are in `thesis_materials/benchmarks/sp2bench/docker/` directory. Build it locally from current working directory `sparql-engine-evaluation-tanmay` directory as follows:

```bash
docker build -t sp2bench:1.01 --platform linux/386 --build-arg UID=$(id -u) --build-arg GID=$(id -g) thesis_materials/benchmarks/sp2bench/docker/
```

### 3.3 Move benchmark Qleverfiles to the QLever-control submodule

For the engine-specific wrapper scripts `<qengine>` to locate the benchmark configurations, you must move the Qleverfiles from the thesis materials into the `qlever-control` submodule:

```bash
cp thesis_materials/Qleverfiles/* qlever-control/src/qlever/Qleverfiles/
```