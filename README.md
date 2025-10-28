# SPARQL Engine Evaluation: Reproducibility Materials

This repository contains configuration and experiment files for reproducing the [`Master Thesis`](https://ad-publications.cs.uni-freiburg.de/theses/) results using [`qlever-control`](https://github.com/ad-freiburg/sparql-engine-evaluation-tanmay/tree/all-new-engines), a Python-based CLI tool.  
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

## 3. Visualizing Existing Thesis Experiment Results

To inspect the results generated for the Master’s thesis without rerunning the complete experiments, the evaluation web application can be launched directly from the repository root as follows:

```bash
qlever serve-evaluation-app --results-dir thesis_materials/evaluation_results/
```

This command starts a local web application that becomes available at:
`http://localhost:8000`

Optional flags for customizing the host address and port are also supported:
```bash
qlever serve-evaluation-app --results-dir thesis_materials/evaluation_results/ --host <HOSTNAME> --port <PORT>
```

## 4. Pre-Experiment Setup

Before running any experiments, the following setup steps are required to ensure all dependencies and datasets are correctly prepared.

### 4.1. Build the SP²Bench Docker Image

The SP²Bench dataset generator requires a Docker image to run. The `Dockerfile` and `entrypoint.sh` are in `thesis_materials/benchmarks/sp2bench/docker/` directory. Build it locally from the repository root as follows:

```bash
docker build -t sp2bench:1.01 --platform linux/386 --build-arg UID=$(id -u) --build-arg GID=$(id -g) thesis_materials/benchmarks/sp2bench/docker/
```

### 4.2. Configure Benchmark Qleverfiles and Execution Environment

Each Qleverfile in `thesis_materials/Qleverfiles/` specifies the parameters needed to retrieve the dataset for the benchmark, index and serve the SPARQL endpoint for all the engines. 
By default, all Qleverfiles are configured to use the **native index and server binaries** of their respective SPARQL engines.  
These binaries must be available on the system `PATH`.

#### Installing Native Engine Binaries

To install the required binaries, refer to the official repositories or release pages:

- **QLever** — [https://github.com/ad-freiburg/qlever](https://github.com/ad-freiburg/qlever)  
- **MillenniumDB** — [https://github.com/MillenniumDB/MillenniumDB](https://github.com/MillenniumDB/MillenniumDB)  
- **Virtuoso** — [https://github.com/openlink/virtuoso-opensource/releases/](https://github.com/openlink/virtuoso-opensource/releases/)  
- **Blazegraph** — [https://github.com/blazegraph/database](https://github.com/blazegraph/database)  
- **GraphDB (Free version)** — [https://www.ontotext.com/products/graphdb/download/](https://www.ontotext.com/products/graphdb/download/)  
- **Apache Jena** — [https://jena.apache.org/download/index.cgi](https://jena.apache.org/download/index.cgi)  
- **Oxigraph** — [https://github.com/oxigraph/oxigraph/releases/](https://github.com/oxigraph/oxigraph/releases/)

> [!NOTE]  
>To run experiments with **Ontotext GraphDB**, a free license is needed:
>- Visit the [GraphDB Free License page](https://www.ontotext.com/products/graphdb/) and generate a license file.
>- Download the license file. This license file is needed when starting the server for GraphDB.

#### Using Containerized Systems (Optional)

If a **container-based** setup is preferred instead of native binaries, modify the Qleverfiles to use Docker or Podman by updating the `SYSTEM` field:
`SYSTEM = docker` or `SYSTEM = podman`.

The `SYSTEM` field of all the Qleverfiles can be updated simultaneously with the following command:
```bash
sys="docker"  # or podman
for f in thesis_materials/Qleverfiles/Qleverfile*; do
  sed -i -E "s/^SYSTEM[[:space:]]*=[[:space:]]*.*/SYSTEM = ${sys}/" "$f"
done
```

> [!NOTE]
>Even with containerized execution for **Ontotext GraphDB**, a free license is needed!

#### Moving the Benchmark Qleverfiles

Once the Qleverfiles are properly configured, they must be moved into the qlever-control submodule so that the engine-specific wrapper scripts (`<qengine>`) can locate and use them:
```bash
cp thesis_materials/Qleverfiles/* qlever-control/src/qlever/Qleverfiles/
```

## 5. Running the Experiments

For the evaluation, multiple synthetic and real-world benchmarks (in total 8 benchmarks) are executed to compare the performance and scalability of SPARQL engines at three dataset scales: **small** (~50 million triples), **medium** (~500 million triples), and **large** (~8 billion triples).
Each scale defines a set of **benchmarks**, along with Qleverfiles and query workloads that determine how endpoints are set up and benchmarks are executed.
However, not all benchmarks require building a new index. Two of the benchmarks reuse an index from another benchmark at the same scale, but run a distinct query workload.
This means that although 8 benchmarks are executed, only 6 index builds are required.

### 5.1. Benchmark Overview Across All Scales

| SCALE  | BENCHMARK                      | BENCHMARK_ID          | INDEX_CONFIG_NAME     | QUERIES_FILE                               | SERVER_MEMORY | TIMEOUT |
|:-------|:-------------------------------|:----------------------|:--------------------  |:-------------------------------------------|:--------------|:--------|
| Small  | Sp²Bench                       | sp2bench-small        | sp2bench-small        | `sp2bench.small.queries.yaml`              | 16G           | 60s     |
| Small  | Watdiv                         | watdiv-small          | watdiv-small          | `watdiv.small.queries.yaml`                | 16G           | 60s     |
| Small  | Sparqloscope (SP²Bench)        | sp2b-spqscope-small   | sp2bench-small        | `sp2bench-sparqloscope.small.queries.yaml` | 16G           | 60s     |  
| Medium | Sp²Bench                       | sp2bench-medium       | sp2bench-medium       | `sp2bench.medium.queries.yaml`             | 32G           | 180s    | 
| Medium | Watdiv                         | watdiv-medium         | watdiv-medium         | `watdiv.medium.queries.yaml`               | 32G           | 180s    | 
| Medium | Sparqloscope (DBLP)            | dblp-medium           | dblp-medium           | `dblp.medium.queries.yaml`                 | 32G           | 180s    | 
| Large  | Sparqloscope (Wikidata-truthy) | wikidata-truthy-large | wikidata-truthy-large | `wikidata-truthy.large.queries.yaml`       | 64G           | 300s    | 
| Large  | WDBench                        | wdbench-large         | wikidata-truthy-large | `wdbench.large.queries.yaml`               | 64G           | 300s    | 

The `BENCHMARK_ID` uniquely identifies the benchmark and its query workload execution.

The `INDEX_CONFIG_NAME` corresponds to a Qleverfile configuration used to retrieve the dataset and build an index for a benchmark. It also determines the directory where the index files live. For benchmarks with the same `INDEX_CONFIG_NAME`, the index needs to be built only once and just the benchmark query workload differs.

The `QUERIES_FILE` specifies the query workload executed against that index. These files are located in `/thesis_materials/benchmarks` directory of the repo.

### 5.2. Directory Layout

Benchmark indexes must be stored on a **fast SSD**, outside the repository.

At a chosen location (denoted as `BASE_DIR` in the code section below), a directory is created for each SPARQL engine (denoted as `<ENGINE>` in the following instructions).  
Each engine directory contains a subdirectory for every benchmark configuration that requires index building.  
These subdirectories hold the benchmark dataset, generated index and index/server logs.

An empty directory called `eval_results` is created inside the `BASE_DIR` to hold all the experiment benchmark results.

This structure can be generated automatically based on the available Qleverfiles:

```bash
# An empty SSD directory where all the experiment data would be stored
BASE_DIR=/path/to/experiments

# An empty directory to hold all the benchmark results
mkdir -p ${BASE_DIR}/eval_results

# All engines to evaluate
ENGINES=(qlever virtuoso mdb graphdb blazegraph jena oxigraph)

# Extract configuration names from Qleverfiles (e.g., Qleverfile.sp2bench-small → sp2bench-small)
INDEX_CONFIG_NAMES=$(cd thesis_experiments/Qleverfiles && ls Qleverfile.* | sed 's/^Qleverfile\.//')

# Create directories for each engine and index_config_name
for ENGINE in "${ENGINES[@]}"; do
  for INDEX_CONFIG_NAME in ${CONFIGS}; do
    mkdir -p ${BASE_DIR}/${ENGINE}/${INDEX_CONFIG_NAME}
  done
done
```

The directory layout would look like:
```bash
/path/to/experiments/
├── eval_results/
├── qlever/
│   ├── sp2bench-small/
│   ├── watdiv-small/
│   ├── sp2bench-medium/
│   ├── watdiv-medium/
│   ├── dblp-medium/
│   └── wikidata-truthy-large/
├── virtuoso/
│   ├── sp2bench-small/
│   ├── watdiv-small/
│   └── ...
└── ...
```

Once the directories are created, the setup for each benchmark and each SPARQL engine simply involves navigating into the corresponding `<ENGINE>/<INDEX_CONFIG_NAME>` folder and executing the appropriate `<qengine>` commands.

### 5.3. Building Indexes (only once per unique `INDEX_CONFIG_NAME`)

For each SPARQL engine:

```bash
# Navigate to the benchmark subdirectory for the SPARQL engine
cd /path/to/experiments/<ENGINE>/<INDEX_CONFIG_NAME>

# Generate the engine-specific Qleverfile for the benchmark
# --total-index-memory can be greater than SERVER_MEMORY from the table for faster indexing
# --total-index-memory and --total-server-memory arguments are not needed for qengine = qlever and qoxigraph
<qengine> setup-config <INDEX_CONFIG_NAME> --total-index-memory <SERVER_MEMORY> --total-server-memory <SERVER_MEMORY>

# Retrieve the dataset 
<qengine> get-data  

# Build index data-structures
<qengine> index     
```

### 5.4. Executing Benchmarks (one run per `BENCHMARK_ID`) 

For each SPARQL engine and benchmark:

```bash
# Navigate to the benchmark subdirectory for the SPARQL engine where the index was built
cd /path/to/experiements/<ENGINE>/<INDEX_CONFIG_NAME>

<qengine> start     # Start the engine server using the index
# qgraphdb start also requires an additional --license-filepath argument with the path to free GraphDB license file

<qengine> query     # Launch an example query for warmup

# Execute the benchmark query workload
<qengine> benchmark-queries --queries-yml /path/to/<QUERIES_FILE> --result-file <BENCHMARK_ID>.<ENGINE> --result-dir ../../eval_results

# If the benchmark execution is successful, stop the server before proceeding to the next benchmark-engine combination
<qengine> stop
```