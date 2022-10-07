%% SDR Frequency Modulation Lab

% Load in the data collected
load SDR_FM_Lab.mat

% Create x-axis for time and for frequency
t = linspace(0, length(y_I)/fs, length(y_I));
f = linspace(-fs/2, fs/2, length(y_I));

%% Exercise 1: Part C

% Take the FFT of y_I
Y_I = fftshift(fft(y_I));

% Plot Y_I
figure(1); hold on; clf;
plot(f, abs(Y_I))
xlabel("Frequency (Hz)")
ylabel("Amplitude")

%% Exercise 1: Part D

% Plot y_I zoomed in to see an area of frequency modulation
figure(2); clf;
plot(t, y_I)
% xlim([5.2043, 5.2063])
xlim([5.2047, 5.2063])
xlabel("Time (seconds)")
ylabel("Amplitude")

%% Exercise 1: Part E

% Take the derivative of y_I
y_I_deriv = diff(y_I);

% Zero out the negative components of y_I_deriv
y_I_deriv_nonneg = max(y_I_deriv, 0);

% Normalize the signal so that its maximum value is 1
y_I_deriv_nonneg_norm = y_I_deriv_nonneg/max(y_I_deriv_nonneg);

% Plot the signal
figure(5); clf; hold on;
plot(t(2:length(t)), y_I_deriv_nonneg_norm)
xlabel("Time (seconds)")
ylabel("Amplitude")
xlim([0,t(length(t))])

%% Exercise 1: Part F

% Lowpass filter the signal
y_I_lowpass = lowpass(y_I_deriv_nonneg_norm, 10e3, fs);

% Normalize the resulting signal
y_I_lowpass_norm = y_I_lowpass/max(y_I_lowpass);

% Plot on the same axes as part (e)
figure(); clf; hold on;
plot(t(2:length(t)), y_I_lowpass_norm)
plot(t(2:length(t)), y_I_deriv_nonneg_norm)
xlabel("Time (seconds)")
ylabel("Amplitude")
% xlim([0,t(length(t))])

% Zoom in to a portion of the signal which illustrates how the diode followed 
% by low pass filter tracks the envelope of the derivative FM signal
xlim([6.1615,6.1645])

%% Exercise 1: Part G

% Subtract the mean out of the signal
y_I_meanless = y_I_lowpass_norm - mean(y_I_lowpass_norm);

% Normalize the new signal
y_I_meanless_norm = y_I_meanless / max(y_I_meanless) / 10;

% Plot the resulting signal
figure(); clf; hold on;
plot(t(2:length(t)), y_I_meanless_norm)
xlabel("Time (seconds)")
ylabel("Amplitude")
xlim([0,t(length(t))])

% Decimate the new normalized signal
y_I_meanless_norm_decimated = decimate(y_I_meanless_norm, 4);

% Play the final signal
decimate_factor = 4;
decimated_fs = fs/decimate_factor;
sound(y_I_meanless_norm_decimated, decimated_fs);

% Save the envelope detector demodulated signal 
audiowrite('Envelope_Detector_Demodulated_Signal.wav',y_I_meanless_norm_decimated,decimated_fs)

%% Exercise 2: Part B

% Take the derivative of y_Q
y_Q_deriv = diff(y_Q);

% Calculate m_hat, which is correlated to the original message signal
m_hat = (y_Q_deriv .* y_I(1:length(y_Q_deriv))) - (y_I_deriv .* y_Q(1:length(y_I_deriv)));

% Normalize, subtract out the mean, and normalize again
m_hat_norm = max(m_hat, 0) ./ max(m_hat);
m_hat_norm_safe = m_hat_norm - mean(m_hat_norm);
m_hat_norm_safe_norm = m_hat_norm_safe ./ (max(m_hat_norm_safe) / .1);

% Plot the signal
figure(); clf; hold on;
plot(t(2:length(t)), m_hat_norm_safe_norm);
xlabel("Time (seconds)")
ylabel("Amplitude")
xlim([0,t(length(t))])

% Decimate the signal
m_hat_decimated = decimate(m_hat_norm_safe_norm, decimate_factor);

% Play the final signal
sound(m_hat_decimated, decimated_fs)

% Save the final I and Q demodulated signal 
audiowrite('Final_IQ_Demodulated_Signal.wav',m_hat_decimated,decimated_fs)