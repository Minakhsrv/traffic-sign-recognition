function db = buildReferenceDB(refFolder)
%buildReferenceDB  ساخت پایگاه تصاویر مرجع از یک پوشه
%   اسم هر فایل همان برچسب تابلو است (مثلاً stop.png ← 'stop').
%   فیچرهای SURF فقط یک‌بار اینجا محاسبه می‌شوند، نه در هر بار تشخیص.

files = [dir(fullfile(refFolder, '*.jpg')); ...
         dir(fullfile(refFolder, '*.jpeg')); ...
         dir(fullfile(refFolder, '*.png'))];

if isempty(files)
    error('هیچ تصویر مرجعی در %s پیدا نشد.', refFolder);
end

db = struct('label', {}, 'isTriangle', {}, 'points', {}, 'features', {});

for i = 1:numel(files)
    [~, label] = fileparts(files(i).name);
    img = loadSignImage(fullfile(files(i).folder, files(i).name));

    % برش خود تابلو از تصویر مرجع (همان کاری که برای تصویر تست انجام می‌شود)
    [bbox, ~, isTriangle] = findSign(img);
    if ~isempty(bbox)
        img = imcrop(img, bbox);
    end

    [features, points] = extractSignFeatures(img);

    db(end+1) = struct('label', label, 'isTriangle', isTriangle, ...
                       'points', points, 'features', features); %#ok<AGROW>
end
end
