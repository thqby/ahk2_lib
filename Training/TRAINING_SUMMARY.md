# AutoHotkey v2 Training Examples - Complete Summary

## 📊 Overview

**44 Standalone Training Scripts** extracted from 4 AHK library files

| Library | Examples | Launchers | Total Files | Lines of Code |
|---------|----------|-----------|-------------|---------------|
| struct.ahk | 10 | 1 | 11 | ~600 |
| Promise.ahk | 10 | 1 | 11 | ~650 |
| JSON.ahk | 10 | 1 | 11 | ~850 |
| Crypt.ahk | 10 | 1 | 11 | ~700 |
| **TOTAL** | **40** | **4** | **44** | **~2,800** |

---

## 📚 Library Breakdowns

### 1. struct.ahk - Memory & C Structures

**Location:** `Training/example_scripts/struct_breakdown/`
**Source:** struct.ahk by thqby
**Topic:** C-style structures, memory management, Win32 API interop

#### Beginner (3 examples)
1. **Property Descriptors** - DefineProp() for dynamic properties
2. **Buffer Management** - Buffer(), NumPut(), NumGet() basics
3. **Type Conversion** - Windows API types → AHK types

#### Intermediate (5 examples)
4. **Dynamic Properties** - Bind() closures for property access
5. **String Parsing** - RegEx parsing of C struct definitions
6. **Alignment & Offsets** - Memory alignment calculations
7. **Simple Struct Complete** - Minimal struct implementation
8. **Practical API Usage** - RECT struct with GetWindowRect

#### Advanced (2 examples)
9. **Nested Structures** - Structs containing other structs
10. **Platform Comparison** - 32-bit vs 64-bit pointer handling

**Concepts:** DefineProp, Buffer, NumPut/NumGet, Memory alignment, WinAPI types, Nested structures, Cross-platform

---

### 2. Promise.ahk - Async Programming

**Location:** `Training/example_scripts/promise_breakdown/`
**Source:** Promise.ahk by thqby
**Topic:** JavaScript-style asynchronous programming

#### Beginner (3 examples)
1. **Basic Promise** - Creating promises with resolve/reject
2. **Promise States** - Pending, fulfilled, rejected lifecycle
3. **Then/Catch/Finally** - Promise chaining and cleanup

#### Intermediate (6 examples)
4. **Promise.all()** - Wait for multiple promises (parallel)
5. **Promise.race()** - First to settle wins
6. **Promise.allSettled()** - Wait for all (mixed outcomes)
7. **Await Sync** - Synchronous waiting with timeout
8. **Promise.any()** - First fulfilled or all rejected
10. **Practical Download** - Real-world async file download simulation

#### Advanced (1 example)
9. **WithResolvers()** - External promise control (deferred pattern)

**Concepts:** Promises, Async/await, Chaining, Error handling, Parallel ops, Race conditions, Practical async

---

### 3. JSON.ahk - Data Serialization

**Location:** `Training/example_scripts/json_breakdown/`
**Source:** JSON.ahk by thqby & HotKeyIt
**Topic:** JSON parsing and serialization

#### Beginner (3 examples)
1. **Basic Parsing** - Parse simple JSON to Maps/Arrays
2. **Basic Stringify** - Convert objects to JSON strings
5. **Pretty Printing** - Format JSON with indentation

#### Intermediate (6 examples)
3. **Nested Structures** - Complex nested objects and arrays
4. **Boolean & Null** - Handle true/false/null types
6. **Map vs Object** - Choose Map or Object mode
7. **Escape Characters** - Special characters and escape sequences
8. **Error Handling** - Parse error handling and validation
9. **Array Manipulation** - Iterate, filter, transform arrays

#### Advanced (1 example)
10. **Practical Config** - Read/modify/save configuration files

**Concepts:** JSON.parse, JSON.stringify, Nested structures, Boolean/null, Pretty printing, Map vs Object, Escaping, Arrays, Config files

---

### 4. Crypt.ahk - Hashing & Encryption

**Location:** `Training/example_scripts/crypt_breakdown/`
**Source:** Crypt.ahk
**Topic:** MD5, CRC32, SHA1 hashing and AES encryption

#### Beginner (2 examples)
1. **MD5 Basic** - Generate MD5 hash of strings
2. **MD5 File** - MD5 checksum of files

#### Intermediate (6 examples)
3. **Hash Types** - Compare CRC32, MD5, SHA1 algorithms
4. **Password Checking** - Password verification with hashing
5. **AES Encryption** - AES-256 encryption
6. **AES Decryption** - AES encryption/decryption round-trip
7. **AES Key Sizes** - Compare AES-128/192/256
9. **Data Integrity** - Detect data tampering

#### Advanced (2 examples)
8. **File Encryption** - Encrypt and decrypt entire files
10. **Password Vault** - Simple password vault implementation

**Concepts:** MD5, CRC32, SHA1, Hashing, Password verification, AES encryption, Key sizes, File encryption, Data integrity

---

## 🎯 By Difficulty Level

| Tier | Count | Percentage |
|------|-------|------------|
| **Beginner** | 11 | 28% |
| **Intermediate** | 23 | 58% |
| **Advanced** | 6 | 15% |
| **Launchers** | 4 | - |

---

## 🔑 Key Concepts Covered

### Memory & Structures
- ✅ Dynamic properties with DefineProp()
- ✅ Buffer allocation and management
- ✅ NumPut/NumGet for memory operations
- ✅ Memory alignment calculations
- ✅ Windows API type mapping
- ✅ Nested data structures
- ✅ Cross-platform pointer handling

### Async Programming
- ✅ Promise creation and lifecycle
- ✅ Promise chaining (then/catch/finally)
- ✅ Parallel operations (all, race, any, allSettled)
- ✅ Synchronous waiting (await)
- ✅ Error propagation
- ✅ Deferred patterns
- ✅ Real-world async workflows

### Data Handling
- ✅ JSON parsing and serialization
- ✅ Nested object structures
- ✅ Array and Map manipulation
- ✅ Pretty printing and formatting
- ✅ Escape sequence handling
- ✅ Error handling and validation
- ✅ Configuration file management

### Cryptography
- ✅ Hashing algorithms (MD5, SHA1, CRC32)
- ✅ File checksums
- ✅ Password verification
- ✅ AES encryption/decryption
- ✅ Multiple key sizes (128/192/256-bit)
- ✅ File encryption
- ✅ Data integrity checking
- ✅ Secure storage patterns

---

## 🚀 Usage

### Run Individual Examples
```bash
AutoHotkey.exe Training/example_scripts/struct_breakdown/01_property_descriptors.ahk
AutoHotkey.exe Training/example_scripts/promise_breakdown/01_basic_promise.ahk
AutoHotkey.exe Training/example_scripts/json_breakdown/01_basic_parsing.ahk
AutoHotkey.exe Training/example_scripts/crypt_breakdown/01_md5_basic.ahk
```

### Run Launchers (Recommended)
```bash
# Browse all struct examples
AutoHotkey.exe Training/example_scripts/struct_breakdown/LAUNCHER.ahk

# Browse all Promise examples
AutoHotkey.exe Training/example_scripts/promise_breakdown/LAUNCHER.ahk

# Browse all JSON examples
AutoHotkey.exe Training/example_scripts/json_breakdown/LAUNCHER.ahk

# Browse all Crypt examples
AutoHotkey.exe Training/example_scripts/crypt_breakdown/LAUNCHER.ahk
```

### Launcher Features
- 📋 Browse all examples in category
- 🔍 Filter by difficulty (Beginner/Intermediate/Advanced)
- ▶️ Run examples with one click
- 📄 View source code in editor
- 📖 Read concept descriptions
- ℹ️ About and statistics

---

## 📖 Learning Paths

### Path 1: Foundation (Beginner)
Start here if new to AHK v2 advanced features:
1. `struct/01_property_descriptors.ahk` - Dynamic properties
2. `struct/02_buffer_management.ahk` - Memory basics
3. `promise/01_basic_promise.ahk` - First promise
4. `json/01_basic_parsing.ahk` - Parse JSON
5. `crypt/01_md5_basic.ahk` - Hashing basics

### Path 2: Intermediate Techniques
After understanding basics:
1. `struct/09_practical_api_usage.ahk` - Real WinAPI usage
2. `promise/04_promise_all.ahk` - Parallel operations
3. `json/03_nested_structures.ahk` - Complex JSON
4. `crypt/05_aes_encryption.ahk` - Encryption

### Path 3: Advanced Patterns
Master level techniques:
1. `struct/08_nested_structures.ahk` - Complex memory layouts
2. `promise/09_with_resolvers.ahk` - Manual control
3. `json/10_practical_config.ahk` - Real config files
4. `crypt/10_practical_password_vault.ahk` - Complete app

### Path 4: Full Stack Project
Combine everything learned:
- Use **struct.ahk** for WinAPI calls
- Use **Promise.ahk** for async operations
- Use **JSON.ahk** for configuration
- Use **Crypt.ahk** for secure storage

---

## 📊 Statistics

- **Total Examples:** 40
- **Total Launchers:** 4
- **Total Files:** 44
- **Total Lines of Code:** ~2,800
- **Libraries Broken Down:** 4
- **Concepts Demonstrated:** 50+
- **Difficulty Tiers:** 3
- **Average Examples per Library:** 10

---

## 📝 File Structure

```
Training/example_scripts/
│
├── struct_breakdown/
│   ├── 01_property_descriptors.ahk
│   ├── 02_buffer_management.ahk
│   ├── 03_dynamic_properties.ahk
│   ├── 04_string_parsing.ahk
│   ├── 05_alignment_offsets.ahk
│   ├── 06_type_conversion.ahk
│   ├── 07_simple_struct_complete.ahk
│   ├── 08_nested_structures.ahk
│   ├── 09_practical_api_usage.ahk
│   ├── 10_platform_comparison.ahk
│   └── LAUNCHER.ahk
│
├── promise_breakdown/
│   ├── 01_basic_promise.ahk
│   ├── 02_promise_states.ahk
│   ├── 03_then_catch_finally.ahk
│   ├── 04_promise_all.ahk
│   ├── 05_promise_race.ahk
│   ├── 06_promise_allsettled.ahk
│   ├── 07_await_sync.ahk
│   ├── 08_promise_any.ahk
│   ├── 09_with_resolvers.ahk
│   ├── 10_practical_file_download.ahk
│   └── LAUNCHER.ahk
│
├── json_breakdown/
│   ├── 01_basic_parsing.ahk
│   ├── 02_basic_stringify.ahk
│   ├── 03_nested_structures.ahk
│   ├── 04_boolean_null.ahk
│   ├── 05_pretty_printing.ahk
│   ├── 06_map_vs_object.ahk
│   ├── 07_escape_characters.ahk
│   ├── 08_error_handling.ahk
│   ├── 09_array_manipulation.ahk
│   ├── 10_practical_config.ahk
│   └── LAUNCHER.ahk
│
└── crypt_breakdown/
    ├── 01_md5_basic.ahk
    ├── 02_md5_file.ahk
    ├── 03_hash_types.ahk
    ├── 04_password_checking.ahk
    ├── 05_aes_encryption.ahk
    ├── 06_aes_decryption.ahk
    ├── 07_aes_key_sizes.ahk
    ├── 08_file_encryption.ahk
    ├── 09_data_integrity.ahk
    ├── 10_practical_password_vault.ahk
    └── LAUNCHER.ahk
```

---

## 🎓 Each Example Includes

✅ **`#Requires AutoHotkey v2.0`** header
✅ **Focused concept** - One specific technique
✅ **Runnable code** - Works standalone
✅ **Comments** - Explains the "why"
✅ **MsgBox output** - Shows results and concepts
✅ **Real patterns** - From actual library code
✅ **Error handling** - Where appropriate
✅ **Best practices** - Following AHK v2 conventions

---

## 🔮 Potential Future Breakdowns

Additional libraries that could be broken down:
- **CLR.ahk** - .NET interop (10 examples)
- **WebSocket.ahk** - WebSocket connections (10 examples)
- **Chrome.ahk** - Chrome DevTools Protocol (10 examples)
- **Base64.ahk** - Encoding/decoding (5-8 examples)
- **Archive.ahk** - ZIP file handling (10 examples)
- **YAML.ahk** - YAML parsing (10 examples)
- **Socket.ahk** - Network sockets (10 examples)
- **Direct2D.ahk** - Graphics rendering (10 examples)
- **heap.ahk** - Data structure (5-8 examples)
- **sort.ahk** - Sorting algorithms (5-8 examples)

Potential total: ~100+ additional training examples

---

## ✨ Project Goals Achieved

✅ **Extract patterns** from real library code
✅ **Create focused examples** - One concept per file
✅ **Categorize by difficulty** - Beginner → Advanced
✅ **Provide launchers** - Easy browsing and execution
✅ **Document thoroughly** - Explanations in every file
✅ **Make runnable** - All examples work standalone
✅ **Cover breadth** - Memory, async, data, crypto
✅ **Progressive learning** - Build on previous concepts

---

## 📅 Creation Timeline

- **2025-11-20:** Initial Training infrastructure
- **2025-11-20:** struct.ahk breakdown (11 files)
- **2025-11-20:** Promise.ahk breakdown (11 files)
- **2025-11-20:** JSON.ahk breakdown (11 files)
- **2025-11-20:** Crypt.ahk breakdown (11 files)

**Total Time:** Created in a single session
**Status:** ✅ Complete and ready for use

---

## 🎯 Success Metrics

- **Coverage:** 4 major libraries
- **Examples:** 40 focused training scripts
- **Launchers:** 4 browsable GUIs
- **Concepts:** 50+ AHK v2 techniques
- **Difficulty:** 3 progressive tiers
- **Lines:** ~2,800 lines of training code
- **Documentation:** Comprehensive in-code explanations
- **Usability:** Click-and-run via launchers

---

**Ready to learn AutoHotkey v2!** 🚀

Start with any launcher or follow the learning paths above.
