<#
.SYNOPSIS
    A test filter function for AST parsing.
.DESCRIPTION
    This filter demonstrates how filter functions work and how they can be parsed.
#>
filter Test-FilterFunction {
    $_ | ForEach-Object {
        # Process each item
        if ($_ -is [string]) {
            [PSCustomObject]@{
                Type    = 'String'
                Value   = $_
                Length  = $_.Length
                IsEmpty = [string]::IsNullOrEmpty($_)
            }
        } elseif ($_ -is [int] -or $_ -is [double]) {
            [PSCustomObject]@{
                Type       = $_.GetType().Name
                Value      = $_
                IsPositive = $_ -gt 0
                IsZero     = $_ -eq 0
            }
        } else {
            [PSCustomObject]@{
                Type     = $_.GetType().Name
                Value    = $_
                ToString = $_.ToString()
            }
        }
    }
}

# Add a helper function in the same file
function Convert-InputObject {
    <#
        .SYNOPSIS
        Short description

        .DESCRIPTION
        Long description
    #>
    param(
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process {
        $InputObject | Test-FilterFunction
    }
}
