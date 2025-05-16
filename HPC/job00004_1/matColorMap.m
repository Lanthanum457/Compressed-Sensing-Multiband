function cmap = matColorMap(colorMat, n)
if nargin < 2
    n = 256;
end

cmap = [];
for k = 1:(size(colorMat,1)-1)
    color1 = colorMat(k,:);
    color2 = colorMat(k+1,:);
    nper = round(n/(size(colorMat,1)-1));
    r = linspace(color1(1), color2(1), nper)';
    g = linspace(color1(2), color2(2), nper)';
    b = linspace(color1(3), color2(3), nper)';
    cmap = [cmap;r g b];
end
end
