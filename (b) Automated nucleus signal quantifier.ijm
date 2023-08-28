//Just run this script - you don't necessarily need to change any code
//Parameters you could change:

//Size of nuclei (ROI) in pixels
nucleus_size = "350-Infinity";

//Circularity of nuclei (ROI) 
nucleus_circulatority = "0.50-1.00";

//What the script does:

//This macro will go through a set of specified .oir files (confocal microscopy images with two channels). 
//will return Excel file with "mean gray value" of each region of interest (ROI, i.e. nucleus) along with file number, treatment, batch date, and date image was taken
//this macro makes a few assumptions: 
	//files are called e.g. "image_000[n].oir", with only n changing between files and n>0 and n<999
	
	//there is an information spreadsheet that stores information about files 
	//the information sheet has three columns titled "File", "Treatment", "Batch", e.g. line 2 might be "2", "Furamidine 100uM", "22 March"
	//the information spreadsheet is a .csv file. Make sure you don't use CSV UTF-8 format.
	
	//the following plugins are installed: Olympus (https://imagej.net/formats/olympus) and Read and write excel (https://imagej.net/plugins/read-and-write-excel)
	
//results file has columns "Label" (treatment), "Mean" (mean gray area of a nucleus), "File" (number between 1 and 999), "Date" (when images taken), "Batch" 
//note that a new results file is made if there isn't one already, and if there is an existing data file with the same name and location, it will be deleted. 
	
//results can be plotted nicely in R script (see github/ilyacarey). 

//telling user about script
waitForUser("This script will measure and export the fluorescence signal per nucleus from confocal immunofluorescence microscopy images,\nusing channel 2 to identify nuclei and channel 1 to measure pixel density.\n \nThis is a measure of DNA replication per nucleus (for either in vitro or in vivo reactions) \n \nYou need the Olympus plugin and the Read and Write Excel plugin\nYou can adjust parameters (e.g. nucleus size) in the code.");

//asking for directory of images
waitForUser("Select the folder with the images");
images_directory=getDir("Select the folder with the images");

//asking for directory of information spreadsheet
waitForUser("Select the .csv file with information about the images \n \nThe file has three columns titled 'File', 'Treatment, 'Batch', \n \nFor example, an entry for the second image may be '2', 'Furamidine 100uM', '22 March'");
info_directory=File.openDialog("Select information spreadsheet");

//naming output Excel file
output = getString("Name output file", "data");
output_directory = images_directory+"/"+output+".xlsx]";

//asking for date images were taken
full_date = getString("What date were the images taken? e.g. 22 November 2022.\nThis will be added to the data when exported", "default");

//stop images from popping up (makes script run faster)
setBatchMode(true);

//opening excel file where results are to be stored
run("Read and Write Excel", "file_mode=read_and_open file=["+output_directory);

//making sure there's no data waiting to be queued already by deleting existing results + deleting output file of same name if it exists
run("Read and Write Excel", "file_mode=write_and_close");
File.delete(images_directory+"/"+output + ".xlsx");
run("Clear Results");
run("Read and Write Excel", "file_mode=read_and_open file=["+output_directory);

//opening info sheet which stores which image corresponds to what treatment
Table.open(info_directory);
files=Table.getColumn("File");
treatments=Table.getColumn("Treatment");
batches=Table.getColumn("Batch");

//progress bar
 title = "[Progress]";
 run("Text Window...", "name="+ title +" width=30 height=2 monospaced");
   function getBar(p1, p2) {
        n = 20;
        bar1 = "--------------------";
        bar2 = "********************";
        index = round(n*(p1/p2));
        if (index<1) index = 1;
        if (index>n-1) index = n-1;
        return substring(bar2, 0, index) + substring(bar1, index+1, n);
  }

//for loop to go through each file specified in the info sheet. n stores the number of the image, i its position in the sheet. 
for (i = 0; i < files.length; i++) {
    n=files[i];
	if (n<10) {m="_000";}
	else {m="_00";}
	if (n>99) {m="_0";}
	
	//progress bar
	print(title, "\\Update:"+i+"/"+files.length+" ("+(i*100)/files.length+"%)\n"+getBar(i, files.length));

	//opening images
	 run("Viewer", "open=["+ images_directory + "/image"+ m + n +".oir]");

	//splitting into red and green
	run("Split Channels");
	selectWindow("C2-image"+m + n +".oir Group:1 Level:1 Area:1");

	//blur to improve watershed later
	run("Gaussian Blur...", "sigma=3");

	//converting into black and white
	setAutoThreshold("Default dark");
//	setThreshold(1000, 65535); //you could choose to specify the threshold settings. Works well with auto threshold. 
	setOption("BlackBackground", false);
	run("Convert to Mask");

	//filling holes in nuclei
	run("Fill Holes");

	//watershed to split touching nuclei
	run("Watershed");

	//setting settings so that green channel signal is measured
	run("Set Measurements...", "mean display redirect=[C1-image"+m + n +".oir Group:1 Level:1 Area:1] decimal=3");

	//counting particles in red channel
	run("Analyze Particles...", "size=nucleus_size pixel circularity=nucleus_circularity display");
	
	//adding treatment and other metadata for each nucleus
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

//progress bar
 print(title, "\\Close");

//telling user script is done
waitForUser("The script is finished.\n\nExported results are here:\n\n"+ images_directory + output+".xlsx");
