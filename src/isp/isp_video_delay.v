`timescale 1ns / 1ps

/**
 * @brief ISP 视频流 N 级流水线延迟模块
 * @details 将 vsync, valid 和 data 信号延迟 N 个时钟周期。
 * 使用 generate 循环创建可综合的 N 级寄存器。
 *
 * @param STAGES 延迟拍数 (时钟周期数)，默认为 1。
 * @param DATA_WIDTH 数据位宽，默认为 24 (用于 RGB888)。
 */
module isp_video_delay #(
    parameter STAGES = 1,
    parameter DATA_WIDTH = 24
) (
    .clk        (clk),
    .rst_n      (rst_n),
    
    // Input Stream
    .vsync_i    (vsync_i),
    .valid_i    (valid_i),
    .data_i     (data_i),
    
    // Output Stream (Delayed)
    .vsync_o    (vsync_o),
    .valid_o    (valid_o),
    .data_o     (data_o)
);

    input                   clk;
    input                   rst_n;
    
    input                   vsync_i;
    input                   valid_i;
    input       [DATA_WIDTH-1:0]  data_i;
    
    output                  vsync_o;
    output                  valid_o;
    output      [DATA_WIDTH-1:0]  data_o;
    
    // 内部流水线线网数组 (N+1 级)
    // pipe[0] 是输入, pipe[STAGES] 是输出
    wire [STAGES:0]         vsync_pipe;
    wire [STAGES:0]         valid_pipe;
    wire [DATA_WIDTH-1:0]   data_pipe [STAGES:0]; // 综合工具支持的线网数组

    // 将输入连接到流水线的第 0 级
    assign vsync_pipe[0] = vsync_i;
    assign valid_pipe[0] = valid_i;
    assign data_pipe[0]  = data_i;
    
    // 将输出从流水线的最后一级 (STAGES) 引出
    assign vsync_o = vsync_pipe[STAGES];
    assign valid_o = valid_pipe[STAGES];
    assign data_o  = data_pipe[STAGES];

    // 使用 generate 循环生成 N 级寄存器
    genvar i;
    generate
        for (i = 0; i < STAGES; i = i + 1) begin : gen_delay_stage
            
            // 每一级的寄存器
            reg                     vsync_reg;
            reg                     valid_reg;
            reg [DATA_WIDTH-1:0]    data_reg;
            
            // 时序逻辑
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    vsync_reg <= 1'b0;
                    valid_reg <= 1'b0;
                    data_reg  <= {DATA_WIDTH{1'b0}};
                end else begin
                    // 从上一级 (i) 获取数据
                    vsync_reg <= vsync_pipe[i];
                    valid_reg <= valid_pipe[i];
                    data_reg  <= data_pipe[i];
                end
            end
            
            // 将寄存器的输出连接到下一级 (i+1)
            assign vsync_pipe[i+1] = vsync_reg;
            assign valid_pipe[i+1] = valid_reg;
            assign data_pipe[i+1]  = data_reg;
            
        end
    endgenerate

endmodule