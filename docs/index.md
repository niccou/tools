---
layout: home
title: Accueil
nav_order: 1
---

# Tools — Analyse de dépendances .NET

Scripts PowerShell pour analyser, visualiser et auditer les dépendances entre projets `.csproj` d'une solution .NET.

## Scripts disponibles

| Script | Description |
|--------|-------------|
| [`analyze-deps.ps1`]({% link analyze-deps.md %}) | Construit le graphe de dépendances, calcule hubs et appelants, exporte des CSV et génère un diagramme Mermaid. **Point d'entrée — à lancer en premier.** |
| [`dangerous-analyze.ps1`]({% link dangerous-analyze.md %}) | Score chaque projet selon sa centralité (`Incoming + Outgoing`) pour identifier les modules les plus risqués à modifier. |
| [`dfs-analyze.ps1`]({% link dfs-analyze.md %}) | Détecte les dépendances circulaires entre projets via un parcours en profondeur (DFS). |

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

Pour utiliser un dossier de sortie personnalisé sur l'ensemble de la chaîne :

```powershell
$out = "C:\output\deps"
.\analyze-deps.ps1 -OutDir $out
.\dangerous-analyze.ps1 -CsvPath "$out\all-edges.csv"
.\dfs-analyze.ps1 -CsvPath "$out\all-edges.csv"
```

## Prérequis

- PowerShell 5.1 ou PowerShell 7+
- Être positionné à la racine de la solution (dossier contenant les projets `.csproj`)
