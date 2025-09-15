function wnext = euler_step(fun, t, w, dt)
% Explicit Euler for 1st-order ODE
    wnext = w + dt * fun(t, w);
end
