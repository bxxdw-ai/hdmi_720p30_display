`timescale 1ns / 1ps

/**
 * @brief AWB 统计模块 (灰度世界法)
 * @details 收集一帧图像中 R, G, B 分量的总和，用于 AWB 控制器计算增益。
 * 为简单起见，采用“灰度世界”假设，对所有有效像素求和。
 */
module awb_statistics (
    .clk            (clk),
    .rst_n          (rst_n),
    
    // 输入来自 ISP (黑电平校正后)
    .in_vsync       (in_vsync),
    .in_valid       (in_valid), // Href / Valid
    .in_r           (in_r),
    .in_g           (in_g),
    .in_b           (in_b),

    // 输出至 AWB Control
    .r_sum_out      (r_sum_out),
    .g_sum_out      (g_sum_out),
    .b_sum_out      (b_sum_out),
    .frame_done_out (frame_done_out)
);

    input                   clk;
    input                   rst_n;
    
    input                   in_vsync;
    input                   in_valid;
    input       [7:0]       in_r;
    input       [7:0]       in_g;
    input       [7:0]       in_b;

    output  reg [31:0]      r_sum_out;
    output  reg [31:0]      g_sum_out;
    output  reg [31:0]      b_sum_out;
    output  reg             frame_done_out;

    // 内部累加器
    reg [31:0] sum_r_acc;
    reg [31:0] sum_g_acc;
    reg [31:0] sum_b_acc;
    
    // VSync 边沿检测
    reg  in_vsync_dly;
    wire frame_end = in_vsync_dly & ~in_vsync; // 帧结束信号 (Vsync 下降沿)

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_vsync_dly <= 1'b0;
        end else begin
            in_vsync_dly <= in_vsync;
        end
    end

    // 1. 像素累加
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_r_acc <= 32'd0;
            sum_g_acc <= 32'd0;
            sum_b_acc <= 32'd0;
        end else if (frame_end) begin
            // 帧结束后清零，准备下一帧
            sum_r_acc <= 32'd0;
            sum_g_acc <= 32'd0;
            sum_b_acc <= 32'd0;
        end else if (in_valid) begin
            // 在有效区域内累加
            sum_r_acc <= sum_r_acc + in_r;
            sum_g_acc <= sum_g_acc + in_g;
            sum_b_acc <= sum_b_acc + in_b;
        end
    end
    
    // 2. 帧结束时锁存结果
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_sum_out      <= 32'd0;
            g_sum_out      <= 32'd0;
            b_sum_out      <= 32'd0;
            frame_done_out <= 1'b0;
        end else begin
            frame_done_out <= frame_end; // 在帧结束时输出一个周期的脉冲
            if (frame_end) begin
                r_sum_out <= sum_r_acc;
                g_sum_out <= sum_g_acc;
                b_sum_out <= sum_b_acc;
            end
        end
    end

endmodule