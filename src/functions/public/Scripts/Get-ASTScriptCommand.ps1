function Get-ASTScriptCommand {
    <#
        .SYNOPSIS
        Retrieves the commands used within a specified PowerShell script.

        .DESCRIPTION
        Analyzes a given PowerShell script and extracts all command invocations.
        Optionally includes call operators (& and .) in the results.
        Returns details such as command name, position, and file reference.

        .EXAMPLE
        Get-ASTScriptCommand -Path "C:\Scripts\example.ps1"

        Extracts and lists all commands found in the specified PowerShell script.

        .EXAMPLE
        Get-ASTScriptCommand -Path "C:\Scripts\example.ps1" -IncludeCallOperators

        Extracts all commands, including those executed with call operators (& and .).

        .LINK
        https://psmodule.io/AST/Functions/Scripts/Get-ASTScriptCommand/
    #>
    [CmdletBinding()]
    param (
        # The path to the PowerShell script file to be parsed.
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string] $Path,

        # Include call operators in the results, i.e. & and .
        [Parameter()]
        [switch] $IncludeCallOperators
    )

    # Extract function definitions
    $ast = Get-ASTScript -Path $Path

    # Gather CommandAsts
    $commandAST = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true)

    if (-not $IncludeCallOperators) {
        $commandAST = $commandAST | Where-Object { $_.InvocationOperator -notin 'Ampersand', 'Dot' }
    }

    $commandAST | ForEach-Object {
        $invocationOperator = switch ($_.InvocationOperator) {
            'Ampersand' { '&' }
            'Dot' { '.' }
        }
        $_.CommandElements[0].Extent | ForEach-Object {
            [pscustomobject]@{
                Name              = [string]::IsNullOrEmpty($invocationOperator) ? $_.Text : $invocationOperator
                StartLineNumber   = $_.StartLineNumber
                StartColumnNumber = $_.StartColumnNumber
                EndLineNumber     = $_.EndLineNumber
                EndColumnNumber   = $_.EndColumnNumber
                File              = $_.File
            }
        }
    }
}
