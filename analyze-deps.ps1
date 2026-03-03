param(
    [int]$TopHubs = 20,
    [int]$TopCallers = 20,
    [switch]$IncludeTests = $false,
    [string]$OutDir = ".\deps-analysis"
)

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# --- Collect csproj files

$csprojs = Get-ChildItem -Recurse -Filter *.csproj | Where-Object { $_.FullName -notmatch '\\packages\\' -and $_.FullName -notmatch '\\obj\\' -and $_.FullName -notmatch '\\bin\\' }

if (-not $IncludeTests) {
   $csprojs = $csprojs | Where-Object { $_.Name -notmatch 'Test' -and $_.FullName -notmatch '\\tests\\' } 
}

# --- Build Edges: from -> to

$edges = New-Object System.Collections.Generic.List[object]
$projects = New-Object System.Collections.Generic.HashSet[string]

foreach ($p in $csprojs) {
    $from = [IO.Path]::GetFileNameWithoutExtension($p.Name)
    [void]$projects.Add($from)

    try {
        [xml]$xml = Get-Content $p.FullName
    } catch  {
        Write-Warning "Impossible de lire $($p.FullName)"
        continue
    }

    $refs = $xml.Project.ItemGroup.ProjectReference | ForEach-Object { $_.Include} | Where-Object { $_ }

    foreach ($r in $refs){
        $to = [IO.Path]::GetFileNameWithoutExtension($r)

        if (-not $IncludeTests -and ($to -match 'Test')) { continue }

        $edges.Add([PSCustomObject]@{
            From = $from
            To = $to
        }) | Out-Null

        [void]$projects.Add($to)
    }
}

# Deduplicate Edges
$edges = $edges | Sort-Object From, To -Unique

# Compute incoming and outgoing
$incoming = @{} # project -> HashSet of referrers
$outgoing = @{} # project -> count

foreach ($p in $projects) {
    $incoming[$p] = New-Object System.Collections.Generic.HashSet[string]
    $outgoing[$p] = 0
}

foreach ($e in $edges) {
    [void]$incoming[$e.To].Add($e.From)
    $outgoing[$e.From]++
}

$hubs = $incoming.GetEnumerator() |
    ForEach-Object { [PSCustomObject]@{ Project=$_.Key; ReferencedBy=$_.Value.Count}} |
    Sort-Object ReferencedBy -Descending

$callers = $outgoing.GetEnumerator() |
    ForEach-Object { [PSCustomObject]@{ Project=$_.Key; References=$_.Value}} |
    Sort-Object References -Descending

# Export CSV Summaries

$hubs | Select-Object -First 500 | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutDir "top-hubs.csv")
$callers | Select-Object -First 500 | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $OutDir "top-callers.csv")

# Select Important nodes = top hubs + top callers
$important = New-Object System.Collections.Generic.HashSet[string]

($hubs | Select-Object -First $TopHubs).Project | ForEach-Object { [void]$important.Add($_) }
($callers | Select-Object -First $TopCallers).Project | ForEach-Object { [void]$important.Add($_) }

$subEdges = $edges | Where-Object { $important.Contains($_.From) -and $important.Contains($_.To) } 

function To-NodeId([string]$name){
    return ($name -replace '[^a-zA-Z0-9_]', '_')
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("``````mermaid") | Out-Null
$lines.Add("graph LR") | Out-Null

foreach ($n in ($important | Sort-Object)) {
    $id = To-NodeId $n
    $lines.Add("  $id[""$n""]") | Out-Null
}

foreach ($e in $subEdges){
    $fromId = To-NodeId $e.From
    $toId = To-NodeId $e.To
    $lines.Add("  $fromId --> $toId") | Out-Null
}

$lines.Add("``````") | Out-Null

$allEdgesPath = Join-Path $OutDir "all-edges.csv"
$edges | Export-Csv -NoTypeInformation -Encoding UTF8 $allEdgesPath

$mermaidPath = Join-Path $OutDir "deps-subgraph.md"
$lines | Set-Content -Encoding UTF8 $mermaidPath

Write-Host "Done"
