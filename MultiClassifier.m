classdef MultiClassifier
   properties
      trainingData;
      trainingDataResults;
      validationData;
      validationDataResults;
      svmClassifier;
      treeClassifier;
      neuralNetworkClassifier;
   end
   
   
   
   methods 
       
       function obj = MultiClassifier(trainingData, trainingDataResults, validationData, validationDataResults)
          obj.trainingData = trainingData;
          obj.trainingDataResults = trainingDataResults;
          obj.validationData = validationData;
          obj.validationDataResults = validationDataResults;
       end
       
       
       function obj = trainSVMClassifier(obj)
           t = templateSVM('Standardize', true,'KernelFunction','gaussian');
           obj.svmClassifier = fitcecoc(obj.trainingData,obj.trainingDataResults, 'Learners',t); 
       end
       
       function class = predictClassWithSVM(obj, vector)
          class = predict(obj.svmClassifier, vector); 
       end
       
       function acc = computeSVMClassifierAccuracy(obj, class)
           nValidationData = size(obj.validationData, 1);
           truePos = 0;
           falsePos = 0;
           trueNeg = 0;
           falseNeg = 0;
           for i = 1:nValidationData
               vector = obj.validationData(i,:);
               trueClass = obj.validationDataResults(i);
               predictedClass = predict(obj.svmClassifier, vector);
               if(predictedClass == trueClass && trueClass == class)
                  truePos = truePos + 1; 
               elseif(predictedClass ~= trueClass && trueClass == class)
                  falseNeg = falseNeg + 1;
               elseif(predictedClass ~= trueClass && trueClass ~= class)
                   trueNeg = trueNeg + 1;
               elseif(predictedClass == class && trueClass ~= class)
                   falsePos = falsePos + 1;
               end
           end
           
           accCalculator = AccuracyCalculator();
           acc = accCalculator.computeAccuracy(truePos, falseNeg, trueNeg, falsePos);
       end
       
       function obj = trainForestClassifier(obj, nTrees)
           tTree = templateTree('surrogate','on');
           tEnsemble = templateEnsemble('GentleBoost',nTrees,tTree);
           obj.treeClassifier = fitcecoc(obj.trainingData,obj.trainingDataResults, 'Learners',tEnsemble); 
       end
       
       function class = predictClassWithForest(obj, vector)
          class = predict(obj.treeClassifier, vector); 
       end
       
       function acc = computeForestClassifierAccuracy(obj, class)
           nValidationData = size(obj.validationData, 1);
           truePos = 0;
           falsePos = 0;
           trueNeg = 0;
           falseNeg = 0;
           for i = 1:nValidationData
               vector = obj.validationData(i,:);
               trueClass = obj.validationDataResults(i);
               predictedClass = predict(obj.treeClassifier, vector);
               if(predictedClass == trueClass && trueClass == class)
                  truePos = truePos + 1; 
               elseif(predictedClass ~= trueClass && trueClass == class)
                  falseNeg = falseNeg + 1;
               elseif(predictedClass ~= trueClass && trueClass ~= class)
                   trueNeg = trueNeg + 1;
               elseif(predictedClass == class && trueClass ~= class)
                   falsePos = falsePos + 1;
               end
           end
           
           accCalculator = AccuracyCalculator();
           acc = accCalculator.computeAccuracy(truePos, falseNeg, trueNeg, falsePos);
       end
       
   end
   
end