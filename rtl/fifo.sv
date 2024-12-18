// Some design;
//    head = write pointer
//    tail = read pointer
module count_fifo #( // counter
    parameter DATA_WIDTH = 8,  // Veri genişliği
    parameter FIFO_DEPTH = 4  // FIFO derinliği
)(
    input  logic clk,          // Saat sinyali
    input  logic rst,          // Reset
    input  logic write_en,     // Yazma enable
    input  logic read_en,      // Okuma enable
    input  logic [DATA_WIDTH-1:0] write_data, // Yazılacak veri
    output logic [DATA_WIDTH-1:0] read_data,  // Okunan veri
    output logic full,          // FIFO dolu sinyali
    output logic empty          // FIFO boş sinyali
);

    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH); // Adres genişliği
    logic [DATA_WIDTH-1:0] fifo_mem [FIFO_DEPTH]; // FIFO belleği
    logic [ADDR_WIDTH-1:0] write_ptr, read_ptr;       // İşaretçiler
    logic [ADDR_WIDTH:0] fifo_count;                  // FIFO içindeki eleman sayısı

    always_ff @(posedge clk) begin
        if (rst) begin
            write_ptr <= 0;
            read_ptr <= 0;
            fifo_count <= 0;
        end else begin
            case ({write_en, read_en})
                2'b10: fifo_count <= fifo_count + 1; // Write only
                2'b01: fifo_count <= fifo_count - 1; // Read only
                default: fifo_count <= fifo_count;   // No operation
            endcase
            if (write_en && !full) begin
                fifo_mem[write_ptr] <= write_data;
                write_ptr <= write_ptr + 1;
            end
            if (read_en && !empty) begin
                read_data <= fifo_mem[read_ptr];
                read_ptr <= read_ptr + 1;
            end
        end
    end

    assign full  = (fifo_count == FIFO_DEPTH);
    assign empty = (fifo_count == 0);

endmodule

module le_fifo#( // last empty
    parameter DATA_WIDTH = 8,  // Veri genişliği
    parameter FIFO_DEPTH = 4  // FIFO derinliği
)(
    input  logic clk,          // Saat sinyali
    input  logic rst,          // Reset
    input  logic write_en,     // Yazma enable
    input  logic read_en,      // Okuma enable
    input  logic [DATA_WIDTH-1:0] write_data, // Yazılacak veri
    output logic [DATA_WIDTH-1:0] read_data,  // Okunan veri
    output logic full,          // FIFO dolu sinyali
    output logic empty          // FIFO boş sinyali
);

    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH); // Adres genişliği
    logic [DATA_WIDTH-1:0] fifo_mem [FIFO_DEPTH]; // FIFO belleği
    logic [ADDR_WIDTH-1:0] write_ptr, read_ptr;       // İşaretçiler
    logic wrap_around;

    always_ff @(posedge clk) begin
        if (rst) begin
            write_ptr <= 0;
            read_ptr <= 0;
        end else begin
            if (write_en && !full) begin
                fifo_mem[write_ptr] <= write_data;
                write_ptr <= write_ptr + 1;
            end
            if (read_en && !empty) begin
                read_data <= fifo_mem[read_ptr];
                read_ptr <= read_ptr + 1;
            end
        end
    end

    assign full = ((write_ptr+1'b1) == read_ptr); // not (write_ptr+1 == read_ptr);
    assign empty = (write_ptr == read_ptr);

endmodule

module wbit_fifo#(  // wrapper bit
    parameter DATA_WIDTH = 8,  // Veri genişliği
    parameter FIFO_DEPTH = 4  // FIFO derinliği
)(
    input  logic clk,          // Saat sinyali
    input  logic rst,          // Reset
    input  logic write_en,     // Yazma enable
    input  logic read_en,      // Okuma enable
    input  logic [DATA_WIDTH-1:0] write_data, // Yazılacak veri
    output logic [DATA_WIDTH-1:0] read_data,  // Okunan veri
    output logic full,          // FIFO dolu sinyali
    output logic empty          // FIFO boş sinyali
);

    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH); // Adres genişliği
    logic [DATA_WIDTH-1:0] fifo_mem [FIFO_DEPTH]; // FIFO belleği
    logic [ADDR_WIDTH:0] write_ptr, read_ptr;       // İşaretçiler
    logic wrap_around;

    always_ff @(posedge clk) begin
        if (rst) begin
            write_ptr <= 0;
            read_ptr <= 0;
        end else begin
            if (write_en && !full) begin
                fifo_mem[write_ptr[ADDR_WIDTH-1:0]] <= write_data;
                write_ptr <= write_ptr + 1;
            end
            if (read_en && !empty) begin
                read_data <= fifo_mem[read_ptr[ADDR_WIDTH-1:0]];
                read_ptr <= read_ptr + 1;
            end
        end
    end

    assign wrap_around  = (write_ptr[ADDR_WIDTH] ^ read_ptr[ADDR_WIDTH]);

    assign full = wrap_around & (write_ptr[ADDR_WIDTH-1:0] == read_ptr[ADDR_WIDTH-1:0]);
    assign empty = (write_ptr == read_ptr);

endmodule