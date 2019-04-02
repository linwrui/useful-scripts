#使用colortool美化powershell界面
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
$confirm = "n"
do{
	$theme=Read-Host "Please enter the name of your favorite theme,or enter 'e' to exit"
	if($theme -eq 'e'){
		break
	}
	colortool $theme
}while($(Read-Host "Are you sure to set this theme as the default theme? [Y]es or [N]o").ToLower() -eq 'n')
colortool -d $theme
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
if (!(Test-Path -Path $PROFILE )) { New-Item -Type File -Path $PROFILE -Force }
notepad $PROFILE
