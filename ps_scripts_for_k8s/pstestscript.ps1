function Get-DirInfo($dir)
{
    $results = Get-ChildItem $dir -Recurse | Measure-Object -Property length -Sum
    return [math]::round(($results).sum/1GB,2)
}

Get-DirInfo C:\Temp
Get-DirInfo C:\Users