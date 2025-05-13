function Zadanie_3_3
    % --- Vytvorenie hlavnej figury ---
    fig = figure('Name', 'Zadanie 3.3', 'Position', [300, 300, 900, 600]);

    % --- Vstupné polia ---
    uicontrol('Style', 'text', 'Position', [30 500 100 20], 'String', 'Polomer R1 [m]');
    hR1 = uicontrol('Style', 'edit', 'Position', [30 480 100 20], 'String', '5');

    uicontrol('Style', 'text', 'Position', [30 440 100 20], 'String', 'Dĺžka L1 [m]');
    hL1 = uicontrol('Style', 'edit', 'Position', [30 420 100 20], 'String', '10');

    uicontrol('Style', 'text', 'Position', [30 380 100 20], 'String', 'Polomer R2 [m]');
    hR2 = uicontrol('Style', 'edit', 'Position', [30 360 100 20], 'String', '10');

    % --- Miesto na hlavny graf ---
    mainAxes = axes('Position', [0.3 0.35 0.65 0.6]);

    % --- Miesto na maly graf rychlosti ---
    hVelPlot = axes('Position', [0.1 0.05 0.8 0.2]);

    % --- Tlacidlo na spustenie ---
    uicontrol('Style', 'pushbutton', 'String', 'Spustiť simuláciu', ...
        'Position', [30 310 100 30], 'Callback', @(~,~) startSimulation(hR1, hL1, hR2, mainAxes, hVelPlot));
end

function startSimulation(hR1, hL1, hR2, mainAxes, hVelPlot)
    % --- Parametre ---
    b = 0.2;         % šírka podvozku [m]
    dt = 0.01;       % časový krok [s]
    v = 5;           % konštantná rýchlosť [m/s]
    l_wheel = 0.1;   % dĺžka kolesa [m]
    w_wheel = 0.05;  % šírka kolesa [m]

    % --- Získanie hodnôt od užívateľa ---
    R1 = -str2double(get(hR1, 'String'));
    L1 = str2double(get(hL1, 'String'));
    R2 = str2double(get(hR2, 'String'));

    % --- Inicializácia stavu ---
    x = 0; y = 0; psi = pi/2;
    traj_cg = [];
    traj_L = [];
    traj_R = [];
    V_L_hist = [];
    V_R_hist = [];
    V_CG_hist = [];
    time_hist = [];
    t_now = 0;

    % --- Inicializácia kolies ---
    wheel_L_global = NaN(2,4);
    wheel_R_global = NaN(2,4);
    wheel_L = [0;0];
    wheel_R = [0;0];

    % --- Nastavenie grafov ---
    axes(mainAxes);
    cla;
    hold on;
    grid on;
    axis equal;
    xlabel('X [m]');
    ylabel('Y [m]');
    h_cg = plot(NaN, NaN, 'g', 'LineWidth', 2);
    h_L = plot(NaN, NaN, 'r--', 'LineWidth', 1);
    h_R = plot(NaN, NaN, 'b--', 'LineWidth', 1);
    h_robot_body = plot(NaN, NaN, 'k-', 'LineWidth', 2);
    h_robot_cg = plot(NaN, NaN, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 8);
    h_wheel_L = fill(NaN, NaN, 'r');
    h_wheel_R = fill(NaN, NaN, 'b');

    axes(hVelPlot);
    cla;
    hold on;
    grid on;
    xlabel('Čas [s]');
    ylabel('Rýchlosť [m/s]');
    h_VL = plot(NaN, NaN, 'r--', 'LineWidth', 1.5);
    h_VR = plot(NaN, NaN, 'b:', 'LineWidth', 1.5);
    h_VCG = plot(NaN, NaN, 'g-', 'LineWidth', 1.5);
    legend('V_L', 'V_R', 'V_{CG}');
    title('Priebeh rýchlosti kolies a ťažiska');
    hold off;

    function updatePlots()
        set(h_cg, 'XData', traj_cg(:,1), 'YData', traj_cg(:,2));
        set(h_L, 'XData', traj_L(:,1), 'YData', traj_L(:,2));
        set(h_R, 'XData', traj_R(:,1), 'YData', traj_R(:,2));
        set(h_robot_body, 'XData', [wheel_L(1) wheel_R(1)], 'YData', [wheel_L(2) wheel_R(2)]);
        set(h_robot_cg, 'XData', x, 'YData', y);
        set(h_wheel_L, 'XData', wheel_L_global(1,:), 'YData', wheel_L_global(2,:));
        set(h_wheel_R, 'XData', wheel_R_global(1,:), 'YData', wheel_R_global(2,:));

        axes(hVelPlot);
        set(h_VL, 'XData', time_hist, 'YData', V_L_hist);
        set(h_VR, 'XData', time_hist, 'YData', V_R_hist);
        set(h_VCG, 'XData', time_hist, 'YData', V_CG_hist);
        drawnow limitrate;
    end

    function computeWheelShapes()
        Rmat = [cos(psi) -sin(psi); sin(psi) cos(psi)];
        wheel_L_local = [0; b/2];
        wheel_R_local = [0; -b/2];
        wheel_L = Rmat * wheel_L_local + [x; y];
        wheel_R = Rmat * wheel_R_local + [x; y];

        wheel_shape = [ -l_wheel/2, l_wheel/2, l_wheel/2, -l_wheel/2;
                        -w_wheel/2, -w_wheel/2, w_wheel/2, w_wheel/2 ];
        wheel_L_global = Rmat * wheel_shape + wheel_L;
        wheel_R_global = Rmat * wheel_shape + wheel_R;
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

        computeWheelShapes();

        traj_cg = [traj_cg; x, y];
        traj_L = [traj_L; wheel_L'];
        traj_R = [traj_R; wheel_R'];
        V_L_hist = [V_L_hist; V_L];
        V_R_hist = [V_R_hist; V_R];
        V_CG_hist = [V_CG_hist; (V_L + V_R)/2];
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

        computeWheelShapes();

        traj_cg = [traj_cg; x, y];
        traj_L = [traj_L; wheel_L'];
        traj_R = [traj_R; wheel_R'];
        V_L_hist = [V_L_hist; V_L];
        V_R_hist = [V_R_hist; V_R];
        V_CG_hist = [V_CG_hist; (V_L + V_R)/2];
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

        computeWheelShapes();

        traj_cg = [traj_cg; x, y];
        traj_L = [traj_L; wheel_L'];
        traj_R = [traj_R; wheel_R'];
        V_L_hist = [V_L_hist; V_L];
        V_R_hist = [V_R_hist; V_R];
        V_CG_hist = [V_CG_hist; (V_L + V_R)/2];
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
