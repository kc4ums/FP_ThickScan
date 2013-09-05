use DBI;

my $press_product_id = 'C:\FP_ThickScan\Data\PressProductID.txt'; 			# Press Product ID From SQL Server

my $dsn = 'DBI:ODBC:Driver={SQL Server}';
my $host = 'xxx.x.x.x,1433';
my $database = 'Runtime';
my $user = 'sa';
my $auth = 'sa';
# Connect via DBD::ODBC by specifying the DSN dynamically.
my $dbh = DBI->connect("$dsn;Server=$host;Database=$database",$user,$auth,{ RaiseError => 1, AutoCommit => 1}
) || die "Database connection not made: $DBI::errstr";

my $sql = "SELECT Value FROM v_AnalogLive WHERE TagName = 'hPressProductID'";
my $sth = $dbh->prepare( $sql );
#Execute the statement
$sth->execute();
			
my($value);
# Bind the results to the local variables
$sth->bind_columns(\$value);

#Retrieve values from the result set
while( $sth->fetch() ) {
$value = sprintf("%u", $value);

}
#Close the connection
$sth->finish();
$dbh->disconnect();

open OUTFILE, ">$press_product_id";
print  OUTFILE "$value\n";
print   "Product ID from SQL Server (SAM): $value\n";
close OUTFILE;
