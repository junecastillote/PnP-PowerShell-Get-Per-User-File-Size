#requires -Module PnP.PowerShell

[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $SummarizeByAuthor
)

# Get the current site URL
try {
    $site = (Get-PnPSite -ErrorAction Stop).Url
}
catch {
    Write-Error "Cannot get the current site's URL. $($_.Exception)"
    return $null
}

$excludedSystemLibrary = @("Style Library", "Site Assets", "Form Templates")

try {
    $docLibraries = Get-PnPList | Where-Object {
        $_.BaseTemplate -eq 101 -and ($_.Title -notin $excludedSystemLibrary)
    }
}
catch {
    Write-Error "Cannot retrieve document libraries in site. $($_.Exception)"
    return $null
}

$docLibraries | ForEach-Object {
    $libraryName = $_.Title
    # Retrieve all items with Author and File Size fields
    $items = Get-PnPListItem -List $libraryName -PageSize 5000 -Fields "Author", "AppAuthor", "FileDirRef", "FileLeafRef", "File_x0020_Size", "FSObjType" | Where-Object { $_["FSObjType"] -eq 0 }

    # Build a report
    $report = $items | ForEach-Object {

        # The file author can be user or app. This code block determines which one.
        $author = ''
        $authorEmail = ''
        $authorType = ''
        if (-not [string]::IsNullOrEmpty($_.FieldValues.AppAuthor.LookupValue)) {
            $authorType = 'App'
            $author = $_.FieldValues.AppAuthor.LookupValue
        }
        else {
            $authorType = 'User'
            $author = $_.FieldValues.Author.LookupValue
            $authorEmail = $_.FieldValues.Author.Email
        }

        [PSCustomObject]([ordered]@{
                Site       = $site
                AuthorType = $authorType
                Author     = $author
                Email      = $authorEmail
                Library    = $libraryName
                Folder     = $_.FieldValues.FileDirRef
                FileName   = $_.FieldValues.FileLeafRef
                SizeMB     = [math]::Round($_.FieldValues.File_x0020_Size / 1MB, 2)
            })
    }

    if (!$SummarizeByAuthor) {
        # Show the report as is.
        return $report
    }
    else {
        # Group by user and sum file sizes
        $userTotals = $report | Group-Object Author | ForEach-Object {
            [PSCustomObject]([ordered]@{
                    Site       = $site
                    AuthorType = $_.Group[0].AuthorType
                    Author     = $_.Name
                    Email      = $_.Group[0].Email
                    FileCount  = $_.Group.Count
                    TotalMB    = [math]::Round(($_.Group | Measure-Object SizeMB -Sum).Sum, 2)
                })
        }
        # Show results
        return $userTotals | Sort-Object TotalMB -Descending
    }
}
