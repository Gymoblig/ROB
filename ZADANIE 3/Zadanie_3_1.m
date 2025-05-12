function Zadanie_3_1()
    % Parametre podvozku
    b = 0.2;                  % vzdialenosť medzi kolesami [m]
    dt = 0.01;               % časový krok [s]
    t_end = 25;              % celkový čas simulácie [s]
    steps = t_end/dt;        % počet krokov simulácie

    % Rozmery kolies
    r_l_wheel = 0.05;        % polomer kolesa [m]
    w_wheel = 0.03;          % šírka kolesa [m]
    l_wheel = 2*r_l_wheel;

    % Časové body a rýchlosti
    T = [0 5 10 15 20];          % časové body [s]
    V_L_values = [2 0 1 2 1];    % rýchlosti ľavého kolesa [m/s]
    V_R_values = [2 1 1 -2 1];   % rýchlosti pravého kolesa [m/s]

    % Počiatočné podmienky
    x = 0;
    y = 0;
    psi = 0;

    traj_cg = [];
    traj_L = [];
    traj_R = [];
    V_L_hist = [];
    V_R_hist = [];
    V_CG_hist = [];
    time_hist = [];

    % Príprava Figure
    f = figure("Name", "Zadanie 3.1");
    clf;

    % Simulácia
    for k = 1:steps
        t_now = (k-1)*dt; % aktuálny simulovaný čas
        
        % --- Rýchlosti na základe aktuálneho času ---
        V_L = interp1(T, V_L_values, t_now, 'previous', 'extrap');
        V_R = interp1(T, V_R_values, t_now, 'previous', 'extrap');
        
        % Výpočet rýchlosti robota
        v = (V_R + V_L) / 2;
        omega = (V_R - V_L) / b;
        
        % Aktualizácia stavu
        x = x + v * cos(psi) * dt;
        y = y + v * sin(psi) * dt;
        psi = psi + omega * dt;
        psi = atan2(sin(psi), cos(psi));

        % Výpočet pozícií kolies
        Rmat = [cos(psi) -sin(psi); sin(psi) cos(psi)];
        wheel_L_local = [0; b/2];
        wheel_R_local = [0; -b/2];
        wheel_L_pos = Rmat * wheel_L_local + [x; y];
        wheel_R_pos = Rmat * wheel_R_local + [x; y];
        
        % Definícia tvaru kolesa v lokálnych súradniciach
        wheel_shape = [ -l_wheel/2  l_wheel/2  l_wheel/2  -l_wheel/2;
                        -w_wheel/2 -w_wheel/2 w_wheel/2  w_wheel/2 ];
        % Transformácia tvaru kolesa
        wheel_L_global = Rmat * wheel_shape + wheel_L_pos;
        wheel_R_global = Rmat * wheel_shape + wheel_R_pos;
        
        % Ukladanie histórií
        traj_cg = [traj_cg; x, y];
        traj_L = [traj_L; wheel_L_pos'];
        traj_R = [traj_R; wheel_R_pos'];
        V_L_hist = [V_L_hist; V_L];
        V_R_hist = [V_R_hist; V_R];
        time_hist = [time_hist; t_now];
        V_CG_hist = [V_CG_hist; v];
        
        % --- Vykreslenie ---
        if mod(k,5)==0 % aktualizuj graf len každých pár krokov na zrýchlenie
            figure(f); % explicitne nastavte, že vykresľujete do tejto figúry
            subplot(1,2,1);
            cla;
            hold on;
            plot(traj_cg(:,1), traj_cg(:,2), 'g', 'LineWidth', 1);
            plot(traj_L(:,1), traj_L(:,2), 'r--', 'LineWidth', 0.5);
            plot(traj_R(:,1), traj_R(:,2), 'b--', 'LineWidth', 0.5);
            plot([wheel_L_pos(1) wheel_R_pos(1)], [wheel_L_pos(2) wheel_R_pos(2)], 'k-', 'LineWidth', 0.02);
            fill(wheel_L_global(1,:), wheel_L_global(2,:), 'r'); % vykreslenie ľavého kolesa
            fill(wheel_R_global(1,:), wheel_R_global(2,:), 'b'); % vykreslenie pravého kolesa
            plot(x, y, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 5);
            axis equal;
            xlabel('X [m]');
            ylabel('Y [m]');
            title('Robot - Trajektória a poloha');
            grid on;
            hold off;
            
            subplot(1,2,2);
            cla;
            hold on;
            plot(time_hist, V_CG_hist, 'g-', 'LineWidth', 2);  % ťažisko - zelená plná čiara
            plot(time_hist, V_L_hist, 'r--', 'LineWidth', 2);  % ľavé koleso - červená prerušovaná
            plot(time_hist, V_R_hist, 'b:', 'LineWidth', 2);  % pravé koleso - modrá bodkovaná
            legend('V_{CG} - ťažisko', 'V_L - Ľavé', 'V_R - Pravé');
            xlabel('Čas [s]');
            ylabel('Rýchlosť [m/s]');
            ylim([-3 3]);
            grid on;
            title('Rýchlosti kolies a ťažiska');
            hold off;
            
            drawnow;
        end
    end
end
