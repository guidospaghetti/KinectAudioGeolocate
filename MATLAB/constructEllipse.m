function x = constructEllipse(P, center, conf)
center = center(:);

[V, D] = eig(P);
k = chi2inv(conf, 2);

theta = 0:0.01:2*pi;

a = [cos(theta); sin(theta)];
x = center + V*sqrt(k*D)*a;

end