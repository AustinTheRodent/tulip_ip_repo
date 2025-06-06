#!/bin/python3

import os
import sys

def strip_newline(input_string):
  ret_string = input_string
  if ret_string == "":
    return ""
  if ret_string[len(ret_string)-1] == "\r":
    ret_string = ret_string[0:-1]
  if ret_string == "":
    return ""
  if ret_string[len(ret_string)-1] == "\n":
    ret_string = ret_string[0:-1]
  if ret_string == "":
    return ""
  if ret_string[len(ret_string)-1] == "\r":
    ret_string = ret_string[0:-1]
  if ret_string == "":
    return ""
  return ret_string

def strip_whitespace(input_string):
  ret_string = input_string
  count = 0
  for i in range(len(ret_string)):
    if ret_string[i] != " ":
      break
    else:
      count += 1
  ret_string = ret_string[count:]
  count = 0
  for i in reversed(range(len(ret_string))):
    if ret_string[i] != " ":
      break
    else:
      count += 1
  return ret_string[0:len(ret_string)-count]

def add_spaces(input_string, template_string):
  num_spaces = template_string.find("#")
  ret_string = input_string
  for i in range(num_spaces):
    ret_string += " "
  return ret_string

def add_spaces2(input_string, num_spaces):
  ret_string = input_string
  for i in range(num_spaces):
    ret_string += " "
  return ret_string

def write_all(template_file_obj, reg_file_obj, constants, registers, package_name):
  for line in template_file_obj:
    if line.find("#") == -1:
      reg_file_obj.write(line)
    else:
      line = strip_newline(line)
      type = line[line.find("#")+1:]
      if type == "package name":
        wr_line = ""
        wr_line = add_spaces(wr_line, line)
        wr_line += "package %s_pkg is\n" % package_name
        reg_file_obj.write(wr_line)
      elif type == "use package":
        wr_line = ""
        wr_line = add_spaces(wr_line, line)
        wr_line += "use work.%s_pkg.all;\n" % package_name
        reg_file_obj.write(wr_line)
      elif type == "entity name":
        wr_line = ""
        wr_line = add_spaces(wr_line, line)
        wr_line += "entity %s is\n" % package_name
        reg_file_obj.write(wr_line)
      elif type == "architecture name":
        wr_line = ""
        wr_line = add_spaces(wr_line, line)
        wr_line += "architecture rtl of %s is\n" % package_name
        reg_file_obj.write(wr_line)
      elif type == "constant data width":
        wr_line = ""
        wr_line = add_spaces(wr_line, line)
        wr_line += "constant C_REG_FILE_DATA_WIDTH : integer := %s;\n" % constants["REG_FILE_DATA_WIDTH"]
        reg_file_obj.write(wr_line)
      elif type == "constant address width":
        wr_line = ""
        wr_line = add_spaces(wr_line, line)
        wr_line += "constant C_REG_FILE_ADDR_WIDTH : integer := %s;\n" % constants["REG_FILE_ADDR_WIDTH"]
        reg_file_obj.write(wr_line)
      elif type == "register names":
        for i in registers:
          wr_line = ""
          wr_line = add_spaces(wr_line, line)
          wr_line += "%s_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);\n" % i
          reg_file_obj.write(wr_line)
      elif type == "awc process":
        for i in registers:
          if registers[i]["type"] == "AWC":
            wr_line = ""
            wr_line += "  process(s_axi_aclk)\n"
            wr_line += "  begin\n"
            wr_line += "    if rising_edge(s_axi_aclk) then\n"
            wr_line += "      if s_axi_aresetn = '0' then\n"
            wr_line += "        registers.%s_REG <= x\"%08X\";\n" % (i, registers[i]["reset_val"])
            wr_line += "      else\n"
            wr_line += "        if std_logic_vector(to_unsigned(%s_addr, C_REG_FILE_ADDR_WIDTH)) = awaddr and s_axi_wvalid = '1' and s_axi_wready_int = '1' then\n" % i
            wr_line += "          registers.%s_REG <= registers.%s_REG and (not s_axi_wdata);\n" % (i, i)
            wr_line += "        else\n"
            for j in registers[i]["subreg"]:
              wr_line += "          if s_%s_%s_v = '1' then\n" % \
                (i, j)
              wr_line = add_spaces(wr_line, line)
              if registers[i]["subreg"][j]["length"] == 1:
                tmp = registers[i]["subreg"][j]["range"]
                tmp = tmp.split()[0]
                wr_line += "          registers.%s_REG(%s) <= registers.%s_REG(%s) or s_%s_%s;\n" % \
                  (i, tmp, i, tmp, i, j)
              else:
                wr_line += "          registers.%s_REG(%s) <= registers.%s_REG(%s) or s_%s_%s;\n" % \
                  (i, registers[i]["subreg"][j]["range"], i, registers[i]["subreg"][j]["range"], i, j)
              wr_line += "          end if;\n"
            wr_line += "        end if;\n"
            wr_line += "      end if;\n"
            wr_line += "    end if;\n"
            wr_line += "  end process;\n"
            reg_file_obj.write(wr_line)


      elif type == "register wr pulses":
        for i in registers:
          wr_line = ""
          wr_line = add_spaces(wr_line, line)
          wr_line += "%s_wr_pulse : std_logic;\n" % i
          reg_file_obj.write(wr_line)
      elif type == "register rd pulses":
        for i in registers:
          wr_line = ""
          wr_line = add_spaces(wr_line, line)
          wr_line += "%s_rd_pulse : std_logic;\n" % i
          reg_file_obj.write(wr_line)
      elif type == "register addresses":
        for i in registers:
          wr_line = ""
          wr_line = add_spaces(wr_line, line)
          wr_line += "constant %s_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := %i;\n" % (i, registers[i]["address"])
          reg_file_obj.write(wr_line)
      elif type == "wr pulse eq zero":
        for i in registers:
          wr_line = ""
          wr_line = add_spaces(wr_line, line)
          wr_line += "registers.%s_wr_pulse <= '0';\n" % i
          reg_file_obj.write(wr_line)
      elif type == "rd pulse eq zero":
        for i in registers:
          wr_line = ""
          wr_line = add_spaces(wr_line, line)
          wr_line += "registers.%s_rd_pulse <= '0';\n" % i
          reg_file_obj.write(wr_line)
      elif type == "rd pulse eq one":
        for i in registers:
          wr_line = ""
          wr_line = add_spaces(wr_line, line)
          wr_line += "when std_logic_vector(to_unsigned(%s_addr, C_REG_FILE_ADDR_WIDTH)) =>\n" % i
          wr_line = add_spaces(wr_line, line)
          wr_line += "  registers.%s_rd_pulse <= '1';\n" % i
          reg_file_obj.write(wr_line)
      elif type == "awaddr case":
        for i in registers:
          if registers[i]["type"] == "RW":
            wr_line = ""
            wr_line = add_spaces(wr_line, line)
            wr_line += "when std_logic_vector(to_unsigned(%s_addr, C_REG_FILE_ADDR_WIDTH)) =>\n" % i
            wr_line = add_spaces(wr_line, line)
            wr_line += "  registers.%s_REG <= s_axi_wdata;\n" % i
            wr_line = add_spaces(wr_line, line)
            wr_line += "  registers.%s_wr_pulse <= '1';\n" % i
            reg_file_obj.write(wr_line)
          elif registers[i]["type"] == "AWC":
            wr_line = ""
            wr_line = add_spaces(wr_line, line)
            wr_line += "when std_logic_vector(to_unsigned(%s_addr, C_REG_FILE_ADDR_WIDTH)) =>\n" % i
            wr_line = add_spaces(wr_line, line)
            wr_line += "  registers.%s_wr_pulse <= '1';\n" % i
            reg_file_obj.write(wr_line)
          elif registers[i]["type"] == "RO":
            wr_line = ""
            wr_line = add_spaces(wr_line, line)
            wr_line += "when std_logic_vector(to_unsigned(%s_addr, C_REG_FILE_ADDR_WIDTH)) =>\n" % i
            wr_line = add_spaces(wr_line, line)
            wr_line += "  registers.%s_wr_pulse <= '1';\n" % i
            reg_file_obj.write(wr_line)
      elif type == "araddr case":
        for i in registers:
          wr_line = ""
          wr_line = add_spaces(wr_line, line)
          wr_line += "when std_logic_vector(to_unsigned(%s_addr, C_REG_FILE_ADDR_WIDTH)) =>\n" % i
          wr_line = add_spaces(wr_line, line)
          wr_line += "  s_axi_rdata <= registers.%s_REG;\n" % i
          reg_file_obj.write(wr_line)
      elif type == "reset regs":
        for i in registers:
          if registers[i]["type"] == "RW":
            wr_line = ""
            wr_line = add_spaces(wr_line, line)
            if int(constants["REG_FILE_DATA_WIDTH"]) == 32:
              wr_line += "registers.%s_REG <= x\"%08X\";\n" % (i, registers[i]["reset_val"])
            if int(constants["REG_FILE_DATA_WIDTH"]) == 24:
              wr_line += "registers.%s_REG <= x\"%06X\";\n" % (i, registers[i]["reset_val"])
            if int(constants["REG_FILE_DATA_WIDTH"]) == 16:
              wr_line += "registers.%s_REG <= x\"%04X\";\n" % (i, registers[i]["reset_val"])
            if int(constants["REG_FILE_DATA_WIDTH"]) == 8:
              wr_line += "registers.%s_REG <= x\"%02X\";\n" % (i, registers[i]["reset_val"])
            reg_file_obj.write(wr_line)
      elif type == "reset read only regs":
        for i in registers:
          if registers[i]["type"] == "RO":
            wr_line = ""
            wr_line = add_spaces(wr_line, line)
            if int(constants["REG_FILE_DATA_WIDTH"]) == 32:
              wr_line += "registers.%s_REG <= x\"%08X\";\n" % (i, registers[i]["reset_val"])
            if int(constants["REG_FILE_DATA_WIDTH"]) == 24:
              wr_line += "registers.%s_REG <= x\"%06X\";\n" % (i, registers[i]["reset_val"])
            if int(constants["REG_FILE_DATA_WIDTH"]) == 16:
              wr_line += "registers.%s_REG <= x\"%04X\";\n" % (i, registers[i]["reset_val"])
            if int(constants["REG_FILE_DATA_WIDTH"]) == 8:
              wr_line += "registers.%s_REG <= x\"%02X\";\n" % (i, registers[i]["reset_val"])
            reg_file_obj.write(wr_line)
      elif type == "read only regs":
        for i in registers:
          if registers[i]["type"] == "RO":
            for j in registers[i]["subreg"]:
              wr_line = ""
              wr_line = add_spaces(wr_line, line)
              wr_line += "if s_%s_%s_v = '1' then\n" % \
                (i, j)
              wr_line = add_spaces(wr_line, line)
              if registers[i]["subreg"][j]["length"] == 1:
                tmp = registers[i]["subreg"][j]["range"]
                tmp = tmp.split()[0]
                wr_line += "  registers.%s_REG(%s) <= s_%s_%s;\n" % \
                  (i, tmp, i, j)
              else:
                wr_line += "  registers.%s_REG(%s) <= s_%s_%s;\n" % \
                  (i, registers[i]["subreg"][j]["range"], i, j)
              wr_line = add_spaces(wr_line, line)
              wr_line += "end if;\n"
              reg_file_obj.write(wr_line)
      elif type == "read only regs port":
        for i in registers:
          if registers[i]["type"] == "RO":
            for j in registers[i]["subreg"]:
              wr_line = ""
              wr_line = add_spaces(wr_line, line)
              if registers[i]["subreg"][j]["length"] == 1:
                wr_line += "s_%s_%s : in std_logic;\n" % \
                  (i, j)
              else:
                wr_line += "s_%s_%s : in std_logic_vector(%s);\n" % \
                  (i, j, registers[i]["subreg"][j]["min_range"])
              wr_line = add_spaces(wr_line, line)
              wr_line += "s_%s_%s_v : in std_logic;\n\n" % \
                (i, j)
              reg_file_obj.write(wr_line)
      elif type == "awc regs port":
        for i in registers:
          if registers[i]["type"] == "AWC":
            for j in registers[i]["subreg"]:
              wr_line = ""
              wr_line = add_spaces(wr_line, line)
              if registers[i]["subreg"][j]["length"] == 1:
                wr_line += "s_%s_%s : in std_logic;\n" % \
                  (i, j)
              else:
                wr_line += "s_%s_%s : in std_logic_vector(%s);\n" % \
                  (i, j, registers[i]["subreg"][j]["min_range"])
              wr_line = add_spaces(wr_line, line)
              wr_line += "s_%s_%s_v : in std_logic;\n\n" % \
                (i, j)
              reg_file_obj.write(wr_line)
      elif type == "subreg type":
        for i in registers:
          if registers[i]["type"] == "RW" or registers[i]["type"] == "AWC":
            wr_line = ""
            wr_line = add_spaces(wr_line, line)
            wr_line += "type %s_subreg_t is record\n" % i
            for j in registers[i]["subreg"]:
              wr_line = add_spaces(wr_line, line)
              wr_line = add_spaces2(wr_line, 2)
              if registers[i]["subreg"][j]["length"] == 1:
                wr_line += "%s : std_logic;\n" % j
              else:
                wr_line += "%s : std_logic_vector(%s);\n" % (j, registers[i]["subreg"][j]["min_range"])
            wr_line += "  end record;\n\n"
            reg_file_obj.write(wr_line)
      elif type == "subreg declare":
        for i in registers:
          if registers[i]["type"] == "RW" or registers[i]["type"] == "AWC":
            wr_line = ""
            wr_line = add_spaces(wr_line, line)
            wr_line += "%s : %s_subreg_t;\n" % (i, i)
            reg_file_obj.write(wr_line)
      elif type == "subreg assign":
        for i in registers:
          if registers[i]["type"] == "RW" or registers[i]["type"] == "AWC":
            for j in registers[i]["subreg"]:
              wr_line = ""
              wr_line = add_spaces(wr_line, line)
              if registers[i]["subreg"][j]["length"] == 1:
                tmp = registers[i]["subreg"][j]["range"]
                tmp = tmp.split()[0]
                wr_line += "registers.%s.%s <= registers.%s_REG(%s);\n" % \
                  (i, j, i, tmp)
              else:
                wr_line += "registers.%s.%s <= registers.%s_REG(%s);\n" % \
                  (i, j, i, registers[i]["subreg"][j]["range"])

              reg_file_obj.write(wr_line)

def get_constants(data_file_name):
  constants = {}
  for line in open(data_file_name, "r"):
    if line.find("#") != -1:
      line = line[0:line.find("#")]
    line = strip_newline(line)
    line = strip_whitespace(line)

    if line != "":
      if line.find("(") != -1:
        line = line[line.find("(")+1:line.find(")")]
        args = line.split()
        name = args[0]
        if len(args) == 2:
          data = args[1]
        else:
          data = args[1:]
        constants[name] = data

  return constants

def get_registers(data_file_name):
  registers = {}
  subreg_process = False
  current_reg_name = ""
  for line in open(data_file_name, "r"):
    if line.find("#") != -1:
      line = line[0:line.find("#")]
    line = strip_newline(line)
    line = strip_whitespace(line)

    if line == "":
      pass
    elif line == "}":
      subreg_process = False
    elif subreg_process == True:
      subreg_args = line.split()
      subreg_name = subreg_args[0]
      range_tmp = strip_whitespace(subreg_args[1][1:-1])
      range_tmp = range_tmp.replace(":", " downto ")
      range_max = int(range_tmp.split()[0])
      range_min = int(range_tmp.split()[2])
      registers[current_reg_name]["subreg"][subreg_name] = {}
      registers[current_reg_name]["subreg"][subreg_name]["range"] = range_tmp
      registers[current_reg_name]["subreg"][subreg_name]["min_range"] = "%i downto %i" % (range_max-range_min, 0)
      registers[current_reg_name]["subreg"][subreg_name]["length"] = range_max-range_min+1


    elif line.find("{") != -1:
      subreg_process = True
      reg_args = line.split()
      name = reg_args[0]
      type = reg_args[1]
      address = reg_args[2]
      reset_val = reg_args[3]
      current_reg_name = name
      if address[0:2] == "0x":
        address = int(address[2:len(address)], 16)
      else:
        address = int(address)
      if reset_val[0:2] == "0x":
        reset_val = int(reset_val[2:len(reset_val)], 16)
      else:
        reset_val = int(reset_val)
      registers[name] = {}
      registers[name]["type"] = type
      registers[name]["address"] = address
      registers[name]["reset_val"] = reset_val
      registers[name]["subreg"] = {}


  return registers

def write_h_file(data_file_name, header_fname, registers):
  registers_name = header_fname

  f = open(registers_name+".h", "w")
  f.write("#ifndef "+registers_name+"_H\n")
  f.write("#define "+registers_name+"_H\n\n")

  for i in registers:
    f.write("#define %s 0x%X\n" % (i, registers[i]["address"]))
    print("%s 0x%X" % (i, registers[i]["address"]))

  f.write("\n")
  print("")

  for i in registers:
    reg_name = i
    for j in registers[i]["subreg"]:
      subreg_name = j
      dt_n = registers[i]["subreg"][j]["range"].find("downto")
      lshift = int(registers[i]["subreg"][j]["range"][dt_n+6:])
      mask_len = int(registers[i]["subreg"][j]["range"][0:dt_n]) - int(registers[i]["subreg"][j]["range"][dt_n+6:]) + 1
      mask = 0
      for k in range(mask_len):
        mask |= 1 << k
      f.write("#define %s_%s_MASK 0x%X\n" % (reg_name, subreg_name, mask))
      f.write("#define %s_%s_SHIFT %i\n" % (reg_name, subreg_name, lshift))
      print("%s_%s_MASK 0x%X" % (reg_name, subreg_name, mask))
      print("%s_%s_SHIFT %i" % (reg_name, subreg_name, lshift))
      if mask_len == 1:
        f.write("#define %s_%s (0x%X)\n" % (reg_name, subreg_name, 1<<lshift))
        print("%s_%s (0x%X)" % (reg_name, subreg_name, 1<<lshift))
    f.write("\n")
    print("")

  f.write("#endif\n")
  f.close()

def main():

  print("Starting Register File HDL Generator")
  template_file_name  = "axil_reg_file.template"
  data_file_name      = "registers.dat"

  constants = get_constants(data_file_name)
  registers = get_registers(data_file_name)

  if len(sys.argv) > 1:
    for arg in sys.argv:
      if arg == "clean" or arg == "-clean":
        print("removing generated files...")
        os.system("rm %s" % constants["reg_file_name"])
        os.system("rm %s.h" % constants["header_name"])
        return 0

  reg_file_name = constants["reg_file_name"]
  package_name  = constants["package_name"]

  print("")
  print(constants)
  print(registers)
  print("")
  print("")

  write_h_file(data_file_name, constants["header_name"], registers)

  template_file_obj = open(template_file_name, "r")
  reg_file_obj = open(reg_file_name, "w")
  write_all(template_file_obj, reg_file_obj, constants,  registers, package_name)

  template_file_obj.close()
  reg_file_obj.close()
  return 0

if __name__ == "__main__":
  ret = main()
  if ret == 0:
    print("register file successfully generated")
  else:
    print("register file not generated successfully")
    print("return code: "+str(ret))
