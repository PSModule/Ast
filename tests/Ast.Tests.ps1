#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

BeforeAll {
    # Set paths for test files
    $testSamplesDir = Join-Path -Path $PSScriptRoot -ChildPath 'src\Get-AstScript-Samples'
    $testScript1 = Join-Path -Path $testSamplesDir -ChildPath 'TestScript1.ps1'
    $testScript2 = Join-Path -Path $testSamplesDir -ChildPath 'TestScript2.ps1'
    $subfolderScript = Join-Path -Path $testSamplesDir -ChildPath 'Subfolder\TestScript3.ps1'

    # Create a temp folder for additional tests
    $tempFolder = Join-Path -Path $TestDrive -ChildPath 'TempScripts'
    New-Item -Path $tempFolder -ItemType Directory -Force | Out-Null

    # Create some test scripts in the temp folder
    @'
function Get-Something {
    param($param1)
    Write-Output $param1
}
'@ | Out-File -FilePath (Join-Path -Path $tempFolder -ChildPath 'Script1.ps1')

    @'
function Set-Something {
    param($value)
    $global:testValue = $value
}
'@ | Out-File -FilePath (Join-Path -Path $tempFolder -ChildPath 'Script2.ps1')

    # Create a subfolder with a script
    $subFolder = Join-Path -Path $tempFolder -ChildPath 'SubFolder'
    New-Item -Path $subFolder -ItemType Directory -Force | Out-Null

    @'
function Test-Something {
    return $true
}
'@ | Out-File -FilePath (Join-Path -Path $subFolder -ChildPath 'Script3.ps1')

    # Also create a non-PS1 file that should be ignored
    "This is not a PowerShell script" | Out-File -FilePath (Join-Path -Path $tempFolder -ChildPath 'NotAScript.txt')

    # Create a new test script with multiple commands
    $multiCommandScriptPath = Join-Path -Path $TestDrive -ChildPath 'MultiCommandScript.ps1'
    @'
function Test-MultiCommand {
    param($value)

    Get-Process | Where-Object { $_.WorkingSet -gt 100MB }
    Write-Host "Testing commands"
    Invoke-Command -ScriptBlock { Get-Service }
}
'@ | Out-File -FilePath $multiCommandScriptPath

    # Create a file with multiple functions for testing
    $multiFunctionScriptPath = Join-Path -Path $TestDrive -ChildPath 'MultiFunctionScript.ps1'
    @'
function Get-Something {
    param($param1)
    Write-Output $param1
}

function Set-Something {
    param($value)
    $global:testValue = $value
}

function Private-Helper {
    # Hidden helper function
    return $true
}
'@ | Out-File -FilePath $multiFunctionScriptPath

    # Create test scripts with different function types
    $functionTypesPath = Join-Path -Path $TestDrive -ChildPath 'FunctionTypes.ps1'
    @'
function Regular-Function {
    param($param1)
    Write-Output $param1
}

filter Filter-Function {
    $_ | Where-Object { $_ -gt 5 }
}

workflow Test-Workflow {
    param($items)
    foreach -parallel ($item in $items) {
        Write-Output $item
    }
}

configuration Test-Configuration {
    param($ComputerName)

    Node $ComputerName {
        File TestFile {
            DestinationPath = "C:\test.txt"
            Contents = "Test content"
        }
    }
}
'@ | Out-File -FilePath $functionTypesPath

    # Create another file for testing multiple files with function types
    $secondTypesFilePath = Join-Path -Path $TestDrive -ChildPath 'SecondFunctionTypes.ps1'
    @'
function Another-Function {
    # Regular function
}

filter Another-Filter {
    # Filter function
}
'@ | Out-File -FilePath $secondTypesFilePath

    # Create a folder structure for testing recursion with function types
    $typesFolder = Join-Path -Path $TestDrive -ChildPath 'FunctionTypesFolder'
    New-Item -Path $typesFolder -ItemType Directory -Force | Out-Null
    Copy-Item -Path $functionTypesPath -Destination $typesFolder

    $typesSubfolder = Join-Path -Path $typesFolder -ChildPath 'SubFolder'
    New-Item -Path $typesSubfolder -ItemType Directory -Force | Out-Null

    $typesSubfolderFilePath = Join-Path -Path $typesSubfolder -ChildPath 'SubFile.ps1'
    @'
function Nested-Function {
    # Nested function
}

filter Nested-Filter {
    # Nested filter
}
'@ | Out-File -FilePath $typesSubfolderFilePath

    # Create test scripts with function aliases
    $functionAliasPath = Join-Path -Path $TestDrive -ChildPath 'FunctionAlias.ps1'
    @'
function Get-Something {
    [Alias("gs", "getSomething")]
    param($param1)
    Write-Output $param1
}

function Set-Something {
    [Alias("ss")]
    param($value)
    $global:testValue = $value
}

function Test-NoAlias {
    param($test)
    # This function has no alias
}
'@ | Out-File -FilePath $functionAliasPath

    # Create another file for testing multiple files with aliases
    $secondAliasFilePath = Join-Path -Path $TestDrive -ChildPath 'SecondAliasFile.ps1'
    @'
function Get-AnotherThing {
    [Alias("gat", "getAnother")]
    param($item)
    return $item
}
'@ | Out-File -FilePath $secondAliasFilePath

    # Create a folder structure for testing recursion with aliases
    $aliasFolder = Join-Path -Path $TestDrive -ChildPath 'AliasFolder'
    New-Item -Path $aliasFolder -ItemType Directory -Force | Out-Null
    Copy-Item -Path $functionAliasPath -Destination $aliasFolder

    $aliasSubfolder = Join-Path -Path $aliasFolder -ChildPath 'SubFolder'
    New-Item -Path $aliasSubfolder -ItemType Directory -Force | Out-Null

    $aliasSubfolderFilePath = Join-Path -Path $aliasSubfolder -ChildPath 'NestedAlias.ps1'
    @'
function Get-NestedItem {
    [Alias("gni", "getNestedItem")]
    param($item)
    return $item
}
'@ | Out-File -FilePath $aliasSubfolderFilePath

    # Create a folder with test scripts for command testing
    $testCommandFolder = Join-Path -Path $TestDrive -ChildPath 'CommandTests'
    New-Item -Path $testCommandFolder -ItemType Directory -Force | Out-Null

    # Create scripts in the command test folder
    @'
Get-ChildItem | Sort-Object Name
'@ | Out-File -FilePath (Join-Path -Path $testCommandFolder -ChildPath 'Script1.ps1')

    @'
Get-Process | Select-Object Name, Id
'@ | Out-File -FilePath (Join-Path -Path $testCommandFolder -ChildPath 'Script2.ps1')

    # Create a subfolder with script for command testing
    $commandSubFolder = Join-Path -Path $testCommandFolder -ChildPath 'SubFolder'
    New-Item -Path $commandSubFolder -ItemType Directory -Force | Out-Null

    @'
Get-Service | Where-Object { $_.Status -eq 'Running' }
'@ | Out-File -FilePath (Join-Path -Path $commandSubFolder -ChildPath 'Script3.ps1')
}

Describe 'Core' {
    Context "Function: 'Get-ASTScript'" {
        It 'Get-ASTScript gets the script AST' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $script = Get-ASTScript -Path $path
            $script | Should -Not -BeNullOrEmpty
            $script.Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
        }

        It 'Should process an array of file paths' {
            $results = Get-AstScript -Path @($testScript1, $testScript2)

            # Verify we got results for both files
            $results | Should -HaveCount 2

            # Verify paths
            $paths = $results | ForEach-Object { $_.Path }
            $paths | Should -Contain $testScript1
            $paths | Should -Contain $testScript2

            # Verify ASTs
            $results | ForEach-Object {
                $_.Ast | Should -BeOfType [System.Management.Automation.Language.ScriptBlockAst]
            }
        }

        It 'Should process all PS1 files in a folder' {
            $results = Get-AstScript -Path $testSamplesDir

            # Should find the two scripts in the root folder but not the one in subfolder
            $results | Should -HaveCount 2

            # Check paths
            $paths = $results | ForEach-Object { $_.Path }
            $paths | Should -Contain $testScript1
            $paths | Should -Contain $testScript2
            $paths | Should -Not -Contain $subfolderScript
        }

        It 'Should process all PS1 files in a folder recursively when -Recurse is specified' {
            $results = Get-AstScript -Path $testSamplesDir -Recurse

            # Should find all three scripts (including subfolder)
            $results | Should -HaveCount 3

            # Check paths
            $paths = $results | ForEach-Object { $_.Path }
            $paths | Should -Contain $testScript1
            $paths | Should -Contain $testScript2
            $paths | Should -Contain $subfolderScript
        }

        It 'Should validate all paths in an array exist' {
            # Testing the ValidateScript for array paths
            { Get-AstScript -Path @($testScript1, 'NonExistentFile.ps1') } |
                Should -Throw
        }

        It 'Should handle mixed paths (files and folders)' {
            $script1Path = Join-Path -Path $tempFolder -ChildPath 'Script1.ps1'
            $results = Get-AstScript -Path @($script1Path, $tempFolder)

            # Should get results for Script1.ps1 (explicitly) + Script1.ps1 and Script2.ps1 (from folder)
            $results | Should -HaveCount 3

            $paths = $results | ForEach-Object { $_.Path }
            $script1Path | Should -BeIn $paths
            (Join-Path -Path $tempFolder -ChildPath 'Script2.ps1') | Should -BeIn $paths
        }

        It 'Should not process files that are not PS1' {
            $results = Get-AstScript -Path $tempFolder

            # Should only find the PS1 files (2), not the txt file
            $results | Should -HaveCount 2

            $paths = $results | ForEach-Object { $_.Path }
            (Join-Path -Path $tempFolder -ChildPath 'NotAScript.txt') | Should -Not -BeIn $paths
        }

        It 'Should properly handle the -Recurse switch' {
            # Without recurse
            $withoutRecurse = Get-AstScript -Path $tempFolder
            $withoutRecurse | Should -HaveCount 2

            # With recurse
            $withRecurse = Get-AstScript -Path $tempFolder -Recurse
            $withRecurse | Should -HaveCount 3

            $paths = $withRecurse | ForEach-Object { $_.Path }
            (Join-Path -Path $tempFolder -ChildPath 'SubFolder\Script3.ps1') | Should -BeIn $paths
        }

        It 'Should return Path property for file inputs' {
            $results = Get-AstScript -Path (Join-Path -Path $tempFolder -ChildPath 'Script1.ps1')
            $results.Path | Should -Not -BeNullOrEmpty
        }

        It 'Should include correct AST information' {
            $results = Get-AstScript -Path (Join-Path -Path $tempFolder -ChildPath 'Script1.ps1')

            # Check for function definition in the AST
            $functionDef = $results.Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
            $functionDef.Name | Should -Be 'Get-Something'
        }
    }

    Context "Function: 'Get-ASTFunction'" {
        It 'Get-ASTFunction gets the function AST' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $function = Get-ASTFunction -Path $path
            $function | Should -Not -BeNullOrEmpty
            $function.Ast | Should -BeOfType [System.Management.Automation.Language.FunctionDefinitionAst]
        }

        It 'Should process an array of file paths' {
            $results = Get-AstFunction -Path @($testScript1, $testScript2)

            # We should have two ASTs (one for each function)
            $results.Ast | Should -HaveCount 2

            # Verify function names
            $functionNames = $results.Ast | ForEach-Object { $_.Name }
            $functionNames | Should -Contain 'Test-Function1'
            $functionNames | Should -Contain 'Test-Function2'
        }

        It 'Should process all PS1 files in a folder' {
            $results = Get-AstFunction -Path $testSamplesDir

            # Should find function definitions from the two scripts in the root folder
            $results.Ast | Should -HaveCount 2

            # Verify function names
            $functionNames = $results.Ast | ForEach-Object { $_.Name }
            $functionNames | Should -Contain 'Test-Function1'
            $functionNames | Should -Contain 'Test-Function2'
            $functionNames | Should -Not -Contain 'Test-Function3'
        }

        It 'Should process all PS1 files in a folder recursively when -Recurse is specified' {
            $results = Get-AstFunction -Path $testSamplesDir -Recurse

            # Should find functions from all three scripts (including subfolder)
            $results.Ast | Should -HaveCount 3

            # Verify function names
            $functionNames = $results.Ast | ForEach-Object { $_.Name }
            $functionNames | Should -Contain 'Test-Function1'
            $functionNames | Should -Contain 'Test-Function2'
            $functionNames | Should -Contain 'Test-Function3'
        }

        It 'Should filter function names based on the -Name parameter' {
            $results = Get-AstFunction -Path $testSamplesDir -Recurse -Name 'Test-Function1'

            # Should only find the one specified function
            $results.Ast | Should -HaveCount 1
            $results.Ast[0].Name | Should -Be 'Test-Function1'
        }

        It 'Should support wildcards in -Name parameter' {
            $results = Get-AstFunction -Path $testSamplesDir -Recurse -Name 'Test-Function*'

            # Should find all three functions
            $results.Ast | Should -HaveCount 3

            $functionNames = $results.Ast | ForEach-Object { $_.Name }
            $functionNames | Should -Contain 'Test-Function1'
            $functionNames | Should -Contain 'Test-Function2'
            $functionNames | Should -Contain 'Test-Function3'
        }
    }

    Context "Function: 'Get-ASTCommand'" {
        It 'Get-ASTCommand gets the command AST' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $command = Get-ASTCommand -Path $path
            $command | Should -Not -BeNullOrEmpty
            $command.Ast | Should -BeOfType [System.Management.Automation.Language.CommandAst]
        }

        It 'Should process an array of file paths' {
            $results = Get-AstCommand -Path @($multiCommandScriptPath, $testScript1)

            # Should find commands from both files
            $results.Ast | Should -Not -BeNullOrEmpty

            # The multi-command script has 5 commands: Get-Process, Where-Object, Write-Host, Invoke-Command, Get-Service
            # The test script has 1 command: Write-Host
            # So we expect at least 6 commands in total
            $results.Ast.Count | Should -BeGreaterOrEqual 6

            # Verify some command names are found
            $commandNames = $results.Ast | ForEach-Object { $_.CommandElements[0].Value }
            $commandNames | Should -Contain 'Get-Process'
            $commandNames | Should -Contain 'Write-Host'
        }

        It 'Should process all PS1 files in a folder' {
            # Test without recursion
            $resultsNoRecurse = Get-AstCommand -Path $testCommandFolder

            # Should find commands from the two scripts in the root folder
            $commandsNoRecurse = $resultsNoRecurse.Ast | ForEach-Object {
                $_.CommandElements[0].Value
            } | Where-Object { $_ }

            $commandsNoRecurse | Should -Contain 'Get-ChildItem'
            $commandsNoRecurse | Should -Contain 'Sort-Object'
            $commandsNoRecurse | Should -Contain 'Get-Process'
            $commandsNoRecurse | Should -Contain 'Select-Object'
            $commandsNoRecurse | Should -Not -Contain 'Get-Service'
        }

        It 'Should process all PS1 files in a folder recursively when -Recurse is specified' {
            # Test with recursion
            $resultsRecurse = Get-AstCommand -Path $testCommandFolder -Recurse

            $commandsRecurse = $resultsRecurse.Ast | ForEach-Object {
                $_.CommandElements[0].Value
            } | Where-Object { $_ }

            $commandsRecurse | Should -Contain 'Get-ChildItem'
            $commandsRecurse | Should -Contain 'Sort-Object'
            $commandsRecurse | Should -Contain 'Get-Process'
            $commandsRecurse | Should -Contain 'Select-Object'
            $commandsRecurse | Should -Contain 'Get-Service'
            $commandsRecurse | Should -Contain 'Where-Object'
        }

        It 'Should filter command names based on the -Name parameter' {
            $results = Get-AstCommand -Path $multiCommandScriptPath -Name 'Get-Process'

            # Should only find the specified command
            $results.Ast | Should -HaveCount 1
            $results.Ast[0].CommandElements[0].Value | Should -Be 'Get-Process'
        }

        It 'Should support wildcards in -Name parameter' {
            $results = Get-AstCommand -Path $multiCommandScriptPath -Name 'Get-*'

            # Should find Get-Process and Get-Service
            $results.Ast | Should -HaveCount 2

            $commandNames = $results.Ast | ForEach-Object { $_.CommandElements[0].Value }
            $commandNames | Should -Contain 'Get-Process'
            $commandNames | Should -Contain 'Get-Service'
        }
    }
}

Describe 'Functions' {
    Context "Function: 'Get-ASTFunctionType'" {
        It 'Get-ASTFunctionType gets the function type' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionType = Get-ASTFunctionType -Path $path
            $functionType.Type | Should -Be 'Function'
        }

        It 'Should process an array of file paths' {
            $results = Get-AstFunctionType -Path @($functionTypesPath, $secondTypesFilePath)

            # Should find function types from both files
            $results | Should -HaveCount 6

            # Check regular functions
            $results | Where-Object { $_.Name -eq 'Regular-Function' } | ForEach-Object { $_.Type | Should -Be 'Function' }
            $results | Where-Object { $_.Name -eq 'Another-Function' } | ForEach-Object { $_.Type | Should -Be 'Function' }

            # Check filter functions
            $results | Where-Object { $_.Name -eq 'Filter-Function' } | ForEach-Object { $_.Type | Should -Be 'Filter' }
            $results | Where-Object { $_.Name -eq 'Another-Filter' } | ForEach-Object { $_.Type | Should -Be 'Filter' }

            # Check workflow and configuration
            $results | Where-Object { $_.Name -eq 'Test-Workflow' } | ForEach-Object { $_.Type | Should -Be 'Workflow' }
            $results | Where-Object { $_.Name -eq 'Test-Configuration' } | ForEach-Object { $_.Type | Should -Be 'Configuration' }
        }

        It 'Should process all PS1 files in a folder' {
            $results = Get-AstFunctionType -Path $typesFolder

            # Should find functions from the main script in the folder (4 functions)
            $results | Should -HaveCount 4
            $functionNames = $results | ForEach-Object { $_.Name }
            $functionNames | Should -Contain 'Regular-Function'
            $functionNames | Should -Contain 'Filter-Function'
            $functionNames | Should -Contain 'Test-Workflow'
            $functionNames | Should -Contain 'Test-Configuration'
            $functionNames | Should -Not -Contain 'Nested-Function'
        }

        It 'Should process all PS1 files in a folder recursively when -Recurse is specified' {
            $results = Get-AstFunctionType -Path $typesFolder -Recurse

            # Should find functions from all scripts (6 functions total)
            $results | Should -HaveCount 6
            $functionNames = $results | ForEach-Object { $_.Name }
            $functionNames | Should -Contain 'Regular-Function'
            $functionNames | Should -Contain 'Filter-Function'
            $functionNames | Should -Contain 'Test-Workflow'
            $functionNames | Should -Contain 'Test-Configuration'
            $functionNames | Should -Contain 'Nested-Function'
            $functionNames | Should -Contain 'Nested-Filter'

            # Check the types
            $results | Where-Object { $_.Name -eq 'Nested-Function' } | ForEach-Object { $_.Type | Should -Be 'Function' }
            $results | Where-Object { $_.Name -eq 'Nested-Filter' } | ForEach-Object { $_.Type | Should -Be 'Filter' }
        }

        It 'Should filter function names based on the -Name parameter' {
            $results = Get-AstFunctionType -Path $functionTypesPath -Name '*-Function'

            # Should only find functions matching the pattern
            $results | Should -HaveCount 1
            $results[0].Name | Should -Be 'Regular-Function'
            $results[0].Type | Should -Be 'Function'
        }
    }

    Context "Function: 'Get-ASTFunctionName'" {
        It 'Get-ASTFunctionName gets the function name' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $functionName = Get-ASTFunctionName -Path $path
            $functionName | Should -Be 'Test-Function'
        }

        It 'Should process an array of file paths' {
            $results = Get-AstFunctionName -Path @($testScript1, $testScript2)

            # Should return function names from both files
            $results | Should -HaveCount 2
            $results | Should -Contain 'Test-Function1'
            $results | Should -Contain 'Test-Function2'
        }

        It 'Should process all PS1 files in a folder' {
            $results = Get-AstFunctionName -Path $testSamplesDir

            # Should find functions from the two scripts in the root folder
            $results | Should -HaveCount 2
            $results | Should -Contain 'Test-Function1'
            $results | Should -Contain 'Test-Function2'
            $results | Should -Not -Contain 'Test-Function3'
        }

        It 'Should process all PS1 files in a folder recursively when -Recurse is specified' {
            $results = Get-AstFunctionName -Path $testSamplesDir -Recurse

            # Should find functions from all three scripts (including subfolder)
            $results | Should -HaveCount 3
            $results | Should -Contain 'Test-Function1'
            $results | Should -Contain 'Test-Function2'
            $results | Should -Contain 'Test-Function3'
        }

        It 'Should filter function names based on the -Name parameter' {
            $results = Get-AstFunctionName -Path $multiFunctionScriptPath -Name 'Get-*'

            # Should only find functions matching the pattern
            $results | Should -HaveCount 1
            $results | Should -Contain 'Get-Something'
            $results | Should -Not -Contain 'Set-Something'
            $results | Should -Not -Contain 'Private-Helper'
        }

        It 'Should support exact matches in -Name parameter' {
            $results = Get-AstFunctionName -Path $multiFunctionScriptPath -Name 'Set-Something'

            # Should only find the exact match
            $results | Should -HaveCount 1
            $results | Should -Contain 'Set-Something'
        }

        It 'Should return all function names from a file with multiple functions' {
            $results = Get-AstFunctionName -Path $multiFunctionScriptPath

            # Should find all three functions
            $results | Should -HaveCount 3
            $results | Should -Contain 'Get-Something'
            $results | Should -Contain 'Set-Something'
            $results | Should -Contain 'Private-Helper'
        }
    }

    Context "Function: 'Get-AstFunctionAlias'" {
        It 'Should process an array of file paths' {
            $results = Get-AstFunctionAlias -Path @($functionAliasPath, $secondAliasFilePath)

            # Should find aliases from both files (3 functions with aliases)
            $results | Should -HaveCount 3

            # Check function names and their aliases
            $getSomething = $results | Where-Object { $_.Name -eq 'Get-Something' }
            $getSomething.Alias | Should -Contain 'gs'
            $getSomething.Alias | Should -Contain 'getSomething'

            $setSomething = $results | Where-Object { $_.Name -eq 'Set-Something' }
            $setSomething.Alias | Should -Contain 'ss'

            $getAnotherThing = $results | Where-Object { $_.Name -eq 'Get-AnotherThing' }
            $getAnotherThing.Alias | Should -Contain 'gat'
            $getAnotherThing.Alias | Should -Contain 'getAnother'

            # Function without alias should not be returned
            $results | Where-Object { $_.Name -eq 'Test-NoAlias' } | Should -BeNullOrEmpty
        }

        It 'Should process all PS1 files in a folder' {
            $results = Get-AstFunctionAlias -Path $aliasFolder

            # Should find functions with aliases from the main script in the folder
            $results | Should -HaveCount 2
            $functionNames = $results | ForEach-Object { $_.Name }
            $functionNames | Should -Contain 'Get-Something'
            $functionNames | Should -Contain 'Set-Something'
            $functionNames | Should -Not -Contain 'Get-NestedItem'
        }

        It 'Should process all PS1 files in a folder recursively when -Recurse is specified' {
            $results = Get-AstFunctionAlias -Path $aliasFolder -Recurse

            # Should find functions with aliases from all scripts
            $results | Should -HaveCount 3
            $functionNames = $results | ForEach-Object { $_.Name }
            $functionNames | Should -Contain 'Get-Something'
            $functionNames | Should -Contain 'Set-Something'
            $functionNames | Should -Contain 'Get-NestedItem'

            # Check the nested function aliases
            $nestedFunc = $results | Where-Object { $_.Name -eq 'Get-NestedItem' }
            $nestedFunc.Alias | Should -Contain 'gni'
            $nestedFunc.Alias | Should -Contain 'getNestedItem'
        }

        It 'Should filter function names based on the -Name parameter' {
            $results = Get-AstFunctionAlias -Path $functionAliasPath -Name 'Get-*'

            # Should only find functions matching the pattern
            $results | Should -HaveCount 1
            $results[0].Name | Should -Be 'Get-Something'
            $results[0].Alias | Should -Contain 'gs'
            $results[0].Alias | Should -Contain 'getSomething'
        }
    }
}

Describe 'Lines' {
    Context 'Function: Get-ASTLineComment' {
        It 'Get-ASTLineComment gets the line comment' {
            $line = '# This is a comment'
            $line = Get-ASTLineComment -Line $line
            $line | Should -Be '# This is a comment'
        }
        It 'Get-ASTLineComment gets the line comment without leading whitespace' {
            $line = '    # This is a comment'
            $line = Get-ASTLineComment -Line $line
            $line | Should -Be '# This is a comment'
        }
        It 'Get-ASTLineComment gets the line comment but not the command' {
            $line = '    Get-Command # This is a comment    '
            $line = Get-ASTLineComment -Line $line
            $line | Should -Be '# This is a comment    '
        }
        It 'Get-ASTLineComment returns nothing when no comment is present' {
            $line = 'Get-Command'
            $line | Get-ASTLineComment | Should -BeNullOrEmpty
        }
    }
}

Describe 'Scripts' {
    Context "Function: 'Get-ASTScriptCommands'" {
        It 'Get-ASTScriptCommands gets the script commands' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-ASTScriptCommand -Path $path
            $commands | Should -Not -BeNullOrEmpty
            $commands | Should -BeOfType [pscustomobject]
            $commands.Name | Should -Not -Contain 'ForEach-Object'
            $commands.Name | Should -Not -Contain 'Get-Process'
            $commands.Name | Should -Not -Contain 'ipmo'
            $commands.Name | Should -Contain 'Register-ArgumentCompleter'
            $commands.Name | Should -Not -Contain '.'
            $commands.Name | Should -Not -Contain '&'
        }
        It 'Get-ASTScriptCommands gets the script commands (recursive)' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-ASTScriptCommand -Path $path -Recurse
            $commands | Should -Not -BeNullOrEmpty
            $commands | Should -BeOfType [pscustomobject]
            $commands.Name | Should -Contain 'ForEach-Object'
            $commands.Name | Should -Contain 'Get-Process'
            $commands.Name | Should -Contain 'ipmo'
            $commands.Name | Should -Contain 'Register-ArgumentCompleter'
            $commands.Name | Should -Not -Contain '.'
            $commands.Name | Should -Not -Contain '&'
        }
        It 'Get-ASTScriptCommands gets the script commands with call operators' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-ASTScriptCommand -Path $path -IncludeCallOperators
            $commands | Should -Not -BeNullOrEmpty
            $commands | Should -BeOfType [pscustomobject]
            $commands.Name | Should -Not -Contain 'ForEach-Object'
            $commands.Name | Should -Not -Contain 'Get-Process'
            $commands.Name | Should -Not -Contain 'ipmo'
            $commands.Name | Should -Contain 'Register-ArgumentCompleter'
            $commands.Name | Should -Not -Contain '.'
            $commands.Name | Should -Not -Contain '&'
        }
        It 'Get-ASTScriptCommands gets the script commands with call operators (recursive)' {
            $path = Join-Path $PSScriptRoot 'src\Test-Function.ps1'
            $commands = Get-ASTScriptCommand -Path $path -Recurse -IncludeCallOperators
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
