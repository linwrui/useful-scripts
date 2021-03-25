#使用colortool和oh-my-posh美化powershell界面
#参考：https://ppundsh.github.io/posts/ad6e/
$shellPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Function FindLineIndexFromProfile($content){
	$profileContent = Get-Content $profile
	$isContentExits = -1
	if($null -ne $profileContent){
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
		Write-Output "Install $moduleName"
		Install-Module $moduleName -Scope CurrentUser
	}
	Write-Output "import $moduleName"
	Import-Module -Name (Join-Path $modulesPath "$moduleName\*\$moduleName.psm1")
	#检查profile中是否存在即将写入的字符串
	$out = 'Import-Module -Name ' + (Join-Path $modulesPath "$moduleName\*\$moduleName.psm1")
	if((FindLineIndexFromProfile $out) -eq -1){
		$out >> $profile
	}
}
Write-Output "confirm for access"
set-executionpolicy remotesigned -scope currentuser
try{
	Write-Output "check scoop"
	scoop
	Clear-Host
} catch{
	Write-Output "install scoop"
	Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')
}
# try{
	# colortool -s
# } catch {
	# Write-Output "install color-tool"
	# scoop install colortool
	# Write-Output "list all themes"
	# colortool -s
# }
# do{
	# $color=Read-Host "Please enter the name of your favorite color-theme,or enter 'e' to exit"
	# if($null -eq $color -or $color -eq '' -or $color -eq 'e'){
		# break
	# }
	# colortool $color
# }while($(Read-Host "Are you sure to set this theme as the default theme? [Y]es or [N]o").ToLower() -eq 'n')
# if($null -ne $color -and $color -ne '' -and $color -ne 'e'){
	# colortool -d $color
	# $out =((Get-Content $profile) | Where-Object {!($_.StartsWith('colortool -q '))}) 
	# #写入新设定的主题
	# $out > $profile
	# ('colortool -q ' + $color) >> $profile
# }
Clear-Host
#设置powershell的主题
Write-Output "Import posh-git"
ImportModule "posh-git"
Write-Output "Import oh-my-posh" 
ImportModule "oh-my-posh" 
Get-PoshThemes
do{
	$theme = Read-Host "Please enter the name of your favorite theme,or enter 'e' to exit"
	if($null -eq $theme -or $theme -eq '' -or $theme -eq 'e'){
		break
	}
	Set-PoshPrompt -Theme $theme
}while($(Read-Host "Are you sure to set this theme as the default theme? [Y]es or [N]o").ToLower() -eq 'n')
if($null -ne $theme -and $theme -ne '' -and $theme -ne 'e'){
	#删除之前的主题
	$out =((Get-Content $profile) | Where-Object {!($_.StartsWith('Set-Theme '))}) 
	#写入新设定的主题
	$out > $profile
	('Set-PoshPrompt -Theme ' + $theme) >> $profile
}
#安装适用于PowerShell的字体
if(!(Test-Path (join-path $env:windir "Fonts\sarasa-monoT-sc-regular.ttf"))){
	$confirm = Read-Host "Would you want to install some font for powershell? [Y]es or [N]o"
	if($confirm.ToLower() -eq 'y'){
		$objShell = New-Object -ComObject Shell.Application
		$objFolder = $objShell.Namespace(0x14)
		$objFolder.CopyHere("$shellPath\powershell-fonts\sarasa-monoT-sc-regular.ttf")
	}
	#TODO：暂时需要手动设置字体，正在研究如何通过脚本修改字体
}
# Import-Module -Name (Join-Path $shellPath "\modules\set-console-font.psm1")
# Get-ConsoleFontInfo | Format-Table -AutoSize
Write-Output "Complete"
clear