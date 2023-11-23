classdef LinearFitter
    %   LinearFit: class to solve linear fit problems
    %   Fill the properties of the class then call fit() to fit your data
    %   against a linear model

    properties
        datax(:, 1) double {mustBeReal, mustBeFinite} = []
        datay(:, 1) double {mustBeReal, mustBeFinite} = []
        sigmax(:, 1) double {mustBeReal, mustBeFinite} = []
        sigmay(:, 1) double {mustBeReal, mustBeFinite} = []
        unitx(1, 1) string = "ux"
        unity(1, 1) string = "uy"
        unita(1, 1) string = ""
        unitb(1, 1) string = ""
        nolog(1, :) logical = false
        verbose(1, :) logical = false
        name(1, 1) string = "Linear model"
        labelx(1, 1) string = "X axes"
        labely(1, 1) string = "Y axes"
        filename(1, 1) string = ""
        box string = ""
        cifrea(1, 1) uint8 = 0
        cifreb(1, 1) uint8 = 0
        pedice(1, 1) char = ' '
        showzoom(1, 1) logical = false
        zoompos(1, 4) double = [0.21, 0.75, 0.15, 0.15] % [x, y, w, h]
        fontsize(1, 1) double = 14
        ratio(1, 1) double = 4/3
    end

    methods
        % CONSTRUCTOR
        function self = LinearFitter()
            self.datax = [];
            self.datay = [];
            self.sigmax = [];
            self.sigmay = [];
            self.unitx = "ux";
            self.unity = "uy";
            self.nolog = false;
            self.verbose = false;
            self.name = "Modello lineare";
            self.labelx = "Asse X";
            self.labely = "Asse Y";
            self.filename = "";
            self.box = "";
            self.cifrea = 0;
            self.cifreb = 0;
            self.pedice = ' ';
            self.showzoom = false;
            self.zoompos = [0.21, 0.75, 0.15, 0.15];
            self.fontsize = 14;
            self.ratio = 4/3;
        end


        % LINEAR FIT
        function [res_a, res_b, res_sa, res_sb, res_chi2, res_chi2_str] = fit(self)        
            % safety checks
            if ( ...
                ~isequal(size(self.datax), size(self.datay)) || ...
                ~isequal(size(self.datax), size(self.sigmay)) || ...
                ~isequal(size(self.datax), size(self.sigmax)) ...
            ) 
                disp("size(datax)  = "); disp(size(self.datax));
                disp("size(datay)  = "); disp(size(self.datay));
                disp("size(sigmax) = "); disp(size(self.sigmax));
                disp("size(sigmay) = "); disp(size(self.sigmay));
                assert(false, "datax, datay, sigmax and sigmay should have the same size");
            end
            if(isempty(self.datax))
                assert(false, "Missing data.");
            end
        
            old_b = 9999999;
            a = 0;
            b = 0;
            togo = true;
            iterations = 0;
            max_it = 20;
            while(togo && iterations <= max_it)
                iterations = iterations + 1;
                new_old_b = b;
        
                % 1) usiamo b per calcolare un sigma_tot comprensivo di self.sigmax e self.sigmay
                sigma_tot = sqrt(self.sigmay.^2 + (b*self.sigmax).^2);
                sigma_tot2 = sigma_tot.^2;
        
                % 2) utilizziamo sigma_tot per calcolare a, b, sigma_a, sigma_b
                delta = (...
                    sum(1./sigma_tot2)*sum(self.datax.^2 ./ (sigma_tot2)) - ...
                    (sum(self.datax ./ (sigma_tot2)))^2 ...
                );
                a = (1 / delta) * ( ...
                        sum(self.datax.^2 ./ sigma_tot2)*sum(self.datay ./ sigma_tot2) - ...
                        sum(self.datax ./ sigma_tot2)*sum(self.datax.*self.datay ./ sigma_tot2)...
                    );
                b = (1 / delta) * ( ...
                    sum(1./sigma_tot2)*sum(self.datax.*self.datay ./ sigma_tot2) - ...
                    sum(self.datax ./ sigma_tot2)*sum(self.datay ./ sigma_tot2)...
                );
                sigma_a = sqrt(sum(self.datax.^2 ./ sigma_tot2)/delta);
                sigma_b = sqrt(sum(1./sigma_tot2)/delta);
        
                delta_b = abs(old_b - b);
                old_b = new_old_b;
       
                if(delta_b < sigma_b)
                    togo = false;
                end
        
            end
        
            % Test del chi quadro
            sigma_tot = sqrt(self.sigmay.^2 + (b*self.sigmax).^2);
            chi_quadro = sum((self.datay - self.datax*b - a).^2 ./ (sigma_tot.^2));
            
            if(not(self.nolog))
                disp("-------- y = a + bx --------------------------------------");
                disp(self.name);
                disp("X: " + self.labelx + ", Y: " + self.labely);
                disp("Coefficiente angolare (b) : " + b + " ± " + sigma_b + " [" + self.unity + "/" + self.unitx + "]");
                disp("Reciproco (1/b)           : " + 1/b + " [" + self.unitx + "/" + self.unity + "]");
                disp("Intercetta (a)            : " + a + " ± " + sigma_a + " [" + self.unity + "]");
                disp("Chi2                      : " + chi_quadro + "/" + (length(self.datax) - 2));
                disp("----------------------------------------------------------");
            end

            if (self.verbose && not(self.nolog))
                disp("Iterazioni: " + iterations);
                expected_self.sigmay = 1/(length(self.datax) - 2) * sum((self.datay - self.datax*b - a).^2);
                disp("self.sigmay attesa: " + expected_self.sigmay);
                disp("self.sigmay media: " + mean(self.sigmay));
            end
            
            % OUTPUT
            res_a = a;
            res_b = b;
            res_sa = sigma_a;
            res_sb = sigma_b;
            res_chi2 = chi_quadro / (length(self.datax) - 2);
            res_chi2_str = "";
            if round(chi_quadro) ~= 0
                res_chi2_str = round(chi_quadro) + "/" + (length(self.datax) - 2);
            else
                factor_chi2 = 10^(floor(log10(chi_quadro)));
                res_chi2_str = (round(chi_quadro / factor_chi2) * factor_chi2) + "/" + (length(self.datax) - 2);
            end
        end

        % FIT AND PLOT
        function [res_a, res_b, res_sa, res_sb, res_chi2, res_chi2_str] = plotfit(self)
            [res_a, res_b, res_sa, res_sb, res_chi2, res_chi2_str] = self.fit();
            a = res_a;
            b = res_b;
            sa = res_sa;
            sb = res_sb;

            sigma_tot_vec = sqrt(self.sigmay.^2 + (b*self.sigmax).^2);
    
            % --------------------------------
            
            figure();
            
            axes();
            
            h = 3;
            tl = tiledlayout(h,1);
            tl.TileSpacing = 'tight';
            tl.Padding = 'tight';
            
            nexttile(1, [h-1, 1]);
            delta_x = max(self.datax) - min(self.datax);
            xlim([min(self.datax)-0.1*delta_x max(self.datax)+0.1*delta_x]);
            x2 = [min(self.datax)-0.1*delta_x max(self.datax)+0.1*delta_x];
            y2 = b*x2 + a;
            line(x2,y2,'Color','red','LineStyle','-')
            box on;
            grid on;
            grid minor;
            hold on;
            scatter(self.datax, self.datay, "MarkerEdgeColor",[0.00 0.45 0.74]);
            
            title(self.name);
            set(gca, 'XTickLabel', []);
            if self.unity == "" || self.unity == "1"
                ylabel(self.labely);
            else
                ylabel(self.labely + " [" + self.unity + "]");
            end
        
            % textbox
            ta = numberToText(a, sa, self.cifrea);
            tb = numberToText(b, sb, self.cifreb);
            pd = "";
            unit_alpha = self.unita;
            unit_beta = self.unitb;
            if self.unita == ""
                unit_alpha = self.unity;
            end
            if self.unitb == ""
                if self.unitx == "" || self.unitx == "1"
                    unit_beta = self.unity;
                else
                    unit_beta = self.unity + "/" + self.unitx;
                end
            end
            if self.pedice ~= ' '
                text = [ ...
                        "\alpha_{" + self.pedice + "} = " + ta + unit_alpha; ...
                        "\beta_{" + self.pedice + "} = " + tb + unit_beta; ...
                        "\chi^2_{" + self.pedice + "} = " + res_chi2_str ...
                    ];
            else
                text = ["\alpha = " + ta + unit_alpha; "\beta = " + tb + unit_beta; "\chi^2 = " + res_chi2_str];
            end
            top_axes = gca;
        
            set(gca, "FontSize", self.fontsize);
         
            
            % grafico degli scarti
            nexttile([1 1]);
            scarto_y = self.datay - (b*self.datax + a);
            e2 = errorbar(self.datax, scarto_y, sigma_tot_vec);
            e2.LineStyle = 'none';
            xlim([min(self.datax)-0.1*delta_x max(self.datax)+0.1*delta_x]);
            ylim([-max(scarto_y.*2)-max(sigma_tot_vec) max(scarto_y.*2)+max(sigma_tot_vec)]);
            x = [min(self.datax)-0.1*delta_x max(self.datax)+0.1*delta_x];
            y = [0 0];
            line(x,y,'Color','red','LineStyle','-')
            grid on;
            box on;
            grid minor;
            hold on;
            scatter(self.datax, scarto_y, "MarkerEdgeColor",[0.00 0.45 0.74]);
            set(gca, "FontSize", self.fontsize);
            
            if self.unity == "" || self.unity == "1"
                ylabel("Residui");
            else
                ylabel("Residui [" + self.unity + "]");
            end
            if self.unitx == "" || self.unitx == "1"
                xlabel(self.labelx);
            else
                xlabel(self.labelx + " [" + self.unitx + "]");
            end
            
            if(self.showzoom)
                hold on;
                id = round(length(self.datax) / 2)
                x = self.datax(id);
                y = self.datay(id);
                axes("Position",self.zoompos);
                errorbar(x,y,-self.sigmay(id),self.sigmay(id),-self.sigmax(id),self.sigmax(id),'o');
                xlim([(x-self.sigmax(id)*1.5) (x+self.sigmax(id)*1.5)]);
                ylim([(y-self.sigmay(id)*1.5) (y+self.sigmay(id)*1.5)]);
                % xlabel(self.labelx);
                % ylabel(self.labely);
                grid on;
                grid minor;

            end    

            if self.box == ""
                if b > 0 
                    textBox(text, "southeast", top_axes, self.fontsize, 0.01, 0.01 * self.ratio);
                else
                    textBox(text, "northeast", top_axes, self.fontsize, 0.01, 0.01 * self.ratio);
                end
            else
                textBox(text, self.box, top_axes, self.fontsize, 0.01, 0.01 * self.ratio);
            end
            
            % Export
            if(strlength(self.filename) > 0)
                exportFigure(self.filename, gcf, self.fontsize, self.ratio);
            end
        end
    end
end