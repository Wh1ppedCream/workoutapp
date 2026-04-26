import os, sys, gzip
import zstandard as zstd

src  = sys.argv[1] if len(sys.argv) > 1 else 'foods.min.jsonl.zst'
dest = sys.argv[2] if len(sys.argv) > 2 else os.path.join('assets','foods','foods.min.jsonl.gz')

os.makedirs(os.path.dirname(dest), exist_ok=True)

dctx = zstd.ZstdDecompressor()
with open(src, 'rb') as f_in, gzip.open(dest, 'wb', compresslevel=9) as f_out:
    with dctx.stream_reader(f_in) as reader:
        while True:
            chunk = reader.read(1 << 20)  # 1 MiB
            if not chunk:
                break
            f_out.write(chunk)
print('Wrote', dest)
