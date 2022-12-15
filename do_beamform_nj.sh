#!/bin/bash
# From Jiawen Kang - CUHK

set -e
set -u
set -o pipefail

KALDIPATH=$(realpath someplace)
source $KALDIPATH/kaldi/tools/extras/env.sh
utils=$KALDIPATH/kaldi/egs/wsj/s5/utils

dataroot=/DATAPATH/alimeeting

nj=64

modes="Train_Ali_far Eval_Ali_far"
for mode in $modes; do
    echo "$mode"
    inputDir=$dataroot/${mode}/audio_dir
    outputDir=$dataroot/${mode}_beam/audio_dir
    files_dir=tmp/${mode}
    channels_file=$files_dir/channels_file

    # reset dir
    rm -rf ${outputDir} ${files_dir}
    mkdir -p ${outputDir} ${files_dir}
    echo "output dir is" $outputDir

    # make files
    touch $files_dir/utt2cf
    for wav in ${inputDir}/*.wav; do
        wav_fn=$(basename $wav)
        utt_id=$(echo $wav_fn | cut -d . -f1)

        echo "${utt_id} $wav" > $files_dir/channel_file.${utt_id}
        echo "${utt_id} $files_dir/channel_file.${utt_id}" >> $files_dir/utt2cf
    done

    # split nj files
    mkdir $files_dir/$nj
    split_list=
    for n in $(seq $nj);do 
            split_list="$split_list $files_dir/$nj/utt2cf.$n"
    done
    $utils/split_scp.pl $files_dir/utt2cf $split_list || exit 1;

    # run nj
    $utils/run.pl JOB=1:$nj $files_dir/ali.JOB.log \
    bash beamform.sh  --config beamformit.cfg \
            --utt2cf $files_dir/$nj/utt2cf.JOB \
            --outputDir ${outputDir} || exit 1;
done
echo "All done."
exit 0;
