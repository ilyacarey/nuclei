//This macro will open a set of specified .oir files (confocal images with two channels) and make a composite of each. Helpful for manual counting.
//Assumptions:
	//files are called e.g. "image_000[n].oir", with only n changing between files and n>0 and n<999
	
	//files are stored in a folder called "day month treatment", e.g. "11 may Furamidine"
	
	//in the folder there is an information spreadsheet that stores information about files 
	//the information sheet has a column titled "File", with file numbers (i.e. 1-999) underneath. Any other columns are ignored. 
	//the information spreadsheet is a .csv file and is called "date info.csv" (e.g. "11 may info.csv"). Make sure you don't use CSV UTF-8 format.
	
	//the following plugin is installed: Olympus (https://imagej.net/formats/olympus) 
		
//to use this macro, you need to:
	// (1) specify the general directory of the files (you might not need to change this)
		general_directory="C:/Users/ilyai/Pictures/Camera Roll/Confocal microscopy/";
	// (2) specify date images were taken (i.e. start of folder name)
		date="17 august";
	// (3) specify treatment (i.e. rest of folder name)
		treatment="asyn in vitro";
		
//the rest of the script you don't need to change

//setting files directory
d1=general_directory+date+" "+treatment;
//setting info sheet directory (sheet has "File" column with numbers and "Treatment" column). Assumes it is called "[date] info.csv"
d2=general_directory+date+" "+treatment+"/"+date+" info.csv";	

//opening info sheet which stores which image corresponds to what treatment
Table.open(d2);
files=Table.getColumn("File");
treatments=Table.getColumn("Treatment");

//for loop to go through each file specified in the info sheet. n stores the number of the image, i its position in the sheet. 
for (i = 0; i < files.length; i++) {
    n=files[i];
	if (n<10) {m="_000";}
	else {m="_00";}
	if (n>99) {m="_0";}

	//opening images
	 if (n==0){	run("Viewer", "open=["+ d1 + "/image.oir]");}
	 else {run("Viewer", "open=["+ d1 + "/image"+ m + n +".oir]");}
	run("Make Composite");
}
