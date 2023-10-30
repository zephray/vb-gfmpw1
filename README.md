# Caravel User Project

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)

Uses VerilogBoy design from https://github.com/zephray/VerilogBoy.

VerilogBoy is a GameBoy-compatible system design in synthesizable Verilog RTL. The submission for GFMPW1 includes the following components:

- SM83 (GBZ80) CPU core
- Pixel processing unit
- Programmable sound generator
- Timer
- Stereo PDM audio output
- 16KB integrated SRAM

To form a complete GB system, users need to provide the following additional components:

- Some buttons for input
- 160x144 LCD
- Low pass filter and audio amplifier
- Unmodified GameBoy game cartridge
- Small amount of glue logic

The simtop.v maybe used as a reference on external components required.

A Verilator-based testbench is provided in verilog/sim.

## Status

WIP

## License

Unless otherwise stated, HDL codes are dual-licensed under OHDL 1.0 and Apache 2.0, and software codes are dual-licensed under MIT and Apache 2.0.
