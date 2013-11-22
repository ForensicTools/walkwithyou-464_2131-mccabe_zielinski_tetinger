#Currently Copied code from http://cheeky4n6monkey.blogspot.com/2012/02/diving-in-to-perl-with-geotags-and.html 
#That deals with the file processing

sub ProcessFilename
{
    my $filename = shift;

    if (-e $filename) #file must exist
    {
        my $exif = Image::ExifTool->new();
        # Extract all info from existing image
        if ($exif->ExtractInfo($filename))
        {
            # Ensure all 4 GPS params are present
            # ie GPSLatitude, GPSLatitudeRef, GPSLongitude, GPSLongitudeRef
            # The Ref values indicate North/South and East/West
            if ($exif->HasLocation())
            {
                my ($lat, $lon) = $exif->GetLocation();
                # Where the code turns it into a google url
                print("\n$filename contains Lat: $lat, Long: $lon\n");
                print("URL: http://maps.google.com/maps?q=$lat,+$lon($filename)&iwloc=A&hl=en\n");
                if ($htmloutput) # save GoogleMaps URL to global hashmap indexed by filename
                {
                    $file_listing{$filename} = "<A HREF = \"http://maps.google.com/maps?q=$lat,+$lon($filename)&iwloc=A&hl=en\"> http://maps.google.com/maps?q=$lat,+$lon($filename)&iwloc=A&hl=en</A>";
                }
# Can add 
use Browser::Open qw( open_browser );

my $url = "http://maps.google.com/maps?q=$lat,+$lon($filename)&iwloc=A&hl=en";
open_browser($url);

# Should open browser to cordiantes (though im still working on how to link them

