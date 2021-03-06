function Get-ObjectTitles {
    [CmdletBinding()]
    param(
        $Object
    )
    $ArrayList = New-Object System.Collections.ArrayList
    Write-Verbose "Get-ObjectTitles - ObjectType $($Object.GetType())"

    #$Object |ft -a

    #$Object.PSObject | ft -AutoSize


    #$Object.PSObject.Properties | ft -AutoSize

    #$Object.PSObject.BaseObject | Get-Member | ft -a
    #$Titles = $Object | Get-Member | Where-Object { $_.MemberType -eq 'Property' -or $_.MemberType -eq 'NoteProperty' }
    foreach ($Title in $Object.PSObject.Properties) {
        $ArrayList.Add($Title.Name) | Out-Null
    }
    # $ArrayList | ft -AutoSize
    return $ArrayList
}
function Get-ObjectData {
    [CmdletBinding()]
    param(
        $Object,
        $Title,
        [switch] $DoNotAddTitles
    )
    $ArrayList = New-Object System.Collections.ArrayList
    $Values = $Object.$Title
    Write-Verbose "Get-ObjectData1: Title $Title Values: $Values"
    if ((Get-ObjectCount $values) -eq 1 -and $DoNotAddTitles -eq $false) {
        $ArrayList.Add("$Title - $Values") | Out-Null
    } else {
        if ($DoNotAddTitles -eq $false) { $ArrayList.Add($Title) | Out-Null }
        foreach ($Value in $Values) {
            $ArrayList.Add("$Value") | Out-Null
        }
    }
    Write-Verbose "Get-ObjectData2: Title $Title Values: $(Get-ObjectCount $ArrayList)"
    #Write-Color 'Get-ObjectData2: Title', ' ', $Title, ' ArrayList: ', (Get-ObjectCount $ArrayList) -Color Yellow, White, Green, White, Yellow
    return $ArrayList
}
function Get-ObjectCount {
    [CmdletBinding()]
    param(
        $Object
    )
    return $($Object | Measure-Object).Count
}