% --- Hlavné menu aplikácie s prepínaním obsahom ---
function robot_menu_app
    fig = figure('Name', 'Robot Simulator Menu', 'Position', [300, 200, 1000, 700]);
    main_menu(fig);
end

function main_menu(fig)
    clf(fig);
    set(fig, 'Name', 'Robot Simulator Menu');

    uicontrol('Style', 'pushbutton', 'String', 'Zadanie 3.1', 'FontSize', 12, ...
        'Position', [150 450 300 100], 'Callback', @(~,~) Zadanie_3_1(fig));

    uicontrol('Style', 'pushbutton', 'String', 'Zadanie 3.2', 'FontSize', 12, ...
        'Position', [550 450 300 100], 'Callback', @(~,~) Zadanie_3_2(fig));

    uicontrol('Style', 'pushbutton', 'String', 'Zadanie 3.3', 'FontSize', 12, ...
        'Position', [150 250 300 100], 'Callback', @(~,~) Zadanie_3_3(fig));

    uicontrol('Style', 'pushbutton', 'String', 'Zadanie 3.4', 'FontSize', 12, ...
        'Position', [550 250 300 100], 'Callback', @(~,~) Zadanie_3_4(fig));
end

function Zadanie_3_1(fig)
    clf(fig);
    set(fig, 'Name', 'Zadanie 3.1');

    % --- Nastavenie grafiky ---
    ax1 = subplot(1,2,1, 'Parent', fig);
    axis equal;
    grid on;
    xlabel('X [m]');
    ylabel('Y [m]');
    title('Robot - Trajektória a poloha');
    hold on;
    
    ax2 = subplot(1,2,2, 'Parent', fig);
    grid on;
    xlabel('Čas [s]');
    ylabel('Rýchlosť [m/s]');
    title('Rýchlosti ľavého a pravého kolesa');
    hold on;
    
    % --- Prázdne grafické objekty ---
    h_cg = plot(ax1, NaN, NaN, 'g', 'LineWidth', 2);
    h_L = plot(ax1, NaN, NaN, 'r--', 'LineWidth', 1);
    h_R = plot(ax1, NaN, NaN, 'b--', 'LineWidth', 1);
    h_robot = plot(ax1, NaN, NaN, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 8);
    
    h_VL = plot(ax2, NaN, NaN, 'r', 'LineWidth', 2);
    h_VR = plot(ax2, NaN, NaN, 'b', 'LineWidth', 2);
    
    % --- Parametre ---
    b = 2;                  % vzdialenosť medzi kolesami [m]
    dt = 0.001;              % časový krok [s]
    t_end = 20;             % celkový čas simulácie [s]
    steps = t_end/dt;       % počet krokov simulácie
    
    % Časové body a rýchlosti
    T = [0 5 10 15 20];      
    V_L_values = [0 2 -1 1 2]; 
    V_R_values = [0 2 1 1 -2]; 
    
    % Počiatočné podmienky
    x = 0;
    y = 0;
    psi = 0;
    
    traj_cg = [];
    traj_L = [];
    traj_R = [];
    V_L_hist = [];
    V_R_hist = [];
    time_hist = [];
    
    % --- Simulácia ---
    for k = 1:steps
        t_now = (k-1)*dt;
        
        % Nájsť aktuálny interval
        idx = find(T <= t_now, 1, 'last');
        
        if idx < length(T)
            V_L = V_L_values(idx+1);
            V_R = V_R_values(idx+1);
        else
            V_L = V_L_values(end);
            V_R = V_R_values(end);
        end
        
        % Výpočet rýchlostí
        v = (V_R + V_L)/2;
        omega = (V_R - V_L)/b;
        
        % Aktualizácia stavu
        x = x + v * cos(psi) * dt;
        y = y + v * sin(psi) * dt;
        psi = psi + omega * dt;
        psi = atan2(sin(psi), cos(psi));
        
        % Výpočet pozícií kolies
        Rmat = [cos(psi) -sin(psi); sin(psi) cos(psi)];
        wheel_L_local = [0; b/2];
        wheel_R_local = [0; -b/2];
        wheel_L = Rmat * wheel_L_local + [x; y];
        wheel_R = Rmat * wheel_R_local + [x; y];
        
        % Ukladanie histórií
        traj_cg = [traj_cg; x, y];
        traj_L = [traj_L; wheel_L'];
        traj_R = [traj_R; wheel_R'];
        V_L_hist = [V_L_hist; V_L];
        V_R_hist = [V_R_hist; V_R];
        time_hist = [time_hist; t_now];
        
        % --- Aktualizácia grafov každých 10 krokov ---
        if mod(k,10) == 0
            set(h_cg, 'XData', traj_cg(:,1), 'YData', traj_cg(:,2));
            set(h_L, 'XData', traj_L(:,1), 'YData', traj_L(:,2));
            set(h_R, 'XData', traj_R(:,1), 'YData', traj_R(:,2));
            set(h_robot, 'XData', x, 'YData', y);
            
            set(h_VL, 'XData', time_hist, 'YData', V_L_hist);
            set(h_VR, 'XData', time_hist, 'YData', V_R_hist);
            
            drawnow limitrate;
        end
    end

    % --- Tlacitko Späť ---
    uicontrol('Style', 'pushbutton', 'String', 'Späť', 'FontSize', 10, ...
        'Position', [20 20 80 30], 'Callback', @(~,~) main_menu(fig));
end


function Zadanie_3_2(fig)
    clf(fig);
    set(fig, 'Name', 'Zadanie 3.2');

    % --- Vstupné polia ---
    uicontrol('Style', 'text', 'Position', [30 500 100 20], 'String', 'Polomer R1 [m]');
    hR1 = uicontrol('Style', 'edit', 'Position', [30 480 100 20], 'String', '5');

    uicontrol('Style', 'text', 'Position', [30 440 100 20], 'String', 'Dĺžka L1 [m]');
    hL1 = uicontrol('Style', 'edit', 'Position', [30 420 100 20], 'String', '10');

    uicontrol('Style', 'text', 'Position', [30 380 100 20], 'String', 'Polomer R2 [m]');
    hR2 = uicontrol('Style', 'edit', 'Position', [30 360 100 20], 'String', '10');



     % --- Miesto na grafy už vopred ---
    mainAxes = axes('Position', [0.3 0.35 0.65 0.6], 'Parent', fig);
    hold(mainAxes, 'on'); grid on; axis equal;

    hVelPlot = axes('Position', [0.1 0.05 0.8 0.2], 'Parent', fig);
    hold(hVelPlot, 'on'); grid on;

    % --- Tlacidlo na spustenie ---
    uicontrol('Style', 'pushbutton', 'String', 'Spustiť simuláciu', ...
        'Position', [30 310 100 30], 'Callback', @(~,~) startSimulation(hR1, hL1, hR2, fig));

    % --- Tlacidlo späť ---
    uicontrol('Style', 'pushbutton', 'String', 'Späť', 'FontSize', 10, ...
        'Position', [20 20 80 30], 'Callback', @(~,~) main_menu(fig));
end

function startSimulation(hR1, hL1, hR2, fig)
    clf(fig);
    set(fig, 'Name', 'Simulácia Zadanie 3.2');

    % --- Rozdelenie okna na dva grafy ---
    ax1 = subplot(1,2,1, 'Parent', fig);
    hold(ax1, 'on');
    axis equal;
    grid on;
    xlabel('X [m]');
    ylabel('Y [m]');
    title('Robot - Trajektória a poloha');

    ax2 = subplot(1,2,2, 'Parent', fig);
    hold(ax2, 'on');
    grid on;
    xlabel('Čas [s]');
    ylabel('Rýchlosť [m/s]');
    title('Priebeh rýchlosti kolies');
    legend('V_L', 'V_R');

    % --- Parametre ---
    b = 2;        % šírka podvozku [m]
    dt = 0.01;    % časový krok [s]
    v = 5;        % KONSTANTNA RYCHLOST robota [m/s]

    % --- Načítanie parametrov od užívateľa ---
    R1 = -str2double(get(hR1, 'String'));
    L1 = str2double(get(hL1, 'String'));
    R2 = str2double(get(hR2, 'String'));

    % --- Inicializácia stavu ---
    x = 0;
    y = 0;
    psi = pi/2;
    traj_cg = [];
    traj_L = [];
    traj_R = [];
    V_L_hist = [];
    V_R_hist = [];
    time_hist = [];
    t_now = 0;

    % --- Prázdne grafické objekty ---
    h_cg = plot(ax1, NaN, NaN, 'g', 'LineWidth', 2);
    h_L = plot(ax1, NaN, NaN, 'r--', 'LineWidth', 1);
    h_R = plot(ax1, NaN, NaN, 'b--', 'LineWidth', 1);
    h_robot = plot(ax1, NaN, NaN, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 8);

    h_VL = plot(ax2, NaN, NaN, 'r', 'LineWidth', 2);
    h_VR = plot(ax2, NaN, NaN, 'b', 'LineWidth', 2);

    % --- Funkcia na aktualizáciu grafov ---
    function updatePlots()
        set(h_cg, 'XData', traj_cg(:,1), 'YData', traj_cg(:,2));
        set(h_L, 'XData', traj_L(:,1), 'YData', traj_L(:,2));
        set(h_R, 'XData', traj_R(:,1), 'YData', traj_R(:,2));
        set(h_robot, 'XData', x, 'YData', y);
        set(h_VL, 'XData', time_hist, 'YData', V_L_hist);
        set(h_VR, 'XData', time_hist, 'YData', V_R_hist);
        drawnow limitrate;
    end

    % --- 1. FAZA: OBLUK R1 ---
    omega = v / R1;
    traveled = 0;
    while traveled < abs(pi/2 * R1)
        V_L = v - omega * b/2;
        V_R = v + omega * b/2;

        x = x + v * cos(psi) * dt;
        y = y + v * sin(psi) * dt;
        psi = psi + omega * dt;
        psi = atan2(sin(psi), cos(psi));

        traj_cg = [traj_cg; x, y];
        traj_L = [traj_L; (x + b/2*sin(psi)), (y - b/2*cos(psi))];
        traj_R = [traj_R; (x - b/2*sin(psi)), (y + b/2*cos(psi))];
        V_L_hist = [V_L_hist; V_L];
        V_R_hist = [V_R_hist; V_R];
        t_now = t_now + dt;
        time_hist = [time_hist; t_now];

        if mod(size(traj_cg,1),10)==0
            updatePlots();
        end

        traveled = traveled + v * dt;
    end

    % --- 2. FAZA: ROVNY POHYB L1 ---
    omega = 0;
    traveled = 0;
    while traveled < L1
        V_L = v;
        V_R = v;

        x = x + v * cos(psi) * dt;
        y = y + v * sin(psi) * dt;

        traj_cg = [traj_cg; x, y];
        traj_L = [traj_L; (x + b/2*sin(psi)), (y - b/2*cos(psi))];
        traj_R = [traj_R; (x - b/2*sin(psi)), (y + b/2*cos(psi))];
        V_L_hist = [V_L_hist; V_L];
        V_R_hist = [V_R_hist; V_R];
        t_now = t_now + dt;
        time_hist = [time_hist; t_now];

        if mod(size(traj_cg,1),10)==0
            updatePlots();
        end

        traveled = traveled + v * dt;
    end

    % --- 3. FAZA: OBLUK R2 ---
    omega = v / R2;
    traveled = 0;
    while traveled < abs(pi/2 * R2)
        V_L = v - omega * b/2;
        V_R = v + omega * b/2;

        x = x + v * cos(psi) * dt;
        y = y + v * sin(psi) * dt;
        psi = psi + omega * dt;
        psi = atan2(sin(psi), cos(psi));

        traj_cg = [traj_cg; x, y];
        traj_L = [traj_L; (x + b/2*sin(psi)), (y - b/2*cos(psi))];
        traj_R = [traj_R; (x - b/2*sin(psi)), (y + b/2*cos(psi))];
        V_L_hist = [V_L_hist; V_L];
        V_R_hist = [V_R_hist; V_R];
        t_now = t_now + dt;
        time_hist = [time_hist; t_now];

        if mod(size(traj_cg,1),10)==0
            updatePlots();
        end

        traveled = traveled + v * dt;
    end

    % --- Finalizácia ---
    updatePlots();
end



function Zadanie_3_3(fig)
    clf(fig);
    set(fig, 'Name', 'Zadanie 3.3');
    ax = axes('Position', [0.1 0.2 0.8 0.7]);
    title('Simulácia Zadanie 3.3');
    grid on;
    axis equal;
    hold(ax, 'on');

    % --- Sem tvoj obsah pre Zadanie 3.3 ---
    plot([0 5 5 0 0], [0 0 5 5 0], 'r-', 'LineWidth', 2);

    uicontrol('Style', 'pushbutton', 'String', 'Späť', 'FontSize', 10, ...
        'Position', [20 20 80 30], 'Callback', @(~,~) main_menu(fig));
end

function Zadanie_3_4(fig)
    clf(fig);
    set(fig, 'Name', 'Zadanie 3.4');
    ax = axes('Position', [0.1 0.2 0.8 0.7]);
    title('Simulácia Zadanie 3.4');
    grid on;
    axis equal;
    hold(ax, 'on');

    % --- Sem tvoj obsah pre Zadanie 3.4 ---
    rectangle('Position',[-2 -2 4 4],'Curvature',[1 1],'EdgeColor','m','LineWidth',2);

    uicontrol('Style', 'pushbutton', 'String', 'Späť', 'FontSize', 10, ...
        'Position', [20 20 80 30], 'Callback', @(~,~) main_menu(fig));
end
