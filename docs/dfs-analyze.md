---
layout: default
title: dfs-analyze.ps1
nav_order: 4
---

# dfs-analyze.ps1

Détecte les cycles dans le graphe de dépendances entre projets en effectuant un parcours en profondeur (DFS — Depth-First Search) sur le fichier `all-edges.csv` généré par [`analyze-deps.ps1`]({% link analyze-deps.md %}). Un cycle indique une dépendance circulaire, ce qui empêche la compilation et doit être résolu.

## Prérequis

- PowerShell 5.1 ou PowerShell 7+
- Avoir préalablement exécuté `analyze-deps.ps1` afin de disposer du fichier `all-edges.csv`

## Utilisation

```powershell
.\dfs-analyze.ps1 [-CsvPath <string>]
```

### Paramètre

| Paramètre   | Type     | Défaut                          | Description |
|-------------|----------|---------------------------------|-------------|
| `-CsvPath`  | `string` | `.\deps-analysis\all-edges.csv` | Chemin vers le fichier CSV des arêtes à analyser. |

## Sortie

Le script affiche dans la console les 50 premiers cycles détectés, sous la forme :

```
ProjectA -> ProjectB -> ProjectC -> ProjectA
```

Si aucune sortie n'est produite, aucun cycle n'a été détecté.

## Exemples

Analyse avec le fichier par défaut :

```powershell
.\dfs-analyze.ps1
```

Analyse avec un fichier CSV personnalisé :

```powershell
.\dfs-analyze.ps1 -CsvPath "C:\output\deps\all-edges.csv"
```

Chaîner avec `analyze-deps.ps1` :

```powershell
.\analyze-deps.ps1
.\dfs-analyze.ps1
```

## Fonctionnement interne

1. **Chargement** : lit le CSV et construit une liste d'adjacence (`$graph`).
2. **DFS avec détection de cycle** : pour chaque nœud non encore visité, lance un parcours récursif en maintenant une pile (`$stack`) des nœuds en cours de visite.
3. **Détection** : si un nœud déjà présent dans la pile courante est rencontré, le chemin entre la première occurrence et le nœud courant forme un cycle.
4. **Affichage** : les cycles sont dédupliqués et les 50 premiers sont affichés.

## Cas d'usage

- Vérifier l'absence de dépendances circulaires avant une livraison.
- Diagnostiquer des erreurs de compilation liées à des références circulaires entre projets.
- Préparer un refactoring en identifiant les cycles à casser.
