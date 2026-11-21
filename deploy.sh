#!/usr/bin/env bash
# Deploy script for Hugo site and GitHub Pages submodule
set -e

# Default commit message if none provided
MSG="${1:-Update site $(date '+%Y-%m-%d %H:%M:%S')}"

echo "=================================================="
echo "🚀 Building Hugo Site & Updating GitHub Pages..."
echo "=================================================="

# Move to script directory (root of bp repository)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

# 1. Build Hugo site into public/
echo ""
echo "📦 Running Hugo build..."
hugo --minify

# 2. Check and commit changes in public/ submodule
echo ""
echo "📤 Updating public submodule (bradystephenprice.github.io)..."
cd "$DIR/public"

# Ensure we're on main branch and up to date
git checkout main 2>/dev/null || git checkout -b main origin/main
git pull origin main --rebase 2>/dev/null || true

# Stage all changes in public
git add -A

if git diff --staged --quiet; then
  echo "ℹ️  No changes to commit in public."
else
  echo "💾 Committing changes in public..."
  git commit -m "$MSG"
  echo "⬆️  Pushing public to https://github.com/BradyStephenPrice/bradystephenprice.github.io.git..."
  git push origin main
fi

# 3. Update submodule reference and changes in parent bp repo
cd "$DIR"
echo ""
echo "📤 Updating bp repository..."
git add -A

if git diff --staged --quiet; then
  echo "ℹ️  No changes to commit in bp."
else
  echo "💾 Committing changes in bp..."
  git commit -m "$MSG"
  echo "⬆️  Pushing bp to https://github.com/BradyStephenPrice/bp.git..."
  git push origin main
fi

echo ""
echo "=================================================="
echo "✅ Site and public folder successfully updated!"
echo "🌐 Live site: https://bradystephenprice.github.io/"
echo "=================================================="
