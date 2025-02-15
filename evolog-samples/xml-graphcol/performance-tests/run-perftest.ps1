$specPath = "./filespecs"
$outfile = "./output/perftest.out"

$classicAspInPath = "./infiles_classic"
$classicAspOutPath = "./output"

# Delete all output files from previous runs
Get-ChildItem -Path "output/" -Include *.* -File -Recurse | foreach { $_.Delete()}

$infilesAsp = Get-ChildItem -Path "$classicAspInPath"
echo "Running Classic ASP on Alpha Tests"
ForEach ($infile in $infile) {
	echo "Running perftest $filespec" >> $outfile
	Measure-Command { alpha-solver -q -n6 -i .\src\3col-classic.asp -i $infile } *>> $outfile
}

$filespecs = Get-ChildItem -Path "$specPath"
echo "Running Evolog Tests"
ForEach ($filespec in $filespecs) {
	echo "Running perftest $filespec" >> $outfile
	Measure-Command { alpha-solver -q -i .\src\perftest-file-based-3col.evl -i .\src\xml_dom.mod.evl -i .\src\3col-module-with-lists.evl -i .\src\3col_to_xml.mod.evl -i "$specPath/$filespec" } *>> $outfile
}