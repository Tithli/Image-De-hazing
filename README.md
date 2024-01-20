# Image-De-hazing
This repository contains MATLAB code for a dehazing algorithm based on non-local dehazing and airlight estimation. The primary script, main.m, serves as the entry point and demonstrates the usage of the non-local dehazing algorithm with airlight estimation.
# Introduction
The dehazing algorithm is designed to enhance hazy images by removing atmospheric effects. It combines non-local dehazing, which considers similarities between patches in the image, with an airlight estimation method to improve visibility and clarity.
# File Structure
-main.m: The main script that loads a hazy image, estimates the airlight, and applies non-local dehazing to generate a clear image.
-non_local_dehazing.m: The implementation of the non-local dehazing algorithm.
-estimate_airlight.m: The script for estimating the airlight in the input image.
-wls_optimization.m: Weighted least squares optimization used in the dehazing process.
