# Branch URL Comparison: main vs clean-main

This document shows the different URLs between the `main` branch (with full history) and `clean-main` branch (single commit, no history).

## Repository Base URL

**Same for both branches:**
- `https://github.com/amol124r/bigquery-cleanroom-poc`

## Branch-Specific URLs

### Main Branch (with history)
- **Branch view**: `https://github.com/amol124r/bigquery-cleanroom-poc/tree/main`
- **Latest commit**: `https://github.com/amol124r/bigquery-cleanroom-poc/commit/879bf47`
- **Commit SHA**: `879bf4795f0663eb7b77899018d2a5cff5f3f167`

### Clean-Main Branch (no history)
- **Branch view**: `https://github.com/amol124r/bigquery-cleanroom-poc/tree/clean-main`
- **Latest commit**: `https://github.com/amol124r/bigquery-cleanroom-poc/commit/8b5a5e5`
- **Commit SHA**: `8b5a5e5ab8d4c93dd4c59d0e5eeb5f2f1ada04fa`

## File URLs

### Main Branch
- **README.md**: `https://github.com/amol124r/bigquery-cleanroom-poc/blob/main/README.md`
- **Comprehensive Summary**: `https://github.com/amol124r/bigquery-cleanroom-poc/blob/main/docs/70-comprehensive-summary-and-recommendations.md`
- **Any file**: `https://github.com/amol124r/bigquery-cleanroom-poc/blob/main/{file-path}`

### Clean-Main Branch
- **README.md**: `https://github.com/amol124r/bigquery-cleanroom-poc/blob/clean-main/README.md`
- **Comprehensive Summary**: `https://github.com/amol124r/bigquery-cleanroom-poc/blob/clean-main/docs/70-comprehensive-summary-and-recommendations.md`
- **Any file**: `https://github.com/amol124r/bigquery-cleanroom-poc/blob/clean-main/{file-path}`

## Directory/Tree URLs

### Main Branch
- **Root directory**: `https://github.com/amol124r/bigquery-cleanroom-poc/tree/main`
- **docs folder**: `https://github.com/amol124r/bigquery-cleanroom-poc/tree/main/docs`
- **scripts folder**: `https://github.com/amol124r/bigquery-cleanroom-poc/tree/main/scripts`
- **Any directory**: `https://github.com/amol124r/bigquery-cleanroom-poc/tree/main/{directory-path}`

### Clean-Main Branch
- **Root directory**: `https://github.com/amol124r/bigquery-cleanroom-poc/tree/clean-main`
- **docs folder**: `https://github.com/amol124r/bigquery-cleanroom-poc/tree/clean-main/docs`
- **scripts folder**: `https://github.com/amol124r/bigquery-cleanroom-poc/tree/clean-main/scripts`
- **Any directory**: `https://github.com/amol124r/bigquery-cleanroom-poc/tree/clean-main/{directory-path}`

## Commit History URLs

### Main Branch
- **Commits page**: `https://github.com/amol124r/bigquery-cleanroom-poc/commits/main`
- **Shows**: 7 commits with full history
- **Individual commits**:
  - Latest: `https://github.com/amol124r/bigquery-cleanroom-poc/commit/879bf47`
  - Previous: `https://github.com/amol124r/bigquery-cleanroom-poc/commit/13087f0`
  - Previous: `https://github.com/amol124r/bigquery-cleanroom-poc/commit/f7e846b`
  - etc.

### Clean-Main Branch
- **Commits page**: `https://github.com/amol124r/bigquery-cleanroom-poc/commits/clean-main`
- **Shows**: 1 commit (no history)
- **Single commit**: `https://github.com/amol124r/bigquery-cleanroom-poc/commit/8b5a5e5`

## Raw File URLs

### Main Branch
- **README.md**: `https://github.com/amol124r/bigquery-cleanroom-poc/raw/main/README.md`
- **Any file**: `https://github.com/amol124r/bigquery-cleanroom-poc/raw/main/{file-path}`

### Clean-Main Branch
- **README.md**: `https://github.com/amol124r/bigquery-cleanroom-poc/raw/clean-main/README.md`
- **Any file**: `https://github.com/amol124r/bigquery-cleanroom-poc/raw/clean-main/{file-path}`

## Blame URLs

### Main Branch
- **README.md**: `https://github.com/amol124r/bigquery-cleanroom-poc/blame/main/README.md`
- **Any file**: `https://github.com/amol124r/bigquery-cleanroom-poc/blame/main/{file-path}`

### Clean-Main Branch
- **README.md**: `https://github.com/amol124r/bigquery-cleanroom-poc/blame/clean-main/README.md`
- **Any file**: `https://github.com/amol124r/bigquery-cleanroom-poc/blame/clean-main/{file-path}`

## Default URLs (What Visitors See)

### Current Default (clean-main)
- **Repository home**: `https://github.com/amol124r/bigquery-cleanroom-poc` → Shows `clean-main` branch
- **Default file links**: Use `clean-main` branch (or no branch specified = default)

### If Main Was Default
- **Repository home**: `https://github.com/amol124r/bigquery-cleanroom-poc` → Would show `main` branch
- **Default file links**: Would use `main` branch

## URL Pattern Summary

| URL Type | Main Branch | Clean-Main Branch | Difference |
|----------|-------------|-------------------|------------|
| **Repository root** | `/bigquery-cleanroom-poc` | `/bigquery-cleanroom-poc` | ✅ Same |
| **Branch view** | `/tree/main` | `/tree/clean-main` | ❌ Different |
| **File view** | `/blob/main/{path}` | `/blob/clean-main/{path}` | ❌ Different |
| **Directory view** | `/tree/main/{path}` | `/tree/clean-main/{path}` | ❌ Different |
| **Commits page** | `/commits/main` | `/commits/clean-main` | ❌ Different |
| **Commit SHA** | `879bf47...` | `8b5a5e5...` | ❌ Different |
| **Raw file** | `/raw/main/{path}` | `/raw/clean-main/{path}` | ❌ Different |
| **Blame view** | `/blame/main/{path}` | `/blame/clean-main/{path}` | ❌ Different |

## Key Differences

1. **Branch name in URL**: `main` vs `clean-main`
2. **Commit SHAs**: Completely different (different commit history)
3. **Commits page**: Shows 7 commits vs 1 commit
4. **Default view**: Currently shows `clean-main` (no history visible)

## What Stays the Same

- Repository URL
- File content (same files in both branches)
- Directory structure
- All documentation and code

## Impact on Shared Links

### Links That Will Still Work
- ✅ Links to `main` branch files: `/blob/main/README.md` → Still work
- ✅ Links to `main` branch commits: `/commit/879bf47` → Still work
- ✅ Links without branch specified: Will now point to `clean-main` (default)

### Links That Changed
- ⚠️ Default repository view: Now shows `clean-main` instead of `main`
- ⚠️ New links without branch: Will use `clean-main` by default

## Recommendation

If you've shared links to specific files, they will continue to work as long as they include the branch name (`main`). If links don't specify a branch, they will now point to `clean-main` (the default branch).

