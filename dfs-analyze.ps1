# Detect cycles in all-edges.csv
param(
  [string]$CsvPath = ".\deps-analysis\all-edges.csv"
)

$edges = Import-Csv $CsvPath

# Build adjacency list
$graph = @{}
foreach ($e in $edges) {
  if (-not $graph.ContainsKey($e.From)) {
    $graph[$e.From] = @()
  }
  $graph[$e.From] += $e.To
}

$visited = @{}
$stack = @{}
$cycles = New-Object System.Collections.Generic.List[string]

function Visit($node, $path) {
  if ($stack[$node]) {
    $cycleStart = $path.IndexOf($node)
    if ($cycleStart -ge 0) {
      $cycle = $path[$cycleStart..($path.Count-1)] + $node
      $cycles.Add(($cycle -join " -> "))
    }
    return
  }

  if ($visited[$node]) { return }

  $visited[$node] = $true
  $stack[$node] = $true

  if ($graph.ContainsKey($node)) {
    foreach ($next in $graph[$node]) {
      Visit $next ($path + $node)
    }
  }

  $stack[$node] = $false
}

foreach ($node in $graph.Keys) {
  Visit $node @()
}

$cycles | Sort-Object -Unique | Select-Object -First 50