# nuclei
ImageJ scripts for: 

(a) batch opening confocal files with two channels and merging them and 

(b) for a batch of confocal images with two channels, identifying nuclei as ROIs using one channel and quantifying the mean pixel intensity of each ROI using the other channel, and outputting results in Excel. 

(c) analysing a batch of images and counting the number of nuclei as well as size. Can be used to measure e.g. cell proliferation after DAPI staining cells.

Requirements and assumptions are in comments at top of scripts.


Script (b) based on https://www.unige.ch/medecine/bioimaging/files/3714/1208/5964/CellCounting.pdf

Summary of script (b) operations: isolate second channel;
apply a Gaussian blur (Sigma = 3) to improve nuclei identification; 
convert image to greyscale (automatic thresholds);
fill holes in nuclei; 
apply watershed function to separate touching nuclei; 
identify individual nuclei as regions of interest (ROIs) using the Analyse Particles function (size>350 pixel units, circularity 0.5-1); 
overlay the ROIs onto the corresponding first channel image and quantify the “mean gray value” (dig-dUTP uptake) per ROI; 
export results to an Excel file using a plugin (https://imagej.net/plugins/read-and-write-excel).

Written for MPhil at Cambridge University in Krude Lab (2021-2022).
