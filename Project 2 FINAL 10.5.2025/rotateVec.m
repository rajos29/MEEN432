function out = rotateVec(v, theta)
% rotateVec rotates a 2D vector (or column vectors) by an angle theta [rad]
%
%   v      : 2xN vector(s) [ [x; y] or [x1 x2 ...; y1 y2 ...] ]
%   theta  : scalar rotation angle in radians
%   out    : rotated 2xN vector(s)

R = [cos(theta) -sin(theta);
     sin(theta)  cos(theta)];

out = R * v;
end
