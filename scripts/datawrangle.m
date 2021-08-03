%% オープンデータの取得
addpath('scripts')
call_center = getCallCenter;
test_count = getTestCount;
patients = getPatients;


%% 公表日ベースの陽性者数取得
start_date = min(test_count.InspectionDate);
end_date = max(test_count.InspectionDate);
confirmedNumberbyDate = [];
for date_ = start_date:end_date
confirmed_number = length(find(patients.ConfirmedDate==date_));
confirmedNumberbyDate = [confirmedNumberbyDate, confirmed_number];
end

%% 各7日間移動平均を計算
% 公表日ベースの陽性者数
confirmednumber_movave = movmean(confirmedNumberbyDate,[6 0]);

% 検査数
inspection_movave = movmean(test_count.InspectionNum, [6 0]);
% 検査日ベースの陽性者数
positive_movave = movmean(test_count.Positive, [6 0]);

% 陽性率
positive_rate = test_count.Positive ./ test_count.InspectionNum .* 100;
posrate_movave = movmean(positive_rate, [6 0]);
posrate_movave2 = positive_movave./inspection_movave.*100;