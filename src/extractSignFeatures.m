function [features, points] = extractSignFeatures(img)
%extractSignFeatures  استخراج فیچرهای SURF از تصویر RGB یک تابلو
%   همه تصاویر قبل از استخراج به اندازه ثابت 256x256 تبدیل می‌شوند تا
%   تصویر تست و تصاویر مرجع در یک مقیاس مقایسه شوند.

gray = rgb2gray(img);
gray = imresize(gray, [256 256]);

pts = detectSURFFeatures(gray);
[features, points] = extractFeatures(gray, pts);
end
