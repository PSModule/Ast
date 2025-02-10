function Get-AstScript {
    <#

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
