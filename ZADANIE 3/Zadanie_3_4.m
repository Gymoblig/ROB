function Zadanie_3_4
    fig = figure('Name', 'Zadanie 3.4', ...
        'Position', [300, 300, 1100, 600], ...
        'KeyPressFcn', @keyDownListener, ...
        'CloseRequestFcn', @closeFigure);

    % --- Axes pre simuláciu ---
    mainAxes = axes('Parent', fig, 'Units', 'pixels', ...
        'Position', [350 100 720 480]);

    % --- Tabuľka s rýchlosťami ---
    uitable('Data', [0; 0], 'RowName', {'V_L', 'V_R'}, ...
        'ColumnName', {'Rýchlosť [m/s]'}, ...
        'Position', [50 430 200 100], ...
        'Tag', 'VelocityTable', ...
        'FontSize', 12);

    uicontrol('Style', 'pushbutton', 'String', 'Ukončiť a vykresliť rýchlosti', ...
        'Position', [75 380 150 30], ...
        'Callback', @closeFigure, ...
        'FontSize', 10);

    % --- Layout klávesnice ---
    keys = {'q', 'w', 'e'; 'a','s', 'd'; '', '', ''; '', 'space', ''};
    keyPos = [60 120];  % Ľavý dolný roh
    keySize = [50 50];
    spacing = 10;
    handles = struct();

    for row = 1:size(keys, 1)
        for col = 1:size(keys, 2)
            key = keys{row, col};
            if ~isempty(key)
                x = keyPos(1) + (col - 1) * (keySize(1) + spacing);
                y = keyPos(2) + (size(keys,1) - row) * (keySize(2) + spacing);
                label = upper(key);
                if strcmp(key, 'space')
                    label = 'SPACE';
                    keySizeTemp = [160 40];
                    x = keyPos(1);
                    y = y - 10;
                else
                    keySizeTemp = keySize;
                end
                handles.(key) = uicontrol('Style', 'text', 'String', label, ...
                    'Position', [x y keySizeTemp], ...
                    'FontSize', 12, ...
                    'BackgroundColor', [0.9 0.9 0.9], ...
                    'Tag', key);
            end
        end
    end

    % --- Inicializácia premenných ---
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

    % --- Funkcia na obsluhu kláves ---
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
                V_R = V_R - velkost_kroku;
            case 'e'
                v = (V_L + V_R) / 2;
                V_L = v;
                V_R = v;
            case 'q'
                delta = (V_R - V_L) / 2;
                V_L = -delta;
                V_R = delta;
            case 'space'
                V_L = 0; V_R = 0;
                x = 0; y = 0; psi = pi/2;
                traj_cg = []; traj_L = []; traj_R = [];
        end

        V_L = round(V_L, 1);
        V_R = round(V_R, 1);
        if abs(V_L) < 0.01, V_L = 0; end
        if abs(V_R) < 0.01, V_R = 0; end

        updateTable();
        updateWASD(event.Key);
    end

    % --- Pohyb robota ---
    function moveRobot(~, ~)
        v = (V_L + V_R) / 2;
        omega = (V_R - V_L) / b;

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
        plot(x, y, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 8);
        axis equal;
        grid on;
        xlabel('X [m]');
        ylabel('Y [m]');
        hold off;
        drawnow;
    end

    % --- Aktualizácia tabuľky rýchlostí ---
    function updateTable()
        velocityTable = findobj('Tag', 'VelocityTable');
        set(velocityTable, 'Data', [V_L; V_R]);
    end

    % --- Zvýraznenie stlačeného tlačidla ---
    function updateWASD(key)
        keyFields = fieldnames(handles);
        for i = 1:length(keyFields)
            set(handles.(keyFields{i}), 'BackgroundColor', [0.9 0.9 0.9]);
        end
        if isfield(handles, key)
            set(handles.(key), 'BackgroundColor', [0.4 1 0.4]);
        end
    end

    % --- Zatvorenie a vykreslenie ---
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

            delete(fig);
        end
    end
end
