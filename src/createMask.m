function [BW, maskedRGBImage] = createMask(RGB)
%createMask  جداسازی نواحی قرمز تصویر (رنگ اغلب تابلوهای ایست و ممنوعیت)
%   آستانه‌ها با ابزار Color Thresholder در فضای HSV پیدا شدند.

% تبدیل تصویر RGB به HSV
I = rgb2hsv(RGB);
H = I(:,:,1);
S = I(:,:,2);
V = I(:,:,3);

% رنگ قرمز در دو سر محور Hue قرار دارد (نزدیک 0 و نزدیک 1)، برای همین از "یا" استفاده می‌شود
hueMin = 0.97;   % قرمز تیره
hueMax = 0.04;   % قرمز روشن

% حداقل اشباع و روشنایی، تا نواحی خاکستری و تیره به‌عنوان قرمز انتخاب نشوند
satMin = 0.45;
valMin = 0.25;

BW = (H >= hueMin | H <= hueMax) & (S >= satMin) & (V >= valMin);

% پاکسازی ماسک: حذف نویز، پر کردن داخل تابلو (مثل حروف STOP) و حذف لکه‌های خیلی کوچک
BW = imopen(BW, strel('disk', 2));
BW = imfill(BW, 'holes');
BW = bwareaopen(BW, round(0.001 * numel(BW)));

% تصویر ماسک‌شده (پس‌زمینه صفر)
maskedRGBImage = RGB;
maskedRGBImage(repmat(~BW, [1 1 3])) = 0;
end
