# Face Detection Preprocessing on FPGA

[![Python](https://img.shields.io/badge/Python-3.12-blue)](https://www.python.org/)
[![Verilog](https://img.shields.io/badge/Verilog-FPGA-red)](https://www.xilinx.com/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Motivation](#motivation)
3. [Repository Structure](#repository-structure)
4. [Technical Details](#technical-details)
    - [Verilog Modules](#verilog-modules)
    - [FSM Design](#fsm-design)
    - [Sobel Edge Detection](#sobel-edge-detection)
    - [Thresholding](#thresholding)
5. [Workflow](#workflow)
    - [Generating Input Hex (`image.hex`)](#generating-input-hex-imagehex)
    - [FPGA Simulation](#fpga-simulation)
    - [Converting Output Hex (`out.hex`) to Image](#converting-output-hex-outhex-to-image)
    - [Colab Behavioral Simulation](#colab-behavioral-simulation)
6. [How to Run](#how-to-run)
7. [References](#references)
8. [License](#license)

---

## Project Overview

This project implements a **64×64 face image preprocessing pipeline on FPGA** using **Verilog HDL**. The pipeline performs:

- Grayscale image processing 
- **Sobel edge detection**
- Thresholding to produce binary edge images

The design is optimized for **Xilinx Zynq-7000 FPGA** with the goal of **real-time processing and low resource usage**. A behavioral Python simulation is also provided for testing without hardware.

---

## Motivation

Preprocessing images on FPGA is crucial for:

- Accelerating real-time computer vision applications
- Offloading computation from CPUs
- Edge detection for AI pipelines, face recognition, and robotics

This project demonstrates a complete **hardware-software co-design approach** from **Verilog RTL** to image reconstruction using **hex files**.

---

## Repository Structure

FaceDetection_FPGA/
│
├── verilog/
│ ├── face_preprocess.v # Top-level Verilog module
│ ├── sobel.v # Sobel filter module
│ ├── threshold.v # Threshold module
│ └── tb_face_preprocess.v # Testbench
│
├── hex_files/
│ ├── image.hex # Input grayscale image in hex
│ └── out.hex # FPGA output hex file
│
├── images/
│ ├── face.png # Original grayscale image
│ └── output.png # Processed edge-detected image
│
├── scripts/
│ ├── generate_image_hex.py # Python script to generate image.hex
│ ├── hex_to_image.py # Python script to convert out.hex → PNG
│ └── full_pipeline_colab.ipynb # Colab notebook for end-to-end workflow
│
├── vivado_project/
│ └── PREPROCESSING.xpr # Vivado project files (optional)
│
├── docs/
│ └── pipeline_diagram.png # Block diagram of preprocessing pipeline
│
├── README.md
└── .gitignore

---

## Technical Details

### Verilog Modules

1. **face_preprocess.v** — Top-level module controlling image processing.
    - Implements a **finite state machine (FSM)** for pixel-by-pixel processing.
    - Interfaces with input and output memory (`img_mem` and `out_mem`).

2. **sobel.v** — Implements 3×3 Sobel operator for edge detection.
    - Outputs edge intensity per pixel.

3. **threshold.v** — Converts Sobel output to binary image (0 or 1).
    - Simple thresholding for edge highlighting.

---

### FSM Design

- States: `IDLE`, `RUN`, `FINISH`
- **IDLE:** Waits for `start` signal.
- **RUN:** Iterates over the 64×64 image, applies Sobel + Threshold.
- **FINISH:** Writes last pixel and asserts `done` signal.

---

### Sobel Edge Detection

- Uses two kernels `Gx` and `Gy` to detect horizontal and vertical gradients.
- Edge magnitude calculated as:

\[
Edge = \sqrt{Gx^2 + Gy^2}
\]

- Result fed into threshold module.

---

### Thresholding

- Converts edge magnitude to binary output:
  - `1` → edge
  - `0` → background
- Threshold value adjustable (default 100).

---

## Workflow

### Generating Input Hex (`image.hex`)

- Python script `generate_image_hex.py` converts **64×64 grayscale PNG** → `image.hex`.
- Each pixel represented as **2-digit hexadecimal** for FPGA simulation.

### FPGA Simulation

1. Import `face_preprocess.v` and other Verilog modules in Vivado.
2. Run testbench `tb_face_preprocess.v`.
3. Simulation produces **`out.hex`**, representing processed edge image.

### Converting Output Hex (`out.hex`) to Image

- Python script `hex_to_image.py`:
  - Reads `out.hex`
  - Converts to **64×64 array**
  - Generates PNG for visualization

### Colab Behavioral Simulation

- `full_pipeline_colab.ipynb` provides:
  - Upload original image → auto-generate `image.hex`
  - Behavioral Sobel + threshold simulation → generates `out.hex`
  - Directly display processed image
- Allows testing **without Vivado or FPGA hardware**.

---

## How to Run

### Step 1: Generate Input Hex
python scripts/generate_image_hex.py
Step 2: FPGA Simulation

Open Vivado → create project → add verilog/ files → run tb_face_preprocess.v
OR use Colab notebook for simulation.

Step 3: Convert Output Hex to Image
python scripts/hex_to_image.py


Processed edge image saved as images/output.png.
