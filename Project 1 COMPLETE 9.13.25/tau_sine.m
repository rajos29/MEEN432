function tau = tau_sine(t, amp, Om)
% Sinusoidal applied torque = amp * sin(Om*t)
    tau = amp * sin(Om * t);
end
