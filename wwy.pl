#!/usr/bin/perl

#Things to be achieved:
#++++warning alllll Psudocode

#1. Take in an Array of jpeg or png Files (command line entered) have abilit to enter a
#directory and use all files in directory


#2. sub to do a file crawl through direcotry and some way to tell whether attributes are files
#or directories

#3. pipe files to jhead and save data to files

#4. scan and seperate gps cordinates from file

#5. modify cordinate inforamtion to work for google maps (convert to decimal)


#----------------------------------------------------------
#6. create a bread crumb trail in google maps
#----------------------------------------------------------

#Code using files entered in command line

my @tmpArr;		#Temporary array for storing jhead information of a given file
my $cnt = 0;	#Counter to keep keep track of number of files read in
my @dates;		#Array for storing date photo was taken
my @latitudes;	#Array for GPS latitude of photo
my @longitudes;	#Array for GPS longitude of photo

#Populate date, latitude, and longitude arrays
foreach my $file (@ARGV) {
	#Read jhead information into temp array
	@tmpArr = `jhead $file`;
		
	#Place date, latitude, and longitude into respective arrays
	$date($cnt) = chomp($tmpArr(5)); 
	$latitude($cnt) = chomp($tmpArr(13));
	$longitude($cnt) = chomp($tmpArr(14));

	#Increment counter variable
	$cnt++;
}	
	
#Separate headers from data
for (my $count = 0; $count <= $cnt; $count++) {
	#Remove first 15 characters to isolate data
	$date($count) = substr($date($count), 15); 
	$latitude($count) = substr($latitude($count), 15);
	$longitude($count) = substr($longitude($count), 15);
}	
	
#Convert DMS format to decimal format	
for (my $count = 0; $count <= $cnt; $count++) {	
	#Temporary arrays to separate cardinal directions from coordinates
	my $latDir = substr($latitude($count), 0, 2);
	my $longDir = substr($longitude($count), 0, 2);
	my $tmpLat = substr($latitude($count), 2);
	my $tmpLong = substr($longitude($count), 2);
	
	#Separate degree, minute, and second values and remove letters (d, m, s)
	$tmpLat =~ tr/dms//d;
	$tmpLong =~ tr/dms//d;
	my @sepLat = split(/ /, $tmpLat);
	my @sepLong = split(/ /, $tmpLong);
	
	#Convert DMS to decimal
	$tmpLat = ($sepLat(2) / 60 + $sepLat(1)) / 60 + $sepLat(0);
	$tmpLong = ($sepLong(2) / 60 + $sepLong(1)) / 60 + $sepLong(0);
	
	#Append cardinal direction back to coordinates
	$latitude($count) = $latDir . $tmpLat;
	$longitude($count) = $longDir . $tmpLong;
}	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	