function Get-AstScript {
    <#
        .SYNOPSIS
        Parses a PowerShell script or script file and returns its abstract syntax tree (Ast).

        .DESCRIPTION
        The Get-AstScript function parses a PowerShell script or script file and returns its abstract syntax tree (Ast),
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

        Parses the PowerShell script located at "C:\\Scripts\\example.ps1" and returns its Ast, tokens, and any parsing errors.

        .EXAMPLE
        Get-AstScript -Script "Write-Host 'Hello World'"

        Output:
        ```powershell
        Ast    : [System.Management.Automation.Language.ScriptBlockAst]
        Tokens : {Token1, Token2, ...}
        Errors : {}
        ```

        Parses the provided PowerShell script string and returns its Ast, tokens, and any parsing errors.

        .EXAMPLE
        Get-AstScript -Path "C:\\Scripts" -Recurse

        Parses all PowerShell script files in the "C:\\Scripts" directory and its subdirectories.

        .EXAMPLE
        Get-AstScript -Path @("C:\\Scripts\\example.ps1", "C:\\Scripts\\example2.ps1")

        Parses multiple PowerShell script files and returns their Asts.

        .OUTPUTS
        PSCustomObject

        .NOTES
        The returned custom object contains the following properties:
        - `Ast` - [System.Management.Automation.Language.ScriptBlockAst]. The abstract syntax tree (Ast) of the parsed script.
        - `Tokens` - [System.Management.Automation.Language.Token[]]. The tokens generated during parsing.
        - `Errors` - [System.Management.Automation.Language.ParseError[]]. Any parsing errors encountered.

        .LINK
        https://psmodule.io/Ast/Functions/Core/Get-AstScript/
    #>
    [outputType([System.Management.Automation.Language.ScriptBlockAst])]
    [CmdletBinding()]
    param (
        # The path(s) to PowerShell script file(s) or folder(s) to be parsed.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Path'
        )]
        [ValidateScript({
                foreach ($p in $_) {
                    if (-not (Test-Path -Path $p)) { return $false }
                }
                return $true
            })]
        [string[]] $Path,

        # Process directories recursively
        [Parameter(ParameterSetName = 'Path')]
        [switch] $Recurse,

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
                foreach ($p in $Path) {
                    # Check if the path is a directory
                    if (Test-Path -Path $p -PathType Container) {
                        # Get all .ps1 files in the directory
                        $files = Get-ChildItem -Path $p -Filter '*.ps1' -File -Recurse:$Recurse

                        foreach ($file in $files) {
                            $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
                            [pscustomobject]@{
                                Path   = $file.FullName
                                Ast    = $ast
                                Tokens = $tokens
                                Errors = $errors
                            }
                        }
                    } else {
                        # Path is a file
                        $ast = [System.Management.Automation.Language.Parser]::ParseFile($p, [ref]$tokens, [ref]$errors)
                        [pscustomobject]@{
                            Path   = $p
                            Ast    = $ast
                            Tokens = $tokens
                            Errors = $errors
                        }
                    }
                }
            }
            'Script' {
                $ast = [System.Management.Automation.Language.Parser]::ParseInput($Script, [ref]$tokens, [ref]$errors)
                [pscustomobject]@{
                    Ast    = $ast
                    Tokens = $tokens
                    Errors = $errors
                }
            }
        }
    }

    end {}
}
