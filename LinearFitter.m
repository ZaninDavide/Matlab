classdef LinearFitter
    %   LinearFit: class to solve linear fit problems
    %   Fill the properties of the class then call fit() to fit your data
    %   agains a linear function

    properties
        datax(:, 1) double {mustBeReal, mustBeFinite} = []
        datay(:, 1) double {mustBeReal, mustBeFinite} = []
        sigmax(:, 1) double {mustBeReal, mustBeFinite} = []
        sigmay(:, 1) double {mustBeReal, mustBeFinite} = []
        unitx(1, 1) string = "ux"
        unity(1, 1) string = "uy"
        nolog(1, :) logical = false
        verbose(1, :) logical = false
        name(1, 1) string = "Linear model"
        labelx(1, 1) string = "X axes"
        labely(1, 1) string = "Y axes"
        filename(1, 1) string = ""
        box(1, 4) double = [0.55, 0.50, 0.1, 0.1] % [x, y, w, h]
        cifrea(1, 1) uint8 = 5
        cifreb(1, 1) uint8 = 5
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
            self.box = [0.55, 0.50, 0.1, 0.1];
            self.cifrea = 5;
            self.cifreb = 5;
        end


        % LINEAR FIT
        function [res_a, res_b, res_sa, res_sb, res_chi2, res_chi2_str] = fit(self)        
            % safety checks
            if ( ...
                length(self.datax) ~= length(self.datay) || ...
                length(self.datax) ~= length(self.sigmay) || ...
                length(self.datax) ~= length(self.sigmax) ...
            ) 
                throw("self.datax, self.datay, self.sigmax and self.sigmay should have the same length");
            end
            if(isempty(self.datax))
                throw("Missing data.");
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
            res_chi2_str = round(chi_quadro) + "/" + (length(self.datax) - 2);
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
            tiledlayout(h,1);
            nexttile(1, [h-1, 1]);
            delta_x = max(self.datax) - min(self.datax);
            xlim([min(self.datax)-0.1*delta_x max(self.datax)+0.1*delta_x]);
            x2 = [min(self.datax)-0.1*delta_x max(self.datax)+0.1*delta_x];
            y2 = b*x2 + a;
            line(x2,y2,'Color','red','LineStyle','-')
            grid on;
            grid minor;
            hold on;
            scatter(self.datax, self.datay, "MarkerEdgeColor",[0.00 0.45 0.74]);
            
            title(self.name);
            xlabel(self.labelx);
            ylabel(self.labely);
        
            % textbox
            ta = numberToText(a, sa, self.cifrea);
            tb = numberToText(b, sb, self.cifreb);
            text = ["\alpha = " + ta + self.unity; "\beta = " + tb + self.unity + "/" + self.unitx];
            annotation("textbox", self.box, ...
                "BackgroundColor", [1,1,1], ...
                "FontSize", 14, ...
                "String", text, ...
                'FitBoxToText', 'on' ...
            );
        
            set(gca, "FontSize", 14);
         
            
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
            grid minor;
            hold on;
            scatter(self.datax, scarto_y, "MarkerEdgeColor",[0.00 0.45 0.74]);
            
            title("Residui da modello lineare");
            
            % Export
            if(strlength(self.filename) > 0)
                exportFigure(gcf, gca, self.filename);
            end
        end
    end
end