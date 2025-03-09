<#
.SYNOPSIS
    A complex test function with nested commands and structures.
.DESCRIPTION
    This function demonstrates complex PowerShell structures for AST testing.
#>
function Test-ComplexFunction {
    [OutputType([System.Object[]])]
    [CmdletBinding()]
    [Alias('ComplexTest', 'Test-Complex')]
    param (
        [Parameter(Mandatory)]
        [string]$InputValue,

        [switch]$DebugTest
    )

    begin {
        # Comments should be parsed correctly
        $results = @()
        if ($DebugTest) {
            Write-Verbose 'Debug mode enabled'
        }
    }

    process {
        try {
            # This is a nested command structure
            $items = $InputValue -split ',' | ForEach-Object {
                $item = $_.Trim()
                if ($item -match '\d+') {
                    [int]$item
                } else {
                    $item.ToUpper()
                }
            }

            # This uses the call operator
            & {
                param($data)
                foreach ($d in $data) {
                    [PSCustomObject]@{
                        Value = $d
                        Type  = $d.GetType().Name
                    }
                }
            } -data $items | ForEach-Object {
                $results += $_
            }
        } catch {
            Write-Error "Error processing input: $_"
        }
    }

    end {
        return $results
    }
}
