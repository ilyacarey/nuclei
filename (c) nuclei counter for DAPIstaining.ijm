//This scrippt will count the number of nuclei in images and measure the size of each nucleus too
//to use this macro, you need to:
	// (1) specify the general directory of the files (you might not need to change this)
		general_directory="C:/Users/ilyai/Pictures/Camera Roll/Confocal microscopy/in vivo/";
	// (2) specify date images were taken (i.e. start of folder name)
		date="5 august";
		
	// (3) have installed Read and write excel plugin (https://imagej.net/plugins/read-and-write-excel)
	// (4) in the folder there is an information spreadsheet that stores information about files 
		//the information sheet has two columns titled "File" and "Treatment",  e.g. line 2 might be "2", "Furamidine 100uM"
		//the information spreadsheet is a .csv file and is called "date info.csv" (e.g. "11 may info.csv"). Make sure you don't use CSV UTF-8 format.
	
//stop images from popping up
setBatchMode(true);

//setting files directory
d1=general_directory+date;
//setting info sheet directory (sheet has "File" column with numbers and "Treatment" column). Assumes it is called "[date] info.csv"
d2=general_directory+date+"/"+date+" info.csv";	
//setting output file 
d3=general_directory+date+"/"+date+ " data.xlsx]";

//opening excel file where results are to be stored
run("Read and Write Excel", "file_mode=read_and_open file=["+d3);
	
//opening info sheet which stores which image corresponds to what treatment
Table.open(d2);
files=Table.getColumn("File");
treatments=Table.getColumn("Treatment");

//for loop to go through each file specified in the info sheet. n stores the number of the image, i its position in the sheet. 
for (i = 0; i < files.length; i++) {
    n=files[i];
	if (n<10) {m="img_00000000";}
	else {m="img_0000000";}
	if (n>99) {m="img_000000";}

	//opening images
	
	 if (n==0){	open(d1+"/"+"img_000000000_Default0_000.tif");}
	 else {open(d1+"/"+ m + n + "_Default_000.tif");}
	 
	//blur to improve watershed later
	run("Gaussian Blur...", "sigma=3");	 
	
	//converting into black and white
	setAutoThreshold("Default dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	
	//filling holes in nuclei
	run("Fill Holes");

	//watershed to split touching nuclei
	run("Watershed");
	
	//setting settings so that green channel signal is measured
	run("Set Measurements...", "area display redirect=None decimal=3");

	//counting particles in red channel
	run("Analyze Particles...", "size=500-Infinity circularity=0.60-1.00 display");
	
	//adding treatment label for results
	for (q=0; q<nResults; q++) {
		setResult("Label", q , treatments[i]);
		setResult("File", q , n);
		setResult("Date", q , date);
	}
	//extracting results and queing them
	run("Read and Write Excel", "file_mode=queue_write no_count_column stack_results dataset_label=[ ]");
	run("Clear Results");

	//closing windows
	if (n==0){	close("img_000000000_Default0_000.tif");}
	else {close( m + n + "_Default_000.tif");}
}
//saving queued results
run("Read and Write Excel", "file_mode=write_and_close");
