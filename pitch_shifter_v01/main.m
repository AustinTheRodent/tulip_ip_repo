clear all;
close all;

pkg load signal;

fid = fopen("capture.bin");
data = fread(fid, "int32");
fclose(fid);

data = data(1:2:end);
data = data(500e3:2000e3);
data = 0.5 * data/max(data);

%data = 0.5*sin(2*pi*(0:2^16-1)'/240);

average_delay = 1000; % samples
lfo_depth = 500; % samples
lfo_freq = 1/(48000*8); % normalized frequency

lfo = lfo_depth*sin(2*pi*lfo_freq*(0:length(data)-1)');

buffer = zeros(average_delay+lfo_depth+2, 1);
output = zeros(length(data),1);

wr_index = 0;

for i=1:length(data)
  if mod(i,10000) == 0
    i
  end
  %buffer = circshift(buffer, 1);
  %buffer(1) = data(i);
  buffer(wr_index+1) = data(i);

  lfo_index = floor(lfo(i));
  rd_index0 = mod(wr_index+average_delay+lfo_index, length(buffer));
  rd_index1 = mod(wr_index+average_delay+lfo_index+1, length(buffer));
  
  fract = lfo(i) - lfo_index;

  output(i) = buffer(rd_index0+1)*(1-fract) + buffer(rd_index1+1)*fract;
  wr_index = mod(wr_index + 1, length(buffer));
end

%output = resample(output, 1, 10);

player = audioplayer((data+output)/2, 48000);
play(player);



figure();
hold on;
plot(20*log10(abs(fftshift(fft(output)))))
plot(20*log10(abs(fftshift(fft(data)))))


return;

chorus = data .* exp(-1i*pi.*(0:length(data)-1)'/2);

h = remez(510, [0 0.493 0.501 1], [1 1 0 0]);

chorus_filt = filter(h, 1, chorus);
chorus_filt = chorus_filt .* exp(1i*pi.*(0:length(data)-1)'/2);

modulation1 = -(10/2^24) + (1/2^16)*sin(2*pi/48000 * (0:length(data)-1)');
modulation2 = (5/2^24) + (2.222/2^20)*sin(2*pi/24000 * (0:length(data)-1)');

mod_sin1 = zeros(length(modulation1), 1);
mod_sin2 = zeros(length(modulation2), 1);
alpha1 = 0;
alpha2 = 0;
for i=1:length(mod_sin1)
  mod_sin1(i) = exp(2i*pi * alpha1);
  mod_sin2(i) = exp(2i*pi * alpha2);
  alpha1 = alpha1 + modulation1(i);
  alpha2 = alpha2 + modulation2(i);
end

chorus_filt1 = chorus_filt .* mod_sin1;
chorus_filt2 = chorus_filt .* mod_sin2;

chorus_filt1 = real(chorus_filt1);
chorus_filt2 = real(chorus_filt2);

combined = data + chorus_filt1 + chorus_filt2;

w = (-0.5:1/length(data):0.5-1/length(data))*48000;

figure(); hold on;
plot(w, 20*log10(abs(fftshift(fft(data)))));
plot(w, 20*log10(abs(fftshift(fft(combined)))));

player = audioplayer(combined, 48000);
play (player);

return;


fid = fopen("hw_output.bin", "r");
%fid = fopen("sw_model.bin", "r");
data = fread(fid, "int32");
fclose(fid);
data = 0.5 * data/max(data);
player = audioplayer(data/4, 48000);
play (player);

plot(20*log10(abs(fftshift(fft(data.*hanning(length(data)))))))


