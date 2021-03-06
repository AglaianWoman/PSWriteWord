function Add-WordTable {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.Container] $WordDocument,
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.InsertBeforeOrAfter] $Paragraph,
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.InsertBeforeOrAfter] $Table,
        [ValidateNotNullOrEmpty()]$DataTable,
        [AutoFit] $AutoFit,
        [TableDesign] $Design,
        [Direction] $Direction,
        [switch] $BreakPageAfterTable,
        [switch] $BreakPageBeforeTable,
        [int] $MaximumColumns = 5,
        [string[]]$Columns = @('Name', 'Value'),
        [switch] $DoNotAddTitle,

        [alias ("C")] [System.Drawing.Color[]]$Color = @(),
        [alias ("S")] [double[]] $FontSize = @(),
        [alias ("FontName")] [string[]] $FontFamily = @(),
        [alias ("B")] [bool[]] $Bold = @(),
        [alias ("I")] [bool[]] $Italic = @(),

        [float[]] $ColummnWidth = @(),
        [nullable[float]] $TableWidth = $null,
        [bool] $Percentage,

        [bool] $Supress = $true
    )
    $DataTable = Convert-ObjectToProcess -DataTable $DataTable
    #$DataTable
    $ObjectType = $DataTable.GetType().Name

    if ($ObjectType -eq 'Hashtable' -or $ObjectType -eq 'OrderedDictionary') {
        Write-Verbose 'Add-WordTable - Option 1'
        $NumberRows = $DataTable.Count + 1
        $NumberColumns = 2

        Write-Verbose "Add-WordTable - Column Count $($NumberColumns) Rows Count $NumberRows "
        Write-Verbose "Add-WordTable - Titles: $([string] $Columns)"

        if ($Table -eq $null) {
            $WordTable = New-WordTable -WordDocument $WordDocument -Paragraph $Paragraph -NrRows $NumberRows -NrColumns $NumberColumns -Supress $false
        } else {
            $WordTable = $Table
            Add-WordTableRow -Table $WordTable -Count $DataTable.Count
        }
        if (-not $DoNotAddTitle) {
            Add-WordTableTitle -Title $Columns `
                -Table $WordTable `
                -MaximumColumns $MaximumColumns `
                -Color $Color[0] `
                -FontSize $FontSize[0] `
                -FontFamily $FontFamily[0] `
                -Bold $Bold[0] `
                -Italic $Italic[0]
        }
        $RowNr = 1
        foreach ($TableEntry in $DataTable.GetEnumerator()) {
            $ColumnNrForTitle = 0
            $ColumnNrForData = 1
            $Data = Add-WordTableCellValue -Table $WordTable -Row $RowNr -Column $ColumnNrForTitle -Value $TableEntry.Name `
                -Color $Color[$RowNr] `
                -FontSize $FontSize[$RowNr] `
                -FontFamily $FontFamily[$RowNr] `
                -Bold $Bold[$RowNr] `
                -Italic $Italic[$RowNr]
            $Data = Add-WordTableCellValue -Table $WordTable -Row $RowNr -Column $ColumnNrForData -Value $TableEntry.Value `
                -Color $Color[$RowNr] `
                -FontSize $FontSize[$RowNr] `
                -FontFamily $FontFamily[$RowNr] `
                -Bold $Bold[$RowNr] `
                -Italic $Italic[$RowNr]
            Write-Verbose "Add-WordTable - RowNr: $RowNr / ColumnNr: $ColumnTitle Name: $($TableEntry.Name) Value: $($TableEntry.Value)"
            $RowNr++

        }
    } elseif ($ObjectType -eq 'PSCustomObject') {
        Write-Verbose 'Add-WordTable - Option 2'

        $Titles = Get-ObjectTitles -Object $DataTable[0]

        $NumberRows = $Titles.Count + 1
        $NumberColumns = 2

        Write-Verbose "Add-WordTable - Column Count $($NumberColumns) Rows Count $NumberRows "
        Write-Verbose "Add-WordTable - Titles: $([string] $Titles)"

        if ($Table -eq $null) {
            $WordTable = New-WordTable -WordDocument $WordDocument -Paragraph $Paragraph -NrRows $NumberRows -NrColumns $NumberColumns -Supress $false
        } else {
            $WordTable = $Table
            Add-WordTableRow -Table $WordTable -Count $DataTable.Count
        }
        if (-not $DoNotAddTitle) {
            Add-WordTableTitle -Title $Columns `
                -Table $WordTable `
                -MaximumColumns $MaximumColumns `
                -Color $Color[0] `
                -FontSize $FontSize[0] `
                -FontFamily $FontFamily[0] `
                -Bold $Bold[0] `
                -Italic $Italic[0]
        }
        $RowNr = 1
        foreach ($Title in $Titles) {
            $Value = Get-ObjectData -Object $DataTable -Title $Title -DoNotAddTitles
            $ColumnTitle = 0
            $ColumnData = 1
            $Data = Add-WordTableCellValue -Table $WordTable -Row $RowNr -Column $ColumnTitle -Value $Title `
                -Color $Color[$RowNr] `
                -FontSize $FontSize[$RowNr] `
                -FontFamily $FontFamily[$RowNr] `
                -Bold $Bold[$RowNr] `
                -Italic $Italic[$RowNr]

            $Data = Add-WordTableCellValue -Table $WordTable -Row $RowNr -Column $ColumnData -Value $Value `
                -Color $Color[$RowNr] `
                -FontSize $FontSize[$RowNr] `
                -FontFamily $FontFamily[$RowNr] `
                -Bold $Bold[$RowNr] `
                -Italic $Italic[$RowNr]
            Write-Verbose "Add-WordTable - Title:  $Title Value: $Value Row: $RowNr "
            $RowNr++

        }
    } elseif ($DataTable.GetType().Name -eq 'Object[]') {
        write-verbose 'Add-WordTable - option 3'

        $Titles = Get-ObjectTitles -Object $DataTable[0]

        $NumberColumns = if ($Titles.Count -ge $MaximumColumns) { $MaximumColumns } else { $Titles.Count }
        $NumberRows = $DataTable.Count + 1

        Write-Verbose "Add-WordTable - Column Count $($NumberColumns) Rows Count $NumberRows "
        Write-Verbose "Add-WordTable - Titles: $([string] $Titles)"
        #Write-Color "Column Count ", $NumberColumns, " Rows Count ", $NumberRows -C Yellow, Green, Yellow, Green

        if ($Table -eq $null) {
            $WordTable = New-WordTable -WordDocument $WordDocument -Paragraph $Paragraph -NrRows $NumberRows -NrColumns $NumberColumns -Supress $false
        } else {
            $WordTable = $Table
            Add-WordTableRow -Table $WordTable -Count $DataTable.Count
        }
        if (-not $DoNotAddTitle) {
            Add-WordTableTitle -Title $Titles `
                -Table $WordTable `
                -MaximumColumns $MaximumColumns `
                -Color $Color[0] `
                -FontSize $FontSize[0] `
                -FontFamily $FontFamily[0] `
                -Bold $Bold[0] `
                -Italic $Italic[0]
        }
        for ($b = 0; $b -lt $NumberRows - 1; $b++) {
            $ColumnNr = 0
            foreach ($Title in $Titles) {
                $RowNr = $($b + 1)
                $Value = $DataTable[$b].$Title
                $Data = Add-WordTableCellValue -Table $WordTable -Row $RowNr -Column $ColumnNr -Value $Value `
                    -Color $Color[$RowNr] `
                    -FontSize $FontSize[$RowNr] `
                    -FontFamily $FontFamily[$RowNr] `
                    -Bold $Bold[$RowNr] `
                    -Italic $Italic[$RowNr]
                if ($ColumnNr -eq $($MaximumColumns - 1)) { break; } # prevents display of more columns then there is space, choose carefully
                $ColumnNr++
            }
        }
    } else {
        Write-Verbose 'Add-WordTable - Option 4'
        $pattern = 'string|bool|byte|char|decimal|double|float|int|long|sbyte|short|uint|ulong|ushort'
        $Columns = ($DataTable | Get-Member | Where-Object { $_.MemberType -like "*Property" -and $_.Definition -match $pattern }) | Select-Object Name
        $NumberColumns = if ($Columns.Count -ge $MaximumColumns) { $MaximumColumns } else { $Columns.Count }
        $NumberRows = $DataTable.Count

        Write-Verbose "Add-WordTable - Column Count $($NumberColumns) Rows Count $NumberRows "
        #Write-Color "Column Count ", $NumberColumns, " Rows Count ", $NumberRows -C Yellow, Green, Yellow, Green

        if ($Table -eq $null) {
            $WordTable = New-WordTable -WordDocument $WordDocument -Paragraph $Paragraph -NrRows $NumberRows -NrColumns $NumberColumns -Supress $false
        } else {
            $WordTable = $Table
            Add-WordTableRow -Table $WordTable -Count $DataTable.Count
        }

        if (-not $DoNotAddTitle) {
            Add-WordTableTitle -Title $Columns `
                -Table $WordTable `
                -MaximumColumns $MaximumColumns `
                -Color $Color[0] `
                -FontSize $FontSize[0] `
                -FontFamily $FontFamily[0] `
                -Bold $Bold[0] `
                -Italic $Italic[0]
        }
        for ($RowNr = 1; $RowNr -lt $NumberRows; $RowNr++) {
            $ColumnNr = 0
            foreach ($Title in $Columns.Name) {
                $Value = $DataTable[$RowNr].$Title
                $Data = Add-WordTableCellValue -Table $WordTable `
                    -Row $RowNr `
                    -Column $ColumnNr `
                    -Value $Value `
                    -Color $Color[$RowNr] `
                    -FontSize $FontSize[$RowNr] `
                    -FontFamily $FontFamily[$RowNr] `
                    -Bold $Bold[$RowNr] `
                    -Italic $Italic[$RowNr]

                if ($ColumnNr -eq $($MaximumColumns - 1)) { break; } # prevents display of more columns then there is space, choose carefully
                $ColumnNr++


            }
        }

    }

    $WordTable | Set-WordTableColumnWidth -Width $ColummnWidth -TotalWidth $TableWidth -Percentage $Percentage

    $WordTable | Set-WordTable -Direction $Direction `
        -AutoFit $AutoFit `
        -Design $Design `
        -BreakPageAfterTable:$BreakPageAfterTable `
        -BreakPageBeforeTable:$BreakPageBeforeTable

    if ($Supress -eq $false) { return $WordTable } else { return }
}

function Remove-WordTable {
    [CmdletBinding()]
    param (
        [Xceed.Words.NET.InsertBeforeOrAfter] $Table
    )
    if ($Table -ne $null) {
        $Table.Remove()
    }

}
function New-WordTable {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.Container] $WordDocument,
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.InsertBeforeOrAfter] $Paragraph,
        [int] $NrRows,
        [int] $NrColumns,
        [bool] $Supress = $true
    )
    Write-Verbose "New-WordTable - Paragraph $Paragraph"
    Write-Verbose "New-WordTable - NrRows $NrRows NrColumns $NrColumns Supress $supress"
    if ($Paragraph -eq $null) {
        $WordTable = $WordDocument.InsertTable($NrRows, $NrColumns)
    } else {
        $TableDefinition = $WordDocument.AddTable($NrRows, $NrColumns)
        $WordTable = $Paragraph.InsertTableAfterSelf($TableDefinition)
    }
    if ($Supress) { return } else { return $WordTable }
}
function Get-WordTable {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.Container] $WordDocument,
        [switch] $ListTables,
        [switch] $LastTable,
        [nullable[int]] $TableID
    )
    if ($LastTable) {
        $Tables = $WordDocument.Tables
        $Table = $Tables[$Tables.Count - 1]
        return $Table
    }
    if ($ListTables) {
        return  $WordDocument.Tables
    }
    if ($TableID -ne $null) {
        return $WordDocument.Tables[$TableID]
    }
}
function Copy-WordTable {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.Container] $WordDocument,
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.InsertBeforeOrAfter] $Paragraph,
        $TableFrom
    )
}

<#
public Table AddTable( int rowCount, int columnCount )
public new Table InsertTable( int rowCount, int columnCount )
public new Table InsertTable( int index, Table t )

#>