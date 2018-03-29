#!/bin/sh
#
# Copyright (C) 2017,2018 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under 2-Clause BSD License.
#   https://opensource.org/licenses/BSD-2-Clause
# 
# mailto: fukachan@fml.org
#    web: http://www.fml.org/
#
# $FML$
# $Revision$
#        NAME: cvs2git-simple
# DESCRIPTION: Provide a simple script to convert CVS to GIT.
#              This may be a minimum script which just wraps "git cvsimport".
#              I hope this is suitable to learn a shell script writing.
#              So I would like to keep this script within 100+ lines if could.
#              Please hack it as you wish. It is the best programming exercise.
# CODINGSTYLE: POSIX compliant (checked by running "bash --posix" this script)
#

# configurations
cvsroot=${1:-/cvsroot}
cvsrepo=${2:-software}
repostr=$(basename ${2})
gitrepo=${3:-$repostr.git}
gitroot=${4:-/some/where/gitroot}

# -a    import all commits
# -k    extract files with -kk ... avoid noisy changesets (Highly recommended)
# -m    attempt to detect merges based on the commit message
# -R    for incremental import (cvs -> git), which generates
#       a $GIT_DIR/cvs-revisions with the mapping "CVS rev <-> GIT commit ID"
# -v    verbose
#       and add your own custom as you like.
opts="-a -k -m -R -v"

# git related arguments: -r cvs -C GIT_LOCAL_REPOSITORY
#    "-r cvs" convert all CVS branches into remotes/cvs/<branch>
#    to distinguish git branches with the original cvs ones.
args_g="-r cvs -C $gitrepo"

# cvs related arguments: -d CVSROOT CVS_REPOSITORY(relative under CVSROOT)
args_c="-d $cvsroot $cvsrepo"


#
# PREPARATION: SHOW HELP IF NEEDED, RUN BASIC CHECKS, ...
#

# show this help and exit if "-h" option specified or no argument.
if [ "X$1" = "X-h" -o "X$1" = "X" ];then
    prog=$(basename $0)
    printf "\nUSAGE: $prog CVSROOT CVS_REPO GIT_REPO [GIT_REMOTE]\n"
    printf "\n[EXAMPLE]\n\n"
    printf "$prog /cvsroot repo repo.git\n\n"
    printf "# if you use your own (local) git shared repository,\n"
    printf "$prog /cvsroot repo repo.git\n\n"
    printf "# if you use a hosting services e.g. github,\n"
    printf "$prog /cvsroot repo repo.git git@github.com:user/repo.git\n\n"
    exit 0
fi

_repo=$cvsroot/$cvsrepo
if [ ! -d $cvsroot ];then printf "error: no CVSROOT $cvsroot\n";  exit 1; fi
if [ ! -d $_repo   ];then printf "error: no repository $_repo\n"; exit 1; fi

# validate if we have cvsps version 2
_path_cvsps=$(which cvsps)
_vers_cvsps=$(cvsps -h 2>&1 | grep "cvsps version 2")
if [ "X$_path_cvsps" = "X" ];then printf "error: cvsps2 required\n"; exit 1; fi
if [ "X$_vers_cvsps" = "X" ];then printf "error: cvsps2 required\n"; exit 1; fi


#
# MAIN
#
log=log.$gitrepo
printf "#\n# $cvsroot/$cvsrepo -> $gitrepo\n#\n"
printf "git cvsimport $opts $args_g $args_c >>$log 2>&1\n" | tee $log
eval   "git cvsimport $opts $args_g $args_c >>$log 2>&1"

# RUN POST HOOKS if available.
# XXX IDEA "for hook in aux/post*.sh; do sh $hook; done" for multiple hooks.
if [ -x ./aux/git-cvsimport-log-parse.sh ];then
    printf "\n# IMPORTANT LOG MESSAGES {\n\n"
    sh ./aux/git-cvsimport-log-parse.sh $log
    printf "\n}\n\n"
fi


#
# POSTSCRIPT: print the instruction here after.
#
(
    printf "\n#\n# INSTRUCTIONS AFTER HERE\n#\n\n"
    printf "cd $gitrepo\n\n"
    printf "# check imported branches and clean up them if needed.\n";
    printf "git branch -a\n\n"
    printf "# create your repository.\n"
    _match=$(expr $gitroot : '^.*github.com')
    if [ "X$_match" != "X0" ];then
	printf "# go the web if you use a git hosting service e.g. github.\n\n"
    else
	printf "git init --bare --shared=group $gitroot/$gitrepo\n\n"
    fi
    printf "# export: run \"git remote\" and \"git push\".\n"
    printf "git remote add --mirror=push $gitrepo $gitroot/$gitrepo\n"
    printf "git push                     $gitrepo\n\n"
    printf "# import: run \"git clone\" and verify it at another place.\n"
    printf "cd ..; mkdir work; cd work;\n"
    printf "git clone $gitroot/$gitrepo\n\n"
) | tee INSTRUCTIONS
printf "# The commands described above are saved at ./INSTRUCTIONS.\n"
printf "# The logs are saved at ./$log.\n\n"

exit 0;


# [Rerefences]
# https://www.kernel.org/pub/software/scm/git/docs/git-cvsimport.html
# http://www.embecosm.com/appnotes/ean11/ean11-howto-cvs-git-1.0.html
# https://sourceforge.net/projects/gcutils/
