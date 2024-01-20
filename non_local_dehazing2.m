function [img_dehazed, transmission] = non_local_dehazing(img_hazy, air_light, gamma)
    % Validate input
    validateRGBImage(img_hazy);
    validateAirlight(air_light);

    % Radiometric correction
    img_hazy_corrected = img_hazy.^gamma;

    % Find haze-lines
    [dist_from_airlight, radius, ind] = findHazeLines(img_hazy_corrected, air_light);

    % Initial Transmission Estimation
    transmission_estimation = estimateInitialTransmission(radius, ind);

    % Regularization
    transmission = performRegularization(transmission_estimation, img_hazy_corrected, air_light);

    % Dehazing
    img_dehazed = performDehazing(img_hazy_corrected, transmission, air_light, gamma);

    % Adjust and convert to uint8
    img_dehazed = adjustAndConvert(img_dehazed);

end

function validateRGBImage(img)
    % Validate input image
    if ndims(img) ~= 3 || size(img, 3) ~= 3
        error('Non-Local Dehazing requires an RGB image.');
    end
end

function validateAirlight(air_light)
    % Validate airlight
    if isempty(air_light) || numel(air_light) ~= 3
        error('Dehazing on sphere requires an RGB airlight.');
    end
end

function [dist_from_airlight, radius, ind] = findHazeLines(img_hazy_corrected, air_light)
    % Translate coordinate system to be air_light-centric
    dist_from_airlight = img_hazy_corrected - air_light;

    % Calculate radius
    radius = sqrt(sum(dist_from_airlight.^2, 3));

    % Cluster pixels to haze-lines using KD-tree
    ind = performKNNClustering(dist_from_airlight);
end

function transmission_estimation = estimateInitialTransmission(radius, ind)
    % Estimate initial transmission as radii ratio
    n_points = 1000;
    K = accumarray(ind, radius(:), [n_points, 1], @max);
    radius_new = K(ind);
    transmission_estimation = radius./radius_new;

    % Limit transmission to the range [trans_min, 1] for numerical stability
    trans_min = 0.1;
    transmission_estimation = min(max(transmission_estimation, trans_min), 1);
end

function transmission = performRegularization(transmission_estimation, img_hazy_corrected, air_light)
    % Regularization
    lambda = 0.1;
    data_term_weight = computeDataTermWeight(transmission_estimation, img_hazy_corrected, air_light);
    transmission = wls_optimization(transmission_estimation, data_term_weight, img_hazy_corrected, lambda);
end

function data_term_weight = computeDataTermWeight(transmission_estimation, img_hazy_corrected, air_light)
    n_points = 1000;
    ind = performKNNClustering(img_hazy_corrected - air_light);
    bin_count = accumarray(ind, 1, [n_points, 1]);
    bin_count_map = reshape(bin_count(ind), size(transmission_estimation));
    bin_eval_fun = @(x) min(1, x/50);

    K_std = accumarray(ind, transmission_estimation(:), [n_points, 1], @std);
    radius_std = K_std(ind);
    radius_eval_fun = @(r) min(1, 3*max(0.001, r-0.1));
    radius_reliability = radius_eval_fun(radius_std./max(radius_std(:)));

    data_term_weight = bin_eval_fun(bin_count_map) .* radius_reliability;
end

function img_dehazed = performDehazing(img_hazy_corrected, transmission, air_light, gamma)
    % Dehazing
    leave_haze = 1.06;
    trans_min = 0.1;
    img_dehazed = zeros(size(img_hazy_corrected));
    for color_idx = 1:3
        img_dehazed(:,:,color_idx) = (img_hazy_corrected(:,:,color_idx) - ...
            (1-leave_haze.*transmission).*air_light(color_idx)) ./ max(transmission, trans_min);
    end

    % Adjust and convert to uint8
    img_dehazed(img_dehazed > 1) = 1;
    img_dehazed(img_dehazed < 0) = 0;
    img_dehazed = img_dehazed.^(1/gamma);
end

function img_dehazed = adjustAndConvert(img_dehazed)
    % Adjust and convert to uint8
    adj_percent = [0.005, 0.995];
    img_dehazed = adjust(img_dehazed, adj_percent);
    img_dehazed = im2uint8(img_dehazed);
end

function ind = performKNNClustering(dist_from_airlight)
    % Perform k-NN clustering using KD-tree
    n_points = 1000;
    fid = fopen(['TR', num2str(n_points), '.txt']);
    points = cell2mat(textscan(fid, '%f %f %f'));
    fclose(fid);
    mdl = KDTreeSearcher(points);
    ind = knnsearch(mdl, reshape(dist_from_airlight, [], 3));
end
