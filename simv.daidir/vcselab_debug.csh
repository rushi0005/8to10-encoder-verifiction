#!/bin/csh -f

cd /home/015310906@SJSUAD.SJSU.EDU/273_project/8to10-encoder-verifiction

#This ENV is used to avoid overriding current script in next vcselab run 
setenv SNPS_VCSELAB_SCRIPT_NO_OVERRIDE  1

/apps/synopsys/vcs/R-2020.12/linux/bin/vcselab $* \
    -o \
    simv \
    -nobanner \

cd -

