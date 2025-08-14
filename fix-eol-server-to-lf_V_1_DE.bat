@echo off
REM [13.08.2025 23:04] Summary: Fix EOLs only for server-relevant types (LF for Unixy files). Creates a report and changes files in place.

setlocal ENABLEDELAYEDEXPANSION

REM Root folder = script location
set "ROOTDIR=%~dp0"
if "%ROOTDIR:~-1%"=="\\" set "ROOTDIR=%ROOTDIR:~0,-1%"

REM Server-relevante Dateitypen (keine HTML/TXT/Assets)
REM Passe die Liste bei Bedarf an (Semikolon-getrennt)
set "INCLUDE=*.sh;*.py;*.php;*.conf;.htaccess;.env;*.env;*.ini;*.json;*.yml;*.yaml;*.sql;Dockerfile;docker-compose.yml;Makefile;*.cgi;*.pl"

REM Empfehlungen (für diese Typen)
REM Grundsatz: Unix-/Server-Skripte und Configs => LF
set "RECOMMEND=sh=LF;py=LF;php=LF;conf=LF;.htaccess=LF;.env=LF;env=LF;ini=LF;json=LF;yml=LF;yaml=LF;sql=LF;Dockerfile=LF;docker-compose.yml=LF;Makefile=LF;cgi=LF;pl=LF"

set "REPORT=eol-fix-report.txt"
> "%REPORT%" echo EOL-Fix Report (nur server-relevante Typen)
>> "%REPORT%" echo Root: %ROOTDIR%
>> "%REPORT%" echo Erstellt am 13.08.2025 23:04
>> "%REPORT%" echo.

echo Scanne und korrigiere EOLs in: %ROOTDIR%
echo (Nur server-relevante Typen; HTML/TXT etc. sind ausgeschlossen)
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$rootDir = $env:ROOTDIR;" ^
  "$patterns = $env:INCLUDE -split ';' | Where-Object { $_ -and $_.Trim().Length -gt 0 };" ^
  "$recommendMap = @{};" ^
  "foreach($pair in ($env:RECOMMEND -split ';')) { if($pair -match '^(.*?)=(LF|CRLF)$') { $recommendMap[$matches[1].ToLower()] = $matches[2] } }" ^
  "function Match-Include($name) { foreach($p in $patterns) { if($name -like $p) { return $true } }; return $false }" ^
  "function Get-LineType($bytes) {" ^
  "  if($bytes.Length -eq 0) { return 'None' }" ^
  "  $hasNull = $false; foreach($b in $bytes) { if($b -eq 0) { $hasNull=$true; break } }" ^
  "  if($hasNull) { return 'Binary' }" ^
  "  $lf=0; $crlf=0; $i=0; while($i -lt $bytes.Length) {" ^
  "    if($bytes[$i] -eq 13 -and ($i+1) -lt $bytes.Length -and $bytes[$i+1] -eq 10) { $crlf++; $lf++; $i+=2; continue }" ^
  "    if($bytes[$i] -eq 10) { $lf++ }" ^
  "    $i++ }" ^
  "  if($crlf -gt 0 -and ($lf - $crlf) -gt 0) { return 'Mixed' }" ^
  "  elseif($crlf -gt 0 -and ($lf - $crlf) -eq 0) { return 'CRLF' }" ^
  "  elseif($crlf -eq 0 -and $lf -gt 0) { return 'LF' }" ^
  "  else { return 'None' }" ^
  "}" ^
  "function Convert-ToLFBytes($bytes) {" ^
  "  $out = New-Object System.Collections.Generic.List[byte];" ^
  "  $i=0; while($i -lt $bytes.Length) {" ^
  "    $b = $bytes[$i];" ^
  "    if($b -eq 13) {" ^
  "      if(($i+1) -lt $bytes.Length -and $bytes[$i+1] -eq 10) { $out.Add(10); $i+=2; continue }" ^
  "      else { $i++; continue }" ^
  "    } elseif($b -eq 10) {" ^
  "      $out.Add(10); $i++; continue" ^
  "    } else {" ^
  "      $out.Add($b); $i++" ^
  "    }" ^
  "  }" ^
  "  return ,$out.ToArray()" ^
  "}" ^
  "function Convert-ToCRLFBytes($bytes) {" ^
  "  $out = New-Object System.Collections.Generic.List[byte];" ^
  "  $i=0; while($i -lt $bytes.Length) {" ^
  "    $b = $bytes[$i];" ^
  "    if($b -eq 13) {" ^
  "      if(($i+1) -lt $bytes.Length -and $bytes[$i+1] -eq 10) { $out.Add(13); $out.Add(10); $i+=2; continue }" ^
  "      else { $out.Add(13); $out.Add(10); $i++; continue }" ^
  "    } elseif($b -eq 10) {" ^
  "      $out.Add(13); $out.Add(10); $i++; continue" ^
  "    } else {" ^
  "      $out.Add($b); $i++" ^
  "    }" ^
  "  }" ^
  "  return ,$out.ToArray()" ^
  "}" ^
  "$report = $env:REPORT;" ^
  "$files = Get-ChildItem -Path $rootDir -Recurse -File | Where-Object { Match-Include $_.Name } | Sort-Object FullName;" ^
  "foreach($f in $files) {" ^
  "  $ext = $f.Extension.TrimStart('.').ToLower();" ^
  "  if(-not $ext) { $ext = $f.Name }" ^
  "  $rec = if($recommendMap.ContainsKey($ext)) { $recommendMap[$ext] } else { '' }" ^
  "  if(-not $rec) { continue }" ^
  "  $bytes = [System.IO.File]::ReadAllBytes($f.FullName);" ^
  "  $type = Get-LineType $bytes;" ^
  "  if($type -eq 'Binary') { Add-Content $report ('SKIP (binary): ' + $f.FullName); continue }" ^
  "  if($type -eq $rec) { continue }" ^
  "  if($rec -eq 'LF') { $new = Convert-ToLFBytes $bytes }" ^
  "  else { $new = Convert-ToCRLFBytes $bytes }" ^
  "  [System.IO.File]::WriteAllBytes($f.FullName, $new);" ^
  "  $rel = $f.FullName.Substring($rootDir.Length).TrimStart('\\');" ^
  "  Add-Content $report ('FIXED -> ' + $rec + ' : ' + $rel)" ^
  "}"

echo.
echo Fertig. Details siehe: %REPORT%
REM [13.08.2025 23:04] End of script. Summary: Converted EOLs for server-relevant types to recommended endings.
