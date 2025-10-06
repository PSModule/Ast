function Get-AstFunctionName {
    <#
        .SYNOPSIS
        Retrieves the names of functions from an abstract syntax tree (Ast) in a PowerShell script.

        .DESCRIPTION
        Parses a PowerShell script file or script content to extract function names using an abstract syntax tree (Ast).
        The function supports searching by name, parsing from a file path, or directly from a script string. It can also
        search within nested functions and script block expressions when the -Recurse switch is used.

        .EXAMPLE
        Get-AstFunctionName -Path "C:\Scripts\example.ps1"

        Output:
        ```powershell
        Get-Data
        Set-Configuration
        ```

        Extracts function names from the specified PowerShell script file.

        .EXAMPLE
        Get-AstFunctionName -Script "function Test-Function { param($x) Write-Host $x }"

        Output:
        ```powershell
        Test-Function
        ```

        Extracts function names from the given script string.

        .EXAMPLE
        Get-AstFunctionName -Path "C:\Scripts\example.ps1" -Recurse

        Output:
        ```powershell
        Get-Data
        Set-Configuration
        Helper-Function
        ```

        Extracts function names from the specified script file, including nested functions.

        .OUTPUTS
        System.String

        Description is here?

        .NOTES
        The name of each function found in the PowerShell script.

        .LINK
        https://psmodule.io/Ast/Functions/Functions/Get-AstFunctionName/
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
                $functionAst = Get-AstFunction -Name $Name -Path $Path -Recurse:$Recurse
            }
            'Script' {
                $functionAst = Get-AstFunction -Name $Name -Script $Script -Recurse:$Recurse
            }
        }

        # Process each function and extract the name
        $functionAst.Ast | ForEach-Object {
            $_.Name
        }
    }

    end {}
}
