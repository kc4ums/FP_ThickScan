$filename = "D:\\FP_ThickScan\\Data\\aPanelHeader.csv";
$previous_time = 0;
$count = 0;  # Number panels before purging RawDate table on EWSOnline

print "\n*********************************************";
print "\nThis program must be running for data";
print "\nto be logged to Model Server (Microsoft SQL)"; 
print "\n*********************************************\n";

while (1){
			
	($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks) = stat($filename);
	
	if ($mtime != $previous_time){
		#print "\nFile Change";
		my $command = "perl MODEL.pl " . $count;
		#print "\n$command";
		system($command);
		$previous_time = $mtime;
		$count++;
	}
	
	if ($count > 200){$count = 0};
	sleep 1;
	
        

};
