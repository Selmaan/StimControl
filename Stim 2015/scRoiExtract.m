function borderXY = scRoiExtract(img,nPoints,desiredPoint)

centroid = round(size(img)/2);

% Extract pixels in polar coordinates from clicked point:
nRays = 300;

% nPoints determines the radius of the captured circle. This should contain
% the entire cell:
theta = linspace(0, 2*pi, nRays);
rho = nPoints:-1:1;
[thetaGrid, rhoGrid] = meshgrid(theta, rho);
[polX, polY] = pol2cart(thetaGrid, rhoGrid);

% Filter Image and get values
imgFilt = imfilter(img,fspecial('gaussian',5,2/3),'Replicate');
ray = interp2(imgFilt,polY+centroid(1),polX+centroid(2));

% Find "inside" of the cell, defined as the area contained within the
% maximum intensity pixel along each ray:
[rayMaxV, rayMaxI] = max(ray);

% Fit a sinusoidal boundary to delineate the "inside" of the cell:
x0 = [mad(rayMaxI)*2, 0, median(rayMaxI)];
xEst = x0;

for i=1:3
    objFunPhase = @(x) ringObjectiveFunction([xEst(1),x,xEst(3)], ray, nRays, nPoints);
    xEst(2)=fminbnd(objFunPhase,0,2*pi);
    objFunAmp = @(x) ringObjectiveFunction([x,xEst(2),xEst(3)], ray, nRays, nPoints);
    xEst(1)=fminbnd(objFunAmp,0,nPoints);
    objFunOffset = @(x) ringObjectiveFunction([xEst(1),xEst(2),x], ray, nRays, nPoints);
    xEst(3)=fminbnd(objFunOffset,0,nPoints);
end
boundInd = xEst(3) + xEst(1)*cos(xEst(2)+linspace(0, 2*pi, nRays));
%figure,imagesc(ray),
%hold on, plot(boundInd,'r'),

outerBound = nPoints+1;
[xCo,yCo] = pol2cart(theta,outerBound-boundInd+1);
borderXY(1,:) = xCo + desiredPoint(1);
borderXY(2,:) = yCo + desiredPoint(2);
%figure,imagesc(img),
%hold on, plot(yCo+centroid(1),xCo+centroid(2),'r')