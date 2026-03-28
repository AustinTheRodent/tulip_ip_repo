import numpy as np

def manual_float_add_v4(a, b, debug=False):
    a_bits = np.float32(a).view(np.uint32)
    b_bits = np.float32(b).view(np.uint32)

    # 1. Edge Case: Zero
    if a == 0: return np.float32(b)
    if b == 0: return np.float32(a)

    def extract(bits):
        s = (bits >> 31) & 1
        e = (bits >> 23) & 0xFF
        m = (bits & 0x7FFFFF) | 0x800000
        return s, e, m

    s1, e1, m1 = extract(a_bits)
    s2, e2, m2 = extract(b_bits)

    # 2. Magnitude Sort (Ensure |op1| >= |op2|)
    if e1 < e2 or (e1 == e2 and m1 < m2):
        s1, s2, e1, e2, m1, m2 = s2, s1, e2, e1, m2, m1

    # 3. Alignment with 3 extra bits (G, R, S)
    shift = e1 - e2
    g, r, s = 0, 0, 0
    if shift > 0:
        if shift <= 24:
            g = (m2 >> (shift - 1)) & 1
            r = (m2 >> (shift - 2)) & 1 if shift >= 2 else 0
            s = 1 if (m2 & ((1 << (max(0, shift - 2))) - 1)) != 0 else 0
            m2 >>= shift
        else:
            m2, g, r, s = 0, 0, 0, 1

    # 4. The Math
    if s1 == s2:
        res_m = m1 + m2
        res_s = s1
    else:
        # SUBTRACTION LOGIC: Handle the fraction (G, R, S)
        # If G, R, or S are non-zero, we "borrow" 1 from the integer mantissa
        if g | r | s:
            res_m = m1 - m2 - 1
            # Compute the 'fractional' remainder for rounding
            # 2's complement style: (1.000 - 0.GRS)
            frac = (1 << 3) - ((g << 2) | (r << 1) | s)
            g = (frac >> 2) & 1
            r = (frac >> 1) & 1
            s = frac & 1
        else:
            res_m = m1 - m2
            res_s = s1
            g, r, s = 0, 0, 0
        res_s = s1

    if res_m == 0 and g == 0: return np.float32(0.0)

    # 5. Normalization
    res_e = e1
    if res_m & 0x1000000: # Overflow
        s = s | r
        r = g
        g = res_m & 1
        res_m >>= 1
        res_e += 1
    #elif res_m != 0 or g != 0: # Underflow
    else:
        while not (res_m & 0x800000) and res_e > 0:
            res_m = (res_m << 1) | g
            g, r = r, 0 # Shift bits back in
            res_e -= 1

    # 6. Round to Nearest Even
    lsb = res_m & 1
    if g == 1 and ((r | s) == 1 or lsb == 1):
        res_m += 1
        if res_m & 0x1000000:
            res_m >>= 1
            res_e += 1

    res_bits = (res_s << 31) | (res_e << 23) | (res_m & 0x7FFFFF)
    return np.uint32(res_bits).view(np.float32)
# Test mixed signs

N = 100000
np.random.seed(3)
#a_bits = np.float32(a).view(np.uint32)

#a0 = np.float32(np.random.randint(-10000000, 10000000, N))/10000
#a1 = np.float32(np.random.randint(-10000000, 10000000, N))/10000


#a0 = np.uint32(np.random.randint(0, 2**32-1, N, dtype=np.uint32))
#a1 = np.uint32(np.random.randint(0, 2**32-1, N, dtype=np.uint32))

s0 = np.uint32(np.random.randint(0, 2, N, dtype=np.uint32))
sign1 = np.uint32(np.random.randint(0, 2, N, dtype=np.uint32))

e0 = np.uint32(np.random.randint(0, 256, N, dtype=np.uint32))
exp1 = np.uint32(np.random.randint(0, 256, N, dtype=np.uint32))

m0 = np.uint32(np.random.randint(0, 2**23, N, dtype=np.uint32))
mant1 = np.uint32(np.random.randint(0, 2**23, N, dtype=np.uint32))

a0 = (s0 << 31) | (e0 << 23) | m0
a1 = (sign1 << 31) | (exp1 << 23) | mant1

a0 = a0.view(np.float32)
a1 = a1.view(np.float32)


man_out = np.zeros(N, dtype=np.float32)
for i in range(N):
  man_out[i] = manual_float_add_v4(a0[i], a1[i])

numpy_out = a0 + a1

print("Check Output:")
print()

for i in range(N):
  if man_out[i].view(np.uint32) != numpy_out[i].view(np.uint32):
    #if np.isnan(man_out[i]) == 0 and np.isnan(numpy_out[i]) == 0:
    if np.isnan(numpy_out[i]) == 0:
      #if np.isnan(a0[i]) == 0 and np.isnan(a1[i]) == 0:

        manual_float_add_v4(a0[i], a1[i], debug=True)
        print()

        print("a0 : 0x%08X" % a0[i].view(np.uint32))
        print("a1 : 0x%08X" % a1[i].view(np.uint32))
        #print("a0 : %f" % a0[i])
        #print("a1 : %f" % a1[i])
        print(a0[i])
        print(a1[i])

        print()

        print("man_out   : 0x%08X" % man_out[i].view(np.uint32))
        print("numpy_out : 0x%08X" % numpy_out[i].view(np.uint32))
        #print("man_out   : %f" % man_out[i])
        #print("numpy_out : %f" % numpy_out[i])
        print(man_out[i])
        print(numpy_out[i])

        print(i)
        print("########################################################")



#print("Manual: %0.16f" % manual_float_add_v3(10.5, -2.25))
#print("NumPy: %0.16f" % (np.float32(10.5) + np.float32(-2.25)))



