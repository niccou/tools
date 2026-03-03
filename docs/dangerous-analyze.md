---
layout: default
title: dangerous-analyze.ps1
nav_order: 3
---

# dangerous-analyze.ps1

Calcule un score de "dangerosité" pour chaque projet à partir du fichier `all-edges.csv` généré par [`analyze-deps.ps1`]({% link analyze-deps.md %}). Le score est la somme des dépendances entrantes et sortantes : plus un projet est central dans le graphe, plus il est risqué à modifier.

## Prérequis

- PowerShell 5.1 ou PowerShell 7+
- Avoir préalablement exécuté `analyze-deps.ps1` afin de disposer du fichier `.\deps-analysis\all-edges.csv`

## Utilisation

```powershell
.\dangerous-analyze.ps1 [-CsvPath <string>] [-Top <int>]
```

### Paramètres

| Paramètre   | Type     | Défaut                          | Description |
|-------------|----------|---------------------------------|-------------|
| `-CsvPath`  | `string` | `.\deps-analysis\all-edges.csv` | Chemin vers le fichier CSV des arêtes généré par `analyze-deps.ps1`. |
| `-Top`      | `int`    | `30`                            | Nombre de projets les plus risqués à afficher. |

## Sortie

Le script affiche dans la console les **30 premiers projets** (configurable via `-Top`) triés par `Score` décroissant :

| Colonne    | Description |
|------------|-------------|
| `Project`  | Nom du projet. |
| `Incoming` | Nombre de projets qui dépendent de ce projet (degré entrant). |
| `Outgoing` | Nombre de projets dont ce projet dépend (degré sortant). |
| `Score`    | `Incoming + Outgoing` — mesure globale de centralité. |

## Exemple

```powershell
# 1. Générer all-edges.csv
.\analyze-deps.ps1

# 2. Identifier les projets les plus risqués (top 30 par défaut)
.\dangerous-analyze.ps1

# Afficher les 50 projets les plus risqués
.\dangerous-analyze.ps1 -Top 50

# Avec un dossier de sortie personnalisé
.\analyze-deps.ps1 -OutDir "C:\output\deps"
.\dangerous-analyze.ps1 -CsvPath "C:\output\deps\all-edges.csv"
```

Exemple de sortie :

```
Project               Incoming Outgoing Score
-------               -------- -------- -----
MyApp.Core                  15        3    18
MyApp.Infrastructure         8        6    14
MyApp.Shared                12        1    13
...
```

## Cas d'usage

- Prioriser les revues de code sur les projets les plus couplés.
- Identifier les candidats à la décomposition ou à l'isolation avant un refactoring.
- Évaluer l'impact potentiel d'une modification avant de la réaliser.
