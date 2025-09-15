function tauJ = fInertia(J, alpha)
% Inertial torque = J * angular acceleration
    tauJ = J .* alpha;
end
