function [call_center, updated] = getCallCenter(url)
    %% ホームページからCSVファイルを取得
    websave('csv/200000_nagano_covid19_call_center.csv', url);

    %% インポート オプションの設定およびデータのインポート
    opts = delimitedTextImportOptions("NumVariables", 7);
    % 範囲と区切り記号の指定
    opts.DataLines = [3, Inf];
    opts.Delimiter = ",";

    % 列名と型の指定
    opts.VariableNames = ["Date", "LocalGovCode", "Pref", "Municipalities", "TotalConsults", "SymptomConsults", "OtherConsults"];
    opts.VariableTypes = ["datetime", "double", "categorical", "string", "double", "double", "double"];

    % ファイル レベルのプロパティを指定
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";

    % 変数プロパティを指定
    opts = setvaropts(opts, "Municipalities", "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["Pref", "Municipalities"], "EmptyFieldRule", "auto");
    opts = setvaropts(opts, "Date", "InputFormat", "yyyy/MM/dd");

    % データのインポート
    call_center_new = readtable("csv/200000_nagano_covid19_call_center.csv", opts, "Encoding", "Shift_JIS");
    load('data/call_center_org.mat');
    updated = ~isequal(call_center, call_center_new);
    if updated
        call_center = call_center_new;
        save("data/call_center_org.mat", "call_center");
    end
    
    %% 一時変数のクリア
    clear opts
end