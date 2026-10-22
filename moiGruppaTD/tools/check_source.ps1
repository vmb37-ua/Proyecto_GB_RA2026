# Comprobaciones estaticas: no ensambla y no ejecuta el juego.
$ErrorActionPreference = 'Stop'
$sourceRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../src'))
$sourceFiles = @(Get-ChildItem -LiteralPath $sourceRoot -Filter '*.asm' -File -Recurse)
$symbols = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$references = [Collections.Generic.List[object]]::new()
$issues = [Collections.Generic.List[string]]::new()
foreach ($sourceFile in $sourceFiles) {
    $scope = ''
    $lineNumber = 0
    foreach ($sourceLine in [IO.File]::ReadAllLines($sourceFile.FullName)) {
        $lineNumber++
        $code = ($sourceLine -split ';', 2)[0].Trim()
        if ($code -match '^INCLUDE\s+"([^"]+)"') {
            if (-not (Test-Path -LiteralPath (Join-Path $sourceRoot $Matches[1]) -PathType Leaf)) {
                $issues.Add("$($sourceFile.Name):${lineNumber}: include inexistente $($Matches[1])")
            }
        }
        if ($code -match '^([A-Za-z_][A-Za-z_0-9]*):{1,2}') {
            $scope = $Matches[1]
            if (-not $symbols.Add($scope)) { $issues.Add("Simbolo duplicado: $scope") }
        } elseif ($code -match '^(\.[A-Za-z_][A-Za-z_0-9]*):?$') {
            $localSymbol = $scope + $Matches[1]
            if (-not $symbols.Add($localSymbol)) { $issues.Add("Simbolo duplicado: $localSymbol") }
        }
        if ($code -match '^(?:call|jp|jr)\s+(?:(?:z|nz|c|nc)\s*,\s*)?([.A-Za-z_][.A-Za-z_0-9]*)$') {
            $target = $Matches[1]
            if ($target -eq 'hl') { continue }
            if ($target.StartsWith('.')) { $target = $scope + $target }
            $references.Add(@{ Target = $target; File = $sourceFile.Name; Line = $lineNumber })
        }
    }
}
foreach ($reference in $references) {
    if (-not $symbols.Contains($reference.Target)) {
        $issues.Add("$($reference.File):$($reference.Line): destino sin definir $($reference.Target)")
    }
}
# HRAM hDMA es memoria con codigo copiado al arrancar; se detecta como etiqueta.
if ($issues.Count -gt 0) { throw ($issues -join [Environment]::NewLine) }
Write-Output "$($sourceFiles.Count) archivos ASM; $($symbols.Count) etiquetas; $($references.Count) saltos/llamadas resueltos. Includes correctos."
Write-Output 'Esto NO valida sintaxis RGBDS, distancias de JR, enlazado, tiempos ni comportamiento en emulador.'
