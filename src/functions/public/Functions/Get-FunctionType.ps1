function Get-FunctionType {
    <#
        .SYNOPSIS
        Extracts function types from a specified PowerShell script.

        .DESCRIPTION
        Parses the given PowerShell script file and retrieves all function types
        defined within it. This function utilizes the PowerShell Abstract Syntax Tree (AST)
        to analyze the script and extract function definitions.

        .EXAMPLE
        Get-FunctionType -Path "C:\Scripts\MyScript.ps1"

        Retrieves all function types defined in the specified script file.
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
