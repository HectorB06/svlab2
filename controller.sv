module controller #(parameter WIDTH = 16,
            parameter INSTR_LEN = 20,
            parameter ADDR = 5) (
    input  logic        clk,
    input  logic        reset,
    input logic         go,
    input  logic [INSTR_LEN-1:0] instruction,
    input  logic        done,
    output logic        enable,
    output logic [ADDR-1:0]  pc,
    output logic [3:0]  opcode,
    output logic [7:0]  a, b,
    output logic invalid_opcode
);

// Your code here
typedef enum logic [2:0] {
        S_WAIT_GO,
        S_FETCH,
        S_EXTRACT,
        S_EXECUTE,
        S_WAIT_GCD,
        S_WAIT_GCD1,
        S_WAIT_GCD2,
        S_EXECUTE_GCD
} state_type;

state_type state, next_state;

logic [ADDR-1:0] pc_reg, next_pc;

always_comb begin : P1
    next_state = state;
    next_pc = pc_reg;

    // Default outputs
    enable = 0;
    invalid_opcode = 0;
    opcode = 0;
    a = 0;
    b = 0;
    case (state)

        S_WAIT_GO : begin
            if (go)
                next_state = S_FETCH;
        end

        S_FETCH : begin
            next_state = S_EXTRACT;
        end

        S_EXTRACT: begin
            opcode = instruction[19:16];
            a = instruction[15:8];
            b = instruction[7:0];
            enable = 1'b1;

            if (opcode == 4'b1111) begin
                next_state = S_WAIT_GO;
            end
            if(opcode == 4'b1011 ) begin
                next_state = S_WAIT_GCD;
            end
            else begin
                next_state = S_EXECUTE;
            end
     
        end

        S_WAIT_GCD: begin
            opcode = 4'b1011;
            enable = 1'b1;
            next_state = S_WAIT_GCD1;
        end

        S_WAIT_GCD1: begin
            opcode = 4'b1011;
            enable = 1'b1;
            next_state = S_WAIT_GCD2;
        end

        S_WAIT_GCD2: begin
            opcode = 4'b1011;
            enable = 1'b1;
            next_state = S_EXECUTE_GCD;
        end

        S_EXECUTE_GCD: begin
            opcode = 4'b1011;
            enable = 1'b1;
             if (done) begin
                next_pc = pc_reg + 1; // advance to next instruction
                next_state = S_FETCH;
            end
        end

        S_EXECUTE: begin
            enable = 1'b1;
             if (done) begin
                next_pc = pc_reg + 1; // advance to next instruction
                next_state = S_FETCH;
            end
        end

    endcase

end

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= S_WAIT_GO;
        pc_reg <= '0;
    end else begin
        state <= next_state;
        pc_reg <= next_pc;
    end
end
assign pc = pc_reg;
endmodule
