#!/bin/sh
#
# Copyright (C) 2018 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under 2-Clause BSD License.
#   https://opensource.org/licenses/BSD-2-Clause
# 
# mailto: fukachan@fml.org
#    web: http://www.fml.org/
#
# $FML$
# $Revision$
#        NAME: gi2git-simple.sh
# DESCRIPTION: Provide a simple script to transfer the GIT repositry.
#              I hope this is suitable to learn a shell script writing.
#              So I would like to keep this script within 100+ lines if could.
#              Please hack it as you wish. It is the best programming exercise.
# CODINGSTYLE: POSIX compliant (checked by running "bash --posix" this script)
#

#
# FUNCTIONS
#
do_usage () {
    local prog=$(basename $0)

    cat 1>&2 <<- _EOF_HELP_
	USAGE: $prog GIT_SRC GIT_DST

	[EXAMPLE]
	$prog $git_src $git_dst

	_EOF_HELP_
}


#
# MAIN
#
script=/var/tmp/git2git-simple.run.sh.$$
trap "rm -f $script" 0 1 3 15

# parse options using getopts
# -h show usage and exit.
while getopts h _opt
do
    case $_opt in
       h | \?) do_usage; exit 1;;
    esac
done
shift $(expr $OPTIND - 1)

# no args: show usage and exit (same as -h).
if [ $# -eq 0 ];then do_usage; exit 1; fi

# get parameters 
git_src=${1:-https://github.com/foo/repo}
git_dst=${2:-ssh://git@github.com/bar/repo}
repostr=$(basename ${git_src})
gitrepo=${3:-$repostr.git}

# go the main work.
cat >$script <<-_EOF_

git clone --mirror $git_src $gitrepo || exit 1

cd $gitrepo || exit 1

git  push --mirror $git_dst

_EOF_

# query the user if this is valid, if ok, go forward.
cat $script
echo -n ">>> ok ? [y/n] "; read yesorno
if [ "X$yesorno" = "Xy" -o "X$yesorno" = "Xyes" ];then
    mkdir work || exit 1
    cd work
    sh $script
else
    printf "\n***stop: DONE NOTHING\n\n" 1>&2
    exit 1
fi


exit 0;
