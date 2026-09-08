import npu_pkg::*;

module npu_controller (
    input  logic                       clk,
    input  logic                       rst_n,
    input  logic                       start,
    output logic [SRAM_ADDR_WIDTH-1:0] sram_addr,
    output logic                       clr_acc,
    output logic                       done_out
);

state_t state, next_state;

logic [SRAM_ADDR_WIDTH-1:0] addr_cnt;
logic [15:0]                cycle_cnt;

localparam int TOTAL_WAIT_CYCLES = (3 * N) + 1;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state     <= IDLE;
        addr_cnt  <= '0;
        cycle_cnt <= '0;
    end else begin
        state <= next_state;

        case (state)
            IDLE: begin
                addr_cnt  <= '0;
                cycle_cnt <= '0;
            end
            LOAD_COMPUTE: begin
                addr_cnt  <= addr_cnt + 1'b1;
                cycle_cnt <= '0;
            end
            WAIT: begin
                cycle_cnt <= cycle_cnt + 1'b1;
                addr_cnt  <= addr_cnt + 1'b1; 
            end
            DONE: begin
                addr_cnt  <= '0;
                cycle_cnt <= '0;
            end
            default: begin
                addr_cnt  <= '0;
                cycle_cnt <= '0;
            end
        endcase
    end
end

always_comb begin
    next_state = state;
    sram_addr  = addr_cnt;
    clr_acc    = 1'b0;
    done_out   = 1'b0;

    case (state)
        IDLE: begin
            if (start) begin
                next_state = LOAD_COMPUTE;
            end
        end 
        LOAD_COMPUTE: begin
            if (addr_cnt == '0) begin
                clr_acc = 1'b1;
            end

            if (addr_cnt == (N - 1)) begin
                next_state = WAIT;
            end
        end
        WAIT: begin
            if (cycle_cnt == (TOTAL_WAIT_CYCLES - 1)) begin
                next_state = DONE;
            end
        end
        DONE: begin
            done_out = 1'b1;
            if (!start) begin
                next_state = IDLE;
            end
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end
    
endmodule
