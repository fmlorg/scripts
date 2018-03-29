#!/usr/bin/env perl
#
# Copyright (C) 2017,2018 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under 2-Clause BSD License.
#   https://opensource.org/licenses/BSD-2-Clause
# 
# mailto: fukachan@fml.org
#    web: http://www.fml.org/
#

use strict;
use Carp;

my $i = 0;

while (<>) {
    $i++;

    if ($i % 9999 == 0) {
	print "   ... $_";
    }
    next if /cvs rlog: Logging |^Fetching |^New |^Update /;
    next if /^Parent ID /;
    next if /^Committed patch \d+|^Commit ID |^Tree ID |^Parent ID /;
    next if /^Delete /;
    next if /^Created tag /;
    next if /^Merge parent branch:/;
    next if /^WARNING: revision .* on unnamed branch/;
    next if /^skip patchset \d+/;
    next if /^Skipping #CVSPS_NO_BRANCH/;
    print;
}

exit 0;
