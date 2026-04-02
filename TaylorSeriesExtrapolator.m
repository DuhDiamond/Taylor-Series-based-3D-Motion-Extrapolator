% This represents a set of vertices that form a bounding box cube
vertices = double([
    -1 -1 -1 1;
    1 -1 -1 1;
    -1 1 -1 1;
    -1 -1 1 1;
    -1 1 1 1;
    1 1 -1 1;
    1 -1 1 1;
    1 1 1 1;
]');


% These matrices parametrize an object's global position and rotation data
% as a modelMatrix. I'm using them in substitute of tracking data to
% average the displacementMatrix from. Try changing it!
syms t
rotationX = [
    1 0 0 0;
    0 cos(t) -sin(t) 0;
    0 sin(t) cos(t) 0;
    0 0 0 1;
];
rotationY = [
    cos(t) 0 sin(t) 0;
    0 1 0 0;
    -sin(t) 0 cos(t) 0;
    0 0 0 1;
];
rotationZ = [
    cos(t) -sin(t) 0 0;
    sin(t) cos(t) 0 0;
    0 0 1 0;
    0 0 0 1;
];

position = [
    1 0 0 t/2;
    0 1 0 4*cos(t);
    0 0 1 4*sin(t);
    0 0 0 1;
];

modelMatrix = position * rotationX*rotationY*rotationZ;

% In an actual environment where there's data to extrapolate, this
% would be calculated from rolling averages of recent changes in
% a given object's data (rotation, translation, and optionally scale)
% rather than directly deriving a parametrized position
displacementMatrix = diff(modelMatrix, t);

% This represents the amount of terms in the taylor series to extrapolate from
terms = 5;

% In an applied case, these would be all
% computed from rolling averages of recent data
taylorSeries = cell(terms, 1);
termMatrix = displacementMatrix;
for i = 1:terms
    taylorSeries{i} = matlabFunction(termMatrix, "Vars", t);
    termMatrix = diff(termMatrix, t);
end

% This function plots iterative ghost cubes representing each accumulated taylor series term
function plotPrediction(currVertices, currPosition, t_val, taylorSeries, dt, v, fig)
    terms = length(taylorSeries);

        currTaylorSeries = currPosition;
        for term = 1:terms
            currTaylorSeries = currTaylorSeries + taylorSeries{term}(t_val) * (dt^(term)) / factorial(term);

            drawnTaylorSeries = currTaylorSeries;
            % I use SVD decomposition to extract translation and rotation
            % data, as using the direct approximations would cause the
            % errors on edges of the cube to accumulate inconsistently
            % (This causes the cube to deform, so SVD orthogonalizes it)
            [U, ~, V] = svd(drawnTaylorSeries(1:3,1:3));
            drawnTaylorSeries(1:3,1:3) = U * V';
            
            predictedVertices = drawnTaylorSeries * currVertices;

            motionColour = ((term)/terms) * [1.0, 0.5, 0];
            
            plotCube(predictedVertices, motionColour, "--", v, fig);
        end
end

% This plots the actual position of the cube for each time step
function plotCube(vertices, colour, lineType, v, fig)
    edges = [1 2; 1 3; 1 4; 2 6; 2 7; 3 5; 3 6; 4 5; 4 7; 5 8; 6 8; 7 8];
        
    for e = edges'
        p1 = vertices(1:3, e(1));
        p2 = vertices(1:3, e(2));
        plot3([p1(1) p2(1)], [p1(2) p2(2)], [p1(3) p2(3)], lineType, "Color", colour);
    end

    % Writing multiple frames and rotating the camera a little bit every
    % time a cube is drawn, to slow down and smoothen out the video footage more
    recordFrame(v, fig);
    recordFrame(v, fig);
    recordFrame(v, fig);
    recordFrame(v, fig);
end

function plotCurrentPath(iter, pastOrigin)
    
    for i = 2:iter
        arrowColour = [0.5, 0.25, 0] * (i/iter) + [0.5, 0.25, 0];
        
        position = pastOrigin(:, i);
        prevPosition = pastOrigin(:, i - 1);
        direction = position - prevPosition;
        quiver3(prevPosition(1), prevPosition(2), prevPosition(3), ...
            direction(1), direction(2), direction(3), 0, "Color", arrowColour, "LineWidth", 2, "maxHeadSize", 1);
    end
end

function recordFrame(v, fig)
    camorbit(0.5, 0);
    frame = getframe(fig);
    writeVideo(v, frame);
end


% Figure/camera/parameters setup
clf;
view(3);
camproj("perspective");
camva(8);
axis equal;
axis manual;
grid on;

xlim([-8, 8]);
ylim([-8, 8]);
zlim([-8, 8]);
xlabel("X");
ylabel("Y");
zlabel("Z");

% Range of time to predict over
time = double(10);
% The time value to start at
t_val = double(0);
% The amount of time steps to plot out (higher value means less
% extrapolation)
timesteps = double(5);
% The time delta each iteration extrapolates over
% (could represent average latency)
dt = time / timesteps;

position = double(zeros(4));

currCubeColour = [0.2, 0.2, 0.2];
nextCubeColour = [0.2, 0.5, 0.2];
pastOrigin = zeros(4, timesteps);

fig = gcf;
v = VideoWriter("time10_timesteps_5", "MPEG-4");
open(v);

% Plots the full iteration; current cube, followed by predicted positions,
% followed by the actual next position of the cube, and then updates values
% for the next iteration
for iter = 1:timesteps
    hold on;

    position = double(subs(modelMatrix, t, t_val));

    pastOrigin(:, iter) = sum((position * vertices), 2) ./ 8;
    plotCurrentPath(iter, pastOrigin);
    
    plotCube(position * vertices, currCubeColour, "-", v, fig);
    plotPrediction(vertices, position, t_val, taylorSeries, dt, v, fig);
           
    nextPosition = double(subs(modelMatrix, t, t_val + dt));
    plotCube(nextPosition * vertices, nextCubeColour, "-", v, fig);
    
    % Drawing some more frames on the next cube's true position to
    % linger more on this part of the footage
    recordFrame(v, fig);
    recordFrame(v, fig);

    hold off;
    cla;

    t_val = t_val + dt;    
end

close(v);