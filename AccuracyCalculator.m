classdef AccuracyCalculator
   methods
       
       function acc = computeAccuracy(obj, truePositives, falseNegatives, trueNegatives, falsePositives)
           acc = (truePositives + trueNegatives)/(truePositives + falseNegatives + trueNegatives + falsePositives);
       end
       
       
   end
    
    
    
end