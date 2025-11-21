# AutoHotkey v2 Training Examples - Created Scripts

## Overview

**22 standalone training scripts** extracted from AHK library files, organized into focused learning modules.

Each example is:
- ✅ **Standalone** - Runs independently
- ✅ **Focused** - One concept per script
- ✅ **Documented** - Explanatory comments throughout
- ✅ **Practical** - Real patterns from library code
- ✅ **Categorized** - Beginner/Intermediate/Advanced

---

## 📚 Library Breakdowns

### 1. struct.ahk Breakdown (11 files)

**Source:** `struct.ahk` by thqby
**Topic:** C-style structures in AutoHotkey v2
**Location:** `Training/example_scripts/struct_breakdown/`

#### Concepts Covered:
- Memory management with Buffers
- Dynamic property creation
- NumPut/NumGet operations
- Memory alignment calculations
- Windows API type conversion
- Nested structures
- Cross-platform pointer handling

#### Examples by Difficulty:

**Beginner (3 scripts)**
| # | File | Concept |
|---|------|---------|
| 01 | `01_property_descriptors.ahk` | DefineProp() for dynamic properties |
| 02 | `02_buffer_management.ahk` | Buffer(), NumPut(), NumGet() basics |
| 06 | `06_type_conversion.ahk` | Windows API type to AHK type mapping |

**Intermediate (5 scripts)**
| # | File | Concept |
|---|------|---------|
| 03 | `03_dynamic_properties.ahk` | Bind() closures for property access |
| 04 | `04_string_parsing.ahk` | RegEx parsing of C struct definitions |
| 05 | `05_alignment_offsets.ahk` | Memory alignment calculations |
| 07 | `07_simple_struct_complete.ahk` | Complete minimal struct implementation |
| 09 | `09_practical_api_usage.ahk` | RECT struct with GetWindowRect API |

**Advanced (2 scripts)**
| # | File | Concept |
|---|------|---------|
| 08 | `08_nested_structures.ahk` | Structs containing other structs |
| 10 | `10_platform_comparison.ahk` | 32-bit vs 64-bit pointer handling |

**Launcher**
- `LAUNCHER.ahk` - GUI browser with filtering and code viewer

---

### 2. Promise.ahk Breakdown (11 files)

**Source:** `Promise.ahk` by thqby
**Topic:** JavaScript-style async programming
**Location:** `Training/example_scripts/promise_breakdown/`

#### Concepts Covered:
- Promise creation and lifecycle
- Async/await patterns
- Promise chaining
- Error handling
- Parallel operations
- Race conditions
- Practical async patterns

#### Examples by Difficulty:

**Beginner (3 scripts)**
| # | File | Concept |
|---|------|---------|
| 01 | `01_basic_promise.ahk` | Creating promises with resolve/reject |
| 02 | `02_promise_states.ahk` | Pending, fulfilled, rejected states |
| 03 | `03_then_catch_finally.ahk` | Chaining and cleanup |

**Intermediate (6 scripts)**
| # | File | Concept |
|---|------|---------|
| 04 | `04_promise_all.ahk` | Wait for all promises (parallel) |
| 05 | `05_promise_race.ahk` | First to settle wins |
| 06 | `06_promise_allsettled.ahk` | Wait for all (mixed outcomes) |
| 07 | `07_await_sync.ahk` | Synchronous waiting with timeout |
| 08 | `08_promise_any.ahk` | First fulfilled or all rejected |
| 10 | `10_practical_file_download.ahk` | Real-world async download simulation |

**Advanced (1 script)**
| # | File | Concept |
|---|------|---------|
| 09 | `09_with_resolvers.ahk` | External promise control |

**Launcher**
- `LAUNCHER.ahk` - GUI browser with filtering and code viewer

---

## 📊 Statistics

| Category | Count |
|----------|-------|
| **Total Scripts** | 22 |
| Library Breakdowns | 2 |
| Struct Examples | 10 |
| Promise Examples | 10 |
| Launchers | 2 |
| | |
| **By Difficulty** | |
| Beginner | 6 |
| Intermediate | 11 |
| Advanced | 3 |
| Launchers | 2 |
| | |
| **Lines of Code** | ~1,700 |

---

## 🎯 Usage

### Running Individual Examples

```bash
# Navigate to breakdown folder
cd Training/example_scripts/struct_breakdown

# Run any example directly
"C:\Path\To\AutoHotkey64.exe" 01_property_descriptors.ahk
```

### Using the Launchers

```bash
# Run the struct launcher
"C:\Path\To\AutoHotkey64.exe" struct_breakdown/LAUNCHER.ahk

# Run the promise launcher
"C:\Path\To\AutoHotkey64.exe" promise_breakdown/LAUNCHER.ahk
```

The launchers provide:
- **Browse** examples by difficulty
- **Filter** by tier (Beginner/Intermediate/Advanced)
- **Run** examples with one click
- **View** source code in editor
- **Description** of each concept
- **About** information

---

## 📖 Learning Paths

### Path 1: Memory & Structures (struct.ahk)
1. Start: `01_property_descriptors.ahk` - Learn dynamic properties
2. Next: `02_buffer_management.ahk` - Understand memory basics
3. Then: `06_type_conversion.ahk` - API types
4. Practice: `03_dynamic_properties.ahk` - Advanced properties
5. Apply: `09_practical_api_usage.ahk` - Real WinAPI usage
6. Master: `08_nested_structures.ahk` - Complex structures

### Path 2: Async Programming (Promise.ahk)
1. Start: `01_basic_promise.ahk` - Create first promise
2. Next: `02_promise_states.ahk` - Understand lifecycle
3. Then: `03_then_catch_finally.ahk` - Chain operations
4. Practice: `04_promise_all.ahk` - Parallel operations
5. Apply: `10_practical_file_download.ahk` - Real async pattern
6. Master: `09_with_resolvers.ahk` - Advanced control

---

## 🔍 Quick Reference

### Struct Concepts
```ahk
; Property descriptors
obj.DefineProp("name", {get: getter, set: setter})

; Buffer management
buf := Buffer(size, init)
NumPut("Type", value, buf, offset)
result := NumGet(buf, offset, "Type")

; Memory alignment
alignedOffset := Mod(offset, typeSize) = 0
    ? offset
    : (Integer(offset / typeSize) + 1) * typeSize
```

### Promise Concepts
```ahk
; Create promise
p := Promise((resolve, reject) => {
    resolve("success") or reject("error")
})

; Chain operations
p.then(val => processValue(val))
 .catch(err => handleError(err))
 .finally(() => cleanup())

; Parallel operations
Promise.all([p1, p2, p3]).then(results => ...)
Promise.race([p1, p2, p3]).then(first => ...)

; Synchronous wait
result := promise.await(timeout)
```

---

## 🎓 Key Takeaways

### From struct.ahk:
- **DefineProp()** creates dynamic properties with custom getters/setters
- **Buffer()** allocates raw memory for WinAPI interaction
- **NumPut/NumGet** write/read typed data to/from memory
- **Memory alignment** ensures proper data structure layout
- **Type conversion** maps Windows types to AHK types
- **Nested structs** enable complex data structures

### From Promise.ahk:
- **Promises** represent eventual completion of async operations
- **States**: pending → fulfilled or rejected (permanent)
- **Chaining** enables sequential async operations
- **Error handling** propagates through catch() handlers
- **Parallel ops** with all(), race(), any(), allSettled()
- **await()** converts async promises to synchronous blocking

---

## 🚀 Next Steps

### More Libraries to Break Down:
1. **JSON.ahk** - JSON parsing and serialization
2. **CLR.ahk** - .NET interop patterns
3. **WebSocket.ahk** - WebSocket connections
4. **Base64.ahk** - Encoding/decoding
5. **Crypt.ahk** - Cryptography operations
6. **Archive.ahk** - ZIP file handling
7. **YAML.ahk** - YAML parsing
8. **Chrome.ahk** - Chrome DevTools Protocol
9. **Direct2D.ahk** - Graphics rendering
10. **Socket.ahk** - Network sockets

### Suggested Breakdown Format:
- 10 focused examples per library
- 1 launcher GUI
- Beginner/Intermediate/Advanced categorization
- Practical real-world examples
- Clear concept documentation

---

## 📝 Notes

- All examples use `#Requires AutoHotkey v2.0`
- Examples are standalone but include library where needed
- Each script includes explanatory comments
- MsgBox output shows results and concepts
- Launchers provide easy browsing and execution

---

**Created:** 2025-11-20
**Status:** ✅ Complete and Committed
**Commit:** `3237269`

Ready to create more library breakdowns!
