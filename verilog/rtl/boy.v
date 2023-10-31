`timescale 1ns / 1ps
`default_nettype wire
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    17:30:26 02/08/2018 
// Module Name:    boy 
// Project Name:   VerilogBoy
// Description: 
//   VerilogBoy portable top level file. This is the file connect the CPU and 
//   all the peripherals in the LR35902 together.
// Dependencies: 
//   cpu
// Additional Comments: 
//   Hardware specific code should be implemented outside of this file
//   So normally in an implementation, this will not be the top level.
////////////////////////////////////////////////////////////////////////////////

module boy(
    input wire rst, // Async Reset Input
    input wire clk, // 4.19MHz Clock Input
    output wire phi, // 1.05MHz Reference Clock Output
    output wire [1:0] ct, // 0-3T cycle number
    // CPU/ DMA bus interface
    output wire [15:0] a, // Address Bus
    output wire [7:0] dout,  // Data Bus
    input wire [7:0] din,
    output wire wr, // Write Enable
    output wire rd, // Read Enable
    // Keyboard input
    input wire [7:0] key,
    // LCD output
    output wire hs, // Horizontal Sync Output
    output wire vs, // Vertical Sync Output
    output wire cpl, // Pixel Data Latch
    output wire [1:0] pixel, // Pixel Data
    output wire valid,
    // Sound output
    output reg [15:0] left,
    output reg [15:0] right,
    // PPU bus interface
    output wire [12:0] ppu_a,
    output wire ppu_wr,
    output wire ppu_rd,
    output wire [7:0] ppu_dout,
    input wire [7:0] ppu_din,
    // Debug interface
    output wire done,
    output wire fault
    );
    
    // CPU
    wire        cpu_rd;            // CPU Read Enable
    wire        cpu_wr;            // CPU Write Enable
    reg  [7:0]  cpu_din;           // CPU Data Bus, to CPU
    wire [7:0]  cpu_dout;          // CPU Data Bus, from CPU
    wire [15:0] cpu_a;             // CPU Address Bus
    wire [15:0] cpu_a_early;       // CPU Address Unbuffered
    wire [4:0]  cpu_int_en;        // CPU Interrupt Enable input
    wire [4:0]  cpu_int_flags_in;  // CPU Interrupt Flags input
    wire [4:0]  cpu_int_flags_out; // CPU Interrupt Flags output
    
    cpu cpu(
        .clk(clk),
        .rst(rst),
        .phi(phi),
        .ct(ct),
        .a(cpu_a),
        .a_early(cpu_a_early),
        .dout(cpu_dout),
        .din(cpu_din),
        .rd(cpu_rd),
        .wr(cpu_wr),
        .int_en(cpu_int_en),
        .int_flags_in(cpu_int_flags_in),
        .int_flags_out(cpu_int_flags_out),
        .key_in(key),
        .done(done),
        .fault(fault));
        
    // High RAM
    reg [7:0] high_ram [0:127];
    wire high_ram_rd = cpu_rd;
    reg high_ram_wr;
    wire [6:0] high_ram_a = cpu_a[6:0];
    wire [7:0] high_ram_din = cpu_dout;
    reg [7:0] high_ram_dout;
    always @(posedge clk) begin
        if (high_ram_wr)
            high_ram[high_ram_a] <= high_ram_din;
        else
            high_ram_dout <= (high_ram_rd) ? high_ram[high_ram_a] : 8'bx;
    end

    //DMA
    wire dma_rd; // DMA Memory Write Enable
    wire dma_wr; // DMA Memory Read Enable
    wire [15:0] dma_a; // Main Address Bus
    wire [7:0]  dma_din; // Main Data Bus
    wire [7:0]  dma_dout;
    wire [7:0]  dma_mmio_dout;
    reg dma_mmio_wr; // actually wire
    wire dma_occupy_bus;
    dma dma(
        .clk(clk),
        .rst(rst),
        .ct(ct),
        .dma_rd(dma_rd),
        .dma_wr(dma_wr),
        .dma_a(dma_a),
        .dma_din(dma_din),
        .dma_dout(dma_dout),
        .mmio_wr(dma_mmio_wr),
        .mmio_din(cpu_dout),
        .mmio_dout(dma_mmio_dout),
        .dma_occupy_bus(dma_occupy_bus)
    );
    assign dma_din = din;

    // Interrupt
    // int_req is the request signal from peripherals.
    // When an interrupt is generated, the peripheral should send a pulse on
    // the int_req for exactly one clock (using 4MHz clock).
    wire [4:0] int_req;

    wire int_key_req;  
    wire int_serial_req;
    wire int_serial_ack;
    wire int_tim_req;
    wire int_tim_ack;
    wire int_lcdc_req;
    wire int_lcdc_ack;
    wire int_vblank_req;
    wire int_vblank_ack;

    assign int_req[4] = int_key_req;
    assign int_req[3] = int_serial_req;
    assign int_req[2] = int_tim_req;
    assign int_req[1] = int_lcdc_req;
    assign int_req[0] = int_vblank_req;

    //reg reg_ie_rd;
    reg reg_ie_wr;
    reg [4:0] reg_ie;
    wire [4:0] reg_ie_din = cpu_dout[4:0];
    wire [4:0] reg_ie_dout;
    always @(posedge clk) begin
        if (reg_ie_wr)
            reg_ie <= reg_ie_din;
    end

    assign reg_ie_dout = reg_ie;
    assign cpu_int_en = reg_ie_dout;

    // Interrupt may be manually triggered
    // int_req should only stay high for only 1 cycle for each interrupt
    //reg reg_if_rd;
    reg reg_if_wr;
    reg [4:0] reg_if;
    wire [4:0] reg_if_din = cpu_dout[4:0];
    wire [4:0] reg_if_dout;
    always @(posedge clk) begin
        if (reg_if_wr)
            reg_if <= reg_if_din | int_req;
        else
            reg_if <= cpu_int_flags_out | int_req;
    end
    assign reg_if_dout = reg_if | int_req;
    assign cpu_int_flags_in = reg_if_dout;

    assign int_serial_ack = reg_if[3];
    assign int_tim_ack = reg_if[2];
    assign int_lcdc_ack = reg_if[1];
    assign int_vblank_ack = reg_if[0];

    // PPU
    wire [7:0] ppu_mmio_dout;
    reg ppu_mmio_wr; // actually wire
    wire [15:0] oam_a;
    wire [7:0] oam_dout;
    wire [7:0] oam_din;
    wire oam_rd;
    wire oam_wr;
    reg oam_cpu_wr;

    assign oam_a = (dma_occupy_bus) ? (dma_a) : (cpu_a);
    assign oam_din = (dma_occupy_bus) ? (dma_dout) : (cpu_dout);
    assign oam_rd = (dma_occupy_bus) ? (1'b0) : (cpu_rd);
    assign oam_wr = (dma_occupy_bus) ? (dma_wr) : (oam_cpu_wr);

    ppu ppu(
        .clk(clk),
        .rst(rst),
        .ct(ct),
        .mmio_a(cpu_a), // mmio bus is always accessable to CPU
        .mmio_dout(ppu_mmio_dout),
        .mmio_din(cpu_dout),
        .mmio_rd(cpu_rd),
        .mmio_wr(ppu_mmio_wr),
        .oam_a(oam_a),
        .oam_dout(oam_dout),
        .oam_din(oam_din),
        .oam_rd(oam_rd),
        .oam_wr(oam_wr),
        .int_vblank_req(int_vblank_req),
        .int_lcdc_req(int_lcdc_req),
        .int_vblank_ack(int_vblank_ack),
        .int_lcdc_ack(int_lcdc_ack),
        .cpl(cpl), // Pixel clock
        .pixel(pixel), // Pixel Data (2bpp)
        .valid(valid),
        .hs(hs), // Horizontal Sync, Low Active
        .vs(vs),  // Vertical Sync, Low Active
        .vram_a(ppu_a),
        .vram_dout(ppu_din),
        .vram_din(ppu_dout),
        .vram_rd(ppu_rd),
        .vram_wr(ppu_wr),
        // Ignore the debugging interface
        /* verilator lint_off PINCONNECTEMPTY */
        .scx(),
        .scy(),
        .state()
        /* verilator lint_on PINCONNECTEMPTY */
    );

    // Timer
    wire [7:0] timer_dout;
    reg timer_wr; // actually wire

    timer timer(
        .clk(clk),
        .rst(rst),
        .ct(ct),
        .a(cpu_a),
        .dout(timer_dout),
        .din(cpu_dout),
        .rd(cpu_rd),
        .wr(timer_wr),
        .int_tim_req(int_tim_req),
        .int_tim_ack(int_tim_ack)
    );
    
    // Dummy Serial
    wire [7:0] serial_dout;
    reg serial_wr; // actually wire

    serial serial(
        .clk(clk),
        .rst(rst),
        .a(cpu_a),
        .dout(serial_dout),
        .din(cpu_dout),
        .rd(cpu_rd),
        .wr(serial_wr),
        .int_serial_req(int_serial_req),
        .int_serial_ack(int_serial_ack)
    );
    
    // Sound
    wire [7:0] sound_dout;
    reg sound_wr; // wire
    wire [15:0] left_pre;
    wire [15:0] right_pre;
    
    sound sound(
        .clk(clk),
        .rst(rst),
        .a(cpu_a),
        .dout(sound_dout),
        .din(cpu_dout),
        .rd(cpu_rd),
        .wr(sound_wr),
        .left(left_pre),
        .right(right_pre),
        // Ignore the debugging signals
        /* verilator lint_off PINCONNECTEMPTY */
        .ch1_level(),
        .ch2_level(),
        .ch3_level(),
        .ch4_level()
        /* verilator lint_on PINCONNECTEMPTY */
    );
    
    always @(posedge clk) begin
        left <= left_pre;
        right <= right_pre;
    end

    // Boot ROM Enable Register
    reg brom_disable;
    reg brom_disable_wr; // actually wire
    always @(posedge clk) begin
        if (rst)
            brom_disable <= 1'b0;
        else
            if (brom_disable_wr && (!brom_disable))
                brom_disable <= cpu_dout[0];
    end

    wire [7:0] brom_dout;
    brom brom(
        .a(cpu_a[7:0]),
        .d(brom_dout)
    );

    // Keypad
    wire [7:0] keypad_reg;
    reg keypad_reg_wr; // actually wire
    reg [1:0] keypad_high;
    always @(posedge clk) begin
        if (rst)
            keypad_high <= 2'b11;
        else
            if (keypad_reg_wr)
                keypad_high <= cpu_dout[5:4];
    end
    assign keypad_reg[7:6] = 2'b11;
    assign keypad_reg[5:4] = keypad_high[1:0];
    assign keypad_reg[3:0] = 
        ~(((keypad_high[1] == 1'b1) ? (key[7:4]) : 4'h0) | 
          ((keypad_high[0] == 1'b1) ? (key[3:0]) : 4'h0)); 
    assign int_key_req = (keypad_reg[3:0] != 4'hf) ? (1'b1) : (1'b0);

    // External Bus (this includes CPU/DMA access to WRAM, VRAM, and cartridge)
    reg ext_cpu_wr;  // wire
    assign a = (dma_occupy_bus) ? (dma_a) : (cpu_a_early);
    assign dout = cpu_dout; // DMA never writes to external bus
    assign wr = (dma_occupy_bus) ? (1'b0) : (ext_cpu_wr);
    assign rd = (dma_occupy_bus) ? (dma_rd) : (cpu_rd);

    // Bus Multiplexing, CPU
    always @(*) begin
        reg_ie_wr = 1'b0;
        reg_if_wr = 1'b0;
        keypad_reg_wr = 1'b0;
        timer_wr = 1'b0;
        serial_wr = 1'b0;
        dma_mmio_wr = 1'b0;
        brom_disable_wr = 1'b0;
        high_ram_wr = 1'b0;
        sound_wr = 1'b0;
        ppu_mmio_wr = 1'b0;
        oam_cpu_wr = 1'b0;
        ext_cpu_wr = 1'b0;
        // -- These are exclusive to CPU --
        if (cpu_a == 16'hffff) begin  // 0xFFFF - IE
            //reg_ie_rd = bus_rd;
            reg_ie_wr = cpu_wr;
            cpu_din = {3'b0, reg_ie_dout};
        end
        else if (cpu_a == 16'hff0f) begin // 0xFF0F - IF
            //reg_if_rd = bus_rd;
            reg_if_wr = cpu_wr;
            cpu_din = {3'b111, reg_if_dout};
        end
        else if (cpu_a == 16'hff00) begin // 0xFF00 - Keypad
            keypad_reg_wr = cpu_wr;
            cpu_din = keypad_reg;
        end
        else if ((cpu_a == 16'hff04) || (cpu_a == 16'hff05) ||  // Timer
                (cpu_a == 16'hff06) || (cpu_a == 16'hff07)) begin
            timer_wr = cpu_wr;
            cpu_din = timer_dout;
        end
        else if ((cpu_a == 16'hff01) || (cpu_a == 16'hff02)) begin // Serial
            serial_wr = cpu_wr;
            cpu_din = serial_dout;
        end
        else if (cpu_a == 16'hff46) begin // 0xFF46 - DMA
            dma_mmio_wr = cpu_wr;
            cpu_din = dma_mmio_dout;
        end
        else if (cpu_a == 16'hff50) begin // 0xFF50 - BROM DISABLE
            brom_disable_wr = cpu_wr;
            cpu_din = {7'b0, brom_disable};
        end
        else if (cpu_a >= 16'hff80) begin // 0xFF80 - High RAM
            high_ram_wr = cpu_wr;
            cpu_din = high_ram_dout;
        end
        else if ((cpu_a >= 16'hff10 && cpu_a <= 16'hff1e) ||
            (cpu_a >= 16'hff20 && cpu_a <= 16'hff26) ||
            (cpu_a >= 16'hff30 && cpu_a <= 16'hff3f)) begin // Sound
            sound_wr = cpu_wr;
            cpu_din = sound_dout;
        end
        else if (cpu_a >= 16'hff40 && cpu_a <= 16'hff4b) begin // PPU MMIO
            ppu_mmio_wr = cpu_wr;
            cpu_din = ppu_mmio_dout;
        end
        else if ((cpu_a <= 16'h00ff) && (!brom_disable)) begin // Boot ROM
            cpu_din = brom_dout;
        end 
        // -- These are shared between CPU and DMA --
        else if (cpu_a >= 16'hfe00 && cpu_a <= 16'hfe9f) begin // OAM
            oam_cpu_wr = cpu_wr;
            cpu_din = (dma_occupy_bus) ? (8'hff) : (oam_dout);
        end
        else if (cpu_a <= 16'hfdff) begin // External/ Work RAM/ Video RAM
            ext_cpu_wr = cpu_wr;
            cpu_din = (dma_occupy_bus) ? (8'hff) : (din);
        end
        else begin
            // Unmapped area
            cpu_din = 8'hff;
        end
    end

endmodule
