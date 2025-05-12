function Zadanie_3_4
    fig = figure('Name', 'Robot Simulator WASD', 'Position', [300, 300, 1000, 600], ...
                 'KeyPressFcn', @keyDownListener, 'CloseRequestFcn', @closeFigure);

    mainAxes = axes('Position', [0.35 0.3 0.6 0.65]);

    uitable('Data', [0;0], 'RowName', {'V_L', 'V_R'}, 'ColumnName', {'Velocity [m/s]'}, ...
            'Position', [30 300 200 100], 'Tag', 'VelocityTable');

    uicontrol('Style', 'pushbutton', 'String', 'Ukončiť a vykresliť rýchlosti', ...
              'Position', [80 250 100 30], 'Callback', @closeFigure);

    % --- WASD + SPACE zobrazenie ---
    handles.W = uicontrol('Style', 'text', 'String', 'W', 'FontSize', 14, ...
        'BackgroundColor', [0.9 0.9 0.9], 'Position', [100 520 40 40]);
    handles.A = uicontrol('Style', 'text', 'String', 'A', 'FontSize', 14, ...
        'BackgroundColor', [0.9 0.9 0.9], 'Position', [60 480 40 40]);
    handles.S = uicontrol('Style', 'text', 'String', 'S', 'FontSize', 14, ...
        'BackgroundColor', [0.9 0.9 0.9], 'Position', [100 480 40 40]);
    handles.D = uicontrol('Style', 'text', 'String', 'D', 'FontSize', 14, ...
        'BackgroundColor', [0.9 0.9 0.9], 'Position', [140 480 40 40]);
    handles.Space = uicontrol('Style', 'text', 'String', 'SPACE - Reštart pozície', 'FontSize', 12, ...
        'BackgroundColor', [0.9 0.9 0.9], 'Position', [40 435 160 40]);

    global V_L V_R traj_cg traj_L traj_R x y psi velkost_kroku b dt timerObj;
    V_L = 0; V_R = 0;
    b = 2;
    dt = 0.01;
    x = 0; y = 0; psi = pi/2;
    velkost_kroku = 0.5;
    traj_cg = []; traj_L = []; traj_R = [];
    V_L_hist = []; V_R_hist = []; V_CG_hist = []; time_hist = [];

    timerObj = timer('ExecutionMode', 'fixedRate', 'Period', dt, 'TimerFcn', @moveRobot);
    start(timerObj);

    function keyDownListener(~, event)
        switch event.Key
            case 'w'
                V_L = V_L + velkost_kroku;
                V_R = V_R + velkost_kroku;
            case 's'
                V_L = V_L - velkost_kroku;
                V_R = V_R - velkost_kroku;
            case 'a'
                V_L = V_L - velkost_kroku;
            case 'd'
                V_L = V_L + velkost_kroku;
            case 'space'
                V_L = 0; V_R = 0;
                x = 0; y = 0; psi = pi/2;
                traj_cg = []; traj_L = []; traj_R = [];
        end

        V_L = round(V_L,1);
        V_R = round(V_R,1);
        if abs(V_L) < 0.01, V_L = 0; end
        if abs(V_R) < 0.01, V_R = 0; end

        updateTable();
        updateWASD(event.Key); % Pridaj zvýraznenie klávesu
    end

    function moveRobot(~, ~)
        v = (V_L + V_R)/2;
        omega = (V_R - V_L)/b;

        x = x + v * cos(psi) * dt;
        y = y + v * sin(psi) * dt;
        psi = atan2(sin(psi + omega * dt), cos(psi + omega * dt));

        traj_cg = [traj_cg; x, y];
        traj_L = [traj_L; (x + b/2*sin(psi)), (y - b/2*cos(psi))];
        traj_R = [traj_R; (x - b/2*sin(psi)), (y + b/2*cos(psi))];

        V_L_hist = [V_L_hist; V_L];
        V_R_hist = [V_R_hist; V_R];
        V_CG_hist = [V_CG_hist; v];
        time_hist = [time_hist; (length(time_hist) + 1) * dt];

        axes(mainAxes);
        cla;
        hold on;
        plot(traj_cg(:,1), traj_cg(:,2), 'g', 'LineWidth', 2);
        plot(traj_L(:,1), traj_L(:,2), 'r--', 'LineWidth', 1);
        plot(traj_R(:,1), traj_R(:,2), 'b--', 'LineWidth', 1);
        plot(x, y, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 8);
        axis equal;
        grid on;
        xlabel('X [m]');
        ylabel('Y [m]');
        hold off;
        drawnow;
    end

    function updateTable()
        velocityTable = findobj('Tag', 'VelocityTable');
        set(velocityTable, 'Data', [V_L; V_R]);
    end

    function closeFigure(~, ~)
        try
            if isvalid(timerObj)
                stop(timerObj);
                delete(timerObj);
            end
        catch ME
            disp(['Chyba pri zatváraní časovača: ', ME.message]);
        end
        if isvalid(fig)
            % Zobrazenie grafu rýchlosti v novom okne
            fig2 = figure('Name', 'Rýchlosti kolies a ťažiska');
            plot(time_hist, V_CG_hist, 'g-', 'LineWidth', 2);
            hold on;
            plot(time_hist, V_L_hist, 'r--', 'LineWidth', 2);
            plot(time_hist, V_R_hist, 'b:', 'LineWidth', 2);
            legend('V_{CG} - ťažisko', 'V_L - Ľavé', 'V_R - Pravé');
            xlabel('Čas [s]');
            ylabel('Rýchlosť [m/s]');
            ylim([-3 3]);
            grid on;
            title('Rýchlosti kolies a ťažiska');
            hold off;
    
            delete(fig);  % Zavrie pôvodné okno
        end
    end


    function updateWASD(key)
        % Reset farieb
        set([handles.W, handles.A, handles.S, handles.D, handles.Space], 'BackgroundColor', [0.9 0.9 0.9]);

        switch key
            case 'w'
                set(handles.W, 'BackgroundColor', [0.4 1 0.4]);
            case 'a'
                set(handles.A, 'BackgroundColor', [0.4 1 0.4]);
            case 's'
                set(handles.S, 'BackgroundColor', [0.4 1 0.4]);
            case 'd'
                set(handles.D, 'BackgroundColor', [0.4 1 0.4]);
            case 'space'
                set(handles.Space, 'BackgroundColor', [1 1 0.4]);
        end
    end
end
