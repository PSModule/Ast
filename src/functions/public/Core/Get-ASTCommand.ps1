function Get-ASTCommand {
    [CmdletBinding()]
    param (
        # The name of the command to search for. Defaults to all commands ('*').
        [Parameter()]
        [string] $Name = '*',

        # The path to the PowerShell script file to be parsed.
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [string] $Path
    )

    begin {}

    process {
        # Parse the script file into an AST
        $ast = Get-ASTScript -Path $Path

        # Extract function definitions
        $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true) | Where-Object { $_.Name -like $Name }
    }

    end {}
}
