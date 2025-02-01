function Get-FunctionAST {
    <#
        .SYNOPSIS
        Retrieves the abstract syntax tree (AST) of function definitions from a PowerShell script.

        .DESCRIPTION
        Parses a specified PowerShell script file and extracts function definitions matching the given name.
        By default, it returns all function definitions if no specific name is provided.

        .EXAMPLE
        Get-FunctionAST -Path "C:\Scripts\MyScript.ps1"

        Retrieves all function definitions from "MyScript.ps1".

        .EXAMPLE
        Get-FunctionAST -Name "Get-Data" -Path "C:\Scripts\MyScript.ps1"

        Retrieves only the function definition named "Get-Data" from "MyScript.ps1".

        .LINK
        https://psmodule.io/AST/Functions/Core/Get-FunctionAST/
    #>
    [CmdletBinding()]
    param (
        # The name of the function to search for. Defaults to all functions ('*').
        [Parameter()]
        [string] $Name = '*',

        # The path to the PowerShell script file to be parsed.
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string] $Path
    )

    begin {}

    process {
        # Parse the script file into an AST
        $ast = Get-ScriptAST -Path $Path

        # Extract function definitions
        $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) | Where-Object { $_.Name -like $Name }
    }

    end {}
}
