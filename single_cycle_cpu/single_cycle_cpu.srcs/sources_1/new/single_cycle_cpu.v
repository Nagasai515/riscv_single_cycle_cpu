`timescale 1ns / 1ps

module single_cycle_cpu(
    input clk,
    input reset
);

    // ======================
    // PC Registers
    // ======================
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_plus4;
    assign pc_plus4 = pc_current + 4;

    pc PC_REG (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc_out(pc_current)
    );

    // ======================
    // Instruction Memory
    // ======================
    wire [31:0] instr;

    instruction_memory IMEM (
        .addr(pc_current),
        .instr(instr)
    );

    // Extract fields from instruction
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];
    wire       funct7b5 = instr[30];

    // Simple opcode flags (used for a few special cases)
    wire is_jalr  = (opcode == 7'b1100111);
    wire is_jal   = (opcode == 7'b1101111);
    wire is_auipc = (opcode == 7'b0010111);
    wire is_lui   = (opcode == 7'b0110111);

    // ======================
    // Control Unit
    // ======================
    wire       RegWrite, MemWrite, ALUSrc, Branch, Jump;
    wire [1:0] ALUOp, ResultSrc;
    wire [2:0] ImmSrc;

    main_control CTRL (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .Branch(Branch),
        .Jump(Jump),
        .ResultSrc(ResultSrc),
        .ALUOp(ALUOp),
        .ImmSrc(ImmSrc)
    );

    // ======================
    // Immediate Generator
    // ======================
    wire [31:0] imm;

    immediate_generator IMMGEN (
        .instr(instr),
        .ImmSrc(ImmSrc),
        .imm_out(imm)
    );

    // ======================
    // Register File
    // ======================
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [4:0] rd  = instr[11:7];

    wire [31:0] rd1, rd2;
    wire [31:0] writeback_data;

    Register_file RF (
        .clk(clk),
        .we(RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(writeback_data),
        .rd1(rd1),
        .rd2(rd2)
    );

    // ======================
    // ALU Control
    // ======================
    wire [3:0] alu_ctrl;

    alu_control ALC (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .alu_ctrl(alu_ctrl)
    );

    // ======================
    // ALU inputs
    // ======================
    // ALU A: normally rs1, but AUIPC uses PC as ALU operand A
    wire [31:0] alu_in1 = (is_auipc ? pc_current : rd1);

    // ALU B: immediate or rs2
    wire [31:0] alu_in2 = (ALUSrc ? imm : rd2);

    // ======================
    // ALU
    // ======================
    wire [31:0] alu_result;
    wire        Zero;

    arithmetic_logic_unit ALU (
        .a(alu_in1),
        .b(alu_in2),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(Zero)
    );

    // Signed/unsigned compare flags for branch unit (use register operands)
    wire slt  = ($signed(rd1) < $signed(rd2));
    wire sltu = (rd1 < rd2);

    // ======================
    // Data Memory
    // ======================
    wire [31:0] read_data;

    data_memory DMEM (
        .clk(clk),
        .MemWrite(MemWrite),
        .addr(alu_result),
        .wd(rd2),
        .rd(read_data)
    );

    // ======================
    // ResultSrc MUX (writeback selection)
    //   00 -> ALU result
    //   01 -> Memory read
    //   10 -> PC + 4
    // LUI -> write imm directly (special case)
    // ======================
    reg [31:0] wb_reg;
    always @(*) begin
        if (is_lui) begin
            wb_reg = imm;                     // U-type immediate already shifted in imm gen
        end else begin
            case (ResultSrc)
                2'b00: wb_reg = alu_result;
                2'b01: wb_reg = read_data;
                2'b10: wb_reg = pc_plus4;
                default: wb_reg = alu_result;
            endcase
        end
    end
    assign writeback_data = wb_reg;

    // ======================
    // Branch Control Unit
    // ======================
    wire PCSrc;

    branch_control BRANCH (
        .Branch(Branch),
        .Jump(Jump),
        .funct3(funct3),
        .Zero(Zero),
        .slt(slt),
        .sltu(sltu),
        .PCSrc(PCSrc)
    );

    // ======================
    // PC Target selection
    // ======================
    // Default branch/jump target = PC + imm (covers branches and JAL)
    wire [31:0] pc_target_pc = pc_current + imm;

    // JALR target = (rs1 + imm) & ~1
    wire [31:0] jalr_target = (rd1 + imm) & 32'hFFFFFFFE;

    // Final pc_target chooses JALR vs PC+imm
    wire [31:0] pc_target = is_jalr ? jalr_target : pc_target_pc;

    // ======================
    // Final PC mux: if PCSrc then target else PC+4
    // ======================
    assign pc_next = PCSrc ? pc_target : pc_plus4;

endmodule
