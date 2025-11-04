`timescale 1ns/1ps

/*
 * 模块: ae_statistics
 * 功能: 统计一帧图像的平均亮度 (Y)
 * 输入为 Demosaic 后的 RGB 图像数据
 * 在 vsync 下降沿输出统计结果
 */
module ae_statistics (
    // 系统时钟 (w_csi_rx_clk)
    input             clk,
    input             rst_n,

    // 图像输入 (来自 Demosaic)
    input             in_vsync,   // 帧同步
    input             in_href,    // 行有效 (或 DE)
    input       [7:0] in_r,
    input       [7:0] in_g,
    input       [7:0] in_b,

    // 统计输出
    output reg  [7:0] avg_brightness_out, // 平均亮度
    output reg        frame_done_out      // 帧结束脉冲
);

    // 硬件近似 Y = (R*77 + G*150 + B*29) >> 8
    // (0.299*R + 0.587*G + 0.114*B)
    wire [15:0] y_calc = (in_r * 8'd77) + (in_g * 8'd150) + (in_b * 8'd29);
    wire [7:0]  y_pix  = y_calc[15:8];

    // 累加器
    reg [27:0] sum_y;           // 28 bits -> 921,600 (20b) * 255 (8b)
    reg [19:0] pixel_count;     // 20 bits -> 1280 * 720 = 921,600

    // 帧状态
    reg  vsync_dly;
    wire frame_active = in_vsync && in_href;
    wire frame_start  = frame_active && (pixel_count == 0);
    wire frame_end    = !in_vsync && vsync_dly; // VSync 下降沿

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vsync_dly <= 1'b0;
            sum_y     <= 28'd0;
            pixel_count <= 20'd0;
        end else begin
            // 寄存 VSync
            vsync_dly <= in_vsync;
            
            if (frame_active) begin
                if (pixel_count == 20'd0) begin // 帧开始 (或被 VSync 中断后重启)
                    sum_y     <= y_pix;
                    pixel_count <= 20'd1;
                end else begin
                    sum_y     <= sum_y + y_pix;
                    pixel_count <= pixel_count + 1;
                end
            end else if (frame_end) begin // 帧结束，清零
                pixel_count <= 20'd0;
            end
        end
    end

    // 锁存统计结果并在帧结束时计算平均值
    reg [27:0] sum_y_latched;
    reg [19:0] pixel_count_latched;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_y_latched       <= 28'd0;
            pixel_count_latched <= 20'd0;
            avg_brightness_out  <= 8'd0;
            frame_done_out      <= 1'b0;
        end else begin
            // 默认清除脉冲
            frame_done_out <= 1'b0;

            if (frame_end) begin
                frame_done_out      <= 1'b1;
                sum_y_latched       <= sum_y;
                pixel_count_latched <= pixel_count;

                // 计算平均值: sum / count
                // 使用移位近似除以 921600 (1280*720)
                // log2(921600) = 19.8. 我们右移 20 位.
                if (pixel_count_latched > 0) begin
                    avg_brightness_out <= sum_y_latched[27:20]; 
                end else begin
                    avg_brightness_out <= 8'd0;
                end
            end
        end
    end

endmodule