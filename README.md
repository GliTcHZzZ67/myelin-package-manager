# Myelin Package Manager

Official package repository for **NoExZOS 1.0 (Sovereign)**.

## Usage

Add this repository to your Myelin configuration:

    echo "noexzos-main https://raw.githubusercontent.com/GliTcHZzZ67/myelin-package-manager/main" > /etc/myelin/repos.conf
    myelin update
    myelin install nano

## Repository Structure

    myelin-package-manager/
    ├── x86_64/              Package files (.mypkg.tar.xz)
    ├── repodata.txt         Package index (auto-generated)
    ├── scripts/             Helper scripts
    └── README.md

## Adding a New Package

1. Build the package:

       myelin build /path/to/pkg

2. Copy the built package to `x86_64/`:

       cp <name>-<version>-x86_64.mypkg.tar.xz x86_64/

3. Regenerate the index:

       ./scripts/generate-repo.sh

4. Commit and push:

       git add .
       git commit -m "Add package: <name>-<version>"
       git push origin main

## Contributing

Pull requests are welcome. For major changes, please open an issue first.

## License

Packages in this repository is licensed GPLv3 (GNU General Public License version 3)
 
