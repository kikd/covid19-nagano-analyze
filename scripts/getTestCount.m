function [test_count,updated] = getTestCount()
    %% ホームページからCSVファイルを取得
    websave('csv/200000_nagano_covid19_test_count.csv','https://www.pref.nagano.lg.jp/hoken-shippei/kenko/kenko/kansensho/joho/documents/200000_nagano_covid19_test_count.csv');
    %% インポート オプションの設定およびデータのインポート
    opts = delimitedTextImportOptions("NumVariables", 8);

    % 範囲と区切り記号の指定
    opts.DataLines = [3, Inf];
    opts.Delimiter = ",";

    % 列名と型の指定
    opts.VariableNames = ["InspectionDate", "LocalGovCode", "Pref", "Municipalities", "InspectionNum", "Remarks", "Positive", "Negative"];
    opts.VariableTypes = ["datetime", "double", "string", "string", "double", "string", "double", "double"];

    % ファイル レベルのプロパティを指定
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";

    % 変数プロパティを指定
    opts = setvaropts(opts, ["Municipalities", "Remarks"], "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["Pref", "Municipalities", "Remarks"], "EmptyFieldRule", "auto");
    opts = setvaropts(opts, "InspectionDate", "InputFormat", "yyyy/MM/dd");

    % データのインポート
    test_count_new = readtable("csv/200000_nagano_covid19_test_count.csv", opts, "Encoding", "Shift_JIS");
    load('data/test_count_org.mat');
    
    updated = ~isequal(test_count, test_count_new);
    if updated
        test_count = test_count_new;
        save("data/test_count_org.mat", "test_count");
    end
    %% 一時変数のクリア
    clear opts test_count_new
end