function Get-AstCommand {
    <#
        .SYNOPSIS
        Retrieves command AST (Abstract Syntax Tree) elements from a PowerShell script or AST object.

        .DESCRIPTION
        This function extracts and returns command AST elements from a specified PowerShell script file,
        script content, or an existing AST object. The function supports multiple input methods, including
        direct script text, file paths, or existing AST objects. It also provides an option to search nested
        functions and script block expressions.

        .EXAMPLE
        Get-AstCommand -Path "C:\Scripts\MyScript.ps1"

        Output:
        ```powershell
        Ast    : {@{Name=Get-Process; Extent=...}, @{Name=Write-Host; Extent=...}}
        Tokens : {...}
        Errors : {}
        ```

        Parses the specified script file and extracts command AST elements.

        .EXAMPLE
        Get-AstCommand -Script "Get-Process; Write-Host 'Hello'"

        Output:
        ```powershell
        Ast    : {@{Name=Get-Process; Extent=...}, @{Name=Write-Host; Extent=...}}
        Tokens : {...}
        Errors : {}
        ```

        Parses the provided script content and extracts command AST elements.

        .EXAMPLE
        $ast = [System.Management.Automation.Language.Parser]::ParseInput("Get-Process", [ref]$null, [ref]$null)
        Get-AstCommand -Ast $ast

        Output:
        ```powershell
        Ast    : {@{Name=Get-Process; Extent=...}}
        Tokens : {...}
        Errors : {}
        ```

        Extracts command AST elements from a manually parsed AST object.

        .OUTPUTS
        PSCustomObject

        .NOTES
        Returns an object containing extracted AST elements, tokens, and errors.

        .LINK
        https://psmodule.io/Ast/Functions/Core/Get-AstCommand/
    #>
    [CmdletBinding(DefaultParameterSetName = 'Ast')]
    param (
        # The name of the command to search for. Defaults to all commands ('*').
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
            $astItem.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $Recurse) |
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
