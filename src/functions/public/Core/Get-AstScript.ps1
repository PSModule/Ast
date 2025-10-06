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

        .EXAMPLE
        Get-AstScript -Script @("Write-Host 'Hello'", "Write-Host 'World'")

        Parses multiple PowerShell script strings and returns their Asts.

        .EXAMPLE
        "Write-Host 'Hello'", "Write-Host 'World'" | Get-AstScript

        Parses multiple PowerShell script strings from the pipeline and returns their Asts.

        .EXAMPLE
        Get-ChildItem -Path "C:\\Scripts" -Filter "*.ps1" | Get-AstScript

        Parses all PowerShell script files returned by Get-ChildItem.

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
    [CmdletBinding(DefaultParameterSetName = 'PipelineInput')]
    param (
        # The path(s) to PowerShell script file(s) or folder(s) to be parsed.
        [Parameter(
            Mandatory,
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
        [Parameter(ParameterSetName = 'PipelineInput')]
        [switch] $Recurse,

        # The PowerShell script(s) to be parsed.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Script'
        )]
        [string[]] $Script,

        # Input from pipeline that will be automatically detected as path or script
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ParameterSetName = 'PipelineInput'
        )]
        [string[]] $InputObject
    )

    begin {}

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                foreach ($p in $Path) {
                    # Check if the path is a directory
                    if (Test-Path -Path $p -PathType Container) {
                        Read-AstDirectory -DirPath $p -RecurseDir $Recurse
                    } else {
                        # Path is a file
                        Read-AstScriptFile -FilePath $p
                    }
                }
            }
            'Script' {
                foreach ($scriptContent in $Script) {
                    Read-AstScriptContent -ScriptContent $scriptContent
                }
            }
            'PipelineInput' {
                # Default parameter set for handling pipeline input
                if ($null -ne $InputObject) {
                    foreach ($item in $InputObject) {
                        # Check if input is a file path or directory
                        if (Test-Path -Path $item -ErrorAction SilentlyContinue) {
                            if (Test-Path -Path $item -PathType Container) {
                                Read-AstDirectory -DirPath $item -RecurseDir $Recurse
                            } else {
                                Read-AstScriptFile -FilePath $item
                            }
                        } elseif ($PSBoundParameters.ContainsKey('InputObject') -and
                            $InputObject.PSObject.Properties.Name -contains 'FullName' -and
                               (Test-Path -Path $InputObject.FullName -ErrorAction SilentlyContinue)) {
                            Read-AstScriptFile -FilePath $InputObject.FullName
                        } else {
                            Read-AstScriptContent -ScriptContent $item
                        }
                    }
                }
            }
        }
    }

    end {}
}
