﻿function Get-AstFunctionType {
    <#
        .SYNOPSIS
        Retrieves the type of an abstract syntax tree (Ast) function.

        .DESCRIPTION
        Parses a PowerShell script file or script content to determine the type of function present.
        The function classifies functions as `Function`, `Filter`, `Workflow`, or `Configuration`.
        It supports searching for specific function names and can process nested functions if required.

        .EXAMPLE
        Get-AstFunctionType -Path "C:\Scripts\MyScript.ps1"

        Output:
        ```powershell
        Name   Type
        ----   ----
        Test1  Function
        Test2  Filter
        ```

        Parses the specified script file and identifies function types.

        .EXAMPLE
        Get-AstFunctionType -Script "function Test { param() Write-Output 'Hello' }"

        Output:
        ```powershell
        Name  Type
        ----  ----
        Test Function
        ```

        Parses the provided script content and determines the function type.

        .OUTPUTS
        PSCustomObject

        .NOTES
        Represents the function name and its determined type.

        .LINK
        https://psmodule.io/Ast/Functions/Functions/Get-AstFunctionType/
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The name of the command to search for. Defaults to all commands ('*').
        [Parameter()]
        [string] $Name = '*',

        # The path to the PowerShell script file to be parsed.
        # Validate using Test-Path
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Path'
        )]
        [ValidateScript({ Test-Path -Path $_ })]
        [string] $Path,

        # The PowerShell script to be parsed.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Script'
        )]
        [string] $Script,

        # Search nested functions and script block expressions.
        [Parameter()]
        [switch] $Recurse
    )

    begin {}

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                $functionAst = Get-AstFunction -Name $Name -Path $Path -Recurse:$Recurse
            }
            'Script' {
                $functionAst = Get-AstFunction -Name $Name -Script $Script -Recurse:$Recurse
            }
        }

        $functionAst.Ast | ForEach-Object {
            $type = if ($_.IsWorkflow) {
                'Workflow'
            } elseif ($_.IsConfiguration) {
                'Configuration'
            } elseif ($_.IsFilter) {
                'Filter'
            } else {
                'Function'
            }
            [pscustomobject]@{
                Name = $_.Name
                Type = $type
            }
        }
    }

    end {}
}
