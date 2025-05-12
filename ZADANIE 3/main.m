function main
    fig = figure('Name', 'Robot Simulator Menu', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 600]);
    main_menu(fig); % Zavoláme funkciu main_menu, ktorá teraz berie fig ako parameter
end

function main_menu(fig)
    % Prázdne okno, aby sa neprekrývalo s predchádzajúcimi
    clf(fig);
    
    % Pridanie tlačidiel pre každé zadanie
    uicontrol('Style', 'pushbutton', 'String', 'Zadanie 3.1', 'FontSize', 12, ...
        'Position', [150 450 300 100], 'Callback', @(~,~) run_script('Zadanie_3_1'));

    uicontrol('Style', 'pushbutton', 'String', 'Zadanie 3.2', 'FontSize', 12, ...
        'Position', [550 450 300 100], 'Callback', @(~,~) run_script('Zadanie_3_2'));

    uicontrol('Style', 'pushbutton', 'String', 'Zadanie 3.3', 'FontSize', 12, ...
        'Position', [150 250 300 100], 'Callback', @(~,~) run_script('Zadanie_3_3'));

    uicontrol('Style', 'pushbutton', 'String', 'Zadanie 3.4', 'FontSize', 12, ...
        'Position', [550 250 300 100], 'Callback', @(~,~) run_script('Zadanie_3_4'));
end

function run_script(scriptName)
    evalin('base', scriptName);  % Spustí .m skript v základnom workspace
end
