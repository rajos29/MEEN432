function deviation = computeDeviation(car_X, car_Y, path)

    % Pre-allocate output array
    deviation = zeros(length(car_X),1);

    % Extract centerline coordinates for convenience
    cx = path.xpath;
    cy = path.ypath;

    % Loop through every recorded vehicle position
    for i = 1:length(car_X)

        % Determine distance from the vehicle to all centerline samples
        dists = sqrt((car_X(i) - cx).^2 + (car_Y(i) - cy).^2);

        % Identify the nearest centerline point
        [minDist, idx] = min(dists);

        % Compute local tangent direction of the track
        if idx < length(cx)
            tangent = [cx(idx+1) - cx(idx), cy(idx+1) - cy(idx)];
        else
            tangent = [cx(idx) - cx(idx-1), cy(idx) - cy(idx-1)];
        end

        % Vector from centerline point to actual vehicle location
        posVec = [car_X(i) - cx(idx), car_Y(i) - cy(idx)];

        % Cross product (2D equivalent) gives sign of lateral offset
        crossVal = tangent(1)*posVec(2) - tangent(2)*posVec(1);

        % Signed deviation
        deviation(i) = sign(crossVal) * minDist;
    end
end
