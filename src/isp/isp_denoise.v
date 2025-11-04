module isp_denoise
#(
    parameter DATA_WIDTH = 8
)
(
    input                          clk,
    input                          rst_n,
    
    // Input Stream
    input                          vsync_i,
    input                          valid_i,
    input      [DATA_WIDTH-1:0]    r_i,
    input      [DATA_WIDTH-1:0]    g_i,
    input      [DATA_WIDTH-1:0]    b_i,

    // Output Stream
    output reg                     vsync_o,
    output reg                     valid_o,
    output reg [DATA_WIDTH-1:0]    r_o,
    output reg [DATA_WIDTH-1:0]    g_o,
    output reg [DATA_WIDTH-1:0]    b_o
);

    // --- 管道延迟寄存器 (模拟 2 拍延迟) ---
    // 实际的 3x3 滤波器至少需要 2 拍像素延迟 (窗口) 和 2 行延迟 (行缓冲)
    // 为简单起见，我们只模拟一个简单的 2 拍数据路径延迟来保持时序.
    
    reg                            p1_vsync, p1_valid;
    reg    [DATA_WIDTH-1:0]        p1_r, p1_g, p1_b;

    reg                            p2_vsync, p2_valid;
    reg    [DATA_WIDTH-1:0]        p2_r, p2_g, p2_b;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            p1_vsync <= 1'b0; p1_valid <= 1'b0;
            p1_r     <= 0; p1_g     <= 0; p1_b     <= 0;
            
            p2_vsync <= 1'b0; p2_valid <= 1'b0;
            p2_r     <= 0; p2_g     <= 0; p2_b     <= 0;
            
            vsync_o  <= 1'b0; valid_o  <= 1'b0;
            r_o      <= 0; g_o      <= 0; b_o      <= 0;
        end else begin
            // 管道第 1 级
            p1_vsync <= vsync_i;
            p1_valid <= valid_i;
            p1_r     <= r_i;
            p1_g     <= g_i;
            p1_b     <= b_i;
            
            // 管道第 2 级
            p2_vsync <= p1_vsync;
            p2_valid <= p1_valid;
            
            // *******************************************************
            // *** 在这里实现你的降噪逻辑 ***
            // *** // *** 例如 (伪代码): 
            // *** p2_r <= (p00_r + p01_r + ... + p22_r) / 9;
            // *** (这需要行缓冲器和 3x3 像素窗口寄存器)
            // *******************************************************
            
            // --- 当前为直通逻辑 ---
            p2_r     <= p1_r; 
            p2_g     <= p1_g;
            p2_b     <= p1_b;
            
            
            // --- 最终输出级 (模拟2拍总延迟) ---
            vsync_o  <= p2_vsync;
            valid_o  <= p2_valid;
            r_o      <= p2_r;
            g_o      <= p2_g;
            b_o      <= p2_b;
        end
    end
    
endmodule