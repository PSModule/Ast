function Get-FunctionType {
    <#
        .SYNOPSIS
        Gets the function type.

        .DESCRIPTION
        This function will get the function type.

        .EXAMPLE
        Get-FunctionType -Path 'C:\MyModule\src\MyModule\functions\public\MyFunction.ps1'

        This will return 'public'.
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The path to the PowerShell script file to be parsed.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Path'
        )]
        #Validate using Test-Path
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string] $Path
    )

    begin {}

    process {
        $functionAST = Get-FunctionAST -Path $Path

        $functionAST | ForEach-Object {
            $type = $_.IsFilter ? 'Filter' : $_.IsWorkflow ? 'Workflow' : $_.IsConfiguration ? 'Configuration' : 'Function'
            [pscustomobject]@{
                Name = $_.Name
                Type = $type
            }
        }
    }

    end {}
}
