#!/bin/bash
# git_autoupdate
# 0.1
# 2023/06/19

REPO="redmine_auto_create_lk"

MAIL="<MAIL>"

BRANCH="master"

cd $HOME/git/$REPO

git remote update

# Were are we locally
LAST_UPDATE=`git show --no-notes --format=format:"%H" $BRANCH | head -n 1`

# Were are we remote
LAST_COMMIT=`git show --no-notes --format=format:"%H" origin/$BRANCH | head -n 1`

# IF we don't match we should update local
if [ $LAST_COMMIT = $LAST_UPDATE ]; then
        echo "Updating your branch $BRANCH"
        git pull --no-edit
        MSG=$(git log -1  --pretty=format:'%cn, %cd, %s' | grep -v "^$")
        echo -e "Update information:\n$MSG" | mail -v -s "Git repository \"$REPO\" updated." $MAIL

else
        echo "No updates available"
fi
