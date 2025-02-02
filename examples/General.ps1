# Gets the AST of a script. Can be any type of PowerShell script file.
Get-ScriptAST -Path $path

# Gets the AST of a function(s) in a script. Can be any type of PowerShell script file.
Get-FunctionAST -Path $path

# Gets the type of all functions in a script file. Function or filter.
Get-FunctionType -Path $path

# Gets the name of all functions in a script file.
Get-FunctionName -Path $path

# Gets the alias of a function in a script, that uses Alias attribute.
Get-FunctionAlias -Path $path

'Get-ChildItem -Path . # This is a comment' | Get-LineComment
