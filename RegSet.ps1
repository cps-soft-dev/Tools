#regedit add/del Tools 
#定位文件格式：csv（逗号切分）
#定义文件名称：RegSet.csv
#项目说明：路径，项目名，项目类型，项目值，用户，操作（Add/Del）,功能描述
#regPath,regName,regType,regData,regUser,regOper,regText
#工具功能：读取定义文件中内容，根据操作，用户，项目类型，调用不同的注册表操作更新注册表
#1.定位读取条件
#   用户列包含admin
#      1.1.操作=Add ：调用reg add （根据类型设定不同参数）
#      1.2.操作=Del ：调用reg del （根据类型设定不同参数）
#2.定位读取条件
#   用户列包含user
#      1.1.reg load HKU\Temp 该用户的ntuser.dat
#      1.2.regPath中的HKEY_CURRENT_USER替换成HKU\Temp
#      1.3.操作=Add ：调用reg add （根据类型设定不同参数）
#      1.4.操作=Del ：调用reg del （根据类型设定不同参数）
#      1.5.调用reg uload HKU\Temp
#3.用1和2类似的方式取出注册表的值进行确认
#   确认结果log样式
#     （OK）功能描述 *取得值和定位文件中的相同
#     （NG）功能描述 *取得值和定义文件中的不同 
#
param($defName="RegSet.csv", $adminID="admin", $userID="user")

$hostname= $env:COMPUTERNAME
$username= $env:USERNAME
$logfile = ".\RegSet_$hostname.log"

function WriteLog($msgtext) {
    $logtime = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
    $logtext = "$logtime $msgtext"
    echo "$logtext"
    echo "$logtext" >> "$logfile"
}

function RegSetExec($id, $def)
{
    #WriteLog "$id $def"
    $regPath=$def.regPath
    $regName=$def.regName
    $regType=$def.regType
    $regData=$def.regData
    $regUser=$def.regUser
    $regOper=$def.regOper
    $regText=$def.regText
    if ($id -ne 0) {
        $regPath = [regex]::replace($regPath, "^HKEY_CURRENT_USER", "HKU\Temp", 1)
        $regPath = [regex]::replace($regPath, "^HKCU", "HKU\Temp", 1)
    }
    if ($regOper -eq "add") {
        WriteLog "[add] $regText"
        if ($regType -match "DWORD") {
            WriteLog "reg.exe add `"$regPath`" /v `"$regName`" /t $regType /d  $regData  /f"
            reg.exe add "$regPath" /v "$regName" /t $regType /d  $regData  /f
        } else {
            WriteLog "reg.exe add `"$regPath`" /v `"$regName`" /t `"$regType`" /d  $regData  /f"
            reg.exe add "$regPath" /v "$regName" /t $regType /d "$regData" /f
        }
    }
    if ($regOper -eq "del") {
        WriteLog "[del] $regText"
        if ($regName -eq "" -or $regName -eq "-") {
            WriteLog "reg.exe delete `"$regPath`" /f"
            reg.exe delete "$regPath" /f
        } else {
            WriteLog "reg.exe delete `"$regPath`" /v `"$regName`" /f"
            reg.exe delete "$regPath" /v "$regName" /f
        }
    }
}

# 定位读取
$defList = Import-Csv ".\$defName" -Header regPath,regName,regType,regData,regUser,regOper,regText

# 用户列包含admin
WriteLog "[$username] RegSetExec"
$defList | ? {$_.regPath -match "^HK" -and $_.regUser -match "$adminID"} | % {
    RegSetExec 0 $_
}

#  用户列包含user
WriteLog "[$userID] RegSetExec"
reg.exe load HKU\Temp C:\users\user\NTUSER.DAT
$defList | ? {$_.regPath -match "^HK" -and $_.regUser -match "$userID"} | % {
    RegSetExec 1 $_
}
reg.exe unload HKU\Temp