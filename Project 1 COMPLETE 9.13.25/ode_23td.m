function [t_out, w_out] = ode_23td(w0, tspan, J, b, tau_func)
    dyn = @(t, w) (1/J) * (tau_func(t) - b * w);

    [t_out, w_out] = ode23tb(dyn, tspan, w0);
end