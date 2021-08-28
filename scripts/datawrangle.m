%% オープンデータ取得URLの設定
base_url = 'https://www.pref.nagano.lg.jp';

webopt = weboptions('CharacterEncoding', 'UTF-8');
site_data = webread(strcat(base_url,"/hoken-shippei/kenko/kenko/kansensho/joho/corona-doko.html"), webopt);
[token,match] = regexp(site_data,expression,'tokens', 'match')

patients_url = strcat(base_url, match{1});
testcount_url = strcat(base_url, match{2});
callcenter_url = strcat(base_url, match{3});


%% 県の人口
% 2021/4/1時点の人口を用いる。
% NHKでは、2019/10/1時点の人口(2049653)を用いている
population = 2024073;
per100k = 1e5 / population;

%% データ取得時間の設定
updated = datetime();
updated.Second = 0;

%% オープンデータの取得
[call_center, call_center_updated] = getCallCenter(callcenter_url);
[test_count, test_count_updated] = getTestCount(testcount_url);
[patients, patients_updated] = getPatients(patients_url);

if ~any([call_center_updated, test_count_updated, patients_updated])
    return
end

%% 不正行の削除
patients = rmmissing(patients);
test_count = rmmissing(test_count);
call_center = rmmissing(call_center);

%% 年代情報の取得
% 1例だけ含まれている乳児は、10歳未満として扱う。
patients.Age(patients.Age == '乳児') = '10歳未満';
age_list = unique(patients.Age);
age_value = { 'age_10s'  'age_under10'  'age_20s'  'age_30s'  'age_40s'  'age_50s'   'age_60s'   'age_70s'   'age_80s'   'age_90s'   'age_over90'};
map_age = containers.Map(age_list', age_value);

%% 公表日ベースの陽性者に関するデータ作成
% 公表日ベースの陽性者数取得
% 0人だった日も知りたいので、日付は検査状況から引用する
% -> 休日は検査状況が更新されていないことを考えていなかった。。。
% -> 発生状況の日付も見たほうがよい。
% -> 自動更新ができるようになったらyesterdayを最後の日付にしてもいいかも。
start_date = test_count.InspectionDate(1);
end_date = max(test_count.InspectionDate(end), patients.ConfirmedDate(end));
d = [start_date:end_date]';
confirmedNumberbyDate = zeros(numel(d),1);
tmp_confirmednumber_byage = zeros(numel(d), numel(age_list));
for index = 1:numel(d)
    % 公表日ベースの陽性者数を抽出
    before_generation = max(1, index - 5);
    tmp_a = find(patients.ConfirmedDate == d(index));
    confirmed_number = length(tmp_a);
    confirmedNumberbyDate(index) = confirmed_number;
    confirmed_by_date = patients(tmp_a,:);
        
    % WIP:年代別で陽性者数を取得
    for age_index = 1:numel(age_list)
        tmp_confirmednumber_byage(index, age_index) = ... 
        length(find(confirmed_by_date.Age == age_list(age_index)));
    end
end

% 年代別陽性者をJSONに吐き出す
confirmednumber_byage = table();
confirmednumber_byage.YMD = d;
for age_index = 1:numel(age_list)
    age_key = age_list(age_index);
    confirmednumber_byage.(char(map_age(age_key))) = ...
        tmp_confirmednumber_byage(:,age_index);
end
confirmed_byage_json = [jsonencode(confirmednumber_byage) newline];
fid = fopen('json/confirm_byage.json', 'w');
fwrite(fid, confirmed_byage_json);
fclose(fid);
clear fid tmp_confirmednumber_byage age_index date_index age_key


% 7日間移動平均を作成
confirmednumber_movave = movmean(confirmedNumberbyDate,[6 0]);

% 10万人当たり陽性者数
confirmed_per100k = confirmednumber_movave.*7.*per100k;

% 簡易実効再生産数の計算
% 7日間移動平均を用いて計算する
% 東洋経済オンラインと同じ数式とする
rt0 = zeros(numel(d),1);
for index = 1:numel(d)
    before_generation = max(1, index - 7);
    beforeval = confirmednumber_movave(before_generation);
    % 0除算対策
    if beforeval == 0
        beforeval = 1;
    end
    rt0(index) = (confirmednumber_movave(index) / beforeval) ^ (5/7);
end
% tableにまとめる
confirm_count=table(d, confirmedNumberbyDate, confirmednumber_movave, confirmed_per100k, rt0);
confirm_count.Properties.VariableNames = {'Date' 'ConfirmedNumber' 'MovingAverage' 'ConfirmedPer100k' 'Rt'};
save('data/confirm_count.mat', 'confirm_count');

% jsonで吐き出す
confirm_json = struct();
confirm_json.lastUpdated = updated;
confirm_json.confirm = confirm_count;
confirm_json_text = [jsonencode(confirm_json) newline];
fid = fopen('json/confirm.json', 'w');
fwrite(fid, confirm_json_text);
fclose(fid);

clear before_generation beforeval confirm_json confirm_json_text d ...
    start_date end_date fid index confirmed_number confirmedNumberbyDate ...
    confirmed_by_date tmp_a map_age rt0 clear age_list age_value ...
    confirmed_per100k per100k population confirmednumber_movave ...
    confirmed_byage_json;

%% 検査数
test_count.Properties.VariableNames = {'YMD' 'regionCode'  'namePref' 'nameMunicipal' 'testedNum' 'misc' 'positiveNum' 'negativeNum'};
inspection_movave = movmean(test_count.testedNum, [6 0]);
test_count.testedAve = inspection_movave;
% 検査日ベースの陽性者数
positive_movave = movmean(test_count.positiveNum, [6 0]);
test_count.positiveAve = positive_movave;

% 陽性率計算
% 計算方法
% 検査陽性数の移動平均 / 検査実施件数の移動平均。
% 移動平均はどちらも7日間の移動平均を用いる
positive_rate = positive_movave./inspection_movave.*100;
test_count.positiveRate = positive_rate;

% jsonファイルを生成
testcount_json = [jsonencode(test_count) newline];
fid = fopen('json/test_count.json', 'w');
fwrite(fid, testcount_json);
fclose(fid);

clear inspection_movave positive_movave positive_rate fid testcount_json...
    updated ans;
