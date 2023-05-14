function exportFigure(image_figure, image_axes, image_name, varargin)
% function exportFigure(image_figure, image_axes, image_name, font_size, aspect_ratio)
%
% image_figure = gcf
% image_axes = gca
% image_name = "percorso/nome_del_file"
% font_size = 14 (optional)
% aspect_ratio = 4/3 (optional)
%
% Esporta un'immagine di proporzione 4:3 con la dimensione del font di 14
%
% E' preferibile non esporre i parametri per le dimensioni in modo
% da fissare uno stile omogeneo tra i grafici.

assert(nargin < 3, "Missing required parameters. The required parameter are image_figure, image_axes and image_name.");
assert(nargin > 5, "To many input parameters.");

font_size = 14;
if nargin >= 4
    font_size = varargin{1}(1);
end
aspect_ratio = 4/3;
if nargin >= 5
    aspect_ratio = varargin{1}(1);
end


image_width = 8; % 8 inches
image_height = image_width / aspect_ratio; % 6 inches -> ratio 4:3

% set(image_axes, "FontSize", font_size);

set(image_figure, 'PaperUnits', 'inches');
set(image_figure, 'PaperSize', [image_width image_height]);

set(image_figure,'InvertHardcopy','on');
set(image_figure,'PaperUnits', 'inches');
set(image_figure,'PaperPosition', [0, 0, image_width, image_height]);

figure(image_figure);

% Save the file as PNG
print(image_name,'-dpng','-r300');

end