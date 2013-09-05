 # perl MODEL.pl 

use DBI;
use Text::CSV;
use Date::Format;


my $header_path = "D:\\FP_ThickScan\\Data\\aPanelHeader.csv"; 			# Contains Panel header Info
#print "\n\n$header_path\n\n";
my @header; 
@header = &field_to_array($header_path);  #Convert the file array.
#print "\nPanel Sample: $header[0][0] $header[0][1] $header[0][2] $header[0][3] $header[0][4] \n";

my $count = $ARGV[0];
my $recipe_number = $header[0][0];
my $nominal_thickness = $header[0][1];
my $target_thickness = $header[0][2];
my $panel_number = $header[0][3];
my $number_samples = $header[0][4];
my $recipe_desc = $header[0][5];

#print "\n Panel Numer: $panel_number\n";

my $panel_path = "D:\\FP_ThickScan\\Data\\aPanel"  . "$panel_number" . ".csv"; 			# Raw Panel Data Contains All 3 Tracks
#print "\n\n$panel_path\n\n";
my @panel; 
@panel = &field_to_array($panel_path);  #Convert the file to an 3 element array.
#print "\nPanel Sample: $panel[0][1]\n";



@date =localtime(time);
# "yyyy-MM-ddTHH:mm:ss.fff"
$date_string =  strftime("%Y-%m-%dT%H:%M:%S.000",@date);


$track1_average = &calc_average(1);  #Track number ONE
$track2_average = &calc_average(2);  #Track number TWO
$track3_average = &calc_average(3);  #Track number THREE

$panel_average = sprintf("%.3f",($track1_average + $track2_average +  $track3_average)/3);

#print "\nNominal Thickness: $nominal_thickness Target Thickness: my $target_thickness Opening: $panel_number\n";
#print "\nAverage: Trk1: $track1_average Trk2: $track2_average Trk3: $track3_average Pnl: $panel_average Samples: $number_samples\n\n";


if ($count >= 200)
{
&delete_records();
}
else
{
&insert_record();
}


sub calc_average() {

my $index = 0;
my $sum = 0;

my $average = 0;
my $track_number = $_[0] - 1;

while ($index < $number_samples){

	
	$sum = $sum + $panel[$track_number][$index] ;
	#print "\nSum: $index $sum $panel[$track_number][$index]\n"  ;
	$index++;
}
  
$average = sprintf("%.3f",$sum/$number_samples);
$track_number = $track_number + 1;


$average;

}

sub field_to_array(){ #Subroutine to get the values into an array by itself

my $in_file = $_[0];
my @field;
my $csv=Text::CSV->new(); 	    				#Creates a new Text::CSV object
my $field_index = 0;

open(INFILE,$in_file) || die "Can't open file $input";

while (<INFILE>) {



	$csv->parse($_);

	my @fields=$csv->fields;  # puts the values from each field in an array
	my $elements=@fields;     #gets the number of elements in the array
	#print "\nNumber Elements: $elements \n";
	for ($csv_index=0;$csv_index<$elements;$csv_index++) {
  
		$field[$field_index][$csv_index] = $fields[$csv_index];
		#print "\n$field[$csv_index]\n";
	
    }
	#print "\nField: $field[$field_index][100]\n";
	$field_index= $field_index+1;

  }


close INFILE;	

@field;
}

sub delete_records(){
	
my $dsn = 'DBI:ODBC:Driver={SQL Server}';
my $host = 'xxx.x.x.xx,1433';  #Model Server in Lab
my $database = 'XXXOnline';
my $user = 'xxxonline';
my $auth = 'xxxonline';
# Connect via DBD::ODBC by specifying the DSN dynamically.
my $dbh = DBI->connect("$dsn;Server=$host;Database=$database",$user,$auth,{ RaiseError => 1, AutoCommit => 1}
) || die "Database connection not made: $DBI::errstr";

my $sql0 = "DELETE FROM Thickness";
my $sql1 = "\nDELETE FROM RawData";
#print "$sql0 $sql1";

#Prepare the statement
my $sth = $dbh->prepare( $sql0 . $sql1);
#Execute the statement
$sth->execute();

$sth->finish();
$dbh->disconnect();
}

sub insert_record(){

my $dsn = 'DBI:ODBC:Driver={SQL Server}';
my $host = 'xxx.x.x.xx,1433';  #Model Server in Lab
my $database = 'XXXOnline';
my $user = 'xxxonline';
my $auth = 'xxxonline';
# Connect via DBD::ODBC by specifying the DSN dynamically.
my $dbh = DBI->connect("$dsn;Server=$host;Database=$database",$user,$auth,{ RaiseError => 1, AutoCommit => 1}
) || die "Database connection not made: $DBI::errstr";

my $sql0 = "\nINSERT RawData(DateTime,DataBaseEntryDateTime,NominalThickness,TargetThickness,Opening,NumberOfSamples,AverageThickOperator,AverageThickCenter,AverageThickBack,AverageThick) 
VALUES (\'" . $date_string  . "\',GETDATE()" . "," . $nominal_thickness . "," . $target_thickness . "," . $panel_number . "," . $number_samples . "," . 
$track3_average . "," . $track2_average . "," . $track1_average . "," . 
$panel_average . ")";
#print "$sql0";

my $sql1 = "\nDECLARE \@myScope INT SET \@myScope =  SCOPE_IDENTITY();SELECT \@myScope\n";
#print "$sql1";



#Prepare the statement
my $sth = $dbh->prepare( $sql0 . $sql1);
#Execute the statement
$sth->execute();

# get the row id from the last insert so we can insert the track data
$last_scope_id = $sth -> fetchrow_array();
#print  "\nScope ID:$last_scope_id ";
$sth->finish();

# Insert Each Track for each panel
my $index=0;
while ($index < 119){
	$sql2 = $sql2 . "INSERT Thickness(ThicknessID, RawDataID, ThickOperator, ThickCenter, ThickWall) VALUES(" . $index  . "," .  $last_scope_id  . "," .  $panel[2][$index]  . "," . $panel[1][$index]  . "," . $panel[0][$index] . ")\n";
	
$index++;
}

#print "$sql2";
#Prepare the statement
my $sth = $dbh->prepare($sql2);
#Execute the statement
$sth->execute();


#Close the connection
$sth->finish();
$dbh->disconnect();

}
