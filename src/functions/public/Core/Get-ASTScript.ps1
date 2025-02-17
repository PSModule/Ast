function Get-AstScript {
    <#
        .SYNOPSIS
        Parses a PowerShell script or script file and returns its abstract syntax tree (AST).

        .DESCRIPTION
        The Get-AstScript function parses a PowerShell script or script file and returns its abstract syntax tree (AST),
        along with tokens and errors encountered during parsing. This function can be used to analyze the structure
        of a script by specifying either the script content directly or the path to a script file.

        .EXAMPLE
        Get-AstScript -Path "C:\\Scripts\\example.ps1"

        Output:
        ```powershell
        Ast    : [System.Management.Automation.Language.ScriptBlockAst]
        Tokens : {Token1, Token2, ...}
        Errors : {Error1, Error2, ...}
        ```

        Parses the PowerShell script located at "C:\\Scripts\\example.ps1" and returns its AST, tokens, and any parsing errors.

        .EXAMPLE
        Get-AstScript -Script "Write-Host 'Hello World'"

        Output:
        ```powershell
        Ast    : [System.Management.Automation.Language.ScriptBlockAst]
        Tokens : {Token1, Token2, ...}
        Errors : {}
        ```

        Parses the provided PowerShell script string and returns its AST, tokens, and any parsing errors.

        .OUTPUTS
        PSCustomObject

        .NOTES
        The returned custom object contains the following properties:
        - `Ast` - [System.Management.Automation.Language.ScriptBlockAst]. The abstract syntax tree (AST) of the parsed script.
        - `Tokens` - [System.Management.Automation.Language.Token[]]. The tokens generated during parsing.
        - `Errors` - [System.Management.Automation.Language.ParseError[]]. Any parsing errors encountered.

        .LINK
        https://psmodule.io/Ast/Functions/Get-AstScript/
    #>
    [outputType([System.Management.Automation.Language.ScriptBlockAst])]
    [CmdletBinding()]
    param (
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
        [string] $Script
    )

    begin {}

    process {
        $tokens = $null
        $errors = $null
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)
            }
            'Script' {
                $ast = [System.Management.Automation.Language.Parser]::ParseInput($Script, [ref]$tokens, [ref]$errors)
            }
        }
        [pscustomobject]@{
            Ast    = $ast
            Tokens = $tokens
            Errors = $errors
        }
    }

    end {}
}
