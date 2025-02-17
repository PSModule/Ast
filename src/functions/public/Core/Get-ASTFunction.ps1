function Get-AstFunction {
    <#
        .SYNOPSIS
        Retrieves function definitions from a PowerShell script or AST.

        .DESCRIPTION
        This function extracts function definitions from a given PowerShell script file, script content,
        or an existing AST (Abstract Syntax Tree) object. It supports searching by function name
        and can optionally search within nested functions and script block expressions.

        .EXAMPLE
        Get-AstFunction -Path "C:\Scripts\MyScript.ps1"

        Output:
        ```powershell
        Ast    : {FunctionDefinitionAst, FunctionDefinitionAst}
        Tokens : {...}
        Errors : {}
        ```

        Retrieves function definitions from the specified script file.

        .EXAMPLE
        Get-AstFunction -Script "$scriptContent"

        Output:
        ```powershell
        Ast    : {FunctionDefinitionAst}
        Tokens : {...}
        Errors : {}
        ```

        Parses and retrieves function definitions from the provided script content.

        .EXAMPLE
        $ast = Get-AstScript -Path "C:\Scripts\MyScript.ps1" | Select-Object -ExpandProperty Ast
        Get-AstFunction -Ast $ast

        Output:
        ```powershell
        Ast    : {FunctionDefinitionAst}
        Tokens : {...}
        Errors : {}
        ```

        Extracts function definitions from an existing AST object.

        .OUTPUTS
        PSCustomObject

        .NOTES
        Contains AST objects, tokenized script content, and parsing errors if any.

        .LINK
        https://psmodule.io/Ast/Functions/Get-AstFunction
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
