function Get-AstScriptCommand {
    <#
        .SYNOPSIS
        Retrieves the commands used within a specified PowerShell script.

        .DESCRIPTION
        Analyzes a given PowerShell script and extracts all command invocations.
        Optionally includes call operators (& and .) in the results.
        Returns details such as command name, position, and file reference.

        .EXAMPLE
        Get-AstScriptCommand -Path "C:\Scripts\example.ps1"

        Extracts and lists all commands found in the specified PowerShell script.

        .EXAMPLE
        Get-AstScriptCommand -Path "C:\Scripts\example.ps1" -IncludeCallOperators

        Extracts all commands, including those executed with call operators (& and .).

        .LINK
        https://psmodule.io/Ast/Functions/Scripts/Get-AstScriptCommand/
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

        # An existing Ast object to search.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Ast'
        )]
        [System.Management.Automation.Language.Ast] $Ast,

        # Search nested functions and script block expressions.
        [Parameter()]
        [switch] $Recurse,

        # Include call operators in the results, i.e. & and .
        [Parameter()]
        [switch] $IncludeCallOperators
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

        # Gather CommandAsts
        $commandAst = $scriptAst.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $Recurse)

        if (-not $IncludeCallOperators) {
            $commandAst = $commandAst | Where-Object { $_.InvocationOperator -notin 'Ampersand', 'Dot' }
        }

        $commandAst | ForEach-Object {
            $invocationOperator = switch ($_.InvocationOperator) {
                'Ampersand' { '&' }
                'Dot' { '.' }
            }
            $_.CommandElements[0].Extent | Where-Object { $_.Text -like $Name } | ForEach-Object {
                [pscustomobject]@{
                    Name              = if ([string]::IsNullOrEmpty($invocationOperator)) { $_.Text } else { $invocationOperator }
                    StartLineNumber   = $_.StartLineNumber
                    StartColumnNumber = $_.StartColumnNumber
                    EndLineNumber     = $_.EndLineNumber
                    EndColumnNumber   = $_.EndColumnNumber
                    File              = $_.File
                }
            }
        }
    }

    end {}
}
