function deviation = computeDeviation(car_X, car_Y, path)
    % Preallocate
    deviation = zeros(length(car_X),1);

    % Centerline points
    cx = path.xpath;
    cy = path.ypath;

    for i = 1:length(car_X)
        % Compute distances to all centerline points
        dists = hypot(car_X(i) - cx, car_Y(i) - cy);

        % Find closest centerline point
        [minDist, idx] = min(dists);

        % Signed deviation: use cross product with tangent
        if idx < length(cx)
            tangent = [cx(idx+1)-cx(idx), cy(idx+1)-cy(idx)];
        else
            tangent = [cx(idx)-cx(idx-1), cy(idx)-cy(idx-1)];
        end
        posVec = [car_X(i)-cx(idx), car_Y(i)-cy(idx)];
        crossVal = tangent(1)*posVec(2) - tangent(2)*posVec(1);

        deviation(i) = sign(crossVal) * minDist;
    end
end

