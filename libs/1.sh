cd /home/diver/Games/wc/CircleL/Interface/AddOns/NSQC3/libs || exit 1

for n in 1 2 4 8; do
    f="pautina${n}.tga"
    [ -f "$f" ] || { echo "skip: $f not found"; continue; }

    # -alpha on   -> гарантируем альфа-канал (прозрачность паутины)
    # -define tga:rle=false -> выключаем RLE, пишем raw
    # TGA32:      -> форсируем 32-bit BGRA, без TGA2 footer/extension
    convert "$f" -alpha on -define tga:rle=false TGA32:"${f}.tmp" \
        && mv -f "${f}.tmp" "$f" \
        && echo "ok: $f"
done