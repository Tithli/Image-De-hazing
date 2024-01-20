image_name = 'train';%'pumpkins';'train'; % 'cityscape'; % 'forest'; % 
img_hazy = imread(['images/train_input.png']);

fid = fopen('images/train_params.txt','r');
[C] = textscan(fid,'%s %f');
fclose(fid);
gamma = C{2}(1);

A = reshape(estimate_airlight(im2double(img_hazy).^(gamma)),1,1,3);	
[img_dehazed, trans_refined] = non_local_dehazing(img_hazy, A, gamma );
figure('Position',[50,50, size(img_hazy,2)*3 , size(img_hazy,1)]);
subplot(1,3,1); imshow(img_hazy);    title('Hazy input')
subplot(1,3,2); imshow(img_dehazed); title('De-hazed output')
subplot(1,3,3); imshow(trans_refined); colormap('jet'); title('Transmission')

