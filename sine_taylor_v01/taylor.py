
import numpy as np

G_DWIDTH = 16
G_TAPWIDTH = 16

din = np.arange(-2**(G_DWIDTH-1), 2**(G_DWIDTH-1), 1, dtype=float)
din = np.array(din * np.pi / 2.0, dtype=int)

dout = np.array([0 for i in range(len(din))], dtype=int)

talor_parmas_double = [
  1.570796326794897,
  -0.2617993877991494,
  0.01308996938995747,
  -0.0003116659378561302,
  4.328693581335143e-06
]

talor_parmas_double = np.array(talor_parmas_double) / (np.pi/2)

taylor_param = [0 for i in range(len(talor_parmas_double))]

for i in range(len(taylor_param)):
  taylor_param[i] = int((2**(G_TAPWIDTH-1) * talor_parmas_double[i]))

for i in range(len(din)):
  estimate_value_long = 0
  for j in range(len(talor_parmas_double)):
    exponent = din[i]
    for k in range(j*2):
      exponent = int((exponent*float(din[i])/(2**(G_DWIDTH-1))))

    estimate_value_n = exponent * taylor_param[j]
    estimate_value_long = estimate_value_long + estimate_value_n

  estimate_value_long = estimate_value_long >> (G_TAPWIDTH)
  dout[i] = estimate_value_long


f = open("taylor_dout.txt", "w")
for i in range(len(dout)):
  f.write("%i\n" % dout[i])
f.close()
































