#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

Describe 'Core' {
    Context "Function: 'Get-AstScript'" {
        It 'Get-AstScript gets the script AST' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $script = Get-AstScript -Path $path
            $script | Should -Not -BeNullOrEmpty
            $script.Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
        }

        It 'Get-AstScript gets the script AST - with pipeline input' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $script = $path | Get-AstScript
            $script | Should -Not -BeNullOrEmpty
            $script.Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
        }

        It 'Get-AstScript gets the script AST - with script content parameter' {
            $scriptContent = 'function Test-Script { param($Param1) Write-Output $Param1 }'
            $script = Get-AstScript -Script $scriptContent
            $script | Should -Not -BeNullOrEmpty
            $script.Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
        }

        It 'Get-AstScript gets the script AST - with script content pipeline input' {
            $scriptContent = 'function Test-Script { param($Param1) Write-Output $Param1 }'
            $script = $scriptContent | Get-AstScript
            $script | Should -Not -BeNullOrEmpty
            $script.Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
        }

        It 'Get-AstScript processes an array of paths - parameter input' {
            $paths = @(
                (Join-Path $PSScriptRoot 'src\Test-Function.ps1'),
                (Join-Path $PSScriptRoot 'src\Test-MultipleAliases.ps1')
            )
            $scripts = Get-AstScript -Path $paths
            $scripts | Should -HaveCount 2
            $scripts[0].Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
            $scripts[1].Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
        }

        It 'Get-AstScript processes an array of paths - pipeline input' {
            $paths = @(
                (Join-Path $PSScriptRoot 'src\Test-Function.ps1'),
                (Join-Path $PSScriptRoot 'src\Test-MultipleAliases.ps1')
            )
            $scripts = $paths | Get-AstScript
            $scripts | Should -HaveCount 2
            $scripts[0].Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
            $scripts[1].Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
        }

        It 'Get-AstScript processes an array of script content - parameter input' {
            $scriptContents = @(
                'function Test-Script1 { Write-Output "Test1" }',
                'function Test-Script2 { Write-Output "Test2" }'
            )
            $scripts = Get-AstScript -Script $scriptContents
            $scripts | Should -HaveCount 2
            $scripts[0].Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
            $scripts[1].Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
        }

        It 'Get-AstScript processes an array of script content - pipeline input' {
            $scriptContents = @(
                'function Test-Script1 { Write-Output "Test1" }',
                'function Test-Script2 { Write-Output "Test2" }'
            )
            $scripts = $scriptContents | Get-AstScript
            $scripts | Should -HaveCount 2
            $scripts[0].Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
            $scripts[1].Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
        }

        It 'Get-AstScript processes a folder and returns script ASTs for all PS1 files - parameter input' {
            $srcFolder = Join-Path $PSScriptRoot 'src'
            $scripts = Get-AstScript -Path $srcFolder
            $scripts | Should -Not -BeNullOrEmpty
            $scripts.Count | Should -BeGreaterThan 1
            $scripts | ForEach-Object {
                $_.Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
            }
        }

        It 'Get-AstScript processes a folder and returns script ASTs for all PS1 files - pipeline input' {
            $srcFolder = Join-Path $PSScriptRoot 'src'
            $scripts = $srcFolder | Get-AstScript
            $scripts | Should -Not -BeNullOrEmpty
            $scripts.Count | Should -BeGreaterThan 1
            $scripts | ForEach-Object {
                $_.Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
            }
        }

        It 'Get-AstScript processes mixed input of files and folders - parameter input' {
            $paths = @(
                (Join-Path $PSScriptRoot 'src\Test-Function.ps1'),
                (Join-Path $PSScriptRoot 'src\Functions')
            )
            $scripts = Get-AstScript -Path $paths
            $scripts | Should -Not -BeNullOrEmpty
            $scripts.Count | Should -BeGreaterThan 2
            $scripts | ForEach-Object {
                $_.Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
            }
        }
    }
    Context "Function: 'Get-AstFunction'" {
        It 'Get-AstFunction gets the function AST' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $function = Get-AstFunction -Path $path
            $function | Should -Not -BeNullOrEmpty
            $function.Ast | Should -BeOfType [System.Management.Automation.Language.FunctionDefinitionAst]
        }
    }
    Context "Function: 'Get-AstCommand'" {
        It 'Get-AstCommand gets the command AST' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $command = Get-AstCommand -Path $path
            $command | Should -Not -BeNullOrEmpty
            $command.Ast | Should -BeOfType [System.Management.Automation.Language.CommandAst]
        }
    }
}

Describe 'Functions' {
    Context "Function: 'Get-AstFunctionType'" {
        It 'Get-AstFunctionType gets the function type' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionType = Get-AstFunctionType -Path $path
            $functionType.Type | Should -Be 'Function'
        }
    }
    Context "Function: 'Get-AstFunctionName'" {
        It 'Get-AstFunctionName gets the function name' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionName = Get-AstFunctionName -Path $path
            $functionName | Should -Be 'Test-Function'
        }
    }
    Context "Function: 'Get-AstFunctionAlias'" {
        It 'Get-AstFunctionAlias gets the function alias' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionAlias = Get-AstFunctionAlias -Path $path
            $functionAlias.Alias | Should -Contain 'Test'
            $functionAlias.Alias | Should -Contain 'TestFunc'
            $functionAlias.Alias | Should -Contain 'Test-Func'
        }
    }
}

Describe 'Lines' {
    Context 'Function: Get-AstLineComment' {
        It 'Get-AstLineComment gets the line comment' {
            $line = '# This is a comment'
            $line = Get-AstLineComment -Line $line
            $line | Should -Be '# This is a comment'
        }
        It 'Get-AstLineComment gets the line comment without leading whitespace' {
            $line = '    # This is a comment'
            $line = Get-AstLineComment -Line $line
            $line | Should -Be '# This is a comment'
        }
        It 'Get-AstLineComment gets the line comment but not the command' {
            $line = '    Get-Command # This is a comment    '
            $line = Get-AstLineComment -Line $line
            $line | Should -Be '# This is a comment    '
        }
        It 'Get-AstLineComment returns nothing when no comment is present' {
            $line = 'Get-Command'
            $line | Get-AstLineComment | Should -BeNullOrEmpty
        }
    }
}

Describe 'Scripts' {
    Context "Function: 'Get-AstScriptCommands'" {
        It 'Get-AstScriptCommands gets the script commands' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-AstScriptCommand -Path $path
            $commands | Should -Not -BeNullOrEmpty
            $commands | Should -BeOfType [pscustomobject]
            $commands.Name | Should -Not -Contain 'ForEach-Object'
            $commands.Name | Should -Not -Contain 'Get-Process'
            $commands.Name | Should -Not -Contain 'ipmo'
            $commands.Name | Should -Contain 'Register-ArgumentCompleter'
            $commands.Name | Should -Not -Contain '.'
            $commands.Name | Should -Not -Contain '&'
        }
        It 'Get-AstScriptCommands gets the script commands (recursive)' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-AstScriptCommand -Path $path -Recurse
            $commands | Should -Not -BeNullOrEmpty
            $commands | Should -BeOfType [pscustomobject]
            $commands.Name | Should -Contain 'ForEach-Object'
            $commands.Name | Should -Contain 'Get-Process'
            $commands.Name | Should -Contain 'ipmo'
            $commands.Name | Should -Contain 'Register-ArgumentCompleter'
            $commands.Name | Should -Not -Contain '.'
            $commands.Name | Should -Not -Contain '&'
        }
        It 'Get-AstScriptCommands gets the script commands with call operators' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-AstScriptCommand -Path $path -IncludeCallOperators
            $commands | Should -Not -BeNullOrEmpty
            $commands | Should -BeOfType [pscustomobject]
            $commands.Name | Should -Not -Contain 'ForEach-Object'
            $commands.Name | Should -Not -Contain 'Get-Process'
            $commands.Name | Should -Not -Contain 'ipmo'
            $commands.Name | Should -Contain 'Register-ArgumentCompleter'
            $commands.Name | Should -Not -Contain '.'
            $commands.Name | Should -Not -Contain '&'
        }
        It 'Get-AstScriptCommands gets the script commands with call operators (recursive)' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-AstScriptCommand -Path $path -Recurse -IncludeCallOperators
            $commands | Should -Not -BeNullOrEmpty
            $commands | Should -BeOfType [pscustomobject]
            $commands.Name | Should -Contain 'ForEach-Object'
            $commands.Name | Should -Contain 'Get-Process'
            $commands.Name | Should -Contain 'ipmo'
            $commands.Name | Should -Contain 'Register-ArgumentCompleter'
            $commands.Name | Should -Contain '.'
            $commands.Name | Should -Contain '&'
        }
    }
}
