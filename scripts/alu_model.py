def alu_64bit(a: int, b: int, alu_op: int) -> tuple[int, bool, bool, bool]:
    """
    Python Golden Model for the 64-bit Structural ALU.
    Returns: (result, zero_flag, carry_out_flag, overflow_flag)
    """
    # Force inputs to be 64-bit unsigned integers
    a &= 0xFFFFFFFFFFFFFFFF
    b &= 0xFFFFFFFFFFFFFFFF
    
    result = 0
    zero = False
    carry_out = False
    overflow = False
    
    # --- Structural Arithmetic Datapath ---
    is_sub = (alu_op == 0b0110) or (alu_op == 0b0111)
    
    # 2's complement logic for subtraction
    b_modified = (b ^ 0xFFFFFFFFFFFFFFFF) if is_sub else b
    sub_enable = 1 if is_sub else 0
    
    # 65-bit sum including carry-in
    sum_res = a + b_modified + sub_enable
    
    add_sub_res = sum_res & 0xFFFFFFFFFFFFFFFF
    add_sub_cout = bool((sum_res >> 64) & 1)
    
    # Overflow: if A and B_modified have same sign, and Result has different sign
    a_sign = (a >> 63) & 1
    b_mod_sign = (b_modified >> 63) & 1
    res_sign = (add_sub_res >> 63) & 1
    add_sub_ovf = (a_sign == b_mod_sign) and (res_sign != a_sign)
    # --------------------------------------
    
    if alu_op == 0b0000:   # AND
        result = a & b
    elif alu_op == 0b0001: # OR
        result = a | b
    elif alu_op == 0b0010: # ADD
        result = add_sub_res
        carry_out = add_sub_cout
        overflow = add_sub_ovf
    elif alu_op == 0b0110: # SUB
        result = add_sub_res
        carry_out = add_sub_cout
        overflow = add_sub_ovf
    elif alu_op == 0b0111: # SLT (Set on Less Than)
        # Natively computed using (Sign_Result XOR Overflow)
        result = 1 if (res_sign ^ int(add_sub_ovf)) else 0
    elif alu_op == 0b1100: # NOR
        result = ~(a | b) & 0xFFFFFFFFFFFFFFFF
    elif alu_op == 0b1101: # XOR
        result = a ^ b
    elif alu_op == 0b1110: # SLL
        shift_amt = b & 0x3F # Lower 6 bits
        result = (a << shift_amt) & 0xFFFFFFFFFFFFFFFF
    elif alu_op == 0b1111: # SRL
        shift_amt = b & 0x3F
        result = a >> shift_amt
    
    zero = (result == 0)
    
    return result, zero, carry_out, overflow

# Quick test mimicking the Verilog testbench
if __name__ == "__main__":
    print("Python 64-bit ALU Golden Model")
    print("==============================")
    
    # 1. ADD: 5 + 10
    res, z, c, ov = alu_64bit(0x5, 0xA, 0b0010)
    print(f"ADD : res=0x{res:016x} | z={int(z)} c={int(c)} ov={int(ov)}")
    
    # 2. SUB: 15 - 5
    res, z, c, ov = alu_64bit(0xF, 0x5, 0b0110)
    print(f"SUB : res=0x{res:016x} | z={int(z)} c={int(c)} ov={int(ov)}")
    
    # 3. SLT: -1 < 0
    res, z, c, ov = alu_64bit(0xFFFFFFFFFFFFFFFF, 0x0, 0b0111)
    print(f"SLT : res=0x{res:016x} | z={int(z)} c={int(c)} ov={int(ov)}")
    
    # 4. Overflow ADD: 7FFF...FFFF + 1
    res, z, c, ov = alu_64bit(0x7FFFFFFFFFFFFFFF, 0x1, 0b0010)
    print(f"OVF : res=0x{res:016x} | z={int(z)} c={int(c)} ov={int(ov)}")
