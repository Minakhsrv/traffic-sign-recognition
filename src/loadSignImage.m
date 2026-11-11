function img = loadSignImage(path)
%loadSignImage  خواندن تصویر و تبدیل آن به RGB از نوع uint8
%   بعضی PNGها indexed، خاکستری یا شفاف (دارای کانال آلفا) هستند و
%   rgb2gray / rgb2hsv روی آن‌ها درست کار نمی‌کند.

[img, map, alpha] = imread(path);

if ~isempty(map)              % تصویر indexed
    img = ind2rgb(img, map);
end
img = im2uint8(img);

if size(img, 3) == 1          % تصویر خاکستری
    img = repmat(img, [1 1 3]);
end
img = img(:, :, 1:3);

% نواحی شفاف PNG روی پس‌زمینه سفید قرار می‌گیرند
if ~isempty(alpha)
    a = double(alpha) / double(intmax(class(alpha)));
    img = uint8(double(img) .* a + 255 * (1 - a));
end
end
