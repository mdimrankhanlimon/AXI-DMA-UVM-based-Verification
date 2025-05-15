## 🔍 Design Source and Reference

This UVM verification environment targets the **AXI-DMA IP core** available on GitHub at:

👉 [Original Design Repo - aignacio/axi_dma](https://github.com/aignacio/axi_dma)

We have **verified the core functionality** of this AXI-DMA engine, which features:
- AXI4 Memory-mapped Master interface for Read/Write data
- AXI4-Lite Slave interface for Control & Status Registers (CSR)
- Register interface to configure source address, destination address, number of bytes, and DMA control flags (`go`, `abort`, etc.)

### 📘 Design Architecture and Register Reference

Refer to the original repo’s documentation:
- 📄 Find the Design block overview
- 📄 `csr_out/csr_dma.md`: CSR registers and field descriptions

---

## 🧹 RTL Cleanup and Integration

The original repository included various extra files and testbenches not directly relevant to verification.

As part of our UVM project:
- We **extracted only necessary RTL** files necessary for DMA operation
- These cleaned-up files are organized under our `RTL/` directory

---

## 📚 Verification Documentation

Our repository includes complete **UVM testbench source** and **project documentation**, including:
- Monitor and scoreboard behavior
- Feature checklist and test coverage
- Sequence configurations and test results
- Block-level verification architecture and ppt summaries

All documentation is maintained under the `documents/` folder and directly integrated into the verification project to ensure traceability.

############################################################################################################################################
############################################################################################################################################


# ✅ AXI-DMA UVM-Based Verification Project

Welcome to the **AXI-DMA Verification Project**, developed by the verification team at **SILICONOVA**. This project delivers a comprehensive **UVM-based testbench** and verification environment for an AXI-DMA Controller IP, covering functionality, protocol compliance, corner cases, and coverage metrics.

---

## 📌 Project Scope

This project verifies a DMA engine that transfers data from a source address to a destination address over an **AXI4** memory-mapped interface. Configuration and control is done using an **AXI4-Lite** interface.

The testbench includes:
- AXI4-Lite UVC (Driver + Monitor + Config Interface)
- AXI4 Reactive Master UVC (Driver + Monitor)
- AXI-DMA Control and Status Register (CSR) sequences
- DMA functional test sequences (aligned, unaligned, error injection)
- Coverage model and scoreboard with full transfer verification

---

## 🔧 Key Components

### ✅ AXI4-Lite Interface Verification
- **Driver**: Writes/reads to DMA CSR registers for config/start/abort.
- **Monitor**: Captures all AW/W/AR/R/B transactions with `dma_done_o` and `dma_error_o`.
- **Config Tracking**: Captures register configuration values per sequence.

### ✅ AXI4 Memory Interface Verification
- **Reactive Master**: Responds to AXI Read/Write initiated by DUT.
- **Monitor**: Verifies address, data, WSTRB, burst, and transaction order.

### ✅ Scoreboard Logic
- Matches:
  - Source address at first read
  - Destination address at first write
  - Per-byte data correctness using WSTRB
  - Total number of bytes read and written (`num_byte`)
  - Done/error per DMA sequence
- Handles:
  - Multiple sequences in pipeline
  - Unaligned transfers and partial WSTRB updates
  - ABORT scenarios and reset recovery

---

## 🧪 Testcases
- `basic_aligned_transfer_test`
- `unaligned_transfer_test`
- `multi_sequence_dma_test`
- `error_injection_test`
- `abort_mid_transfer_test`
- Custom parameterized burst, size, and alignment tests

---

## 📈 Coverage Metrics
- Code coverage (statement, toggle, branch)
- Functional coverage:
  - All AXI4-Lite register accesses
  - All CSR configuration fields
  - Read/Write combinations and burst types
  - WSTRB permutations and unaligned offsets

---

## 🏁 Final Results

- ✅ 100% functional coverage achieved
- ✅ CSR + AXI4 protocol compliance validated
- ✅ All testcases passing with no regressions
- ✅ Robust scoreboard and monitor integration for scalable expansion

---

## 🧠 Contributors

| Name                | Contributions                                                                 |
|---------------------|-------------------------------------------------------------------------------|
| **Md. Imran Khan**  | AXI4-Lite Monitor, Multi-sequence Scoreboard, Unaligned/WSTRB tracking logic |
| **Amit Sikder**     | Verification Env Setup, AXI4-Lite & AXI4 Drivers, Error Testcases             |
| **Shazarul Islam**  | Test Plan Creation, Directed Test Development                                |
| **Mumtahina Orthy** | DMA Feature Extraction, Randomized Testcase Support                          |
| **Jobera Jahan**    | Project Documentation, Testcase Summary                                       |
| **Rashid Shabab**   | Coverage Analysis and Optimization                                            |
| **Sadman Ferdous**  | Coverage Gap Identification, Coverage DB Validation                          |
| **Ramiz Vai**       | Team Mentor, Architecture Guidance, Debug Support                            |

---

## 📫 Contact

Md. Imran Khan  
📧 imran.limon.99@gmail.com  
🏢 SILICONOVA

---

## 🗂️ License

This project is intended for educational and verification training purposes within internal R&D environments.

