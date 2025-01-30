Describe 'Module' {
    Context "Function: 'Get-FunctionName'" {
        It 'Get-FunctionName gets the function name' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionName = Get-FunctionName -Path $path
            $functionName | Should -Be 'Get-FunctionName'
        }
    }
    Context "Function: 'Get-FunctionAlias'" {
        It 'Get-FunctionAlias gets the function alias' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionAlias = Get-FunctionAlias -Path $path
            $functionAlias | Should -Be 'Test'
        }
    }
}
