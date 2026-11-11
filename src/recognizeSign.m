function [label, score] = recognizeSign(signImage, isTriangle, db, minInliers)
%recognizeSign  تشخیص نوع تابلو از روی تصویر برش‌خورده آن
%
%   signImage   تصویر RGB برش‌خورده تابلو
%   isTriangle  خروجی findSign (شکل مثلثی بودن)
%   db          خروجی buildReferenceDB
%   minInliers  حداقل تعداد تطابق درست برای قبول نتیجه (پیش‌فرض 6)، کمتر از آن 'Unknown'
%
%   روش: ابتدا از روی شکل، مرجع‌های هم‌شکل انتخاب می‌شوند. تابلوی مثلثی (Yield) تقریباً
%   بافت ندارد و SURF روی آن فیچر کافی پیدا نمی‌کند، پس با شکل تشخیص داده می‌شود.
%   برای بقیه، فیچرهای SURF تصویر تست با هر مرجع تطبیق داده می‌شوند و فقط تطابق‌هایی
%   شمرده می‌شوند که با یک تبدیل هندسی (مقیاس/چرخش/جابه‌جایی) سازگارند.

if nargin < 4
    minInliers = 6;
end

label = 'Unknown';
score = 0;

% مرجع‌های هم‌شکل با تابلوی تست
candidates = find([db.isTriangle] == isTriangle);
if isempty(candidates)
    return;
end

% فقط یک مرجع مثلثی داریم، پس با شکل مشخص می‌شود
if isTriangle && numel(candidates) == 1
    label = db(candidates).label;
    score = NaN;
    return;
end

%% فیچرهای تصویر تست
[featuresTest, pointsTest] = extractSignFeatures(signImage);
if pointsTest.Count < 3
    return;   % فیچر کافی برای تشخیص نیست
end

%% مقایسه با مرجع‌ها
bestScore = 0;
bestLabel = 'Unknown';

for k = candidates
    pairs = matchFeatures(featuresTest, db(k).features, ...
                          'Unique', true, 'MaxRatio', 0.8);
    if size(pairs, 1) < 3
        continue;
    end

    matchedTest = pointsTest(pairs(:, 1));
    matchedRef  = db(k).points(pairs(:, 2));

    % حذف تطابق‌های اشتباه با RANSAC؛ تعداد inlierها امتیاز این مرجع است
    try
        if exist('estimateGeometricTransform2D', 'file')
            [~, inlierIdx] = estimateGeometricTransform2D( ...
                matchedTest, matchedRef, 'similarity', 'MaxDistance', 8);
            nInliers = nnz(inlierIdx);
        else
            [~, inlierTest] = estimateGeometricTransform( ...
                matchedTest, matchedRef, 'similarity', 'MaxDistance', 8);
            nInliers = inlierTest.Count;
        end
    catch
        nInliers = 0;   % تبدیل هندسی پیدا نشد
    end

    if nInliers > bestScore
        bestScore = nInliers;
        bestLabel = db(k).label;
    end
end

score = bestScore;
if bestScore >= minInliers
    label = bestLabel;
end
end
