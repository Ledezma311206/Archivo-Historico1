# Comprime todos los PDF de la carpeta donde pongas este archivo.
# Las copias ligeras quedan en la subcarpeta "ligeros". Los originales NO se tocan.

$carpeta = $PSScriptRoot
$salida  = Join-Path $carpeta "ligeros"
New-Item -ItemType Directory -Force -Path $salida | Out-Null

# Busca Ghostscript instalado
$gs = Get-ChildItem "C:\Program Files\gs" -Recurse -Filter "gswin64c.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $gs) {
  Write-Host "No encontre Ghostscript. Instalalo primero." -ForegroundColor Red
  exit
}

Get-ChildItem -Path $carpeta -Filter *.pdf | ForEach-Object {
  $destino = Join-Path $salida $_.Name
  if ((Test-Path $destino) -and ((Get-Item $destino).Length -gt 0)) {
    Write-Host "Ya existe, me lo salto: $($_.Name)" -ForegroundColor Yellow
    return
  }
  Write-Host "Comprimiendo $($_.Name) ..."
  $argumentos = @(
    "-sDEVICE=pdfwrite",
    "-dCompatibilityLevel=1.4",
    "-dPDFSETTINGS=/ebook",
    "-dNOPAUSE",
    "-dQUIET",
    "-dBATCH",
    ("-sOutputFile=" + $destino),
    $_.FullName
  )
  & $gs.FullName @argumentos
}

Write-Host ""
Write-Host "Resultado (tamano en MB):" -ForegroundColor Green
Get-ChildItem $salida -Filter *.pdf | ForEach-Object {
  $mb = [math]::Round($_.Length / 1MB, 1)
  $aviso = ""
  if ($mb -gt 50) { $aviso = "  <-- PASA DE 50 MB, hay que comprimir mas" }
  Write-Host ("{0,8} MB  {1}{2}" -f $mb, $_.Name, $aviso)
}
