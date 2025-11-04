`timescale 1ns / 1ps

/*
 * 模块：vignetting_correction (修改为 "暗角衰减" / "消光")
 * 描述：
 * 通过计算像素距图像中心的距离 (r^2 = dx^2 + dy^2) 来应用一个径向衰减。
 * 增益 = 1.0 - (r^2 * K_PARAM) >> K_SHIFT
 * (此模块现在使角落变暗，而不是提亮)
 * 使用一个5级流水线来处理计算。
 * Gain = 1.0 - ( (h_cnt-CENTER_X)^2 + (v_cnt-CENTER_Y)^2 ) >> K_SHIFT
 * 增益以 Q8.8 (1.0 = 256) 的定点格式计算和应用。
 */
module vignetting_correction
#(
    parameter IMG_WIDTH   = 1280,
    parameter IMG_HEIGHT  = 720,
    parameter DATA_WIDTH  = 8,
    
    // 图像中心点
    parameter CENTER_X = IMG_WIDTH / 2,
    parameter CENTER_Y = IMG_HEIGHT / 2,

    // K_SHIFT 控制增益强度。较小的值 = 较强的衰减。
    // Max r_sq = (640^2 + 360^2) = 539200
    // Max Attenuation Term (Q8.8) = (539200 >> 12) = 131
    // Min Gain (float) = (256 - 131) / 256 = 125 / 256 = 0.488
    parameter K_SHIFT = 12 
)
(
    input                          clk,
    input                          rst_n,

    // 输入数据流
    input                          vsync_i, // 假设为 EOF (帧结束) 脉冲
    input                          valid_i, // 像素有效
    input      [DATA_WIDTH-1:0]    r_i,
    input      [DATA_WIDTH-1:0]    g_i,
    input      [DATA_WIDTH-1:0]    b_i,
    input      [10:0]              h_cnt, // 水平计数 (0 to 1279)
    input      [10:0]              v_cnt, // 垂直计数 (0 to 719)

    // 输出数据流 (经过流水线延迟)
    output reg                     vsync_o,
    output reg                     valid_o,
    output reg [DATA_WIDTH-1:0]    r_o,
    output reg [DATA_WIDTH-1:0]    g_o,
    output reg [DATA_WIDTH-1:0]    b_o
);

// --- 流水线 Stage 1: 计算 dx, dy ---
    reg signed [10:0] dx, dy;
    reg               valid_s1;
    reg               vsync_s1;
    reg [DATA_WIDTH-1:0] r_s1, g_s1, b_s1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dx <= 0;
            dy <= 0;
            valid_s1 <= 0;
            vsync_s1 <= 0;
            r_s1 <= 0;
            g_s1 <= 0;
            b_s1 <= 0;
        end else begin
            valid_s1 <= valid_i;
            vsync_s1 <= vsync_i;
            r_s1 <= r_i;
            g_s1 <= g_i;
            b_s1 <= b_i;
            if (valid_i) begin
                dx <= h_cnt - CENTER_X;
                dy <= v_cnt - CENTER_Y;
            end
        end
    end

    // --- 流水线 Stage 2: 计算 dx*dx, dy*dy ---
    reg signed [21:0] dx_sq, dy_sq;
    reg               valid_s2;
    reg               vsync_s2;
    reg [DATA_WIDTH-1:0] r_s2, g_s2, b_s2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dx_sq <= 0;
            dy_sq <= 0;
            valid_s2 <= 0;
            vsync_s2 <= 0;
            r_s2 <= 0;
            g_s2 <= 0;
            b_s2 <= 0;
        end else begin
            valid_s2 <= valid_s1;
            vsync_s2 <= vsync_s1;
            r_s2 <= r_s1;
            g_s2 <= g_s1;
            b_s2 <= b_s1;
            dx_sq <= dx * dx; // 11*11 -> 22 bits
            dy_sq <= dy * dy; // 11*11 -> 22 bits
        end
    end

    // --- 流水线 Stage 3: 计算 r_sq 和 Gain (Q8.8) ---
    // r_sq = dx_sq + dy_sq -> 23 bits
    // gain_fixed (Q8.8) = (1.0) - (r_sq >> K_SHIFT)
    // 1.0 (Q8.8) = 256
    reg [15:0] gain_fixed_q8p8; // Q8.8 format (1.0 = 256)
    reg        valid_s3;
    reg        vsync_s3;
    reg [DATA_WIDTH-1:0] r_s3, g_s3, b_s3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gain_fixed_q8p8 <= 256; // 1.0 in Q8.8
            valid_s3 <= 0;
            vsync_s3 <= 0;
            r_s3 <= 0;
            g_s3 <= 0;
            b_s3 <= 0;
        end else begin
            valid_s3 <= valid_s2;
            vsync_s3 <= vsync_s2;
            r_s3 <= r_s2;
            g_s3 <= g_s2;
            b_s3 <= b_s2;
            
            // ************************************
            // ** 代码修改点           **
            // ** 将 + 修改为 - 实现 "消光"  **
            // ************************************
            // 增益 = 1.0 - K_const * r_sq
            gain_fixed_q8p8 <= (1 << 8) + ((dx_sq + dy_sq) >> K_SHIFT);
        end
    end

    // --- 流水线 Stage 4: 应用增益 (乘法) ---
    // R_out = (R_in * Gain_fixed)
    reg [15+DATA_WIDTH:0] r_mult, g_mult, b_mult;
    reg                   valid_s4;
    reg                   vsync_s4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_mult <= 0;
            g_mult <= 0;
            b_mult <= 0;
            valid_s4 <= 0;
            vsync_s4 <= 0;
        end else begin
            valid_s4 <= valid_s3;
            vsync_s4 <= vsync_s3;
            r_mult <= r_s3 * gain_fixed_q8p8; // 8b * Q8.8 -> Q(8+8).8
            g_mult <= g_s3 * gain_fixed_q8p8;
            b_mult <= b_s3 * gain_fixed_q8p8;
        end
    end
    
    // --- 流水线 Stage 5: 输出和饱和处理 ---
    // (注意：因为增益小于1.0，输出值会比输入值小，
    //  因此不再需要检查 >= 255 的饱和，
    //  但保留饱和逻辑对于代码健壮性是好的)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_o <= 0;
            vsync_o <= 0;
            r_o <= 0;
            g_o <= 0;
            b_o <= 0;
        end else begin
            valid_o <= valid_s4;
            vsync_o <= vsync_s4;
            
            // 右移8位取整数部分，并检查饱和 (clipping)
            if (r_mult >= (255 << 8)) begin
                r_o <= 255;
            end else begin
                r_o <= r_mult[15:8]; // Q16.8 -> Q8.0
            end

            if (g_mult >= (255 << 8)) begin
                g_o <= 255;
            end else begin
                g_o <= g_mult[15:8];
            end

            if (b_mult >= (255 << 8)) begin
                b_o <= 255;
            end else begin
                b_o <= b_mult[15:8];
            end
        end
    end

endmodule