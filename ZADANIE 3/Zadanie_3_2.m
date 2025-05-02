% Robot Simulator App with Adjustable Side Length and CG Speed

function Zadanie_3_2
    % Create UI figure
    fig = uifigure('Name', 'Zadanie 3.2', 'Position', [100 100 1000 600]);

    % Create input field for side length
    uilabel(fig, 'Position', [20 550 120 30], 'Text', 'Dĺžka strany [m]:');
    sideLengthInput = uieditfield(fig, 'numeric', 'Position', [150 555 100 22], 'Value', 2);

    % Create Start Simulation button
    startButton = uibutton(fig, 'push', 'Text', 'Spustiť simuláciu', ...
        'Position', [270 550 120 30], 'ButtonPushedFcn', @(btn,event) startSimulation());

    % Create axes for speed plot
    axSpeed = uiaxes(fig, 'Position', [20 300 450 200]);
    title(axSpeed, 'Rýchlosti kolies a tažiska');
    xlabel(axSpeed, 'Cas [s]');
    ylabel(axSpeed, 'Rychlost [m/s]');
    grid(axSpeed, 'on');

    % Create axes for trajectory plot
    axTrajectory = uiaxes(fig, 'Position', [500 50 450 500]);
    title(axTrajectory, 'Trajektória robota');
    xlabel(axTrajectory, 'X [m]');
    ylabel(axTrajectory, 'Y [m]');
    axis(axTrajectory, 'equal');
    grid(axTrajectory, 'on');

    function startSimulation()
        % --- Parametre ---
        b = 0.2;
        r = 0.05;
        robot_speed = 0.5;
        side_length = sideLengthInput.Value;
        dt = 0.05;
        T_total = 120;
        steps = round(T_total/dt);
        turn_speed = pi/4;

        r_l_wheel = 0.05;
        w_wheel = 0.03;
        l_wheel = 2*r_l_wheel;

        % Inicializácia
        x = 0; y = 0; psi = 0;
        traj_cg = []; traj_L = []; traj_R = [];
        V_L_hist = []; V_R_hist = []; V_CG_hist = []; time_hist = [];
        mode = 'forward';
        distance_travelled = 0;
        side_count = 0;
        turn_time_elapsed = 0;
        turn_time = (pi/2) / turn_speed;

        % --- Simulácia ---
        for k = 1:steps
            t = (k-1)*dt;

            if side_count >= 4
                break;
            end

            switch mode
                case 'forward'
                    V_L = robot_speed;
                    V_R = robot_speed;
                case 'turn'
                    V_L = -turn_speed * b/2;
                    V_R =  turn_speed * b/2;
            end

            v = (V_R + V_L)/2;
            omega = (V_R - V_L)/b;

            x = x + v*cos(psi)*dt;
            y = y + v*sin(psi)*dt;
            psi = psi + omega*dt;
            psi = atan2(sin(psi), cos(psi));

            if strcmp(mode, 'forward')
                distance_travelled = distance_travelled + abs(v)*dt;
                if distance_travelled >= side_length
                    mode = 'turn';
                    distance_travelled = 0;
                    turn_time_elapsed = 0;
                end
            elseif strcmp(mode, 'turn')
                turn_time_elapsed = turn_time_elapsed + dt;
                if turn_time_elapsed >= turn_time
                    mode = 'forward';
                    side_count = side_count + 1;
                end
            end

            Rmat = [cos(psi) -sin(psi); sin(psi) cos(psi)];
            wheel_L_local = [0; b/2];
            wheel_R_local = [0; -b/2];
            wheel_L = Rmat * wheel_L_local + [x; y];
            wheel_R = Rmat * wheel_R_local + [x; y];

            wheel_shape = [ -l_wheel/2 l_wheel/2 l_wheel/2 -l_wheel/2;
                            -w_wheel/2 -w_wheel/2 w_wheel/2 w_wheel/2 ];
            wheel_L_global = Rmat * wheel_shape + wheel_L;
            wheel_R_global = Rmat * wheel_shape + wheel_R;

            traj_cg = [traj_cg; x, y];
            traj_L = [traj_L; wheel_L'];
            traj_R = [traj_R; wheel_R'];
            V_L_hist = [V_L_hist; V_L];
            V_R_hist = [V_R_hist; V_R];
            V_CG_hist = [V_CG_hist; v];
            time_hist = [time_hist; t];

            if mod(k,5)==0
                % Aktualizuj grafy
                cla(axTrajectory);
                hold(axTrajectory, 'on');
                plot(axTrajectory, traj_cg(:,1), traj_cg(:,2), 'g', 'LineWidth', 2);
                plot(axTrajectory, traj_L(:,1), traj_L(:,2), 'r--', 'LineWidth', 1);
                plot(axTrajectory, traj_R(:,1), traj_R(:,2), 'b--', 'LineWidth', 1);
                fill(axTrajectory, wheel_L_global(1,:), wheel_L_global(2,:), 'r');
                fill(axTrajectory, wheel_R_global(1,:), wheel_R_global(2,:), 'b');
                plot(axTrajectory, [wheel_L(1) wheel_R(1)], [wheel_L(2) wheel_R(2)], 'k-', 'LineWidth', 2);
                plot(axTrajectory, x, y, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 10);
                hold(axTrajectory, 'off');

                cla(axSpeed);
                hold(axSpeed, 'on');
                plot(axSpeed, time_hist, V_CG_hist, 'g-', 'LineWidth', 2);   % Tažisko - zelená plná čiara
                plot(axSpeed, time_hist, V_L_hist, 'r--', 'LineWidth', 2);   % Ľavé koleso - červená prerušovaná
                plot(axSpeed, time_hist, V_R_hist, 'b:', 'LineWidth', 2);   % Pravé koleso - modrá čiara s bodkami
                legend(axSpeed, 'V_L', 'V_R', 'V_{CG}');
                grid(axSpeed, 'on');
                hold(axSpeed, 'off');

                drawnow;
            end
        end

                % --- Dotočenie na presný uhol po skončení ---
        final_angle = round(psi/(pi/2))*(pi/2);  % najbližší násobok 90°
        psi_error = atan2(sin(final_angle - psi), cos(final_angle - psi));
        
        while abs(psi_error) > deg2rad(0.5)  % tolerancia 0.5°
            omega = 0.5; % jemná uhlová rýchlosť
            V_L = -omega * b/2;
            V_R = omega * b/2;
            
            v = (V_R + V_L)/2;
            omega_robot = (V_R - V_L)/b;
            
            x = x + v*cos(psi)*dt;
            y = y + v*sin(psi)*dt;
            psi = psi + omega_robot*dt;
            psi = atan2(sin(psi), cos(psi));
        
            % Uložiť do histórie
            traj_cg = [traj_cg; x, y];
            traj_L = [traj_L; (x + b/2*sin(psi)), (y - b/2*cos(psi))];
            traj_R = [traj_R; (x - b/2*sin(psi)), (y + b/2*cos(psi))];
            V_L_hist = [V_L_hist; V_L];
            V_R_hist = [V_R_hist; V_R];
            V_CG_hist = [V_CG_hist; v];
            t_now = t_now + dt;
            time_hist = [time_hist; t_now];
        
            psi_error = atan2(sin(final_angle - psi), cos(final_angle - psi));
        end
        
        % Aktualizuj naposledy grafy
        cla(axTrajectory);
        hold(axTrajectory, 'on');
        plot(axTrajectory, traj_cg(:,1), traj_cg(:,2), 'g', 'LineWidth', 2);
        plot(axTrajectory, traj_L(:,1), traj_L(:,2), 'r--', 'LineWidth', 1);
        plot(axTrajectory, traj_R(:,1), traj_R(:,2), 'b--', 'LineWidth', 1);
        plot(axTrajectory, x, y, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 10);
        hold(axTrajectory, 'off');
        
        cla(axSpeed);
        hold(axSpeed, 'on');
        plot(axSpeed, time_hist, V_CG_hist, 'g-', 'LineWidth', 2);
        plot(axSpeed, time_hist, V_L_hist, 'r--', 'LineWidth', 2);
        plot(axSpeed, time_hist, V_R_hist, 'b:', 'LineWidth', 2);
        legend(axSpeed, 'V_L', 'V_R', 'V_{CG}');
        grid(axSpeed, 'on');
        hold(axSpeed, 'off');
        
        drawnow;
        
            end
end
