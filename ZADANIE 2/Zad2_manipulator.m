% Inicializácia parametrov systému
m1 = 3;           % Hmotnosť 1. ramena [kg]
m2 = 3;           % Hmotnosť 2. ramena [kg]
l1 = 0.25;        % Dĺžka 1. ramena [m]
l2 = 0.25;        % Dĺžka 2. ramena [m]
B1 = 2;           % Tlmenie 1. kĺbu
B2 = 2;           % Tlmenie 2. kĺbu
g = 9.81;         % Gravitačné zrýchlenie [m/s^2]
final_uhol = -pi/4; 

% Spustenie simulácie
simOut = sim('Zad2manipulator.slx');
out = simOut;


% Polohová odozva ramena q1
figure;
plot(out.q1.time, out.q1.signals.values, 'LineWidth', 2);
xlabel('Čas [s]');
ylabel('Uhol q1 [rad]');
title('Polohová odozva ramena q1');
grid on;

% Polohová odozva ramena q2
figure;
plot(out.q2.time, out.q2.signals.values, 'LineWidth', 2);
xlabel('Čas [s]');
ylabel('Uhol q2 [rad]');
title('Polohová odozva ramena q2');
grid on;

% Spoločná polohová odozva ramien q1 a q2
figure;
hold on;
plot(out.q1.time, out.q1.signals.values, 'LineWidth', 2);
plot(out.q2.time, out.q2.signals.values, 'LineWidth', 2);
xlabel('Čas [s]');
ylabel('Uhol [rad]');
title('Polohová odozva ramien q1 a q2');
legend('q1', 'q2');
grid on;
hold off;

% Krútiace momenty τ1 a τ2
figure;
hold on;
plot(out.t1.time, out.t1.signals.values, 'LineWidth', 2);
plot(out.t2.time, out.t2.signals.values, 'LineWidth', 2);
xlabel('Čas [s]');
ylabel('Krútiaci moment [Nm]');
title('Krútiace momenty manipulátora');
legend('τ1', 'τ2');
grid on;
hold off;


figure;
plot(out.rychlost1.time, out.rychlost1.signals.values, 'LineWidth', 2);
xlabel('Čas [s]');
ylabel('Rýchlosť [rad/s]');
title('Rýchlosť ramena q1');
grid on;

% Polohová odozva ramena q2
figure;
plot(out.rychlost2.time, out.rychlost2.signals.values, 'LineWidth', 2);
xlabel('Čas [s]');
ylabel('Rýchlosť [rad/s]');
title('Rýchlosť ramena q2');
grid on;


% Spoločná polohová odozva ramien q1 a q2
figure;
hold on;
plot(out.rychlost1.time, out.rychlost1.signals.values, 'LineWidth', 2);
plot(out.rychlost2.time, out.rychlost2.signals.values, 'LineWidth', 2);
xlabel('Čas [s]');
ylabel('Rýchlosť [rad/s]');
title('Rýchlosť ramien');
legend('q1', 'q2');
grid on;
hold off;