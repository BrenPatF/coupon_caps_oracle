Date -format "dd-MMM-yy HH:mm:ss"
$startTime = Get-Date
[int]$maxIndex = Get-ChildItem -Path . -Filter "results_??.log" |
    ForEach-Object {
        if ($_ -match 'results_(\d{2})\.log') {
            [int]$matches[1]
        }
    } |
    Measure-Object -Maximum |
    Select-Object -ExpandProperty Maximum

$logs = Get-ChildItem | Where-Object { $_.Name -match "^results_\d+.log$" }
$nxtIndex = ($maxIndex + 1).ToString("D2")
$newLog = ('results_' + $nxtIndex)

$inputs = [ordered]@{
    mod_plf     = @(
        @(10000, 12, 22), @(20000, 12, 22), @(30000, 12, 22), @(40000, 12, 22), @(50000, 12, 22), @(60000, 12, 22, 'Y'),
        @(60000, 2, 22),  @(60000, 4, 22),  @(60000, 6, 22),  @(60000, 8, 22),  @(60000, 10, 22),
        @(60000, 12, 12), @(60000, 12, 14), @(60000, 12, 16), @(60000, 12, 18), @(60000, 12, 20)
    )
    mod_plf_rsf = @(
        @(1000, 12, 22),  @(2000, 12, 22),  @(3000, 12, 22),  @(4000, 12, 22),  @(5000, 12, 22),  @(6000, 12, 22, 'Y'),
        @(6000, 2, 22),   @(6000, 4, 22),   @(6000, 6, 22),   @(6000, 8, 22),   @(6000, 10, 22),
        @(6000, 12, 12),  @(6000, 12, 14),  @(6000, 12, 16),  @(6000, 12, 18),  @(6000, 12, 20)
    )
}
#$inputs = [ordered]@{
#    mod_plf     = @(,
#        @(10000, 12, 22),  @(20000, 12, 22, 'Y')
#    )
#    mod_plf_rsf     = @(,
#        @(1000, 12, 22),  @(2000, 12, 22, 'Y')
#    )
#}
$cmdLis = @(
    "@..\install_prereq\initspool $newLog",
    "VAR TIMER_SET NUMBER",
    "DELETE log_lines;"
    "EXEC :TIMER_SET := Timer_Set.Construct('Run_All');"
)
$n_views = 2
foreach($i in $inputs.Keys){
    $i
    foreach($p in $inputs[$i]) {
        $xplan = 'N'
        if($p[3]) {
            $xplan = 'Y'
        }
        $cmdLis += '@run_dp ' + $p[0] + ' ' + $p[1] + ' ' + $p[2] + ' ' + $n_views + ' ' +  $xplan
    }
    $n_views = 3
}
$cmdLis += 'EXEC Utils.L(Timer_Set.Format_Results(:TIMER_SET));'
$cmdLis += 'SET HEAD OFF'
$cmdLis += 'SELECT line FROM log_lines ORDER BY id;'
$cmdLis += '@..\install_prereq\endspool'
$cmdLis += 'exit'
[string]$cmdStr = $cmdLis -join [Environment]::NewLine
$cmdStr
$eat = $cmdStr | sqlplus 'app/app@orclpdb'
.\Get-Csv $nxtIndex
Get-Content ($newLog + '.log') | Select-String 'Result for'
$elapsedTime = (Get-Date) - $startTime
$roundedTime = [math]::Round($elapsedTime.TotalSeconds)

"Total time taken: $roundedTime seconds"