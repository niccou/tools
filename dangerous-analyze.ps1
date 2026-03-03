$edges = Import-Csv ".\deps-analysis\all-edges.csv"

$incoming = @{}
$outgoing = @{}

foreach ($e in $edges) {
  if (-not $incoming.ContainsKey($e.To)) { $incoming[$e.To] = 0 }
  if (-not $outgoing.ContainsKey($e.From)) { $outgoing[$e.From] = 0 }

  $incoming[$e.To]++
  $outgoing[$e.From]++
}

$projects = ($incoming.Keys + $outgoing.Keys) | Sort-Object -Unique

$result = foreach ($p in $projects) {
  [PSCustomObject]@{
    Project = $p
    Incoming = if ($incoming.ContainsKey($p)) { $incoming[$p] } else { 0 }
    Outgoing = if ($outgoing.ContainsKey($p)) { $outgoing[$p] } else { 0 }
    Score = (if ($incoming.ContainsKey($p)) { $incoming[$p] } else { 0 }) + (if ($outgoing.ContainsKey($p)) { $outgoing[$p] } else { 0 })
  }
}

$result | Sort-Object Score -Descending | Select-Object -First 30