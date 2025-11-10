
import sys
from pathlib import Path

REMOVE_LINES = {
    "--!strict",
    "--!nocheck",
    "--!nolint LocalUnused",
    "--!nolint LocalShadow",
    "--!nolint SameLineStatement",
    "--!nolint ImplicitReturn"
}
HEAD_LINES = []


def process_file(path: Path) -> bool:
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except Exception as e:
        print(f"❌ Load file error: {path}  {e}")
        return False

    lines = [ln for ln in lines if ln.strip() not in REMOVE_LINES]


    while lines and lines[0].strip() == "":
        lines.pop(0)

    final_lines = HEAD_LINES + [""] + lines

    if final_lines == path.read_text(encoding="utf-8").splitlines():
        return False

    try:
        path.write_text("\n".join(final_lines), encoding="utf-8")
        print(f"Updated File: {path}")
        return True
    except Exception as e:
        print(f"Write Error: {path}  {e}")
        return False

def main(root_dir: Path) -> None:
    luau_files = list(root_dir.rglob("*.luau"))
    if not luau_files:
        print("No .luau files found")
        return

    changed = sum(process_file(f) for f in luau_files)
    print(f"\nAction completed, updated {changed}/{len(luau_files)} files")

if __name__ == "__main__":
    project_root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
    if not project_root.is_dir():
        print(f"Invalid directory: {project_root}")
        sys.exit(1)
    main(project_root)