classdef DataPrecook
    
    methods
        %Normalizamos los datos del vector x
        function y = normalize(obj,x) 
            n = length(x);
            y = zeros(n,1);
            %Obtenemos la media y desviación estandar
            mu = mean(x);
            sd = std(x);
            for i = 1:n
                if(sd ~= 0)
                    y(i) = (x(i)-mu)/sd;
                end
            end
        end 
        
        function y = normalizeWithMeanStd(obj,x, mu, sd) 
            n = length(x);
            y = zeros(n,1);
            %Obtenemos la media y desviación estandar
            for i = 1:n
                if(sd ~= 0)
                    y(i) = (x(i)-mu)/sd;
                end
            end
        end 
        
        
        function [trainingSet, trainingSetResults, validationSet, validationSetResults] = splitData(obj,X,Y,validationPercentage)
            colSize = size(X,1);
            newIndexes = randperm(colSize);
            shuffledX = X(newIndexes, :);
            shuffledY = Y(newIndexes, :);
            
            cutIndex = floor((1-validationPercentage)*colSize);
            trainingSet = shuffledX(1:cutIndex, :);
            trainingSetResults = shuffledY(1:cutIndex, :);
            validationSet = shuffledX(cutIndex+1:end, :);
            validationSetResults = shuffledY(cutIndex + 1:end, :);
        end
        
         function [newX, newY] = balanceData(obj, X, Y)
            nData = size(X, 1);
            nFeatures = size(X, 2);
            labelsArray = unique(Y);
            labelCounts = histc(Y, labelsArray);
            minCount = Inf;
            for i = 1:length(labelCounts)
                if(labelCounts(i)<minCount)
                    minCount = labelCounts(i);
                end
            end
            
            newX = zeros(minCount*length(labelsArray), nFeatures);
            newY = zeros(minCount*length(labelsArray), 1);
            
            [sortedY,idsSorted] = sort(Y);
            sortedX = X(idsSorted, :);
            classCounter = 0;
            dataCounter = 1;
            for i = 1:nData
                if(classCounter <= minCount)
                    currentClass = sortedY(i);
                    newY(dataCounter) = currentClass;
                    newX(dataCounter, :) = sortedX(i,:);
                    classCounter = classCounter +1;
                    dataCounter = dataCounter + 1;
                else
                    if(currentClass ~= sortedY(i))
                        classCounter = 1;
                        currentClass = sortedY(i);
                        newY(dataCounter) = currentClass;
                        newX(dataCounter, :) = sortedX(i,:);
                        classCounter = classCounter + 1;
                        dataCounter = dataCounter + 1;
                    end
                end
            end
        end
        
    end
    
    
    
end