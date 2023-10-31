## Memory Access / Multiplexing

Due to limited pins, cartridge/ main memory access and VRAM access are multiplexed over one same bus.

4-cycles are divided as follows:

- 0: Cartridge address setup (for external latching)
- 1: VRAM access
- 2: WRAM or cartridge RW
- 3: VRAM access

Diagram:

```
CT       |  0  |  1  |  2  |  3  |
          ___________             ___            
CLK  ____|           |___________|     
     _    __    __    __    __    __    
CK    |__|  |__|  |__|  |__|  |__|  |
     ____       _____________________
EALE     |_____|
                      _____
ECS  ________________|     |_________
     ________________       _________
WR                   |_____|
     ____ _____ _____ _____ _____ ___
ADDR ____X_WR__X_VR1_X_WR__X_VR2_X___
     ____       _____ _____ _____ 
DATA ____>-----<_VR1_X_WR__X_VR2_>---
```

Note that VRAM/WRAM seperation is based on function unit: Only PPU accesses VRAM on cycle 2 and 4. If CPU accesses VRAM, it would still happen on cycle 3.
