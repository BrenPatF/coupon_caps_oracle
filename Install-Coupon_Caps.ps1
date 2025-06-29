<#**************************************************************************************************
Name: Install-Utils.ps1                 Author: Brendan Furey                      Date: 20-Oct-2024

Install script for Oracle PL/SQL Utils module

    GitHub: https://github.com/BrenPatF/oracle_plsql_utils

====================================================================================================
| Script (.ps1)             | Module (.psm1) | Notes                                               |
|==================================================================================================|
| *Install-Coupon_Caps*     | OracleUtils    | Install script for Oracle PL/SQL Utils module       |
|---------------------------|----------------------------------------------------------------------|
|  Test-Format-Coupon_Caps  | TrapitUtils    | Script to test and format results for Oracle PL/SQL |
|                           |                | Utils module                                        |
|---------------------------|----------------|-----------------------------------------------------|
|  Format-JSON-Coupon_Caps  | TrapitUtils    | Script to create template for unit test JSON input  |
|                           |                | file for Oracle PL/SQ Utils module                  |
====================================================================================================

**************************************************************************************************#>
Import-Module .\powershell_utils\OracleUtils\OracleUtils
$inputPath = 'c:/input'
$fileLis = @('.\unit_test\tt_coupon_caps.purely_wrap_coupon_caps_inp.json')

$sysSchema = 'sys'
$libSchema = 'lib'
$appSchema = 'app'

$sqlInstalls = @(@{folder = 'install_prereq';     script = 'drop_utils_users.sql';       schema = $sysSchema; prmLis = @($libSchema, $appSchema)},
                 @{folder = 'install_prereq';     script = 'install_sys.sql';            schema = $sysSchema; prmLis = @($libSchema, $appSchema, $inputPath)},
                 @{folder = 'install_prereq\lib'; script = 'install_lib_all.sql';        schema = $libSchema; prmLis = @($appSchema)},
                 @{folder = 'install_prereq\app'; script = 'c_syns_all.sql';             schema = $appSchema; prmLis = @($libSchema)},
                 @{folder = 'app';                script = 'install_coupon_caps.sql';    schema = $appSchema; prmLis = @()},
                 @{folder = 'app';                script = 'install_coupon_caps_tt.sql'; schema = $appSchema; prmLis = @()},
                 @{folder = '.';                  script = 'l_objects.sql';              schema = $sysSchema; prmLis = @($sysSchema)},
                 @{folder = '.';                  script = 'l_objects.sql';              schema = $libSchema; prmLis = @($libSchema)},
                 @{folder = '.';                  script = 'l_objects.sql';              schema = $appSchema; prmLis = @($appSchema)})
$fileCopies = [PSCustomObject]@{inputPath = $inputPath
                                fileLis = $fileLis}
$ret = Install-OracleApp -fileCopies $fileCopies -sqlInstalls $sqlInstalls -testMode $false
Write-OracleApp $ret
