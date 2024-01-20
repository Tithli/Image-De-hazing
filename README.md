# Image-De-hazing
This repository contains MATLAB code for a dehazing algorithm based on non-local dehazing and airlight estimation. The primary script, main.m, serves as the entry point and demonstrates the usage of the non-local dehazing algorithm with airlight estimation.
# Introduction
The dehazing algorithm is designed to enhance hazy images by removing atmospheric effects. It combines non-local dehazing, which considers similarities between patches in the image, with an airlight estimation method to improve visibility and clarity.
# Software Requirements
- MATLAB: Ensure that MATLAB is installed on your machine. The code for the image dehazing project is implemented in MATLAB.
- Image Processing Toolbox: The Image Processing Toolbox is required for various image processing functions used in the project. Make sure it is installed and accessible in your MATLAB environment.
# File Structure
- main.m: The main script that loads a hazy image, estimates the airlight, and applies non-local dehazing to generate a clear image.
- non_local_dehazing.m: The implementation of the non-local dehazing algorithm.
- estimate_airlight.m: The script for estimating the airlight in the input image.
- wls_optimization.m: Weighted least squares optimization used in the dehazing process.

# Non-local Dehazing
- The non_local_dehazing.m script implements the non-local dehazing algorithm. It takes a hazy image, estimates the airlight, and applies the dehazing process to generate a clear image.
- This is a technique used to remove haze or atmospheric scattering from images.
 It is based on the principle that the appearance of haze is influenced not only by local image information but also by non-local information from surrounding regions.
A high-level overview of the non-local image dehazing process:
- Preprocessing
- Estimate the Air Light
- Estimate the Transmission Map
- Perform Optimization
- Dehazing 

# Air-light Estimation
- The estimate_airlight.m script focuses on estimating the airlight in the input image. It utilizes clustering and voting mechanisms to find the most probable airlight values, contributing to the overall dehazing process.
- Airlight estimation involves estimating the color and intensity of the atmospheric light present in the scene.
 It represents the global illumination that reaches the camera without being affected by haze.
Some methods for airlight estimation are:
- Brightest Pixel
- Sky Region analysis
- Statistical Analysis
- Dark Channel Prior
# WLS Optimization
- In non-local dehazing, it is used to refine initial transmission map.
- Obtain more accurate estimation of the transmission values.


# Mathematical Model
Image dehazing can be mathematically modeled using the atmospheric scattering model:
$$I(x) = J(x)t(x) + A[1 − t(x)]$$
- I(x) - Observed hazy image
- J(x) - Clean image to be recovered
- t(x) - Transmission matrix
  $$𝑡(𝑥)=ⅇ^(−𝛽ⅆ(𝑥) )$$
- A – Airlight to be estimated, having 3 colour components (R, G, B)
- 𝛽 – Attenuation coefficient of the atmosphere
- d(x) – distance of the scene from pixel x
