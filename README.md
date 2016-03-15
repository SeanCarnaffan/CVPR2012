INFO:
In this package, you find an updated version of the MATLAB code for following paper:
Martinel, N., & Micheloni, C. (2012). Re-identify people in wide area camera network. 
2012 IEEE Computer Society Conference on Computer Vision and Pattern Recognition Workshops (pp. 31–36). 
Providence, RI: IEEE. doi:10.1109/CVPRW.2012.6239203

MAIN PACKAGE FUNCTIONS:
- NM_reid_wcnwasa12_main.m : runs the main algorithm.
- NM_reid_wcnwasa12_init_parameters: initialize the parameters used by the algorithm.
	If you want to compute different results, for instance using more images to compute the dataset signatures and the query signatures.
	The input to this function are the datasetname and the test ID.
- NM_reid_wcnwasa12_load_dataset: loads the dataset that will be used for evaluating the algorithm.
	At the moment of writing this package, only the WARD dataset is handled, but you can easily tweak the code and add more datasets.
- NM_reid_wcnwasa12_compute_signature: compute the signatures for each person in the dataset.
- NM_reid_wcnwasa12_match_signature: matches the computed signatures and return the distances computed for all the used features.
- NM_reid_wcnwasa12_evaluate_matches: evaluates matches and compute statistics, i.e., ROC, SRR, AUC, nAUC.
- NM_reid_wcnwasa12_results: shows visual results.

ADDITIONAL TOOLBOX:
With this package some additional libraries used in the method are also provided.
Note that the algorithm works with the given libraries versions and it's not guaranteed to work with newer or older ones.
- Pyramid Histogram of Oriented Gradients (PHOG), Anna Bosch and Andrew Zisserman: http://www.robots.ox.ac.uk/~vgg/research/caltech/phog.html
- vlfeat: A. Vedaldi and B. Fulkerson, VLFeat: An Open and Portable Library of Computer Vision Algorithms: http://www.vlfeat.org/
- vlg: Taehee Lee, Vision Lab Geometry Library: http://vision.ucla.edu/vlg/

COMPILE:
Please note that some libraries contain mex-files that needs to be compiled for your machine.
We provide a limited set of binary within the package and they will be compile as you're running the main algorithm function.
If they would not be compiled, please referr to the function NM_setup_toolbox and  compile the required source codes.

BIBTEX:
@inproceedings{MarMicCVPR2012,
address = {Providence, RI},
author = {Martinel, Niki and Micheloni, Christian},
booktitle = {2012 IEEE Computer Society Conference on Computer Vision and Pattern Recognition Workshops},
doi = {10.1109/CVPRW.2012.6239203},
isbn = {978-1-4673-1612-5},
month = jun,
pages = {31--36},
publisher = {IEEE},
title = {{Re-identify people in wide area camera network}},
url = {http://ieeexplore.ieee.org/lpdocs/epic03/wrapper.htm?arnumber=6239203},
year = {2012}
}