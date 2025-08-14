@echo off
REM [13.08.2025 23:00] Summary: List files not matching recommended LF/CRLF into nicht-LF-konform.txt (relative to script location, with comment).

setlocal ENABLEDELAYEDEXPANSION

REM Remember script directory as root
set "ROOTDIR=%~dp0"
REM Remove trailing backslash
if "%ROOTDIR:~-1%"=="\\" set "ROOTDIR=%ROOTDIR:~0,-1%"

REM Patterns to check
set "INCLUDE=*.sh;Dockerfile;docker-compose.yml;.env;*.env;*.conf;.htaccess;*.php;*.html;*.css;*.js;*.ts;*.json;*.ini;*.txt;*.md;*.sql;*.py;*.yml;*.yaml;Makefile;*.bat;*.cmd"

REM Recommendation table
set "RECOMMEND=sh=LF;Dockerfile=LF;docker-compose.yml=LF;.env=LF;env=LF;conf=LF;.htaccess=LF;php=LF;html=LF;css=LF;js=LF;ts=LF;json=LF;ini=LF;txt=LF;md=LF;sql=LF;py=LF;yml=LF;yaml=LF;Makefile=LF;bat=CRLF;cmd=CRLF"

set "OUTFILE=nicht-LF-konform.txt"
> "%OUTFILE%" echo Dateien, die nicht der empfohlenen Zeilenenden-Norm entsprechen:
>> "%OUTFILE%" echo (Erstellt am 13.08.2025 23:00)
>> "%OUTFILE%" echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$rootDir = $env:ROOTDIR;" ^
  "$patterns = $env:INCLUDE -split ';' | Where-Object { $_ -and $_.Trim().Length -gt 0 };" ^
  "$recommendMap = @{};" ^
  "foreach($pair in ($env:RECOMMEND -split ';')) { if($pair -match '^(.*?)=(LF|CRLF)$') { $recommendMap[$matches[1].ToLower()] = $matches[2] } }" ^
  "function Match-Include($name) { foreach($p in $patterns) { if($name -like $p) { return $true } }; return $false }" ^
  "$outFile = $env:OUTFILE;" ^
  "$files = Get-ChildItem -Path $rootDir -Recurse -File | Where-Object { Match-Include $_.Name };" ^
  "foreach($f in $files) {" ^
  "  $ext = $f.Extension.TrimStart('.').ToLower();" ^
  "  if(-not $ext) { $ext = $f.Name }" ^
  "  $rec = if($recommendMap.ContainsKey($ext)) { $recommendMap[$ext] } else { '' }" ^
  "  if(-not $rec) { continue }" ^
  "  $bytes = [System.IO.File]::ReadAllBytes($f.FullName);" ^
  "  if($bytes.Length -eq 0) { $type='None' }" ^
  "  else {" ^
  "    $hasNull = $false; foreach($b in $bytes) { if($b -eq 0) { $hasNull = $true; break } }" ^
  "    $lfCount = 0; $crlfCount = 0; $i = 0;" ^
  "    while($i -lt $bytes.Length) {" ^
  "      if($bytes[$i] -eq 13 -and ($i+1) -lt $bytes.Length -and $bytes[$i+1] -eq 10) { $crlfCount++; $lfCount++; $i += 2; continue }" ^
  "      if($bytes[$i] -eq 10) { $lfCount++ }" ^
  "      $i++" ^
  "    }" ^
  "    if($hasNull) { $type='Binary' }" ^
  "    elseif($crlfCount -gt 0 -and ($lfCount - $crlfCount) -gt 0) { $type='Mixed' }" ^
  "    elseif($crlfCount -gt 0 -and ($lfCount - $crlfCount) -eq 0) { $type='CRLF' }" ^
  "    elseif($crlfCount -eq 0 -and $lfCount -gt 0) { $type='LF' }" ^
  "    else { $type='None' }" ^
  "  }" ^
  "  if($type -ne $rec) {" ^
  "    $relPath = $f.FullName.Substring($rootDir.Length).TrimStart('\\');" ^
  "    Add-Content -Path $outFile -Value ($relPath + '  REM nicht LF')" ^
  "  }" ^
  "}"

echo.
echo Liste erstellt: %OUTFILE%
REM [13.08.2025 23:00] End of script. Summary: Writes non-conforming files (relative paths) to nicht-LF-konform.txt with comment.
