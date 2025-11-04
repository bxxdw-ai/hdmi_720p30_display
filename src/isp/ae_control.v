`timescale 1ns/1ps

/*
 * 模块: ae_control
 * 功能: 简单的数字自动曝光 (DAE) 控制器
 * 根据输入的平均亮度，计算出一个 Q8.8 格式的增益系数
 */
module ae_control (
    input             clk,
    input             rst_n,

    // 来自 ae_statistics
    input             frame_done,     // 帧结束脉冲
    input       [7:0] avg_brightness, // 平均亮度

    // 输出 (修正: 直接使用 output reg, 在 always 块中赋值)
    output reg [15:0] ae_gain_q8_8    // AE 增益 (Q8.8 格式, 256 = 1.0x)
);

    // --- 可调参数 ---
    parameter [7:0] TARGET_BRIGHTNESS = 8'd100; // 目标亮度 (0-255)
    parameter [7:0] HYSTERESIS        = 8'd5;   // 迟滞范围，防止抖动
    parameter [15:0] GAIN_STEP        = 16'd4;  // 增益调整步长 (4/256)
    parameter [15:0] MAX_GAIN         = 16'h0400; // 最大增益 (4.0x)
    parameter [15:0] MIN_GAIN         = 16'h0080; // 最小增益 (0.5x)
    // ---

    // 初始增益为 1.0x (Q8.8 = 256)
    localparam [15:0] INITIAL_GAIN = 16'h0100; 

    // 初始化
    initial begin
        ae_gain_q8_8 = INITIAL_GAIN;
    end

    // 增益控制逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ae_gain_q8_8 <= INITIAL_GAIN;
        end else if (frame_done) begin
            // 亮度过高，需要降低增益
            if (avg_brightness > (TARGET_BRIGHTNESS + HYSTERESIS)) begin
                if (ae_gain_q8_8 > (MIN_GAIN + GAIN_STEP)) begin
                    ae_gain_q8_8 <= ae_gain_q8_8 - GAIN_STEP;
                end else begin
                    ae_gain_q8_8 <= MIN_GAIN;
                end
            // 亮度过低，需要提高增益
            end else if (avg_brightness < (TARGET_BRIGHTNESS - HYSTERESIS)) begin
                if (ae_gain_q8_8 < (MAX_GAIN - GAIN_STEP)) begin
                    ae_gain_q8_8 <= ae_gain_q8_8 + GAIN_STEP;
                end else begin
                    ae_gain_q8_8 <= MAX_GAIN;
                end
            end
            // 在目标范围内，保持不变
        end
    end

    // [已删除] 错误的 assign 语句
    // assign ae_gain_q8_8 = current_gain_q8_8;

endmodule