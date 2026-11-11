function [bbox, extent, isTriangle] = findSign(img)
%findSign  پیدا کردن بزرگ‌ترین ناحیه قرمز تصویر به‌عنوان تابلو
%   bbox       کادر دور تابلو به‌صورت [x y w h] (اگر چیزی پیدا نشد: [])
%   extent     نسبت مساحت ناحیه به مساحت کادرش (مثلثی ≈ 0.5 ، دایره ≈ 0.785 ، هشت‌ضلعی ≈ 0.83)
%   isTriangle آیا شکل تابلو مثلثی است یا نه

BW = createMask(img);
stats = regionprops(BW, 'BoundingBox', 'Area', 'Extent');

if isempty(stats)
    bbox = [];
    extent = NaN;
    isTriangle = false;
    return;
end

% فرض: بزرگ‌ترین ناحیه قرمز همان تابلو است
[~, idx] = max([stats.Area]);
bbox = stats(idx).BoundingBox;
extent = stats(idx).Extent;
isTriangle = extent < 0.65;
end
