function Get-ASTFunctionAlias {
    <#
        .SYNOPSIS
        Retrieves function aliases from a PowerShell script file.

        .DESCRIPTION
        Parses a specified PowerShell script file to identify function definitions and extract their associated aliases.
        Returns a custom object containing function names and their corresponding aliases.

        .EXAMPLE
        Get-ASTFunctionAlias -Path "C:\Scripts\MyScript.ps1"

        Retrieves all function aliases defined in the specified script file.

        .EXAMPLE
        Get-ASTFunctionAlias -Name "Get-Data" -Path "C:\Scripts\MyScript.ps1"

        Retrieves the alias information for the function named "Get-Data" from the specified script file.

        .LINK
        https://psmodule.io/AST/Functions/Functions/Get-ASTFunctionAlias/
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

    # Extract function definitions
    $functions = Get-FunctionAST -Path $Path

    # Process each function and extract aliases
    $functions | ForEach-Object {
        $funcName = $_.Name
        $funcAttributes = $_.Body.FindAll({ $args[0] -is [System.Management.Automation.Language.AttributeAst] }, $true)

        # Filter only function-level alias attributes
        $aliasAttr = $funcAttributes | Where-Object {
            $_.TypeName.Name -eq 'Alias' -and $_.Parent -is [System.Management.Automation.Language.FunctionDefinitionAst]
        }

        if ($aliasAttr) {
            $aliases = $aliasAttr.PositionalArguments | ForEach-Object { $_.ToString().Trim('"', "'") }
            [PSCustomObject]@{
                Name  = $funcName
                Alias = $aliases
            }
        }
    } | Where-Object { $_.Name -like $Name }
}
