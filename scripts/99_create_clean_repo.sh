#!/usr/bin/env bash
set -euo pipefail

# Script to create a new repository with clean history (single commit)
# This removes all commit history while keeping all files

echo "⚠️  WARNING: This will create a new branch with NO commit history"
echo "All files will be preserved, but commit history will be lost."
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Aborted."
  exit 1
fi

# Create orphan branch (no parent commits)
git checkout --orphan clean-main

# Add all files
git add -A

# Create single commit
git commit -m "Initial commit: BigQuery Data Clean Room POC

Complete POC implementation for Analytics Hub + BigQuery Data Clean Rooms
- Producer/Consumer/Sharing project setup scripts
- DCR exchange creation and subscription automation
- Consumer egress control validation tests
- Comprehensive documentation:
  * Architecture and design
  * Step-by-step setup guide
  * Consumer capabilities matrix
  * Browser testing guide
  * Observed outcomes from live GCP execution
  * Comprehensive summary and recommendations
- SQL scripts for data seeding and validation queries
- Authorized views approach for flexible data sharing"

echo ""
echo "✅ Created clean branch 'clean-main' with single commit"
echo ""
echo "Option A: Push as new branch (keeps old main, nothing breaks):"
echo "  git push origin clean-main"
echo "  Then in GitHub: Settings > Branches > Set 'clean-main' as default"
echo ""
echo "Option B: Replace main branch (breaks commit links, keeps file links):"
echo "  git push origin clean-main:main --force"
echo ""
echo "⚠️  WARNING: Option B will break links to specific commits!"
echo "Option A is safer - keeps both branches available."

