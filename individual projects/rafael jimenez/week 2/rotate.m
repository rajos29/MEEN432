function v_rot = rotate(v, theta)

    if ~isnumeric(v) || size(v,1) ~= 2
        error('Input must be a 2×N matrix where each column is a 2D point');
    end

    R = [cos(theta), -sin(theta); sin(theta), cos(theta)];
    v_rot = R * v;
end