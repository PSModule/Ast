function Test-Function3 {
    param(
        [bool]$Flag
    )

    if ($Flag) {
        Write-Host 'Flag is true'
    } else {
        Write-Host 'Flag is false'
    }
}
