function Get-ASTFunctionAlias {
    <#
        .SYNOPSIS
        Retrieves function aliases from a PowerShell script or file.

        .DESCRIPTION
        This function parses a PowerShell script or file to extract function definitions
        and identify any aliases assigned to them via the `[Alias()]` attribute.
        It supports searching by function name and allows recursive searching
        within nested functions and script blocks.

        .EXAMPLE
        Get-ASTFunctionAlias -Path "C:\Scripts\MyScript.ps1" -Name "Get-User"

        Output:
        ```powershell
        Name       Alias
        ----       -----
        Get-User   {RetrieveUser, FetchUser}
        ```

        Retrieves aliases assigned to the function `Get-User` within the specified script file.

        .EXAMPLE
        Get-ASTFunctionAlias -Script $scriptContent -Recurse

        Output:
        ```powershell
        Name       Alias
        ----       -----
        Get-Data   {FetchData, RetrieveData}
        ```

        Searches for function aliases within the provided script content, including nested functions.

        .OUTPUTS
        PSCustomObject

        .NOTES
        An object containing the function name and its associated aliases.

        .LINK
        https://psmodule.io/AST/Functions/Functions/Get-ASTFunctionAlias
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
        $functionAST.Ast | ForEach-Object {
            $funcName = $_.Name
            $funcAttributes = $_.Body.FindAll({ $args[0] -is [System.Management.Automation.Language.AttributeAst] }, $true) | Where-Object {
                $_.Parent -is [System.Management.Automation.Language.ParamBlockAst]
            }
            $aliasAttr = $funcAttributes | Where-Object { $_.TypeName.Name -eq 'Alias' }

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
