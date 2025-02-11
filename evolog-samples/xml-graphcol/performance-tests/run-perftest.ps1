$specPath = "C:\Users\micha\git\evolog-thesis\evolog-samples\xml-graphcol\performance-tests\filespecs"
$outfile = "output/perftest.out"

# Delete all output files from previous runs
Get-ChildItem -Path "output/" -Include *.* -File -Recurse | foreach { $_.Delete()}

$filespecs = Get-ChildItem -Path "$specPath"

ForEach ($filespec in $filespecs) {
	echo "Running perftest $filespec" >> $outfile
	Measure-Command { alpha-solver -i .\src\perftest-file-based-3col.evl -i .\src\xml_dom.mod.evl -i .\src\3col-module-with-lists.evl -i .\src\3col_to_xml.mod.evl -i "$specPath/$filespec" } *>> $outfile
}