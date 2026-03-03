---
layout: default
title: analyze-deps.ps1
nav_order: 2
---

# analyze-deps.ps1

Analyse les dépendances entre projets `.csproj` d'une solution .NET. Il construit un graphe orienté des références entre projets, calcule les hubs (projets les plus référencés) et les appelants (projets qui référencent le plus d'autres projets), exporte les résultats en CSV et génère un diagramme Mermaid.

## Prérequis

- PowerShell 5.1 ou PowerShell 7+
- Être positionné à la racine de la solution (dossier contenant les projets `.csproj`)

## Utilisation

```powershell
.\analyze-deps.ps1 [-TopHubs <int>] [-TopCallers <int>] [-IncludeTests] [-OutDir <string>]
```

### Paramètres

| Paramètre       | Type     | Défaut            | Description |
|-----------------|----------|-------------------|-------------|
| `-TopHubs`      | `int`    | `20`              | Nombre de projets les plus référencés à inclure dans le sous-graphe Mermaid. |
| `-TopCallers`   | `int`    | `20`              | Nombre de projets référençant le plus d'autres projets à inclure dans le sous-graphe Mermaid. |
| `-IncludeTests` | `switch` | `$false`          | Si précisé, inclut les projets de tests (dont le nom contient `Test` ou situés dans un dossier `tests`). |
| `-OutDir`       | `string` | `.\deps-analysis` | Dossier de sortie pour tous les fichiers générés. |

## Fichiers générés

| Fichier                        | Description |
|-------------------------------|-------------|
| `all-edges.csv`               | Toutes les arêtes du graphe (`From`, `To`). Utilisé en entrée par `dangerous-analyze.ps1` et `dfs-analyze.ps1`. |
| `top-hubs.csv`                | Top 500 projets par nombre de référenceurs (`ReferencedBy`). |
| `top-callers.csv`             | Top 500 projets par nombre de références sortantes (`References`). |
| `deps-subgraph.md`            | Diagramme Mermaid du sous-graphe formé par les top hubs et top callers. |

## Exemples

Analyse standard (sans tests) :

```powershell
.\analyze-deps.ps1
```

Inclure les projets de tests et afficher un sous-graphe plus large :

```powershell
.\analyze-deps.ps1 -IncludeTests -TopHubs 30 -TopCallers 30
```

Exporter dans un dossier personnalisé :

```powershell
.\analyze-deps.ps1 -OutDir "C:\output\deps"
```

## Fonctionnement interne

1. **Collecte** : parcourt récursivement les fichiers `.csproj` en excluant `packages`, `obj` et `bin`.
2. **Construction du graphe** : pour chaque projet, lit les `<ProjectReference>` et crée une arête `From → To`.
3. **Calcul des métriques** :
   - `ReferencedBy` (degré entrant) : nombre de projets qui référencent un projet donné.
   - `References` (degré sortant) : nombre de références émises par un projet.
4. **Export CSV** : `all-edges.csv`, `top-hubs.csv`, `top-callers.csv`.
5. **Sous-graphe Mermaid** : sélectionne les `TopHubs` + `TopCallers` projets les plus importants et génère un diagramme `graph LR` dans `deps-subgraph.md`.
