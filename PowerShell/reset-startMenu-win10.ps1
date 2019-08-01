Remove-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\$start.tilegrid$windows.data.curatedtilecollection.root' -Force -Recurse
Get-Process Explorer | Stop-Process
