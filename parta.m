%Part1 a
%**********************************************************************
load ORLfacedata;
X = data([1:10, 301:310],:);
Y = labels([1:10, 301:310]);

%create a cell to store datase
C = [];
%create 50 partitions and store in the cell
for index = 1:50
 %create a partitions
 [Xtr, Xte, Ytr, Yte] = PartitionData(X, Y, 3);
 C{index} = {Xtr, Xte, Ytr, Yte};
end;

%**********************************************************************
%loop through the all datasets to get the K for testing
for indexData = 1:50
 %loop through the testing samples
 for indexTests = 1:14
 %loop through the possible knn
  for tryKs = 1:6
   ks{tryKs} = knearest(tryKs,C{indexData}{1,2}(indexTests,:), C{indexData}{1,1} ,C{indexData}{1,3});
  end;
  distanceK{indexTests} = ks;
 end;
 datasetKTesting{indexData} = distanceK;
end;
%**********************************************************************
%**********************************************************************
%loop through the all datasets to get the K for training
for indexData = 1:50
 %loop through the testing samples
 for indexTests = 1:6
 %loop through the possible knn
  for tryKs = 1:6
   ks{tryKs} = knearest(tryKs,C{indexData}{1,1}(indexTests,:), C{indexData}{1,1} ,C{indexData}{1,3});
  end;
  distanceK{indexTests} = ks;
 end;
 datasetKTraining{indexData} = distanceK;
end;
 %**********************************************************************
 %calculate the accuracies of Testing
correctClassification = 0;
correctClassificationPerDataSet = 0;
for indexK = 1:6
  for indexData = 1:50
    for indexTests = 1:14
      if(datasetKTesting{1, indexData}{1, indexTests}{1, indexK} == C{indexData}{1,4}(indexTests,1))
        correctClassification = correctClassification + 1;
        correctClassificationPerDataSet = correctClassificationPerDataSet + 1;
%      else
%        C{indexData}{1,4}(indexTests,1)
%        datasetKTesting{1, indexData}{1, indexTests}{1, indexK};
      end;
     end;
     AccuracyTestPerDataSet{indexData} = correctClassificationPerDataSet/14;
     correctClassificationPerDataSet = 0;
  end;
  AccuracyInKTesting{indexK} =  correctClassification / 700;
  AccuracyTestPerKDataSet{indexK} = AccuracyTestPerDataSet;
  correctClassification = 0;
end;


%Training accuracies
for indexK = 1:6
  for indexData = 1:50
    for indexTests = 1:6
      if(datasetKTraining{1, indexData}{1, indexTests}{1, indexK} == C{indexData}{1,3}(indexTests,1))
        correctClassification = correctClassification + 1;
        correctClassificationPerDataSet = correctClassificationPerDataSet + 1;
%      else
%        C{indexData}{1,4}(indexTests,1)
%        datasetKTraining{1, indexData}{1, indexTests}{1, indexK};
      end;
     end;
     AccuracyTrainPerDataSet{indexData} = correctClassificationPerDataSet/6;
     correctClassificationPerDataSet = 0;
  end;
  AccuracyInKTraining{indexK} =  correctClassification / 300;
  AccuracyTrainPerKDataSet{indexK} = AccuracyTrainPerDataSet;
  correctClassification = 0;
end;
%**********************************************************************

%Display  errorbar one using the the averaged testing accuracy and the standard deviations
arrayContainingAccuracyForKTrain = [];
standardDeviationTrain = [];
k = 1:1:6;
for index = 1:6
 arrayContainingAccuracyForKTrain = [arrayContainingAccuracyForKTrain, AccuracyInKTraining{index}];
 tempDeviation = std(cell2mat(AccuracyTrainPerKDataSet{1,index}(1,:)));
 standardDeviationTrain = [standardDeviationTrain, tempDeviation];
end;

errorbar(k,arrayContainingAccuracyForKTrain, standardDeviationTrain)


%**********************************************************************

%Display two different errorbar one using the the averaged testing accuracy and the standard deviations
arrayContainingAccuracyForKTesting = [];
standardDeviationTesting = [];

for index = 1:6
 arrayContainingAccuracyForKTesting = [arrayContainingAccuracyForKTesting, AccuracyInKTesting{index}];
 tempDeviation = std(cell2mat(AccuracyTestPerKDataSet{1,index}(1,:)));
 standardDeviationTesting = [standardDeviationTesting, tempDeviation];
end;
figure
errorbar(k,arrayContainingAccuracyForKTesting, standardDeviationTesting, 'g')
%**********************************************************************

%Observe the classification results of the k-NN classifier on different datasets
%get the label by K of the testing examples and training as well
labelExpected = [];
%get expected labels
for indexK = 1:6
  for indexSet = 1:50
    for indexSample = 1:14
      labelExpected = [labelExpected, datasetKTesting{1, 1}{1, indexSample}(indexK)];
    end;
      labelStoreSetTest{indexSet} = labelExpected;
      labelExpected = [];
  end;
  labelStoreSampleByKTest{indexK} = labelStoreSetTest;
end;
%**************************************************************************
%get expected labels from training
for indexK = 1:6
  for indexSet = 1:50
    for indexSample = 1:6
      labelExpected = [labelExpected, datasetKTraining{1, 1}{1, indexSample}(indexK)];
    end;
      labelStoreSetTrain{indexSet} = labelExpected;
      labelExpected = [];
  end;
  labelStoreSampleByKTrain{indexK} = labelStoreSetTrain;
end;
%labelStoreSampleByKTest{1,1}{1,1}
count = 1;
%printing different results set with differents knn
for indexK = 1:6
  for indexSet = 20:20
    figure(count)
    ShowResult(C{indexSet}{1,2},C{indexSet}{1,4},cell2mat(labelStoreSampleByKTest{1,indexK}{1,indexSet}),7)
    count = count + 1;
  end;
end;
%**************************************************************************
