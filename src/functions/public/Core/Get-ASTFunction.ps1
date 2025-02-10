function Get-AstFunction {
    <#

    #>
    [CmdletBinding(DefaultParameterSetName = 'Ast')]
    param (
        # The name of the function to search for. Defaults to all functions ('*').
        [Parameter()]
        [string] $Name = '*',

        # The path to the PowerShell script file to be parsed.
        # Validate using Test-Path
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Path'
        )]
        [string] $Path,

        # The PowerShell script to be parsed.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Script'
        )]
        [string] $Script,

        # An existing AST object to search.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Ast'
        )]
        [System.Management.Automation.Language.Ast] $Ast,

        # Search nested functions and script block expressions.
        [Parameter()]
        [switch] $Recurse
    )

    begin {}

    process {
        $scriptAst = @()
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                $scriptAst += (Get-AstScript -Path $Path).Ast
            }
            'Script' {
                $scriptAst += (Get-AstScript -Script $Script).Ast
            }
            'Ast' {
                $scriptAst += $Ast
            }
        }

        # Extract function definitions
        $ast = foreach ($astItem in $scriptAst) {
            $astItem.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $Recurse) |
                Where-Object { $_.Name -like $Name }
        }
    }

    end {
        [pscustomobject]@{
            Ast    = @($ast)
            Tokens = $scriptAst.tokens
            Errors = $scriptAst.errors
        }
    }
}
