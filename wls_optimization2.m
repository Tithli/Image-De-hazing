function out = wls_optimization(in, data_weight, guidance, lambda)
    small_num = 0.00001;

    % Set default lambda if not provided
    if ~exist('lambda', 'var') || isempty(lambda)
        lambda = 0.05;
    end

    % Get image dimensions
    [h, w, ~] = size(guidance);
    k = h * w;

    % Convert guidance to grayscale
    guidance = rgb2gray(guidance);

    % Compute affinities between adjacent pixels based on gradients of guidance
    dy = diff(guidance, 1, 1);
    dy = -lambda ./ (sum(abs(dy).^2, 3) + small_num);
    dy = padarray(dy, [1 0], 'post');
    dy = dy(:);

    dx = diff(guidance, 1, 2);
    dx = -lambda ./ (sum(abs(dx).^2, 3) + small_num);
    dx = padarray(dx, [0 1], 'post');
    dx = dx(:);

    B = [dx, dy];
    d = [-h, -1];
    tmp = spdiags(B, d, k, k);

    ea = dx;
    we = padarray(dx, h, 'pre'); we = we(1:end-h);
    so = dy;
    no = padarray(dy, 1, 'pre'); no = no(1:end-1);

    D = -(ea + we + so + no);
    Asmoothness = tmp + tmp' + spdiags(D, 0, k, k);

    data_weight = data_weight - min(data_weight(:));
    data_weight = 1 .* data_weight ./ (max(data_weight(:)) + small_num);

    % Ensure reliability along the first row
    reliability_mask = data_weight(1, :) < 0.6;
    in_row1 = min(in, [], 1);
    data_weight(1, reliability_mask) = 0.8;
    in(1, reliability_mask) = in_row1(reliability_mask);

    Adata = spdiags(data_weight(:), 0, k, k);

    % Combine data and smoothness terms
    A = Adata + Asmoothness;
    b = Adata * in(:);

    % Solve the linear system
    out = A \ b;

    % Reshape the result to the image dimensions
    out = reshape(out, h, w);
end
