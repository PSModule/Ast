function Read-AstScriptFile {
    <#
        .SYNOPSIS
        Parses a PowerShell script file and returns its AST, tokens, and errors.

        .DESCRIPTION
        Reads a PowerShell script file and processes it using the PowerShell parser.
        Returns a custom object containing the file path, abstract syntax tree (AST),
        tokens, and any errors encountered during parsing.

        .EXAMPLE
        Read-AstScriptFile -FilePath "C:\Scripts\example.ps1"

        Output:
        ```powershell
        Path   : C:\Scripts\example.ps1
        Ast    : [System.Management.Automation.Language.ScriptBlockAst]
        Tokens : {Token1, Token2, Token3}
        Errors : {}
        ```

        Parses the script file "example.ps1" and returns its AST, tokens, and any parsing errors.

        .OUTPUTS
        PSCustomObject

        .NOTES
        Contains the file path, AST, tokens, and errors.

        .LINK
        https://psmodule.io/Ast/Functions/Read-AstScriptFile/
    #>

    [CmdletBinding()]
    param(
        # The path to the PowerShell script file to parse.
        [Parameter(Mandatory)]
        [string] $FilePath
    )

    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$tokens, [ref]$errors)

    [pscustomobject]@{
        Path   = $FilePath
        Ast    = $ast
        Tokens = $tokens
        Errors = $errors
    }
}
