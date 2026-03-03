# tools

Scripts PowerShell d'analyse des dépendances entre projets .NET (`.csproj`).

📖 **[Documentation complète sur GitHub Pages](https://niccou.github.io/tools)**

## Scripts

| Script | Description |
|--------|-------------|
| [`analyze-deps.ps1`](docs/analyze-deps.md) | Construit le graphe de dépendances, calcule hubs et appelants, exporte des CSV et génère un diagramme Mermaid. **Point d'entrée — à lancer en premier.** |
| [`dangerous-analyze.ps1`](docs/dangerous-analyze.md) | Score chaque projet selon sa centralité (`Incoming + Outgoing`) pour identifier les modules les plus risqués à modifier. |
| [`dfs-analyze.ps1`](docs/dfs-analyze.md) | Détecte les dépendances circulaires entre projets via un parcours en profondeur (DFS). |

## Démarrage rapide

Depuis la racine de votre solution .NET :

```powershell
# 1. Analyser les dépendances (génère deps-analysis/)
.\analyze-deps.ps1

# 2. Identifier les projets les plus couplés
.\dangerous-analyze.ps1

# 3. Détecter les cycles de dépendances
.\dfs-analyze.ps1
```

Avec un dossier de sortie personnalisé sur toute la chaîne :

```powershell
$out = "C:\output\deps"
.\analyze-deps.ps1 -OutDir $out
.\dangerous-analyze.ps1 -CsvPath "$out\all-edges.csv"
.\dfs-analyze.ps1 -CsvPath "$out\all-edges.csv"
```

## Documentation

La documentation détaillée de chaque script (paramètres, fichiers générés, exemples) est disponible dans le dossier [`docs/`](docs/).
