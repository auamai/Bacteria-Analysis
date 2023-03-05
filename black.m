clear; close all

% Read the video file
vid = VideoReader('bacteria.mp4');

% Define the threshold value for black bacteria
black_thresh = 0.0001; % Try lowering this value

% Define the minimum and maximum blob sizes (in pixels) for filtering
min_blob_size = 50; % Try increasing this value
max_blob_size = 100; % Try decreasing this value

% Define the maximum distance between matching blobs (in pixels)
max_match_dist = 10;

% Create empty array to store the positions of the black bacteria
black_positions = cell(1, vid.NumFrames);

% Create the figure windows
fig1 = figure(1);
fig2 = figure(2);

% Loop through each frame of the video
for i = 1:vid.NumFrames
    %Initialize black_positions{i} with an empty matrix
    black_positions{i} = [];

    % Read the current frame
    frame = readFrame(vid);
    
    % Convert the frame to grayscale
    gray_frame = rgb2gray(frame);
    
    % Threshold the grayscale frame to get a binary image of the bacteria
    black_bacteria = gray_frame < black_thresh;
    
    % Show the binary image in figure 1
    set(0, 'CurrentFigure', fig1);
    imshow(black_bacteria);
    title('Binary Image of Black Bacteria');
    
    % Perform blob analysis on the binary image to get the properties of the bacteria
    black_props = regionprops('table', black_bacteria, 'Centroid', 'Area');
    
    % Filter out blobs that do not meet the size criteria
    black_props = black_props(black_props.Area >= min_blob_size & black_props.Area <= max_blob_size, :);
    
    % Match the black blobs with the corresponding blobs in the previous frame
    if i == 1
        % For the first frame, just use the detected blobs as the initial positions
        black_positions{i} = black_props.Centroid;
    else
        % For subsequent frames, match the current blobs with the previous blobs
        black_prev = black_positions{i-1};
        black_matched = zeros(size(black_props,1),1);
        for j = 1:size(black_props,1)
            % Find the closest previous black blob to the current black blob
            dist = sqrt(sum((black_prev - black_props(j).Centroid).^2,2));
            [min_dist, idx] = min(dist);
            if min_dist <= max_match_dist && black_matched(idx) == 0
                % If the distance is less than the threshold and the
                % previous blob has not been matched, then match the
                % current and previous blobs
                black_positions{i}(j,:) = black_props(j).Centroid;
                black_matched(idx) = 1;
            else

                % Otherwise, create a new black blob
                black_positions{i}(j,:) = black_props(j).Centroid;
            end
        end
        % Any remaining unmatched previous black blobs become lost
        black_positions{i}(black_matched==0,:) = [];
    end
    
    % Plot the positions of the black bacteria
    figure(2);
    imshow(frame);
    hold on;
    for j = 1:size(black_positions{i},1)
        plot(black_positions{i}(j,1), black_positions{i}(j,2), 'r+', 'MarkerSize', 10);
    end
end
