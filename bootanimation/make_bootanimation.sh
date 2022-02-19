#!/bin/sh

cleanup() {
    rm -rf /tmp/frames
    exit 2
}

trap "cleanup" 2

RELATIVE_TOP=0.4
RELATIVE_LEFT=0.5
RELATIVE_WIDTH=0.4

make_bootanimation() {
    X=1080
    Y=2340

    FRAME_SIZE=$(echo "($RELATIVE_WIDTH * $X) / 1" | bc)
    FRAME_X_OFFSET=$(echo "($RELATIVE_LEFT * $X - $FRAME_SIZE / 2) / 1" | bc)
    FRAME_Y_OFFSET=$(echo "($RELATIVE_TOP * $Y - $FRAME_SIZE / 2) / 1" | bc)

    echo $FRAME_X_OFFSET $FRAME_Y_OFFSET

    rm -rf /tmp/frames
    mkdir -p /tmp/frames/part{0,1}
    make_all_frames "part0"
    make_all_frames "part1"
    
    cd /tmp/frames
    cat >desc.txt <<EOF
$X $Y 30
p 0 0 part0
c 1 0 part1
EOF
    
    zip -0qry bootanimation.zip desc.txt part0 part1
}


make_frame() {
    SOURCE=$1
    DEST=$2
    echo "Processing $SOURCE -> $DEST"

    magick /tmp/frames/blank.png \
        \( $SOURCE -resize $((FRAME_SIZE))x$((FRAME_SIZE)) \) \
        -geometry "+$FRAME_X_OFFSET+$FRAME_Y_OFFSET" -composite \
        $DEST
}

make_all_frames() {
    PART=$1
    magick -size $((X))x$((Y)) canvas:black /tmp/frames/blank.png

    for f in $(ls "frames/$PART"); do
        make_frame "frames/$PART/$f" "/tmp/frames/$PART/$f"
    done
}

make_bootanimation 1080 2340
