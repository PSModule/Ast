function Get-ASTFunctionType {
    <#

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
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

        $functionAST | ForEach-Object {
            $type = if ($_.IsWorkflow) {
                'Workflow'
            } elseif ($_.IsConfiguration) {
                'Configuration'
            } elseif ($_.IsFilter) {
                'Filter'
            } else {
                'Function'
            }
            [pscustomobject]@{
                Name = $_.Name
                Type = $type
            }
        }
    }

    end {}
}
