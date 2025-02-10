function Get-ASTFunctionAlias {
    <#

    #>
    [CmdletBinding()]
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
        [ValidateScript({ Test-Path -Path $_ })]
        [string] $Path,

        # The PowerShell script to be parsed.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Script'
        )]
        [string] $Script,

        # Search nested functions and script block expressions.
        [Parameter()]
        [switch] $Recurse
    )

    begin {}

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                $functionAST = Get-ASTFunction -Name $Name -Path $Path -Recurse:$Recurse
            }
            'Script' {
                $functionAST = Get-ASTFunction -Name $Name -Script $Script -Recurse:$Recurse
            }
        }

        # Process each function and extract aliases
        $functionAST | ForEach-Object {
            $funcName = $_.Name
            $funcAttributes = $_.Body.FindAll({ $args[0] -is [System.Management.Automation.Language.AttributeAst] }, $true)

            # Filter only function-level alias attributes
            $aliasAttr = $funcAttributes | Where-Object {
                $_.TypeName.Name -eq 'Alias' -and $_.Parent -is [System.Management.Automation.Language.FunctionDefinitionAst]
            }

            if ($aliasAttr) {
                $aliases = $aliasAttr.PositionalArguments | ForEach-Object { $_.ToString().Trim('"', "'") }
                [PSCustomObject]@{
                    Name  = $funcName
                    Alias = $aliases
                }
            }
        } | Where-Object { $_.Name -like $Name }
    }

    end {}
}
