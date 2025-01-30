function Get-FunctionName {
    <#
        .SYNOPSIS
        Extracts function names from a specified PowerShell script.

        .DESCRIPTION
        Parses the given PowerShell script file and retrieves all function names
        defined within it. This function utilizes the PowerShell Abstract Syntax Tree (AST)
        to analyze the script and extract function definitions.

        .EXAMPLE
        Get-FunctionName -Path "C:\Scripts\MyScript.ps1"

        Retrieves all function names defined in the specified script file.

        .NOTES
        Uses PowerShell's AST to analyze script structure.
    #>

    [CmdletBinding()]
    param (
        # The path to the script file to parse
        [Parameter(Mandatory)]
        [string] $Path
    )

    # Parse the script file into an AST
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$null, [ref]$null)

    # Extract function definitions
    $functions = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)

    # Process each function and extract the name
    $functions | ForEach-Object {
        $_.Name
    }
}
