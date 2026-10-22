# Genera datos RGBDS 2bpp a partir de pixel art y fuente originales del proyecto.
# No compila ni ejecuta la ROM. No requiere bibliotecas ni imagenes externas.
$ErrorActionPreference = 'Stop'
$gfxLines = [System.Collections.Generic.List[string]]::new()
$gfxLines.Add('; Generado con tools/generate_gfx.ps1. Arte y fuente originales del proyecto.')
$gfxLines.Add('INCLUDE "game.inc"')
$gfxLines.Add('SECTION "Assets: graphics", ROM0')
$gfxLines.Add('gfx_tiles::')
$script:gfxCount = 0
function Add-Tile([string[]] $rows) {
    if ($rows.Count -ne 8) { throw 'Un tile debe tener ocho filas' }
    $gfxLines.Add(('    ; Tile {0}' -f $script:gfxCount))
    foreach ($row in $rows) {
        if ($row.Length -ne 8) { throw "Fila invalida: $row" }
        $lowPlane = 0; $highPlane = 0
        for ($pixelX = 0; $pixelX -lt 8; $pixelX++) {
            $value = [int]::Parse($row.Substring($pixelX, 1))
            if ($value -gt 3) { throw 'Color fuera de 2bpp' }
            $lowPlane = ($lowPlane -shl 1) -bor ($value -band 1)
            $highPlane = ($highPlane -shl 1) -bor (($value -shr 1) -band 1)
        }
        $gfxLines.Add(('    db ${0:X2}, ${1:X2}' -f $lowPlane, $highPlane))
    }
    $script:gfxCount++
}
Add-Tile (@('00000000') * 8)
Add-Tile @('11111111','00000000','00000000','00010000','00000000','00000000','00000000','11111111')
for ($towerType = 0; $towerType -lt 5; $towerType++) {
    $pixels = [int[,]]::new(16,16)
    for ($pixelY = 1; $pixelY -lt 15; $pixelY++) {
        for ($pixelX = 1; $pixelX -lt 15; $pixelX++) {
            if ($towerType -eq 3) {
                if (($pixelY % 4 -eq 0) -or (($pixelX + 4 * [int][math]::Floor($pixelY / 4)) % 8 -eq 0)) {
                    $pixels[$pixelY,$pixelX] = 3
                } else { $pixels[$pixelY,$pixelX] = 1 }
            } elseif ($towerType -eq 4) {
                if ($pixelX -eq 2 -or $pixelX -eq 13 -or $pixelY -eq 2 -or $pixelY -eq 13) {
                    $pixels[$pixelY,$pixelX] = 3
                }
                if (($pixelX -eq 6 -and $pixelY -ge 4 -and $pixelY -le 11) -or
                    ($pixelY -eq 4 -and $pixelX -ge 6 -and $pixelX -le 9) -or
                    ($pixelY -eq 7 -and $pixelX -ge 6 -and $pixelX -le 9) -or
                    ($pixelX -eq 10 -and $pixelY -ge 5 -and $pixelY -le 6)) { $pixels[$pixelY,$pixelX] = 3 }
            } else {
                $bodyLeft = 6 - $towerType
                $bodyRight = 9 + $towerType
                if (($pixelY -ge 2 -and $pixelY -le 4 -and $pixelX -ge 6 -and $pixelX -le 9) -or
                    ($pixelY -ge 6 -and $pixelY -le 11 -and $pixelX -ge $bodyLeft -and $pixelX -le $bodyRight) -or
                    ($pixelY -ge 7 -and $pixelY -le 8 -and $pixelX -ge 3 -and $pixelX -le 12) -or
                    ($pixelY -ge 5 -and $pixelY -le 10 -and ($pixelX -eq 2 -or $pixelX -eq 13)) -or
                    ($pixelY -ge 12 -and ($pixelX -eq 5 -or $pixelX -eq 6 -or $pixelX -eq 9 -or $pixelX -eq 10))) {
                    $pixels[$pixelY,$pixelX] = 3
                }
                if ($pixelY -eq 3 -and ($pixelX -eq 7 -or $pixelX -eq 8)) { $pixels[$pixelY,$pixelX] = 1 }
            }
        }
    }
    foreach ($quadrant in @(0,1,2,3)) {
        $rows = @()
        $baseX = ($quadrant % 2) * 8
        $baseY = [int][math]::Floor($quadrant / 2) * 8
        for ($pixelY = 0; $pixelY -lt 8; $pixelY++) {
            $row = ''
            for ($pixelX = 0; $pixelX -lt 8; $pixelX++) { $row += [string]$pixels[($baseY+$pixelY),($baseX+$pixelX)] }
            $rows += $row
        }
        Add-Tile $rows
    }
}
Add-Tile @('00003000','00033300','00313230','03333300','03333000','00330000','00303000','03003000')
Add-Tile @('00002000','00022200','00213230','02222000','02220000','00220000','02020000','20002000')
Add-Tile @('00033000','00333300','03313330','33333330','33333330','03333300','00303000','03303300')
Add-Tile @('00000000','00000000','00033000','00333300','00333300','00033000','00000000','00000000')
Add-Tile @('33330000','30000000','30000000','30000000','00000000','00000000','00000000','00000000')
while ($script:gfxCount -lt 32) { Add-Tile (@('00000000') * 8) }
# Fuente 5x7; orden 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ. Hex = cinco bits por fila.
$glyphs = @(
 '0E 11 13 15 19 11 0E','04 0C 04 04 04 04 0E','0E 11 01 02 04 08 1F',
 '1E 01 01 0E 01 01 1E','02 06 0A 12 1F 02 02','1F 10 10 1E 01 01 1E',
 '0E 10 10 1E 11 11 0E','1F 01 02 04 08 08 08','0E 11 11 0E 11 11 0E',
 '0E 11 11 0F 01 01 0E','0E 11 11 1F 11 11 11','1E 11 11 1E 11 11 1E',
 '0E 11 10 10 10 11 0E','1E 11 11 11 11 11 1E','1F 10 10 1E 10 10 1F',
 '1F 10 10 1E 10 10 10','0E 11 10 17 11 11 0F','11 11 11 1F 11 11 11',
 '0E 04 04 04 04 04 0E','07 02 02 02 12 12 0C','11 12 14 18 14 12 11',
 '10 10 10 10 10 10 1F','11 1B 15 15 11 11 11','11 19 15 13 11 11 11',
 '0E 11 11 11 11 11 0E','1E 11 11 1E 10 10 10','0E 11 11 11 15 12 0D',
 '1E 11 11 1E 14 12 11','0F 10 10 0E 01 01 1E','1F 04 04 04 04 04 04',
 '11 11 11 11 11 11 0E','11 11 11 11 11 0A 04','11 11 11 15 15 15 0A',
 '11 11 0A 04 0A 11 11','11 11 0A 04 04 04 04','1F 01 02 04 08 10 1F'
)
foreach ($glyph in $glyphs) {
    $rows = @()
    foreach ($hexRow in $glyph.Split(' ')) {
        $value = [Convert]::ToInt32($hexRow,16)
        $bits = [Convert]::ToString($value,2).PadLeft(5,'0').Replace('1','3')
        $rows += ('0' + $bits + '00')
    }
    $rows += '00000000'
    Add-Tile $rows
}
$gfxLines.Add('gfx_tiles_end::')
$gfxLines.Add('ASSERT gfx_tiles_end - gfx_tiles == (TILE_FONT + 36) * 16')
$gfxPath = Join-Path $PSScriptRoot '../src/assets/gfx.asm'
[IO.File]::WriteAllLines($gfxPath, $gfxLines, [Text.UTF8Encoding]::new($false))
Write-Output "Escritos $script:gfxCount tiles en src/assets/gfx.asm"
