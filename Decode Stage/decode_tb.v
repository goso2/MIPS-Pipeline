`timescale 1ns / 1ps

module decodeTB();

    reg                 clk_tb,
                        rst_tb,
                        wb_reg_write_tb;
    reg [4:0]           wb_write_reg_location_tb;
    reg [31:0]          mem_wb_write_data_tb,
                        if_id_instr_tb,
                        if_id_npc_tb;

    wire [1:0]          id_ex_wb_tb;
    wire [2:0]          id_ex_mem_tb;
    wire [3:0]          id_ex_execute_tb;
    wire [31:0]         id_ex_npc_tb,
                        id_ex_readdat1_tb,
                        id_ex_readdat2_tb,
                        id_ex_sign_ext_tb;
    wire [4:0]          id_ex_instr_bits_20_16_tb,
                        id_ex_instr_bits_15_11_tb;

    // ============================================
    // Instantiate Decode Module (FIXED VERSION)
    // ============================================
    decode DUT (
        .clk(clk_tb),
        .rst(rst_tb),

        // Writeback inputs
        .wb_reg_write(wb_reg_write_tb),
        .wb_write_reg_location(wb_write_reg_location_tb),
        .mem_wb_write_data(mem_wb_write_data_tb),      // <-- ADDED

        // IF/ID pipeline inputs
        .if_id_instr(if_id_instr_tb),
        .if_id_npc(if_id_npc_tb),

        // Outputs
        .id_ex_wb(id_ex_wb_tb),
        .id_ex_mem(id_ex_mem_tb),
        .id_ex_execute(id_ex_execute_tb),
        .id_ex_npc(id_ex_npc_tb),

        .id_ex_readdat1(id_ex_readdat1_tb),            // <-- ADDED
        .id_ex_readdat2(id_ex_readdat2_tb),            // <-- ADDED

        .id_ex_sign_ext(id_ex_sign_ext_tb),
        .id_ex_instr_bits_20_16(id_ex_instr_bits_20_16_tb),
        .id_ex_instr_bits_15_11(id_ex_instr_bits_15_11_tb)
    );

    // ============================================
    // Clock Generation
    // ============================================
    initial begin
        clk_tb = 0;
        forever #1 clk_tb = ~clk_tb;
    end

    // ============================================
    // Test Vectors
    // ============================================
    initial begin
        rst_tb = 1;
        wb_reg_write_tb = 0;
        wb_write_reg_location_tb = 5'd2;
        mem_wb_write_data_tb = 32'h00000064; // 100 decimal

        if_id_npc_tb = 32'h00000001;
        if_id_instr_tb = 32'h00A41020;   // ADD $v0, $a1, $a0

        #2;
        rst_tb = 0;
        #2;

        if_id_npc_tb = 32'h00000002;
        if_id_instr_tb = 32'h10000008;   // BEQ

        #2;
        if_id_npc_tb = 32'h00000003;
        if_id_instr_tb = 32'h8C820002;   // LW

        #2;
        if_id_npc_tb = 32'h00000004;
        if_id_instr_tb = 32'hAC820002;   // SW

        #2;
        if_id_npc_tb = 32'h00000005;
        wb_reg_write_tb = 1;

        #2;
        if_id_instr_tb = 32'h00421020;   // ADD

        if_id_npc_tb = 32'h00000006;
        wb_reg_write_tb = 0;

        #4;
        $display("Decode Complete");
        $finish;
    end

endmodule
