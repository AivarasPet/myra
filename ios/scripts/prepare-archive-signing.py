import plistlib
from pathlib import Path
import subprocess
import sys
import tempfile

ios_root = Path(__file__).resolve().parent.parent
app = Path(sys.argv[1]) / "Products/Applications/Sverto.app"

for bundle, source in [
    (app / "PlugIns/SvertoShare.appex", ios_root / "SvertoShare/SvertoShare.entitlements"),
    (app, ios_root / "Sverto/Sverto.entitlements"),
]:
    info = plistlib.loads((bundle / "Info.plist").read_bytes())
    entitlements = source.read_text().replace(
        "$(APP_GROUP_IDENTIFIER)", info["SvertoAppGroupIdentifier"]
    )
    if "$(" in entitlements:
        raise ValueError(f"Unresolved build setting in {source}")
    with tempfile.NamedTemporaryFile(suffix=".entitlements") as expanded:
        expanded.write(entitlements.encode())
        expanded.flush()
        subprocess.run(
            ["codesign", "--force", "--sign", "-", "--entitlements", expanded.name, str(bundle)],
            check=True,
        )
