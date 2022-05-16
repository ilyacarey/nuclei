# nuclei
ImageJ scripts for: 

(a) batch opening confocal files with two channels and merging them and 

(b) for a batch of confocal images with two channels, identifying nuclei as ROIs using one channel and quantifying the mean pixel intensity of each ROI using the other channel, and outputting results in Excel. 

Requirements and assumptions are in comments at top of scripts.


Script (b) based on https://www.unige.ch/medecine/bioimaging/files/3714/1208/5964/CellCounting.pdf

Summary of script (b) operations: isolate second channel;
apply a Gaussian blur (Sigma = 3) to improve nuclei identification; 
convert image to greyscale (thresholds of 1000 and 65535); 
fill holes in nuclei; 
apply watershed function to separate touching nuclei; 
identify individual nuclei as regions of interest (ROIs) using the Analyse Particles function (size>500 pixel units, circularity 0.5-1); 
overlay the ROIs onto the corresponding first channel image and quantify the “mean gray value” (dig-dUTP uptake) per ROI; 
export results to an Excel file using a plugin (https://imagej.net/plugins/read-and-write-excel).
