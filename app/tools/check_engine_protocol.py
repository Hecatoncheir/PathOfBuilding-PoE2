"""Проверка отдельного процесса Lua и ошибок протокола без изменения эталонов."""

import json
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def main():
    fixture = ROOT / "app/docs/flutter/fixtures/fireball-basic"
    expected = json.loads((fixture / "expected.json").read_text(encoding="utf-8"))
    requests = [
        {"method": "initialize"},
        {"method": "loadBuild", "params": {"xml": (fixture / "build.xml").read_text(encoding="utf-8")}},
        {"method": "setCustomMods", "params": {"revision": 1, "text": expected["modified"]["customMods"]}},
        {"method": "getSnapshot", "params": {"revision": 1}},
        {"method": "exportBuild", "params": {"revision": 2}},
        {"method": "loadBuild", "params": {"xml": "<broken>"}},
        {"method": "getSnapshot", "params": {"revision": 2}},
        {"method": "unknown"},
        {"method": "shutdown"},
    ]
    lines = [json.dumps({"protocol": 1, "id": str(i), **request}) for i, request in enumerate(requests)]
    lines.insert(0, "invalid json")
    with tempfile.TemporaryFile() as diagnostics:
        process = subprocess.run(
            [sys.executable, "app/tools/run_headless.py", "app/tools/headless_server.lua"],
            cwd=ROOT, input="\n".join(lines) + "\n", stdout=subprocess.PIPE,
            stderr=diagnostics, encoding="utf-8", timeout=60,
        )
        if process.returncode:
            diagnostics.seek(0)
            raise RuntimeError(diagnostics.read().decode("utf-8", errors="replace"))
    responses = [json.loads(line) for line in process.stdout.splitlines()]
    assert len(responses) == len(lines), "Диагностика повредила поток JSON"
    assert responses[0]["error"]["code"] == "INVALID_REQUEST"
    replies = {response["id"]: response for response in responses[1:]}
    assert replies["1"]["revision"] == 1
    assert abs(replies["1"]["result"]["output"]["TotalDPS"] - expected["baseline"]["TotalDPS"]) <= 1e-6
    assert replies["2"]["revision"] == 2
    assert abs(replies["2"]["result"]["output"]["TotalDPS"] - expected["modified"]["TotalDPS"]) <= 1e-6
    assert replies["3"]["error"]["code"] == "STALE_REVISION"
    assert "<PathOfBuilding2>" in replies["4"]["result"]["xml"]
    assert replies["5"]["error"]["code"] == "INVALID_BUILD"
    assert replies["6"]["revision"] == 2
    assert replies["6"]["result"]["output"] == replies["2"]["result"]["output"]
    assert replies["7"]["error"]["code"] == "UNKNOWN_METHOD"
    assert replies["8"]["result"]["stopped"]
    print("ENGINE_PROTOCOL_OK: 10 запросов; расчёты и ошибки проверены")


if __name__ == "__main__":
    main()
