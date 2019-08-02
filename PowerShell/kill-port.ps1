Function KillPort($port,$force=0){
	Write-Host "检索$port -force=$force"
	$str = netstat -ano
	$list = $str.Split("\n")
	for($i = 5; $i -lt $list.Length; $i++) {
		$item_list = [System.Text.RegularExpressions.Regex]::Split($list.Get($i).Trim(), "\s+")
		if([System.Text.RegularExpressions.Regex]::IsMatch($item_list.Get(1).Trim(),":$port"+'$')) {    
			$p_id = $item_list.Get(4)
			break
		}
	}
	if($p_id -eq $null) {
		Write-Output "没有进程占用$port端口"
	} else {
		Write-Output "占用$port端口的进程为\:"
		Get-Process -id $p_id
		if($force){
			Stop-Process -id $p_id
			Write-Host "操作成功"
		} else {
			Write-Host "终止批处理操作吗(Y/N)?" -NoNewline
			$input = Read-Host
			if($input -eq "Y") {
				Stop-Process -id $p_id
				Write-Host "操作成功"
			}
		}
	}
}
