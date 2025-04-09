clc;
clear;

L1 = 10;
L2 = 1;
L3 = 1;
L4 = 1;
L5 = 40;
L6 = 1;

fi1= 0;
fi2= 90;
fi3= -180;



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


p1_vekt = [-L2  0   0   1]';
p2_vekt = [0    0   L4  1]';

p1_plus_p2 = [-L2 0 L4 1]';
p3_vekt = [0    0   L5   1]';
p4_vekt = [L6    0   0  1]';


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
    % Súbor existuje → načítanie dát
    data = readmatrix(filename);
    x_points = data(:, 1);
    y_points = data(:, 2);
    z_points = data(:, 3);

    data2 = readmatrix(filename2);
    x2_points = data2(:, 1);
    y2_points = data2(:, 2);
    z2_points = data2(:, 3);
    disp('Dáta načítané zo súboru.');

else
    fileID = fopen(filename, 'w');  
    fileID2 = fopen(filename2, 'a+');

    x_points = [];
    y_points = [];
    z_points = [];
    
    x2_points = [];
    y2_points = [];
    z2_points = [];
    for i = 0: 10: 360
        for j = 0 : 30 : 90
            k=0;
                for l = 0: 1 : 50
                    Rz = [sind(i) -cosd(i) 0 0; cosd(i) sind(i) 0 0; 0 0 1 0; 0 0 0 1];
                    Ry2 = [cosd(j) 0 sind(j) 0; 0 1 0 0; -sind(j) 0 cosd(j) 0; 0 0 0 1];
                    Ry3 = [cosd(k) 0 sind(k) 0; 0 1 0 0; -sind(k) 0 cosd(k) 0; 0 0 0 1];

                    % pomocne vypocty
                    Tz_L5 = [1 0 0 0; 
                             0 1 0 0; 
                             0 0 1 l; 
                             0 0 0 1]; 
                    A = Tx_L1*Tz_L3*Rz*Tx_L2*Tz_L4;
                    B = Tx_L1*Ry2*Tz_L5;
                    C = Ry3*p4_vekt;

                    P_XY = A*B*C;
                    
                    % Uloženie do premenných
                    x_points = [x_points; P_XY(1)];
                    y_points = [y_points; P_XY(2)];
                    z_points = [z_points; P_XY(3)];

                    % Okamžitý zápis do súboru
                    fprintf(fileID, '%f %f %f\n', P_XY(1), P_XY(2), P_XY(3));
                end
                
        end
    end
    i=0;
    for j = 0 : 1 : 90
        if (j == 0 || j == 90)
            for k = -180:1:0
                for l = 10: 0.5 : 40
                    Rz = [sind(i) -cosd(i) 0 0; cosd(i) sind(i) 0 0; 0 0 1 0; 0 0 0 1];
                    Ry2 = [cosd(j) 0 sind(j) 0; 0 1 0 0; -sind(j) 0 cosd(j) 0; 0 0 0 1];
                    Ry3 = [cosd(k) 0 sind(k) 0; 0 1 0 0; -sind(k) 0 cosd(k) 0; 0 0 0 1];

                    % pomocne vypocty
                    Tz_L5 = [1 0 0 0; 
                             0 1 0 0; 
                             0 0 1 l; 
                             0 0 0 1];  
                    A = Tx_L1 * Tz_L3 * Rz * Tx_L2 * Tz_L4;
                    B = Tx_L1 * Ry2 * Tz_L5;
                    C = Ry3 * p4_vekt;

                    P_XZ = A * B * C;

                    % Uloženie bodov
                    x2_points = [x2_points; P_XZ(1)];
                    y2_points = [y2_points; P_XZ(2)];
                    z2_points = [z2_points; P_XZ(3)];

                    % Okamžitý zápis do súboru
                    fprintf(fileID2, '%f %f %f\n', P_XZ(1), P_XZ(2), P_XZ(3));
                end
            end
        else
            k = -90;
            for l = 9: 0.5 : 40
                Rz = [sind(i) -cosd(i) 0 0; cosd(i) sind(i) 0 0; 0 0 1 0; 0 0 0 1];
                Ry2 = [cosd(j) 0 sind(j) 0; 0 1 0 0; -sind(j) 0 cosd(j) 0; 0 0 0 1];
                Ry3 = [cosd(k) 0 sind(k) 0; 0 1 0 0; -sind(k) 0 cosd(k) 0; 0 0 0 1];

                % pomocne vypocty
                Tz_L5 = [1 0 0 0; 0 1 0 0; 0 0 1 l; 0 0 0 1]; 
                A = Tx_L1 * Tz_L3 * Rz * Tx_L2 * Tz_L4;
                B = Tx_L1 * Ry2 * Tz_L5;
                C = Ry3 * p4_vekt;

                P_XZ = A * B * C;

                % Uloženie bodov
                x2_points = [x2_points; P_XZ(1)];
                y2_points = [y2_points; P_XZ(2)];  
                z2_points = [z2_points; P_XZ(3)];

                % Okamžitý zápis do súboru
                fprintf(fileID2, '%f %f %f\n', P_XZ(1), P_XZ(2), P_XZ(3));
            end
        end
    end

    % Zavretie súborov
    fclose(fileID);
    fclose(fileID2);
    disp('Dáta vypočítané a uložené.');
end

%XY
figure(2);clf;
grid on;
hold on;
e = boundary(x_points, y_points, 1);
plot(x_points(e), y_points(e), 'b-', 'LineWidth', 2);
fill(x_points(e), y_points(e), 'b', 'FaceAlpha', 0.2); 

plot([zaciatok(1,4), a_vekt(1)], [zaciatok(2,4), a_vekt(2)], 'y', 'LineWidth', 3);
plot([a_vekt(1), b_vekt(1)], [a_vekt(2), b_vekt(2)], 'y', 'LineWidth', 3);
plot([b_vekt(1), c_vekt(1)], [b_vekt(2), c_vekt(2)], 'y', 'LineWidth', 3);

%XZ
figure(3);clf;
grid on;
hold on;
f = boundary(y2_points, z2_points, 0.1);

plot(y2_points(f), z2_points(f), 'm-', 'LineWidth', 2);
fill(y2_points(f), z2_points(f), 'm', 'FaceAlpha', 0.2); 

plot([zaciatok(1,4), a_vekt(1)], [zaciatok(3,4), a_vekt(3)], 'y', 'LineWidth', 3);
plot([a_vekt(1), b_vekt(1)], [a_vekt(3), b_vekt(3)], 'y', 'LineWidth', 3);
plot([b_vekt(1), c_vekt(1)], [b_vekt(3), c_vekt(3)], 'y', 'LineWidth', 3);


figure(1); clf;
hold on;
markerSize = 25; 
markerColor = 'k';

origin = [0, 0, 0];  
scale = 3;  % dĺžka každej osi

% Zobrazenie označenia súradnicového systému
% Os X (červená)
quiver3(origin(1), origin(2), origin(3), scale, 0, 0, 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);
% Os Y (zelená)
quiver3(origin(1), origin(2), origin(3), 0, scale, 0, 'g', 'LineWidth', 2, 'MaxHeadSize', 0.5);
% Os Z (modrá)
quiver3(origin(1), origin(2), origin(3), 0, 0, scale, 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);

grid on;
xlabel('X');
ylabel('Y');
zlabel('Z');
title('3D Vykreslenie výsuvnej plošiny hasičského auta');
axis equal;

plot3([0, Tx_L1(1,4)], [0, Tx_L1(2,4)], [0, Tx_L1(3,4)], 'y--', 'LineWidth', 2);
plot3([Tx_L1(1,4),zaciatok(1,4)], [Tx_L1(2,4),zaciatok(2,4)], [Tx_L1(3,4),zaciatok(3,4)], 'y--', 'LineWidth', 2);


plot3([zaciatok(1,4), a_vekt(1)], [zaciatok(2,4), a_vekt(2)], [zaciatok(3,4), a_vekt(3)], 'y', 'LineWidth', 3);
plot3([a_vekt(1), b_vekt(1)], [a_vekt(2), b_vekt(2)], [a_vekt(3), b_vekt(3)], 'y', 'LineWidth', 3);
plot3([b_vekt(1), c_vekt(1)], [b_vekt(2), c_vekt(2)], [b_vekt(3), c_vekt(3)], 'y', 'LineWidth', 3);


% PRE A
scatter3(a_vekt(1), a_vekt(2), a_vekt(3), markerSize, markerColor, 'filled');
origin = [zaciatok(1,4), zaciatok(2,4), zaciatok(3,4)];  
% ošetrenie rotácie
vecX = [scale; 0; 0; 0];
vecY = [0; scale; 0; 0];
vecZ = [0; 0; scale; 0];

rotX = Rz * vecX;
rotY = Rz * vecY;
rotZ = Rz * vecZ;

quiver3(origin(1), origin(2), origin(3), rotX(1), rotX(2), rotX(3), 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);
quiver3(origin(1), origin(2), origin(3), rotY(1), rotY(2), rotY(3), 'g', 'LineWidth', 2, 'MaxHeadSize', 0.5);
quiver3(origin(1), origin(2), origin(3), rotZ(1), rotZ(2), rotZ(3), 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);

% PRE B
scatter3(b_vekt(1), b_vekt(2), b_vekt(3), markerSize, markerColor, 'filled');
origin = [a_vekt(1),a_vekt(2), a_vekt(3)];  
% ošetrenie rotácie
vecX = [scale; 0; 0; 0];
vecY = [0; scale; 0; 0];
vecZ = [0; 0; scale; 0];

rotX = Ry2 * vecX;
rotY = Ry2 * vecY;
rotZ = Ry2 * vecZ;

quiver3(origin(1), origin(2), origin(3), rotX(1), rotX(2), rotX(3), 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);
quiver3(origin(1), origin(2), origin(3), rotY(1), rotY(2), rotY(3), 'g', 'LineWidth', 2, 'MaxHeadSize', 0.5);
quiver3(origin(1), origin(2), origin(3), rotZ(1), rotZ(2), rotZ(3), 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);

% PRE C
scatter3(c_vekt(1), c_vekt(2), c_vekt(3), markerSize, markerColor, 'filled');
origin = [b_vekt(1),b_vekt(2), b_vekt(3)];  
% ošetrenie rotácie
vecX = [scale; 0; 0; 0];
vecY = [0; scale; 0; 0];
vecZ = [0; 0; scale; 0];
fi3 = fi3+90;
Ry3 = [cosd(fi3) 0 sind(fi3) 0; 0 1 0 0; -sind(fi3) 0 cosd(fi3) 0; 0 0 0 1];
rotX = Ry3 * vecX;
rotY = Ry3 * vecY;
rotZ = Ry3 * vecZ;


hX=quiver3(origin(1), origin(2), origin(3), rotX(1), rotX(2), rotX(3), 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);
hY=quiver3(origin(1), origin(2), origin(3), rotY(1), rotY(2), rotY(3), 'g', 'LineWidth', 2, 'MaxHeadSize', 0.5);
quiver3(origin(1), origin(2), origin(3), rotZ(1), rotZ(2), rotZ(3), 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);

fill3(y2_points(f), zeros(size(y2_points(f))), z2_points(f), 'm', 'FaceAlpha', 0.2);
fill3(x_points(e), y_points(e), zeros(size(y2_points(e))), 'b', 'FaceAlpha', 0.2);

view(3);
hold off;
