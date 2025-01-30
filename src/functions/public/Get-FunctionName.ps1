function Get-FunctionName {
    param (
        # The path to the script file to parse
        [string] $Path
    )

    # Parse the script file into an AST
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$null, [ref]$null)

    # Extract function definitions
    $functions = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)

    # Process each function and extract the name
    $functions | ForEach-Object {
        $_.Name
    }
}
