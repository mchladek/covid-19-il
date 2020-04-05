#!/bin/bash
#
###############################################################################
# run.sh
#
# The purpose of this script is to run the R Script `genPlots.R`, move the
# resulting PNG plots to the Hugo blog folder defined in the the global
# variables at the beginning of this script, update the `lastmod` parameter of
# the blog post related to these plots, and finally push the updated plots and
# post to production
###############################################################################

TODAY=$(date "+%Y-%m-%d")
SCRIPT_DIR=$(pwd)
BLOG_DIR=$HOME/Dev/mysite
BLOG_IMG_DIR=$BLOG_DIR/static/images/
BLOG_POST=$BLOG_DIR/content/post/covid-19-il.md

# pull and checkout any changes to blog
cd $BLOG_DIR
hg pull
hg update

#return to script directory
cd $SCRIPT_DIR

# run R script
Rscript genPlots.R

# move resulting plots to directory of blog images
mv *.png $BLOG_IMG_DIR

# cd to blog directory
cd $BLOG_DIR

# update `lastmod` date within blog post
awk -v a="$TODAY" 'NR==4{$0="lastmod = "a}1;' $BLOG_POST > "$BLOG_POST"_tmp
mv "$BLOG_POST"_tmp $BLOG_POST

# commit changes to mercurial repo and push
hg commit -m "Update covid plot data to $TODAY"
hg push
