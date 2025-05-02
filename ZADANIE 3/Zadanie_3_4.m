% --- Funkcia pre GUI a ovladanie robota pomocou WASD ---
function Zadanie_3_4
    % --- Vytvorenie hlavnej figury ---
    fig = figure('Name', 'Robot Simulator WASD', 'Position', [300, 300, 1000, 600], ...
                 'KeyPressFcn', @keyDownListener, 'CloseRequestFcn', @closeFigure);

    % --- Miesto na hlavny graf ---
    mainAxes = axes('Position', [0.35 0.3 0.6 0.65]);

    % --- Miesto na tabulku rýchlosti ---
    uitable('Data', [0;0], 'RowName', {'V_L', 'V_R'}, 'ColumnName', {'Velocity [m/s]'}, ...
            'Position', [30 300 200 100], 'Tag', 'VelocityTable');

    % --- Inicializácia premenných ---
    global V_L V_R traj_cg traj_L traj_R x y psi velkost_kroku b dt timerObj;
    V_L = 0;
    V_R = 0;
    b = 2;        % sirka podvozku [m]
    dt = 0.01;    % casovy krok [s]
    x = 0;
    y = 0;
    psi = pi/2;   % smer hore
    velkost_kroku = 0.5;
    traj_cg = [];
    traj_L = [];
    traj_R = [];

    % --- Hlavný cyklus pohybu ---
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
        end

        % --- Zaokrúhlenie na 1 desatinné miesto ---
        V_L = round(V_L,1);
        V_R = round(V_R,1);
        
        % --- Ak sú veľmi malé hodnoty, nastav ich na 0 ---
        if abs(V_L) < 0.01
            V_L = 0;
        end
        if abs(V_R) < 0.01
            V_R = 0;
        end
        updateTable();
    end

    function moveRobot(~, ~)
        v = (V_L + V_R)/2;
        omega = (V_R - V_L)/b;

        x = x + v * cos(psi) * dt;
        y = y + v * sin(psi) * dt;
        psi = psi + omega * dt;
        psi = atan2(sin(psi), cos(psi));

        % Ukladanie trajektórií
        traj_cg = [traj_cg; x, y];
        traj_L = [traj_L; (x + b/2*sin(psi)), (y - b/2*cos(psi))];
        traj_R = [traj_R; (x - b/2*sin(psi)), (y + b/2*cos(psi))];

        % Kreslenie
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
        drawnow limitrate;
    end

    function updateTable()
        velocityTable = findobj('Tag', 'VelocityTable');
        set(velocityTable, 'Data', [V_L; V_R]);
    end

    function closeFigure(~, ~)
        stop(timerObj);
        delete(timerObj);
        delete(fig);
    end
end