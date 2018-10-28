%Part1 b
%**********************************************************************
clc
clear all

load ORLfacedata;

X = data([1:1:400],:);
Y = labels([1:1:400]);
accuracyWholeSet = [];
accuracyWholeSetN = [];
accuracyOfAllN = 0;
accuracyOfAll = 0;
accuracyMultiPerSet = [];
accuracyPerSubjectMultiClassifier = [];
accuracyMultiClassifier = 0;
ignoreResult = 0;
predictedLabelSample = 0;
predictedLabelPerSet = 0;
per1Sample = [];
result = [];
SK = [];
resultPerSamples = [];
resultPerSet = [];
%pick up one subset of the one of the dataset to use LOOC
%we will evaluate Xtr from dataset 1
accuracyTesting = 0;
accuracyTestingPerSet = [];
accuracy = 0;
accuracyPerSubject = 0;
inAccuracyPerSubject = 0;
knnAccuracy = [];
precisionPerSubject = [];
precisionPerSet = [];
for indexSet = 1:50
  [Xtr, Xte, Ytr, Yte] = PartitionData(X, Y, 5);
  if(indexSet == 1)
    for indexK = 1:5
      for indexToBeTest = 1:200
        trainingWithOutOneSample = Xtr;
        labelWithOutOneLabel = Ytr;
        trainingWithOutOneSample(indexToBeTest, :) = [];
        labelWithOutOneLabel(indexToBeTest) = [];
        if(Ytr(indexToBeTest) == knearest(indexK, Xtr(indexToBeTest,:), trainingWithOutOneSample ,labelWithOutOneLabel))
          accuracy = accuracy + 1;
        end;
      end;
      knnAccuracy = [knnAccuracy, accuracy/200];
      accuracy = 0;
    end;
  end;
  %after cheking the accuracies 1k is the best for the modelling
  for indexSamples = 1:200
      if(Yte(indexSamples) == knearest(1, Xte(indexSamples,:), Xtr ,Ytr))
        accuracyTesting = accuracyTesting + 1;
      end;
  end;
  accuracyTestingPerSet = [accuracyTestingPerSet; accuracyTesting/200];
  accuracyTesting = 0;
  %average precisionPerEach Subject
    for indexSamples = 1:200
      if(Yte(indexSamples) == knearest(1, Xte(indexSamples,:), Xtr ,Ytr))
        accuracyPerSubject = accuracyPerSubject + 1;
        accuracyOfAllN = accuracyOfAllN + 1;
      end;
      if(mod(indexSamples,5) == 0)
        precisionPerSubject = [precisionPerSubject, accuracyPerSubject/5];
        accuracyPerSubject = 0;
      end;
    end;
    precisionPerSet = [precisionPerSet; precisionPerSubject];
    accuracyWholeSetN = [accuracyWholeSetN, accuracyOfAllN/200];
    accuracyOfAllN = 0;
    precisionPerSubject = [];
  %part2b creating a multi binary classifier
  %create an array of zeros to stores the labels
  matrixOfLabels = zeros(200,40);
  subject = 1;
  for labels = 1:200
    matrixOfLabels(labels,subject) = 1;
    if(mod(labels, 5) == 0)
      subject = subject + 1;
    end;
  end;
 for indexSample = 1:200
  XtrainingWith1Column = [ones(size(Xtr,1),1),Xtr];
  w = pinv(XtrainingWith1Column) * matrixOfLabels;
  XtestingWith1Column = [ones(size(Xte,1),1),Xte];
  result = [result, XtestingWith1Column(indexSample,:) * w ];
    %for index = 1:1025
    %end;
    [ignoreResult, predictedLabelSample] = max(result);
    %per1Sample = [per1Sample; predictedLabelSample];
    result = [];
    if(Yte(indexSample) == predictedLabelSample)
    accuracyMultiClassifier = accuracyMultiClassifier + 1;
    accuracyOfAll = accuracyOfAll + 1;
    end;
    if(mod(indexSample,5) == 0)
      accuracyPerSubjectMultiClassifier = [accuracyPerSubjectMultiClassifier, accuracyMultiClassifier/5];
      accuracyMultiClassifier = 0;
    end;
  %predictedLabelPerSet = [resultPerSamples];
  %resultPerSamples = [];
 end;
 accuracyMultiPerSet = [accuracyMultiPerSet; accuracyPerSubjectMultiClassifier];
 accuracyPerSubjectMultiClassifier = [];
 accuracyWholeSet = [accuracyWholeSet, accuracyOfAll/200];
 accuracyOfAll = 0;

end;
averageTestingAccuracy = sum(accuracyTestingPerSet)/50;
standardDeviationTesting = std(accuracyTestingPerSet);
precisionAverageKnn = sum(precisionPerSet)/50;
precisionAverageBinary = sum(accuracyMultiPerSet)/50;
dataSets = [1:1:50];
dataSamples = [1:1:40];
figure()
plot(dataSets, accuracyWholeSet, 'g')
hold on
plot(dataSets, accuracyWholeSetN, 'r')
xlabel('dataSets');
ylabel('Accuracy');
title('AccuracyknnVSbinaryClassifier');
hold off
figure()
plot(dataSamples, precisionAverageKnn, 'r')
hold on
plot(dataSamples, precisionAverageBinary , 'g')
xlabel('Samples');
ylabel('Preccission');
title('PrecissionknnVSbinaryClassifier');
hold off
