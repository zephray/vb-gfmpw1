# https://github.com/JasonLrh/bin2verilog
import sys
import os
import argparse

# 
# argument handle
# 
parser = argparse.ArgumentParser(description='bin file to Verilog.v')
parser.add_argument('-t', help='timescale', default='1ns/1ps')
parser.add_argument('-b', help='Path to input [.bin] file', default='a.bin')
parser.add_argument('-o', help='Path to output [.v] file', default='ROM.v')
parser.add_argument('-addr_width', help='addr width', default=16, type=int)
parser.add_argument('-data_width', help='data width', default=8, type=int)
parser.add_argument('-addr_name', help='addr name', default='addr')
parser.add_argument('-data_name', help='data name', default='data')
parser.add_argument('-module_name', default="ROM")

args = parser.parse_args()

# 
# data_width 
# 
if args.data_width != 8:
    print("! data width not support : " + str(args.data_width))
    exit(0)

# 
# load bin file
# 
with open(args.b, mode='rb') as input_bin_file:
    bin_content = input_bin_file.read()

if bin_content is None:
    # no content in file or error in open file
    print("Warning: check input [.bin] file")
    exit(0)

length = len(bin_content)

if length > 2**int(args.addr_width):
    # addr bus is short    or     bin file too big 
    print("Warning: addr bus width is short for this file")
    length = 2**int(args.addr_width)

# 
# write verilog file 
# 
with open(args.o, mode="w", encoding='utf-8') as output_v_file:
    # test writeablility
    if output_v_file.writable() == False:
        print("! [.v] file can't write")
        exit(0)
    
    # write job
    # head
    output_v_file.write(
f"""`timescale {args.t}
module {args.module_name}(
    input [{args.addr_width - 1}:0] {args.addr_name},
    output reg [{args.data_width - 1}:0] {args.data_name}
);
always@(*)
    case ({args.addr_name})
""" )

    # data content
    for i in range(length):
        output_v_file.write(f"        {args.addr_width}" + f"'h%0{str(args.addr_width // 4)}X: "%i + f"{args.data_name} = {args.data_width}" + f"'h%0{str(args.data_width // 4)}X;\n"%bin_content[i])
    
    # end of file
    output_v_file.write(
f"""    endcase
endmodule
"""
    )
    print("Write OK")