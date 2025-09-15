function [t_out, w_out] = ode_45(w0, tspan, J, b, tau_func)
    dyn = @(t, w) (1/J) * (tau_func(t) - b * w);

    [t_out, w_out] = ode45(dyn, tspan, w0);
end