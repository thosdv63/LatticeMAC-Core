# LatticeMAC-Core

LatticeMAC-Core is a parameterized 16x16 Systolic Array NPU (Neural Processing Unit) written in SystemVerilog. I designed this core primarily to accelerate matrix multiplication and basic neural network inference workloads.

At its core, it's a standalone IP built around a 2D systolic array architecture. It processes 8-bit signed inputs, accumulates them into 32-bit registers, and passes the results through a hardware ReLU activation block.

## What's Inside

The default configuration uses a 16x16 processing grid (256 PEs in total), but the array size is fully parameterized in `npu_pkg.sv` so you can scale it to your needs. 

To handle the dataflow, the design includes a dual-port SRAM scratchpad and skew buffers for both rows and columns. These buffers are critical for getting that staggered, diagonal wavefront alignment right before the data hits the systolic array. Control logic is driven by a standard FSM.

The design has been converted using `sv2v`, simulated with Icarus Verilog, synthesized via Yosys, and tested on actual FPGA hardware.

## How it Works

Data moves through the core in a cycle-accurate, pipelined flow:

1. **Load:** Input matrices are written into the dual-port SRAM.
2. **Skew:** The SRAM feeds the row and column data into the skew buffers. These buffers add incremental delay cycles (0, 1, 2... N-1) to create the required diagonal wavefront.
3. **Compute:** The systolic grid does the heavy lifting, performing MAC operations across the PEs.
4. **Activation:** The 32-bit accumulated results pass through the ReLU unit. Any negative values are zeroed out using sign-bit detection.
5. **Writeback:** Final outputs are written back to the SRAM or routed to the top-level pins.

## Repository Structure

* `Design/` - Contains all the SystemVerilog RTL. 
  * `npu_core.sv` is the top-level module.
  * The rest of the core logic (`mac_pe.sv`, `lattice_grid.sv`, `sram_block.sv`, `skew_buffer.sv`, etc.) is also here.
* `Verification/` - Testbenches. `tb_npu_core.sv` is the main system-level testbench you'll want to run.

## Running Tests

To verify the design, the main testbench uses a software reference model. It generates deterministic signed inputs, loads them into the NPU, runs the computation, and compares all 256 output values (including the ReLU step) against the expected software results.

You'll need `sv2v`, `iverilog`, and `gtkwave`.

**To run the simulation:**
```bash
iverilog -g2012 -o npu_sim Design/npu_pkg.sv Design/mac_pe.sv Design/skew_buffer.sv Design/lattice_grid.sv Design/relu_activation.sv Design/sram_block.sv Design/npu_controller.sv Design/npu_core.sv Verification/tb_npu_core.sv
vvp npu_sim

gtkwave npu_sim.vcd

```

If everything passes, the testbench will output: `SUCCESFULL: 16x16 NPU MATRIX PRODUCT AND RELU VERIFIED!`

## Synthesis Notes

I ran this through generic Yosys synthesis using gate-level primitives. Here is a quick snapshot of the stats for the `npu_core` top module:

* **Total Cells:** ~440,950
* **Total DFFs:** 80,030
* **SRAM Storage:** 65,536 DFFs
* **Systolic Array (256 PEs):** 12,288 DFFs

*Note: This was a clean pass with 0 errors, but keep in mind these are generic synthesis numbers, not specific to any particular FPGA architecture's DSPs or BRAMs.*

```

## License

Distributed under the MIT License.
