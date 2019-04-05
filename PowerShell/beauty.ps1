#使用colortool美化powershell界面
#参考：https://ppundsh.github.io/posts/ad6e/
$shellPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Function FindLineIndexFromProfile($content){
	$profileContent = Get-Content $profile
	$isContentExits = -1
	if($profileContent -ne $null){
		for ($i=0; $i -le $profileContent.length; $i++){
			if($profileContent[$i] -eq $content){
				$isContentExits = $i
				break
			}
		}
	}
	return $isContentExits
}
Function ImportModule($moduleName){
	$profileParentPath = Split-Path -Path $profile -Parent
	$modulesPath = Join-Path $profileParentPath "Modules"
	If (!(Test-Path "$modulesPath\$moduleName")){
		echo "Install $moduleName"
		Install-Module $moduleName -Scope CurrentUser
	}
	echo "import $moduleName"
	Import-Module -Name (Join-Path $modulesPath "$moduleName\*\$moduleName.psm1")
	#检查profile中是否存在即将写入的字符串
	$out = 'Import-Module -Name ' + (Join-Path $modulesPath "$moduleName\*\$moduleName.psm1")
	if((FindLineIndexFromProfile $out) -eq -1){
		$out >> $profile
	}
}
echo "confirm for access"
set-executionpolicy remotesigned -scope currentuser
try{
	echo "check scoop"
	scoop
	clear
} catch{
	echo "install scoop"
	iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
}
try{
	colortool -s
} catch {
	echo "install color-tool"
	scoop install colortool
	echo "list all themes"
	colortool -s
}
do{
	$color=Read-Host "Please enter the name of your favorite color-theme,or enter 'e' to exit"
	if($color -eq $null -or $color -eq '' -or $color -eq 'e'){
		break
	}
	colortool $color
}while($(Read-Host "Are you sure to set this theme as the default theme? [Y]es or [N]o").ToLower() -eq 'n')
if($color -ne $null -and $color -ne '' -and $color -ne 'e'){
	colortool -d $color
	$out =((Get-Content $profile) | Where {!($_.StartsWith('color-tool '))}) 
	#写入新设定的主题
	$out > $profile
	('colortool ' + $color) >> $profile
}
clear
#设置powershell的主题
echo "Import posh-git"
ImportModule "posh-git"
echo "Import oh-my-posh" 
ImportModule "oh-my-posh" 
Get-Theme
#主题列表不能即时显示，需要敲击回车键响应
Read-Host "Press enter to list themes"
do{
	$theme = Read-Host "Please choose a theme,or enter 'e' to exit"
	if($theme -eq $null -or $theme -eq '' -or $theme -eq 'e'){
		break
	}
	Set-Theme $theme
}while($(Read-Host "Are you sure to set this theme as the default theme? [Y]es or [N]o").ToLower() -eq 'n')
if($theme -ne $null -and $theme -ne '' -and $theme -ne 'e'){
	#删除之前的主题
	$out =((Get-Content $profile) | Where {!($_.StartsWith('Set-Theme '))}) 
	#写入新设定的主题
	$out > $profile
	('Set-Theme ' + $theme) >> $profile
}
#安装适用于PowerShell的字体
if(!(Test-Path "C:\Windows\Fonts\sarasa-monoT-sc-regular.ttf")){
	$confirm = Read-Host "Would you want to install some font for powershell? [Y]es or [N]o"
	if($confirm = Read-Host "Would you want to install some font for powershell? [Y]es or [N]o"){
		$objShell = New-Object -ComObject Shell.Application
		$objFolder = $objShell.Namespace(0x14)
		$objFolder.CopyHere("$shellPath\powershell-fonts\sarasa-monoT-sc-regular.ttf")
	}
	#TODO：暂时需要手动设置字体，正在研究如何通过脚本修改字体
}
clear

