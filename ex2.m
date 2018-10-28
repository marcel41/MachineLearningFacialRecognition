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

%**************************************************************************
