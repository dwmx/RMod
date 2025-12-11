import yaml
import os
from pathlib import Path
import subprocess
import sys
import shutil

# ---------------------------
# CONFIG
# ---------------------------
PACKAGE_LIST_FILE = "packages.yaml"
INI_TEMPLATE_FILE = "RModBuild_template.ini"
INI_OUTPUT_FILE = "RModBuild.ini"
UCC_EXE = "../Rune/System/UCC.exe"

# ---------------------------
# HELPERS
# ---------------------------
def load_packages(yaml_file):
    with open(yaml_file, "r") as f:
        data = yaml.safe_load(f)
    return data["mod_folder"], data["rune_install"], data["packages"]

def normalize_win_path(p: Path) -> Path:
    s = str(p)
    if s.startswith("\\\\?\\"):
        s = s[4:]
    return Path(s).resolve()

def ensure_symlinks(mod_folder, rune_install, packages):
    mod_folder = Path(mod_folder).resolve()
    rune_install = Path(rune_install).resolve()

    for pkg in packages:
        target = (mod_folder / pkg).resolve()
        link = rune_install / pkg

        if not target.exists():
            print(f"[ERROR] Cannot create symlink: source does not exist: {target}")
            continue

        if link.exists():
            if link.is_symlink():
                raw = os.readlink(link)
                real_target = normalize_win_path((link.parent / raw).resolve())
                expected = normalize_win_path(target)

                if real_target == expected:
                    print(f"[INFO] Symlink exists and correct: {link}")
                    continue

                print(f"[WARNING] Incorrect symlink: {link} -> {real_target}, expected {expected}")
            else:
                print(f"[WARNING] Path exists but is not a symlink: {link}")

            # Remove incorrect entry
            if link.is_dir():
                shutil.rmtree(link)
            else:
                link.unlink()

        try:
            print(f"[INFO] Creating symlink: {link} -> {target}")
            os.symlink(str(target), str(link), target_is_directory=True)
        except OSError as e:
            print(f"[ERROR] Failed to create symlink {link}: {e}")

def verify_packages(mod_folder, rune_install, packages):
    valid = True
    for pkg in packages:
        pkg_path = Path(mod_folder) / pkg
        if not pkg_path.exists():
            print(f"[ERROR] Package does not exist in mod folder: {pkg_path}")
            valid = False

        symlink_path = Path(rune_install) / pkg
        if not symlink_path.exists():
            print(f"[ERROR] Symlink missing in Rune install: {symlink_path}")
            valid = False
    return valid

def generate_ini(template_file, output_file, packages):
    with open(template_file, "r") as f:
        template = f.read()
    
    edit_packages_lines = "\n".join(f"EditPackages={pkg}" for pkg in packages)
    ini_content = template.replace("{EDIT_PACKAGES}", edit_packages_lines)
    
    with open(output_file, "w") as f:
        f.write(ini_content)
    print(f"[INFO] Generated INI file: {output_file}")

def clean_old_u_files(rune_install, packages):
    system_dir = Path(rune_install) / "System"
    if not system_dir.exists():
        print(f"[WARNING] System folder not found: {system_dir}")
        return

    for pkg in packages:
        u_file = system_dir / f"{pkg}.u"
        if u_file.exists():
            try:
                u_file.unlink()
                print(f"[INFO] Deleted {u_file}")
            except Exception as e:
                print(f"[WARNING] Could not delete {u_file}: {e}")


def run_ucc(ini_file):
    if not Path(UCC_EXE).exists():
        print(f"[ERROR] UCC.exe not found at {UCC_EXE}")
        sys.exit(1)
    
    result = subprocess.run([UCC_EXE, "make", f"ini={ini_file}"], capture_output=True, text=True)
    print(result.stdout)
    if result.returncode != 0:
        print(result.stderr)
        sys.exit(result.returncode)
    print("[INFO] Build finished successfully.")

# ---------------------------
# MAIN
# ---------------------------
def main():
    mod_folder, rune_install, packages = load_packages(PACKAGE_LIST_FILE)

    print("[INFO] Ensuring symlinks...")
    ensure_symlinks(mod_folder, rune_install, packages)

    print("[INFO] Verifying packages...")
    if not verify_packages(mod_folder, rune_install, packages):
        print("[ERROR] Package verification failed.")
        sys.exit(1)

    print("[INFO] Cleaning old .u files...")
    clean_old_u_files(rune_install, packages)
    
    print("[INFO] Generating INI...")
    generate_ini(INI_TEMPLATE_FILE, INI_OUTPUT_FILE, packages)

    print("[INFO] Running UCC...")
    ini_path = os.path.abspath(INI_OUTPUT_FILE)
    run_ucc(ini_path)

if __name__ == "__main__":
    main()
