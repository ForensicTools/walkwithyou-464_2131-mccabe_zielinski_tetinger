#!/usr/bin/perl

#If user enters -v option give version and exit program
if ($ARGV[0] eq "-v") {
	print "This is version 1 of Walk With You\n";
	exit;
}

my $fileCnt = 0;			#Counter to keep keep track of number of files read in
my $optCnt = 0;				#Counter to keep keep track of number of options read in
my $argCnt = 0;				#Counter for number of arguments read in from command line
my @fileNames;				#Array to hold file names
my @dates;				#Array for storing date photo was taken
my @latitudes;				#Array for GPS latitude of photo
my @longitudes;				#Array for GPS longitude of photo
my @options;				#Array of options
my ($d, $o, $DMS) = (0) x 3;		#Variables to determine which options the user has called (0 = no and 1 = yes)
my $dir;				#Variable to hold name of directory containing images if -d option given
my $outFile;				#Variable to hold output file if -o option given

#Iterate through command line arguments to separate options from file(s) or directory
foreach (@ARGV) {
	#If the argument is preceded by a - than add it to the options array
	if ($ARGV[$argCnt] =~ /^[-]/) {
		$options[$optCnt] = $ARGV[$argCnt];
		$optCnt++;
	}

	#If the -d option is given then increment argument and option counters and read in the name of the directory 
	if ($ARGV[$argCnt] eq "-d") {
		$argCnt++;
		$optCnt++;
		$dir = $ARGV[$argCnt];
	}

	#If the -o option is given then increment argument and option counters and read in the name of the file 
	if ($ARGV[$argCnt] eq "-o") {
		$argCnt++;
		$optCnt++;
		$outFile = $ARGV[$argCnt];
	}

	#Increment argument counter
	$argCnt++;
}

#Look through options array to determine which options have been called
foreach my $opt (@options) {
	#If an option has been called set its corresponding variable to 1
	if($opt eq "-d") {
		$d = 1;
	}elsif($opt eq "-o") {
		$o = 1;
	}elsif($opt eq "-DMS") {
		$DMS = 1;
	}
}

#Sub to separate headers from data
sub separate {
	for (my $count = 0; $count < $fileCnt; $count++) {
		#Remove first 15 characters to isolate data
		$dates[$count] = substr($dates[$count], 15); 
		$latitudes[$count] = substr($latitudes[$count], 15);
		$longitudes[$count] = substr($longitudes[$count], 15);
	}		
}

#Sub to convert Decimal to DMS
sub convert {
	for (my $count = 0; $count < $fileCnt; $count++) {	
		#Temporary arrays to separate cardinal directions from coordinates
		my $latDir = substr($latitudes[$count], 0, 2);
		my $longDir = substr($longitudes[$count], 0, 2);
		my $tmpLat = substr($latitudes[$count], 2);
		my $tmpLong = substr($longitudes[$count], 2);
			
		#Separate degree, minute, and second values and remove letters (d, m, s)
		$tmpLat =~ tr/dms//d;
		$tmpLong =~ tr/dms//d;
		my @sepLat = split(/ /, $tmpLat);
		my @sepLong = split(/ /, $tmpLong);
			
		#Convert DMS to decimal
		$tmpLat = ($sepLat[2] / 60 + $sepLat[1]) / 60 + $sepLat[0];
		$tmpLong = ($sepLong[2] / 60 + $sepLong[1]) / 60 + $sepLong[0];
			
		#Append cardinal direction back to coordinates
		$latitudes[$count] = $latDir . $tmpLat;
		$longitudes[$count] = $longDir . $tmpLong;
	}
}	

#Sub to print the name of each file followed by its date taken, latitude, and longitude
sub print {
	#Print to specified file if -o option was given
	if($o == 1) {
		#Open the file for writing
		open (OUTFILE, ">$outFile");
		
		#Write the information to the file
		for (my $count = 0; $count < $fileCnt; $count++){
			print OUTFILE "$fileNames[$count]:\n";
			print OUTFILE "\tDate Taken = $dates[$count]\n";
			print OUTFILE "\tLatitude = $latitudes[$count]\n";
			print OUTFILE "\tLongitude = $longitudes[$count]\n";
		}
	
		#Close the file
		close (OUTFILE);	
	}
	elsif($o == 0) { #Print to stdout		
		for (my $count = 0; $count < $fileCnt; $count++){
			print "$fileNames[$count]:\n";
			print "\tDate Taken = $dates[$count]\n";
			print "\tLatitude = $latitudes[$count]\n";
			print "\tLongitude = $longitudes[$count]\n";
		}
	}
}

#If -d option is not given read files from command line
if($d == 0) {
	#Populate date, latitude, and longitude arrays
	for($count = $optCnt; $count < ($argCnt-1); $count++) {
		#Read jhead information into temp array
		my @tmpArr = `jhead $ARGV[$count]`;

		#Place file name, date, latitude, and longitude into respective arrays
		$fileNames[$fileCnt] = $ARGV[$count];
		$dates[$fileCnt] = $tmpArr[5]; 
		$latitudes[$fileCnt] = $tmpArr[(@tmpArr - 4)];
		$longitudes[$fileCnt] = $tmpArr[(@tmpArr -3)];	
		
		#Remove trailing newline character
		chomp $dates[$fileCnt];
		chomp $latitudes[$fileCnt];
		chomp $longitudes[$fileCnt];
		
		#Increment file counter 
		$fileCnt++;	
	}	
		
	#Call separate sub
	$separation;	

	#Call convert sub if DMS option was given	
	if($DMS == 1){
		&convert;	
	}
	
	#Call print sub
	&print;

}elsif ($d == 1) { #Read in files from specified directory
	#Open specified directory, read file names into the temporary array, and close the directory
	opendir DIR, $dir or die "Cannot open $dir\n";
	my @tmpFileNames = readdir DIR;
	closedir DIR;

	#Populate date, latitude, and longitude arrays
	foreach my $file (@tmpFileNames) {
		#Only look at files ending in .jpg
		if($file =~ /.jpg$/) {	
			#Read jhead information into temp array
			my @tmpArr = `jhead $file`;
	
			#Place file name, date, latitude, and longitude into respective arrays
			$fileNames[$fileCnt] = $file;
			$dates[$fileCnt] = $tmpArr[5]; 
			$latitudes[$fileCnt] = $tmpArr[(@tmpArr - 4)];
			$longitudes[$fileCnt] = $tmpArr[(@tmpArr - 3)];	

			#Remove trailing newline character
			chomp $dates[$fileCnt];
			chomp $latitudes[$fileCnt];
			chomp $longitudes[$fileCnt];
			
			#Increment file counter 
			$fileCnt++;	
		}
	}	
		
	#Call separate sub
	&separate;
			
	#Call convert sub if DMS option was given	
	if($DMS == 1){
		&convert;
	}
	
	#Call print sub
	&print;
}

























	
	
	