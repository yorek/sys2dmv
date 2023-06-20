#
# Generate a batch file that loads all the sys2 
# objects into a target database
#

###############################################################################

#
# Script Variables
# (set before running the script)
#

# Target Server
$targetServer = "localhost"

# Database in which you want to create the sys2 objects
$targetDB = "AdventureWorks2012"

# Bat file that will be generated
$targetFile = "Z:\Work\SQL Scripts\sys2\load-sys2.bat";

# Where to look for the sys2 objects
$sourceFolder = "Z:\Work\SQL Scripts\sys2";

###############################################################################

#
# Generate Batch File
#

$files = Get-ChildItem $sourceFolder;

$payload = "@set sys2path=$sourceFolder";
$payload | Out-File $targetFile;

$payload = "@set targetserver=$targetServer";
$payload | Out-File $targetFile -Append;

$payload = "@set targetdb=$targetDB";
$payload | Out-File $targetFile -Append;

$payload = "";
$payload | Out-File $targetFile -Append;;

foreach ($file in $files) {
	if ($file.Extension -eq ".sql")
	{
		$filePath = $file.FullName.Replace($sourceFolder, "");
	
		$payload = 'sqlcmd -E -S %targetserver% -d %targetdb% -i "%sys2path%' + $filePath + '"';
		$payload | Out-File $targetFile -Append;
	}
}