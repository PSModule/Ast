function Test-ParameterType {
    <#
    .SYNOPSIS
        Tests various parameter types for AST parsing.
    .DESCRIPTION
        This function contains a variety of parameter types to test AST parsing capabilities.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Standard')]
    [Alias('ParamTest')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Standard')]
        [string]$StringParam,

        [Parameter(ParameterSetName = 'Standard')]
        [int]$IntParam,

        [Parameter(ParameterSetName = 'Standard')]
        [datetime]$DateParam,

        [Parameter(ParameterSetName = 'Advanced')]
        [ValidateSet('Option1', 'Option2', 'Option3')]
        [string]$ChoiceParam,

        [Parameter(ParameterSetName = 'Advanced')]
        [ValidateScript({ Test-Path $_ })]
        [string]$PathParam,

        [Parameter(ValueFromPipeline)]
        [object[]]$InputObject,

        [Parameter()]
        [hashtable]$Config = @{}
    )

    begin {
        $results = [System.Collections.ArrayList]::new()
        Write-Verbose "StringParam: $StringParam"
        Write-Verbose "IntParam: $IntParam"
        Write-Verbose "DateParam: $DateParam"
        Write-Verbose "ChoiceParam: $ChoiceParam"
        Write-Verbose "PathParam: $PathParam"
        Write-Verbose "Config: $($Config | Out-String)"
    }

    process {
        # Here we'll invoke some commands for AST testing
        foreach ($item in $InputObject) {
            $info = Get-Member -InputObject $item
            $null = $results.Add(@{
                    Object  = $item
                    Type    = $item.GetType().Name
                    Members = $info | Select-Object -ExpandProperty Name
                })
        }
    }

    end {
        # Use the dot source operator to load helpers
        . {
            param($data)
            foreach ($entry in $data) {
                [PSCustomObject]$entry
            }
        } -data $results
    }
}
