//This macro will go through a set of specified .oir files (confocal images with two channels). 
//will return excel file with "mean gray value" of each region of interest (ROI, i.e. nucleus) along with file number, treatment, batch date, and date image was taken
//this macro makes a few assumptions: 
	//files are called e.g. "image_000[n].oir", with only n changing between files and n>0 and n<999
	
	//files are stored in a folder called "day month treatment", e.g. "11 may Furamidine"
	
	//in the folder there is an information spreadsheet that stores information about files 
	//the information sheet has three columns titled "File", "Treatment", "Batch", e.g. line 2 might be "2", "Furamidine 100uM", "22 March"
	//the information spreadsheet is a .csv file and is called "date info.csv" (e.g. "11 may info.csv"). Make sure you don't use CSV UTF-8 format.
	
	//the following plugins are installed: Olympus (https://imagej.net/formats/olympus) and Read and write excel (https://imagej.net/plugins/read-and-write-excel)
	
	//results file is called "date treatment data.xlsx" (e.g. "11 may furamidine data.xlsx") 
	//results file has columns "Label" (treatment), "Mean" (mean gray area of a nucleus), "File" (number between 1 and 999), "Date" (when images taken), "Batch" 
	//note that a new results file is made if there isn't one already, but results will be added to one if there already is one of the same name. 
	
	//results can be plotted nicely in R script (see github). 
	
//to use this macro, you need to:
	// (1) specify the general directory of the files (you might not need to change this)
		general_directory="C:/Users/ilyai/Pictures/Camera Roll/Confocal microscopy/";
	// (2) specify date images were taken (i.e. start of folder name)
		date="11 may";
	// (3) specify treatment (i.e. rest of folder name)
		treatment="furamidine + DB867"
	// (4) specify the complete date the images were taken (to add to outputted spreadsheet)
		full_date="11 May 2022";
		
//the rest of the script you don't need to change

//setting files directory
d1=general_directory+date+" "+treatment;
//setting info sheet directory 
d2=general_directory+date+" "+treatment+"/"+date+" info.csv";
//setting output file 
d3=general_directory+date+" "+treatment+"/"+date+" "+treatment+" data.xlsx]";
		
//stop images from popping up
setBatchMode(true);

//opening excel file where results are to be stored
run("Read and Write Excel", "file_mode=read_and_open file=["+d3);

//opening info sheet which stores which image corresponds to what treatment
Table.open(d2);
files=Table.getColumn("File");
treatments=Table.getColumn("Treatment");
batches=Table.getColumn("Batch");

//for loop to go through each file specified in the info sheet. n stores the number of the image, i its position in the sheet. 
for (i = 0; i < files.length; i++) {
    n=files[i];
	if (n<10) {m="_000";}
	else {m="_00";}
	if (n>99) {m="_0";}

	//opening images
	 run("Viewer", "open=["+ d1 + "/image"+ m + n +".oir]");

	//splitting into red and green
	run("Split Channels");
	selectWindow("C2-image"+m + n +".oir Group:1 Level:1 Area:1");

	//blur to improve watershed later
	run("Gaussian Blur...", "sigma=3");

	//converting into black and white
	setAutoThreshold("Default dark");
	setThreshold(1000, 65535);
	setOption("BlackBackground", false);
	run("Convert to Mask");

	//filling holes in nuclei
	run("Fill Holes");

	//watershed to split touching nuclei
	run("Watershed");

	//setting settings so that green channel signal is measured
	run("Set Measurements...", "mean display redirect=[C1-image"+m + n +".oir Group:1 Level:1 Area:1] decimal=3");

	//counting particles in red channel
	run("Analyze Particles...", "size=500-Infinity pixel circularity=0.50-1.00 display");
	
	//adding treatment label for results
	for (q=0; q<nResults; q++) {
		setResult("Label", q , treatments[i]);
		setResult("File", q , n);
		setResult("Date", q , full_date);
		setResult("Batch", q , batches[i]);
		}

	//extracting results and queing them
	run("Read and Write Excel", "file_mode=queue_write no_count_column stack_results dataset_label=[ ]");
	run("Clear Results");

	//closing windows
	selectWindow("C2-image"+ m + n +".oir Group:1 Level:1 Area:1");
	close();
	selectWindow("C1-image"+ m + n +".oir Group:1 Level:1 Area:1");
	close();
}
//saving queued results
run("Read and Write Excel", "file_mode=write_and_close");
