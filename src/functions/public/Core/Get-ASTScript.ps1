function Get-ScriptAST {
    <#
        .SYNOPSIS
        Parses a PowerShell script or script file and returns its Abstract Syntax Tree (AST).

        .DESCRIPTION
        This function parses a PowerShell script from a file or a string input and returns its AST.
        It can optionally provide token and error information.

        .EXAMPLE
        Get-ScriptAST -Path "C:\Scripts\MyScript.ps1"

        Parses the PowerShell script at "MyScript.ps1" and returns its AST.

        .EXAMPLE
        Get-ScriptAST -Script "Get-Process | Select-Object Name"

        Parses the provided PowerShell script string and returns its AST.

        .EXAMPLE
        Get-ScriptAST -Path "C:\Scripts\MyScript.ps1" -Tokens ([ref]$tokens) -Errors ([ref]$errors)

        Parses the script file while also capturing tokens and errors.

        .LINK
        https://psmodule.io/AST/Functions/Core/Get-ScriptAST/
    #>
    [outputType([System.Management.Automation.Language.ScriptBlockAst])]
    [CmdletBinding()]
    param (
        # The path to the PowerShell script file to be parsed.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Path'
        )]
        # Validate using Test-Path
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string] $Path,

        # The PowerShell script to be parsed.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Script'
        )]
        [string] $Script,

        # Reference variable to store parsed tokens.
        [Parameter()]
        [ref] $Tokens,

        # Reference variable to store parsing errors.
        [Parameter()]
        [ref] $Errors
    )

    begin {}

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$Tokens, [ref]$Errors)
            }
            'Script' {
                [System.Management.Automation.Language.Parser]::ParseInput($Script, [ref]$Tokens, [ref]$Errors)
            }
        }
    }

    end {}
}
