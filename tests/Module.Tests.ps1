Describe 'Module' {
    BeforeAll{
        $path = Join-Path $PSScriptRoot 'Test-Function.ps1'
    }
    Context "Function: 'Get-FunctionName'" {
        It 'Get-FunctionName gets the function name' {
            $functionName = Get-FunctionName -Path $path
            $functionName | Should -Be 'Get-FunctionName'
        }
    }
    Context "Function: 'Get-FunctionAlias'" {
        It 'Get-FunctionAlias gets the function alias' {
            $functionAlias = Get-FunctionAlias -Path $path
            $functionAlias | Should -Be 'Test'
        }
    }
}
