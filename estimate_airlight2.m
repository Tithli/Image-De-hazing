function Aout = estimate_airlight(img, Amin, Amax, N, spacing, K, thres)
    % Validate input parameters and set defaults
    if ~exist('thres', 'var') || isempty(thres)
        thres = 0.01;
    end
    if ~exist('spacing', 'var') || isempty(spacing)
        spacing = 0.02;
    end
    if ~exist('N', 'var') || isempty(N)
        N = 1000;
    end
    if ~exist('K', 'var') || isempty(K)
        K = 40;
    end

    % Set default search range for airlight
    if ~exist('Amin', 'var') || isempty(Amin)
        Amin = [0, 0.05, 0.1];
    end
    if ~exist('Amax', 'var') || isempty(Amax)
        Amax = 1;
    end

    % Convert the input image to an indexed image
    [img_ind, points] = rgb2ind(img, N);

    % Remove empty clusters and remap indices
    idx_in_use = unique(img_ind(:));
    idx_to_remove = setdiff(0:(size(points, 1)-1), idx_in_use);
    points(idx_to_remove+1, :) = [];
    img_ind_sequential = zeros(size(img, 1), size(img, 2));
    for kk = 1:length(idx_in_use)
        img_ind_sequential(img_ind == idx_in_use(kk)) = kk;
    end

    % Count the occurrences of each index (cluster weight)
    points_weight = histcounts(img_ind_sequential(:), size(points, 1));
    points_weight = points_weight ./ (size(img, 1) * size(img, 2));

    % Define arrays of candidate airlight values and angles
    angle_list = linspace(0, pi, K);
    directions_all = [sin(angle_list(1:end-1)), cos(angle_list(1:end-1))];

    % Air-light candidates in each color channel
    ArangeR = Amin(1):spacing:Amax(1);
    ArangeG = Amin(2):spacing:Amax(2);
    ArangeB = Amin(3):spacing:Amax(3);

    % Estimate airlight in each pair of color channels
    [AoutR, ~] = estimateAirlightForColorPair(points, points_weight, directions_all, ArangeR, ArangeG, thres);
    [AoutG, ~] = estimateAirlightForColorPair(points, points_weight, directions_all, ArangeG, ArangeB, thres);
    [AoutB, ~] = estimateAirlightForColorPair(points, points_weight, directions_all, ArangeR, ArangeB, thres);

    % Find the most probable airlight from marginal probabilities
    Aout = findMostProbableAirlight(AoutR, AoutG, AoutB);
end

function [Aout, Avote2] = estimateAirlightForColorPair(points, points_weight, directions_all, Avals1, Avals2, thres)
    n_directions = size(directions_all, 1);
    [Aall, Avote2] = vote2D(points, points_weight, directions_all, Avals1, Avals2, thres);
    % ... (rest of the code for estimating airlight for a color pair)
end

function [Aall, Avote2] = vote2D(points, points_weight, directions_all, Avals1, Avals2, thres)
    % ... (implementation of the vote_2D function)
end

function Aout = findMostProbableAirlight(AoutR, AoutG, AoutB)
    % ... (implementation of finding the most probable airlight)
end
