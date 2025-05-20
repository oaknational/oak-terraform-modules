#!/usr/bin/env bash
# Script to assist with creating new releases for oak-terraform-modules

set -eo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()   { echo -e "${BLUE}➤ $1"; }
ok()    { echo -e "${GREEN}✔ $1"; }
error() { echo -e "${RED}✖ $1"; exit 1; }

REPO_URL="https://github.com/oaknational/oak-terraform-modules.git"

echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════╗"
echo "║          Oak Terraform Modules Release Tool        ║"
echo "╚════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}Step 1: Running pre-release checks${NC}"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
  error "Must run on 'main' branch. You are currently on '$CURRENT_BRANCH'"
fi
ok "On main branch"

if ! git diff-index --quiet HEAD --; then
    error "You have uncommitted changes. Please commit or stash them first"
fi
ok "Working directory clean, No uncommitted changes"

log "Pulling latest changes from origin/main"
git pull origin main || error "Failed to pull latest changes. Fix any conflicts before proceeding".
ok "Repo is up to date with origin/main"

log "Running standard-version"
npm ci
npm run release || error "standard-version failed"
ok "Version bump, changelog update, commit, and tag complete"

echo
NEW_VERSION=$(node -p "require('./package.json').version")
RELEASE_BRANCH="release/v${NEW_VERSION}"
log "Creating release branch ${RELEASE_BRANCH}"
git switch -c "$RELEASE_BRANCH" || error "Failed to create branch"
git reset --hard main
ok "Release branch created with bumped commit"

echo
log "Pushing release branch and tags"
git push -u origin "$RELEASE_BRANCH" --follow-tags || error "Failed to push tags or branch"
ok "Pushed release branch and tags"

echo
log "Creating Pull Request for release"
gh pr create --base main --head "$RELEASE_BRANCH" \
  --title "chore(release): v${NEW_VERSION}" \
  --body "This PR bumps the version to v${NEW_VERSION} and updates the changelog." || error "Failed to create PR"
ok "Pull Request created"

cat <<EOF

Release branch and PR prep complete!

Next:
 1. Review and merge the release PR into main.
 2. After merge, create a new [release](https://github.com/oaknational/oak-terraform-modules/releases/new) by selecting the created tag and paste the relevant section from `CHANGELOG.md` as description.
 3. Publish the release and reference the tag in the downstream repos source block.

EOF