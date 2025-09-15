function wnext = rk4_step(fun, t, w, dt)
% Classical RK4 for 1st-order ODE
    k1 = fun(t, w);
    k2 = fun(t + 0.5*dt, w + 0.5*dt*k1);
    k3 = fun(t + 0.5*dt, w + 0.5*dt*k2);
    k4 = fun(t + dt,     w + dt*k3);
    wnext = w + (dt/6) * (k1 + 2*k2 + 2*k3 + k4);
end
