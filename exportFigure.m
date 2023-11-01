function exportFigure(image_name, varargin)
% function exportFigure(image_name, image_figure, font_size, aspect_ratio, image_width)
%
% image_name          % path to image with no extension (required)
% image_figure = gcf  % figure handle (optional parameter)
% font_size    = 14   % pt (optional parameter)
% aspect_ratio = 4/3  %    (optional parameter)
% image_width  = 20   % cm (optional parameter)
% image_height        % cm (optional parameter, overrides aspect_ratio)
%
% Optional parameters unset or set to zero will receive their default values.

assert(nargin >= 1, "Missing required parameters. The only required parameter is image_figure. No parameters were provided instead.");
assert(nargin <= 6, "To many input parameters. The number of paramers must be between two and six. Found " + nargin + " parameters instead.");

image_figure = gcf;
if nargin >= 2 && varargin{1} ~= 0
    image_figure = varargin{1};
end
font_size = 14;
if nargin >= 3 && varargin{2} ~= 0
    font_size = varargin{2};
end
aspect_ratio = 4/3;
if nargin >= 4 && varargin{3} ~= 0
    aspect_ratio = varargin{3};
end
image_width = 20; % 20cm
if nargin >= 5 && varargin{4} ~= 0
    image_width = varargin{4};
end
if nargin >= 6 && varargin{5} ~= 0
    aspect_ratio = image_width / varargin{5};
end

figure_axes = findall(image_figure,'type','axes');
for ii=1:length(figure_axes)
    set(figure_axes(ii), "FontSize", font_size);
end

image_height = image_width / aspect_ratio;
set(image_figure, 'PaperUnits', 'centimeters');
set(image_figure, 'PaperSize', [image_width image_height]);
set(image_figure, 'InvertHardcopy','on');
set(image_figure, 'PaperPosition', [0, 0, image_width, image_height]);

figure(image_figure);

% Save the file as PNG
print(image_name,'-dpng','-r300');

end