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

        .LINK
        https://psmodule.io/AST/Functions/Functions/Get-FunctionName/
    #>

    [CmdletBinding()]
    param (
        # The path to the script file to parse
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string] $Path
    )

    # Extract function definitions
    $functions = Get-FunctionAST -Path $Path

    # Process each function and extract the name
    $functions | ForEach-Object {
        $_.Name
    }
}
