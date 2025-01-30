﻿Describe 'Core' {
    Context "Function: 'Get-ScriptAST'" {
        It 'Get-ScriptAST gets the script AST' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $ast = Get-ScriptAST -Path $path
            $ast | Should -Not -BeNullOrEmpty
            $ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
        }
    }
    Context "Function: 'Get-FunctionAST'" {
        It 'Get-FunctionAST gets the function AST' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $ast = Get-FunctionAST -Path $path
            $ast | Should -Not -BeNullOrEmpty
            $ast | Should -BeOfType [System.Management.Automation.Language.FunctionDefinitionAst]
        }
    }
}


Descripbe 'Functions' {
    Context "Function: 'Get-FunctionType'" {
        It 'Get-FunctionAlias gets the function alias' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionType = Get-FunctionType -Path $path
            $functionType | Should -Be 'Function'
        }
    }
    Context "Function: 'Get-FunctionName'" {
        It 'Get-FunctionName gets the function name' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionName = Get-FunctionName -Path $path
            $functionName | Should -Be 'Test-Function'
        }
    }
    Context "Function: 'Get-FunctionAlias'" {
        It 'Get-FunctionAlias gets the function alias' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionAlias = Get-FunctionAlias -Path $path
            $functionAlias.Alias | Should -Contain 'Test'
            $functionAlias.Alias | Should -Contain 'TestFunc'
            $functionAlias.Alias | Should -Contain 'Test-Func'
        }
    }
}
