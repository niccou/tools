param(
  [ValidateNotNullOrEmpty()]
  [string]$CsvPath = ".\deps-analysis\all-edges.csv",
  [ValidateRange(1, [int]::MaxValue)]
  [int]$Top = 30
)

if (-not (Test-Path -LiteralPath $CsvPath)) {
  throw "CSV path '$CsvPath' does not exist or is not accessible."
}

$edges = Import-Csv $CsvPath

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
  $inc = if ($incoming.ContainsKey($p)) { $incoming[$p] } else { 0 }
  $out = if ($outgoing.ContainsKey($p)) { $outgoing[$p] } else { 0 }
  [PSCustomObject]@{
    Project  = $p
    Incoming = $inc
    Outgoing = $out
    Score    = $inc + $out
  }
}

$result | Sort-Object Score -Descending | Select-Object -First $Top