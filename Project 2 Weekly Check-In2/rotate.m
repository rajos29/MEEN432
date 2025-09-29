function v_rot = rotate(v, psi)

    if ~isnumeric(v) || size(v,1) ~= 2
        error('Input must be a 2×N matrix where each column is a 2D point');
    end

    R = [cos(psi), -sin(psi); sin(psi), cos(psi)];
    v_rot = R * v;
end