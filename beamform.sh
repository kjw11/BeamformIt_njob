#!/bin/bash
# From Jiawen Kang - CUHK

config=beamformit.cfg
utt2cf=utt2cf
outputDir=output

echo "$0 $@"  # Print the command line for logging.

. parse_options.sh || exit 1;

while read line; do
    echo $utt2cf
    echo "Process $line"
    channel_file=$(echo $line | awk '{print $2}')
    utt_id=$(echo $line | awk '{print $1}')
    BeamformIt --config_file $config \
            --channels_file $channel_file \
            --show_id $utt_id \
            --result_dir ${outputDir}
    rm -f ${outputDir}/${utt_id}_f0_ch*.wav
    rm -f ${outputDir}/{*.weat *.del *.del2 *.info}
done < $utt2cf
