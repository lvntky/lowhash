# lowhash

**lowhash** is a lightweight, high-performance static hash library written in C with optional hand-tuned assembly for maximum speed. It provides simple, fast, and portable hashing functions designed for use in performance-critical applications, system-level software, or embedded environments.

---

## Features

-  Optimized hashing with optional handcrafted assembly (x86, ARM)
- Clean header + source file model (no single-header nonsense)
- Includes widely used non-cryptographic hash functions:
  - CRC32
  - FNV-1a
  - DJB2
- Zero dependencies, pure ANSI C
- Builds as a static or shared library

---

## Directory Layout
```sh
lowhash/
├── include/
│ └── lowhash.h # Public API
├── src/
│ ├── lowhash.c # Dispatcher + shared code
│ ├── crc32.c # CRC32 implementation
│ ├── fnv1a.c # FNV-1a implementation
│ ├── djb2.c # DJB2 implementation
│ └── asm/ # architecture-specific asm
│ └── crc32_x86.S
├── test/
│ └── test.c # Unit tests
├── examples/
│ └── benchmark.c # Benchmark runner
├── Makefile # Build system
├── README.md # This file
└── LICENSE
```

## License
MIT License — use freely in commercial and personal projects.

