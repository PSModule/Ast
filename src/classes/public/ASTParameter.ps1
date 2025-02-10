class ASTParameter {
    [string]$Name
    [string[]] $Alias
    [string]$Documentation
    [System.Collections.Generic.List[object]]$Requirements # From #Requires
    [string]$Type
    [System.Collections.Generic.List[object]]$Attributes
    [string]$DefaultValue


    ASTParameter() {}
}
