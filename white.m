clear; close all;

% Read the video file
vid = VideoReader('bacteria.mp4');

% Define the threshold value for white bacteria
white_thresh = 0.95; % Try increasing this value

% Define the minimum and maximum blob sizes (in pixels) for filtering
min_blob_size = 50; % Try increasing this value
max_blob_size = 250; % Try decreasing this value

% Define the maximum distance between matching blobs (in pixels)
max_match_dist = 10;

% Create empty array to store the positions of the white bacteria
white_positions = cell(1, vid.NumFrames);

% Loop through each frame of the video
for i = 1:vid.NumFrames
    % Initialize white_positions{i} with an empty matrix
    white_positions{i} = [];

    % Read the current frame
    frame = readFrame(vid);
    
    % Convert the frame to grayscale
    gray_frame = rgb2gray(frame);
    
    % Threshold the grayscale frame to get a binary image of the bacteria
    white_bacteria = gray_frame > white_thresh;
    figure(1);
    imshow(white_bacteria);

    % Perform blob analysis on the binary image to get the properties of the bacteria
    white_props = regionprops('table', white_bacteria, 'Centroid', 'Area');
    
    % Filter out blobs that do not meet the size criteria
    white_props = white_props(white_props.Area >= min_blob_size & white_props.Area <= max_blob_size, :);
    
    % Match the white blobs with the corresponding blobs in the previous frame
    if i == 1
        % For the first frame, just use the detected blobs as the initial positions
        white_positions{i} = white_props.Centroid;
    else
        % For subsequent frames, match the current blobs with the previous blobs
        white_prev = white_positions{i-1};
        white_matched = zeros(size(white_props,1),1);
        for j = 1:size(white_props,1)
            % Find the closest previous white blob to the current white blob
            dist = sqrt(sum((white_prev - white_props(j).Centroid).^2,2));
            [min_dist, idx] = min(dist);
            if min_dist <= max_match_dist && white_matched(idx) == 0
                % If the distance is less than the threshold and the
                % previous blob has not been matched, then match the
                % current and previous blobs
                white_positions{i}(j,:) = white_props(j).Centroid;
                white_matched(idx) = 1;
            else
                % Otherwise, create a new white blob
                white_positions{i}(j,:) = white_props(j).Centroid;
            end
        end
        % Any remaining unmatched previous white blobs become lost
        white_positions{i}(white_matched==0,:) = [];
    end
    
    % Plot the positions of the white bacteria
    figure(2);
    imshow(frame);
    hold on;
    for j = 1:size(white_positions{i},1)
        plot(white_positions{i}(j,1), white_positions{i}(j,2), 'r+', 'MarkerSize', 10);
    end
end
