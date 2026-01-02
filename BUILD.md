# Building AetherOS

## System Requirements
- Linux (Ubuntu/Debian recommended)
- aarch64-linux-gnu toolchain
- QEMU for testing
- Python 3.8+

## Installation

### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install \
  gcc-aarch64-linux-gnu \
  binutils-aarch64-linux-gnu \
  qemu-system-arm \
  build-essential \
  python3