classdef PlosinaApp < matlab.apps.AppBase

    properties (Access = public)
        UIFigure            matlab.ui.Figure
        L5SliderLabel       matlab.ui.control.Label
        L5Slider            matlab.ui.control.Slider
        fi1SliderLabel      matlab.ui.control.Label
        fi1Slider           matlab.ui.control.Slider
        fi2SliderLabel      matlab.ui.control.Label
        fi2Slider           matlab.ui.control.Slider
        fi3SliderLabel      matlab.ui.control.Label
        fi3Slider           matlab.ui.control.Slider
        UIAxes3D            matlab.ui.control.UIAxes
        UIAxesXY            matlab.ui.control.UIAxes
        UIAxesXZ            matlab.ui.control.UIAxes
        RightPanel          matlab.ui.container.Panel
    end

    methods (Access = private)

        function startupFcn(app)
            app.UIFigure.AutoResizeChildren = 'off';
            updatePlot(app);
            updateLayout(app);
        end

        function L5SliderValueChanged(app, ~)
            updatePlot(app);
        end

        function fi1SliderValueChanged(app, ~)
            updatePlot(app);
        end

        function fi2SliderValueChanged(app, ~)
            updatePlot(app);
        end

        function fi3SliderValueChanged(app, ~)
            updatePlot(app);
        end
        
        function UIFigureSizeChanged(app, ~)
            updateLayout(app);
        end
        
        function updateLayout(app)
            figPos = app.UIFigure.Position;
            if figPos(3) < 800 || figPos(4) < 600
                app.UIFigure.Position(3:4) = [800 600];
                return;
            end
            
            margin = 20;
            leftWidth = figPos(3)*0.6;
            rightWidth = figPos(3)*0.4 - 2*margin;
            
            app.UIAxes3D.Position = [margin, margin, leftWidth-margin, figPos(4)-2*margin];
            app.RightPanel.Position = [leftWidth+margin, margin, rightWidth, figPos(4)-2*margin];
            
            panelHeight = figPos(4)-2*margin;
            plotHeight = (panelHeight - 200 - 3*margin)/2;
            
            app.UIAxesXY.Position = [margin, margin + plotHeight + 200 + 2*margin, rightWidth-2*margin, plotHeight];
            app.UIAxesXZ.Position = [margin, margin + 200 + margin, rightWidth-2*margin, plotHeight];

            sliderY = margin;
            sliderWidth = rightWidth - 2*margin;
            
            app.fi3SliderLabel.Position = [margin, sliderY+150, 25, 22];
            app.fi3Slider.Position = [margin+40, sliderY+160, sliderWidth-40, 3];
            
            app.fi2SliderLabel.Position = [margin, sliderY+100, 25, 22];
            app.fi2Slider.Position = [margin+40, sliderY+110, sliderWidth-40, 3];
            
            app.fi1SliderLabel.Position = [margin, sliderY+50, 25, 22];
            app.fi1Slider.Position = [margin+40, sliderY+60, sliderWidth-40, 3];
            
            app.L5SliderLabel.Position = [margin, sliderY, 25, 22];
            app.L5Slider.Position = [margin+40, sliderY+10, sliderWidth-40, 3];
        end
        
        function updatePlot(app)
            L5 = app.L5Slider.Value;
            fi1 = app.fi1Slider.Value;
            fi2 = app.fi2Slider.Value;
            fi3 = app.fi3Slider.Value;
            
            cla(app.UIAxes3D);
            cla(app.UIAxesXY);
            cla(app.UIAxesXZ);
            
            L1 = 10;
            L2 = 1;
            L3 = 1;
            L4 = 1;
            L6 = 1;

            fi3 = fi3+90;

            Tx_L1 = [
                    1 0 0 -L1;
                    0 1 0 0;
                    0 0 1 0;
                    0 0 0 1;
                    ];

            Tz_L3 = [
                    1 0 0 0;
                    0 1 0 0;
                    0 0 1 L3;
                    0 0 0 1;
                    ];

            Tx_L2 = [
                    1 0 0 -L2;
                    0 1 0 0;
                    0 0 1 0;
                    0 0 0 1;
                    ];

            Tz_L4 = [
                    1 0 0 0;
                    0 1 0 0;
                    0 0 1 L4;
                    0 0 0 1;
                    ];

            Tz_L5 = [
                    1 0 0 0;
                    0 1 0 0;
                    0 0 1 L5;
                    0 0 0 1;
                    ];

            Rz = [cosd(fi1) -sind(fi1) 0 0; sind(fi1) cosd(fi1) 0 0; 0 0 1 0; 0 0 0 1];
            Ry2 = [cosd(fi2) 0 sind(fi2) 0; 0 1 0 0; -sind(fi2) 0 cosd(fi2) 0; 0 0 0 1];
            Ry3 = [cosd(fi3) 0 sind(fi3) 0; 0 1 0 0; -sind(fi3) 0 cosd(fi3) 0; 0 0 0 1];

            p1_plus_p2 = [-L2 0 L4 1]';
            p3_vekt = [0    0   L5   1]';
            p4_vekt = [0    0   L6  1]';

            A = Tx_L1* Tz_L3*Rz*Tx_L2*Tz_L4;
            B = Ry2* Tz_L5;
            C = Ry3*p4_vekt;

            zaciatok = Tx_L1*Tz_L3;
            a_vekt = Tx_L1* Tz_L3* Rz * p1_plus_p2;
            b_vekt = A* Ry2 * p3_vekt;
            c_vekt = A *B * C;

            filename = 'data/XYpoints.txt';
            filename2 = 'data/XZpoints.txt';

            if isfile(filename) && isfile(filename2)
                data = readmatrix(filename);
                x_points = data(:, 1);
                y_points = data(:, 2);

                data2 = readmatrix(filename2);
                y2_points = data2(:, 2);
                z2_points = data2(:, 3);
            else
                x_points = [];
                y_points = [];
                y2_points = [];
                z2_points = [];
            end

            if ~isempty(x_points)
                e = boundary(x_points, y_points, 1);
                plot(app.UIAxesXY, x_points(e), y_points(e), 'b-', 'LineWidth', 2);
                fill(app.UIAxesXY, x_points(e), y_points(e), 'b', 'FaceAlpha', 0.2); 
            end
            hold(app.UIAxesXY, 'on');
            plot(app.UIAxesXY, [zaciatok(1,4), a_vekt(1)], [zaciatok(2,4), a_vekt(2)], 'y', 'LineWidth', 3);
            plot(app.UIAxesXY, [a_vekt(1), b_vekt(1)], [a_vekt(2), b_vekt(2)], 'y', 'LineWidth', 3);
            plot(app.UIAxesXY, [b_vekt(1), c_vekt(1)], [b_vekt(2), c_vekt(2)], 'y', 'LineWidth', 3);
            grid(app.UIAxesXY, 'on');
            hold(app.UIAxesXY, 'off');
            title(app.UIAxesXY, 'XY Rovina');
            axis(app.UIAxesXY, 'equal');

            if ~isempty(y2_points)
                f = boundary(y2_points, z2_points, 1);
                plot(app.UIAxesXZ, y2_points(f), z2_points(f), 'm-', 'LineWidth', 2);
                fill(app.UIAxesXZ, y2_points(f), z2_points(f), 'm', 'FaceAlpha', 0.2);
            end
            hold(app.UIAxesXZ, 'on');
            plot(app.UIAxesXZ, [zaciatok(1,4), a_vekt(1)], [zaciatok(3,4), a_vekt(3)], 'y', 'LineWidth', 3);
            plot(app.UIAxesXZ, [a_vekt(1), b_vekt(1)], [a_vekt(3), b_vekt(3)], 'y', 'LineWidth', 3);
            plot(app.UIAxesXZ, [b_vekt(1), c_vekt(1)], [b_vekt(3), c_vekt(3)], 'y', 'LineWidth', 3);
            grid(app.UIAxesXZ, 'on');
            hold(app.UIAxesXZ, 'off');
            title(app.UIAxesXZ, 'XZ Rovina');
            axis(app.UIAxesXZ, 'equal');

            hold(app.UIAxes3D, 'on');
            markerSize = 25; 
            markerColor = 'k';

            origin = [0, 0, 0];  
            scale = 3;

            quiver3(app.UIAxes3D, origin(1), origin(2), origin(3), scale, 0, 0, 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);
            quiver3(app.UIAxes3D, origin(1), origin(2), origin(3), 0, scale, 0, 'g', 'LineWidth', 2, 'MaxHeadSize', 0.5);
            quiver3(app.UIAxes3D, origin(1), origin(2), origin(3), 0, 0, scale, 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);

            grid(app.UIAxes3D, 'on');
            xlabel(app.UIAxes3D, 'X');
            ylabel(app.UIAxes3D, 'Y');
            zlabel(app.UIAxes3D, 'Z');
            title(app.UIAxes3D, '3D Pohľad');
            axis(app.UIAxes3D, 'equal');

            plot3(app.UIAxes3D, [0, Tx_L1(1,4)], [0, Tx_L1(2,4)], [0, Tx_L1(3,4)], 'y--', 'LineWidth', 2);
            plot3(app.UIAxes3D, [Tx_L1(1,4),zaciatok(1,4)], [Tx_L1(2,4),zaciatok(2,4)], [Tx_L1(3,4),zaciatok(3,4)], 'y--', 'LineWidth', 2);

            plot3(app.UIAxes3D, [zaciatok(1,4), a_vekt(1)], [zaciatok(2,4), a_vekt(2)], [zaciatok(3,4), a_vekt(3)], 'y', 'LineWidth', 3);
            plot3(app.UIAxes3D, [a_vekt(1), b_vekt(1)], [a_vekt(2), b_vekt(2)], [a_vekt(3), b_vekt(3)], 'y', 'LineWidth', 3);
            plot3(app.UIAxes3D, [b_vekt(1), c_vekt(1)], [b_vekt(2), c_vekt(2)], [b_vekt(3), c_vekt(3)], 'y', 'LineWidth', 3);

            scatter3(app.UIAxes3D, a_vekt(1), a_vekt(2), a_vekt(3), markerSize, markerColor, 'filled');
            scatter3(app.UIAxes3D, b_vekt(1), b_vekt(2), b_vekt(3), markerSize, markerColor, 'filled');
            scatter3(app.UIAxes3D, c_vekt(1), c_vekt(2), c_vekt(3), markerSize, markerColor, 'filled');

            if ~isempty(x_points) && ~isempty(y2_points)
                fill3(app.UIAxes3D, x_points(e), y_points(e), zeros(size(y_points(e)))+1,'b', 'FaceAlpha', 0.2); 
                fill3(app.UIAxes3D, y2_points(f), zeros(size(y2_points(f))), z2_points(f), 'm', 'FaceAlpha', 0.2);
            end
            
            view(app.UIAxes3D, 3);
            hold(app.UIAxes3D, 'off');
        end
    end

    methods (Access = private)

        function createComponents(app)
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 1200 800];
            app.UIFigure.Name = 'Hasičská plošina';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            app.UIAxes3D = uiaxes(app.UIFigure);
            title(app.UIAxes3D, '3D Pohľad');
            axis(app.UIAxes3D, 'equal');
            
            app.RightPanel = uipanel(app.UIFigure);
            app.RightPanel.AutoResizeChildren = 'off';
            
            app.UIAxesXY = uiaxes(app.RightPanel);
            title(app.UIAxesXY, 'XY Rovina');
            axis(app.UIAxesXY, 'equal');
            
            app.UIAxesXZ = uiaxes(app.RightPanel);
            title(app.UIAxesXZ, 'XZ Rovina');
            axis(app.UIAxesXZ, 'equal');
            
            app.L5SliderLabel = uilabel(app.RightPanel);
            app.L5SliderLabel.HorizontalAlignment = 'right';
            app.L5SliderLabel.Text = 'L5';

            app.L5Slider = uislider(app.RightPanel);
            app.L5Slider.Limits = [10 40];
            app.L5Slider.ValueChangedFcn = createCallbackFcn(app, @L5SliderValueChanged, true);
            app.L5Slider.Value = 10;

            app.fi1SliderLabel = uilabel(app.RightPanel);
            app.fi1SliderLabel.HorizontalAlignment = 'right';
            app.fi1SliderLabel.Text = 'φ1';

            app.fi1Slider = uislider(app.RightPanel);
            app.fi1Slider.Limits = [0 360];
            app.fi1Slider.ValueChangedFcn = createCallbackFcn(app, @fi1SliderValueChanged, true);
            app.fi1Slider.Value = 0;

            app.fi2SliderLabel = uilabel(app.RightPanel);
            app.fi2SliderLabel.HorizontalAlignment = 'right';
            app.fi2SliderLabel.Text = 'φ2';

            app.fi2Slider = uislider(app.RightPanel);
            app.fi2Slider.Limits = [0 90];
            app.fi2Slider.ValueChangedFcn = createCallbackFcn(app, @fi2SliderValueChanged, true);
            app.fi2Slider.Value = 90;

            app.fi3SliderLabel = uilabel(app.RightPanel);
            app.fi3SliderLabel.HorizontalAlignment = 'right';
            app.fi3SliderLabel.Text = 'φ3';

            app.fi3Slider = uislider(app.RightPanel);
            app.fi3Slider.Limits = [-180 0];
            app.fi3Slider.ValueChangedFcn = createCallbackFcn(app, @fi3SliderValueChanged, true);
            app.fi3Slider.Value = -180;
        end
    end

    methods (Access = public)

        function app = PlosinaApp
            createComponents(app)
            registerApp(app, app.UIFigure)
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end
