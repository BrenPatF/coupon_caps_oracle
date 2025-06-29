param ( [String]$index )

$plf = 'coupon_caps_plf_agg_v'
$mod = 'coupon_caps_mod_agg_v'
$rsf = 'coupon_caps_rsf_agg_v'
$inputAll = "results_$index.log"
$outputAll = "results_$index.csv"

# Process each line and append to the output file
function doMethod ($name, $inputFile, $outputFile) {
    Get-Content $inputFile | ForEach-Object {
        if ($_ -match "^($name\S*)\s+(\d+)\s*-\s*(\d+)\s*-\s*(\d+).*?([\d.]+)") {
            $keyword = $matches[1] -replace '^coupon_caps_', ''
            $rounded = [math]::Round([double]$matches[5], 2)
            $line = "$($keyword.Substring(0,3).Toupper()),$($matches[2]),$($matches[3]),$($matches[4]),$rounded"
            Add-Content -Path $outputFile -Value $line
        }
    }
}
"method,#cous,#cap_cous,#caps,Seconds" | Out-File $outputAll -encoding utf8
doMethod $mod $inputAll $outputAll
doMethod $plf $inputAll $outputAll
doMethod $rsf $inputAll $outputAll
