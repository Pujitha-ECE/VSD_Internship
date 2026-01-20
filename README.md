# VSD_Internship
## Questions and Answers

1. **Where is the RISC-V program located in the vsd-riscv2 repository?**  
   The RISC-V program is located in the `software` directory, which contains the C source files for the processor.

2. **How is the program compiled and loaded into memory?**  
   The program is compiled using a RISC-V cross-compiler, and the generated binary is loaded into memory during simulation or when the FPGA is programmed.

3. **How does the RISC-V core access memory and memory-mapped IO?**  
   The core accesses both memory and memory-mapped IO over a common bus, using different address ranges to distinguish RAM from peripherals.

4. **Where would a new FPGA IP block logically integrate in this system?**  
   A new FPGA IP block would be integrated as a memory-mapped peripheral on the system bus, allowing the core to access it using normal load and store instructions.
