function call_center = getCallCenter()
    %% ホームページからCSVファイルを取得
    websave('csv/200000_nagano_covid19_call_center.csv','https://www.pref.nagano.lg.jp/hoken-shippei/kenko/kenko/kansensho/joho/documents/200000_nagano_covid19_call_center.csv');

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
    call_center = readtable("csv/200000_nagano_covid19_call_center.csv", opts);


    %% 一時変数のクリア
    clear opts
end