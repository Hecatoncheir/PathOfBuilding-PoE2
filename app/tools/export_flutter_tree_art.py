"""Преобразовать используемые DDS-слои дерева в PNG для Flutter."""
import hashlib
import io
import json
import struct
from pathlib import Path

import zstandard
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "src/TreeData/0_5"
OUTPUT = ROOT / "app/assets/tree/0_5"


def main():
    tree = json.loads((SOURCE / "tree.json").read_text(encoding="utf-8"))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    needed = {node.get("icon") for node in tree["nodes"].values()}
    needed.update(node.get("activeEffectImage") for node in tree["nodes"].values())
    for overlay in tree["nodeOverlay"].values():
        needed.update(overlay.values())
    for character in tree["classes"]:
        needed.add(character["background"]["image"])
        needed.update(a["background"]["image"] for a in character["ascendancies"] if a.get("background"))
    manifest = {}
    for name, paths in tree["assets"].items():
        source = SOURCE / paths[0]
        if not source.is_file() or source.suffix.lower() != ".png":
            continue
        image = Image.open(source).convert("RGBA")
        output = hashlib.sha256(name.encode()).hexdigest()[:20] + ".png"
        image.save(OUTPUT / output)
        manifest[name] = {"file": output, "width": image.width, "height": image.height}
    for filename, names in tree["ddsCoords"].items():
        names = {name: layer for name, layer in names.items() if name in needed or filename.startswith(("group-background", "mastery-active", "jewel-sockets"))}
        if not names:
            continue
        raw = zstandard.ZstdDecompressor().decompress((SOURCE / filename).read_bytes())
        assert raw[:4] == b"DDS " and raw[84:88] == b"DX10", filename
        count = struct.unpack_from("<I", raw, 140)[0]
        stride = (len(raw) - 148) // count
        assert stride * count == len(raw) - 148
        header = bytearray(raw[:148])
        struct.pack_into("<I", header, 140, 1)
        for name, layer in names.items():
            crop = layer if isinstance(layer, list) else None
            layer = crop[4] if crop else layer
            assert isinstance(layer, int) and 1 <= layer <= count
            start = 148 + (layer - 1) * stride
            image = Image.open(io.BytesIO(bytes(header) + raw[start:start + stride])).convert("RGBA")
            if crop:
                image = image.crop((crop[0], crop[1], crop[0] + crop[2], crop[1] + crop[3]))
            width, height = image.size
            image.thumbnail((768, 768))
            output = hashlib.sha256(name.encode()).hexdigest()[:20] + ".png"
            image.save(OUTPUT / output)
            manifest[name] = {"file": output, "width": width, "height": height}
    (OUTPUT / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False), encoding="utf-8")
    print(f"Exported {len(manifest)} textures")


if __name__ == "__main__":
    main()
