`timescale 1ns / 1ps

/**
 * @brief AWB 控制模块
 * @details 接收 R, G, B 总和，计算 R 和 B 的增益 (G 增益固定为 1.0)。
 * R_Gain = (G_Sum / R_Sum) * 256
 * B_Gain = (G_Sum / B_Sum) * 256
 * 输出为 Q8.8 格式 (256 = 1.0x)。
 */
module awb_control (
    .clk            (clk),
    .rst_n          (rst_n),
    
    // 输入来自 AWB Statistics
    .frame_done_i   (frame_done_i),
    .r_sum_i        (r_sum_i),
    .g_sum_i        (g_sum_i),
    .b_sum_i        (b_sum_i),

    // 输出至 P2_MWB 增益应用模块
    .r_gain_o       (r_gain_o), // Q8.8
    .g_gain_o       (g_gain_o), // Q8.8
    .b_gain_o       (b_gain_o)  // Q8.8
);

    input                   clk;
    input                   rst_n;
    
    input                   frame_done_i;
    input       [31:0]      r_sum_i;
    input       [31:0]      g_sum_i;
    input       [31:0]      b_sum_i;

    output  reg [15:0]      r_gain_o;
    output  reg [15:0]      g_gain_o;
    output  reg [15:0]      b_gain_o;

    // Q8.8 格式常量
    localparam GAIN_1X      = 16'd256;  // 1.0x
    localparam GAIN_MAX     = 16'd1024; // 4.0x (防止过度放大)
    localparam GAIN_MIN     = 16'd128;  // 0.5x (防止过度抑制)

    // 除法器逻辑
    // R_Gain = (G_Sum << 8) / R_Sum
    // G_Sum (32b) << 8 = 40b.
    wire [39:0] g_sum_shifted;
    wire [15:0] r_gain_raw;
    wire [15:0] b_gain_raw;
    
    assign g_sum_shifted = g_sum_i << 8; // 转换为 Q8.8

    // 异步除法器 (结果将在时钟沿被锁存)
    // 防止除以零
    assign r_gain_raw = (r_sum_i == 0) ? GAIN_1X : (g_sum_shifted / r_sum_i);
    assign b_gain_raw = (b_sum_i == 0) ? GAIN_1X : (g_sum_shifted / b_sum_i);

    // 锁存并饱和增益
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 默认增益为 1.0
            r_gain_o <= GAIN_1X;
            g_gain_o <= GAIN_1X;
            b_gain_o <= GAIN_1X;
        end else if (frame_done_i) begin
            // G 增益始终为 1.0
            g_gain_o <= GAIN_1X;

            // 锁存并限制 R 增益
            if (r_gain_raw > GAIN_MAX) begin
                r_gain_o <= GAIN_MAX;
            end else if (r_gain_raw < GAIN_MIN) begin
                r_gain_o <= GAIN_MIN;
            end else begin
                r_gain_o <= r_gain_raw;
            end

            // 锁存并限制 B 增益
            if (b_gain_raw > GAIN_MAX) begin
                b_gain_o <= GAIN_MAX;
            end else if (b_gain_raw < GAIN_MIN) begin
                b_gain_o <= GAIN_MIN;
            end else begin
                b_gain_o <= b_gain_raw;
            end
        end
    end

endmodule