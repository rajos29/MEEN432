function check_speed_error(actual_speed, target_speed)
    error = abs(actual_speed - target_speed);
    max_error = max(error);

    if max_error > 3
        warning('Speed error exceeds 3 mph! Max error: %.2f mph', max_error);
    else
        disp('Speed tracking within 3 mph throughout the cycle.');
    end
end
