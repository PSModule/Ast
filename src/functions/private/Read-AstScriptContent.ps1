function Read-AstScriptContent {
    <#
        .SYNOPSIS
        Parses a PowerShell script and returns its abstract syntax tree (AST), tokens, and errors.

        .DESCRIPTION
        This function takes a PowerShell script as a string and parses it using the PowerShell language parser.
        It returns an object containing the AST representation, tokens, and any syntax errors.

        .EXAMPLE
        $script = "Get-Process"
        Read-AstScriptContent -ScriptContent $script

        Output:
        ```powershell
        Ast    : [System.Management.Automation.Language.ScriptBlockAst]
        Tokens : {Get-Process, EndOfInput}
        Errors : {}
        ```

        Parses the provided script and returns the abstract syntax tree, tokens, and errors.

        .OUTPUTS
        PSCustomObject

        .NOTES
        An object containing the AST, tokens, and errors from parsing the script.

        .LINK
        https://psmodule.io/Ast/Functions/Read-AstScriptContent/
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The PowerShell script content to parse.
        [Parameter(Mandatory)]
        [string] $ScriptContent
    )

    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($ScriptContent, [ref]$tokens, [ref]$errors)

    [pscustomobject]@{
        Ast    = $ast
        Tokens = $tokens
        Errors = $errors
    }
}
