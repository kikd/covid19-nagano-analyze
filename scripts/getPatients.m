function [patients, updated] = getPatients(url)
    %% ホームページからCSVファイルを取得
    webopt = weboptions('CertificateFilename', '');
    websave('csv/200000_nagano_covid19_patients.csv', url, webopt);

    %% インポート オプションの設定およびデータのインポート
    opts = delimitedTextImportOptions("NumVariables", 15);

    % 範囲と区切り記号の指定
    opts.DataLines = [3, Inf];
    opts.Delimiter = ",";

    % 列名と型の指定
    opts.VariableNames = ["No", "LocalGovCode", "Pref", "Municipalities", "ConfirmedDate", "OnsetDate", "Residence", "Age", "Gender", "Job", "Condition", "Symptom", "Traveled", "Discharged", "Remarks"];
    opts.VariableTypes = ["double", "double", "string", "string", "datetime", "string", "string", "string", "string", "string", "string", "string", "double", "double", "string"];

    % ファイル レベルのプロパティを指定
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";

    % 変数プロパティを指定
    opts = setvaropts(opts, ["Pref", "Municipalities", "OnsetDate", "Residence", "Age", "Gender", "Job", "Condition", "Symptom", "Remarks"], "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["Pref", "Municipalities", "OnsetDate", "Residence", "Age", "Gender", "Job", "Condition", "Symptom", "Remarks"], "EmptyFieldRule", "auto");
    opts = setvaropts(opts, "ConfirmedDate", "InputFormat", "yyyy/MM/dd");

    % データのインポート
    patients_new = readtable("csv/200000_nagano_covid19_patients.csv", opts);
    % 渡航履歴と退院フラグが入っていないデータがあるのでケア
    fillmissing(patients_new(:,'Traveled'),'constant', 0);
    fillmissing(patients_new(:,'Discharged'),'constant', 0);
    load('data/patients_org.mat');
    updated = ~isequal(patients, patients_new);
    if updated
        patients = patients_new;
        save("data/patients_org.mat", "patients");
    end
    
    %% 一時変数のクリア
    clear opts
end