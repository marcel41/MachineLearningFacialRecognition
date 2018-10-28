%Part1 a
%**********************************************************************

clc
clear all

load ORLfacedata;
X = data([1:10, 291:300],:);
Y = labels([1:10, 291:300]);
labelExpected = 0;
labelExpectedbyDataSet = [];
countCorrectClassification1Subject = 0;
countCorrectClassification1SubjectPerK = [];
countCorrectClassification1SubjectPerSet = [];
countCorrectClassification30SubjectPerK = [];
countCorrectClassification30SubjectPerSet = [];
countCorrectClassification30Subject = 0;
countCorrectClassification = 0;
correctClassificationPerK = [];
correctClassificationPerSet = [];
result = [];
resultPerSamples = [];
accuracyTesting = 0;
accuracyTestingPerSet = [];
accuracyTestingPerSample = [];
accuracyTraining = 0;
accuracyTrainingPerSet = [];
accuracyTrainingPerSample = [];
resultPerSet = [];
%we will need to store them in order to show the result of certain faces
labelsTestPerSample = [];
%create 50 partitions
for indexSet = 1:50
  for indexK = 1:6
    %computing testing accuracy
    [Xtr, Xte, Ytr, Yte] = PartitionData(X, Y, 3);
    %create a partitions
    for indexSample = 1:6
      if(Ytr(indexSample) == knearest(indexK, Xtr(indexSample,:), Xtr ,Ytr))
        accuracyTraining = accuracyTraining + 1;
      end;
    end;
    accuracyTrainingPerSample = [accuracyTrainingPerSample, accuracyTraining/6];
    accuracyTraining = 0;
    %computin testing
    resultPerSamples = [];
    for indexSample = 1:14
      if(Yte(indexSample) == knearest(indexK, Xte(indexSample,:), Xtr ,Ytr))
        accuracyTesting = accuracyTesting + 1;
      end;
      labelsTestPerSample = [labelsTestPerSample;
      knearest(indexK, Xte(indexSample,:), Xtr ,Ytr)];
    end;
    accuracyTestingPerSample = [accuracyTestingPerSample, accuracyTesting/14];
    accuracyTesting = 0;
    %printing the result of the dataset n with its differents knn
    %if(indexSet == 1|| indexSet == 10 || indexSet == 20 || indexSet == 30 || indexSet == 40 || indexSet == 50)
    %  figure()
    %  ShowResult(Xte,Yte,labelsTestPerSample,7)
    %end;
    labelsTestPerSample = [];
    %The following is the implementation of the binary classifier

  end;
    for indexSample = 1:14
    %-------------------------------------------------------------------------
      XtrainingWith1Column = [ones(size(Xtr,1),1),Xtr];
      w = pinv(XtrainingWith1Column) * Ytr;
    %  L = pinv(XtrainingWith1Column);
      XtestingWith1Column = [ones(size(Xte,1),1),Xte];
        for index = 1:1025
          result = [result, XtestingWith1Column(indexSample,index) * w(index)];
        end;
        result = sum(result);
        resultPerSamples = [resultPerSamples, result];
        result = [];
        %-------------------------------------------------------------------------
    end;
    for index = 1:14
      if(resultPerSamples(index) < 16)
        labelExpected = 1;
        if(labelExpected == Yte(index))
          countCorrectClassification1Subject = countCorrectClassification1Subject + 1;
        end;
      else
        labelExpected = 30;
        if(labelExpected == Yte(index))
          countCorrectClassification30Subject = countCorrectClassification30Subject + 1;
        end;
      end;
      labelExpectedbyDataSet = [labelExpectedbyDataSet; labelExpected];
    end;
    %if(indexSet == 1|| indexSet == 2 || indexSet == 4 || indexSet == 35 || indexSet == 20 || indexSet == 50)
    %  figure()
    %  ShowResult(Xte,Yte,labelExpectedbyDataSet,7)
    %end;
    countCorrectClassification1SubjectPerSet = [countCorrectClassification1SubjectPerSet; countCorrectClassification1Subject/7];
    countCorrectClassification30SubjectPerSet = [countCorrectClassification30SubjectPerSet; countCorrectClassification30Subject/7];
    countCorrectClassification1Subject = 0;
    countCorrectClassification30Subject = 0;
    %------------------------------------------------------------------------%
    correctClassificationPerSet = [correctClassificationPerSet; correctClassificationPerK];
    correctClassificationPerK = [];
    accuracyTrainingPerSet = [accuracyTrainingPerSet; accuracyTrainingPerSample];
    accuracyTestingPerSet = [accuracyTestingPerSet; accuracyTestingPerSample];
    accuracyTrainingPerSample = [];
    accuracyTestingPerSample = [];
end;
trainingAccuracy = sum(accuracyTrainingPerSet)/50;
testingAccuracy = sum(accuracyTestingPerSet)/50;

d = accuracyTestingPerSet(:,1);
%****************************************************************************************
%Display  errorbar one using the the averaged testing accuracy and the standard deviations
standardDeviationTrain = [];
standardDeviationTesting = [];
k = 1:1:6;
for index = 1:6
 tempDeviation = std(accuracyTrainingPerSet(:,index));
 standardDeviationTrain = [standardDeviationTrain; tempDeviation];
end;
for index = 1:6
 tempDeviation = std(accuracyTestingPerSet(:,index));
 standardDeviationTesting = [standardDeviationTesting; tempDeviation];
end;
figure()
errorbar(k,trainingAccuracy, standardDeviationTrain)
xlabel('K');
ylabel('AccuracyTraining');
title('AvgAccuracyForTraining')
figure()
errorbar(k,testingAccuracy, standardDeviationTesting, 'g')
xlabel('K');
ylabel('AccuracyTesting');
title('AvgAccuracyForTesting');
%plot graph of accuracy
averageSubjects = [sum(countCorrectClassification1SubjectPerSet)/50, sum(countCorrectClassification30SubjectPerSet)/50];
Subjects = [1 30];
figure()
bar(Subjects, averageSubjects);
xlabel('Subjects');
ylabel('Accuracy');
figure()
dataSet = [1:1:40];
%plot(dataSet)
