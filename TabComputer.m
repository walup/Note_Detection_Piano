classdef TabComputer
   
    properties
        
        classifier;
        featureExtractor;
        detail;
        noteFreqs;
    end
    
    
    methods
       
        
       function obj = TabComputer(multiClassifier, detail, windowSize, overlap, windowType, waveletType)
            obj.classifier = multiClassifier;
            obj.featureExtractor = FeatureTableNoteExtractor(windowSize, overlap, windowType, waveletType);
          
            obj.detail = detail;
            obj.noteFreqs = [261.6256, 293.6648,329.6276, 349.2282,391.9954,440, 493.8833, 523.2511];
            
       end
        
       function note = classifyNote(obj,noteSignal, Fs, mu, sd)
          features = obj.featureExtractor.extractFeatures(noteSignal,Fs, obj.detail);
          normalizedFeatures = zeros(size(features, 1), size(features, 2));
          dataCooker = DataPrecook();
          for i = 1:size(normalizedFeatures, 2)
             normalizedFeatures(:,i) = dataCooker.normalizeWithMeanStd(features(:,i), mu(i), sd(i)); 
          end
          
          votes = [];
          for i = 1:size(normalizedFeatures, 1)
             vector = normalizedFeatures(i,:);
             note = obj.classifier.predictClassWithSVM(vector);
             votes = [votes, note];
             %disp(votes);
          end
          note = mode(votes);
       end
       
       
       function [tab, tabToDisplay] = analyzeSong(obj, noteTimeCuts, tArray, signal, Fs, mu, sd)
           
           tab = [];
           tabToDisplay = [];
           nCuts = size(noteTimeCuts, 1);
           for i = 1:nCuts
               cut = noteTimeCuts(i,:);
               cutSignal = cutWithTime(tArray, signal, cut(1), cut(2));
               note = obj.classifyNote(cutSignal, Fs, mu, sd);
               if(i == 1 && cut(1)~=0)
                   tab = [tab; [-1, [0, cut(1)]]];
                   tab = [tab; [double(note),[cut(1), cut(2)]]];
                   disp(tab);
               elseif(cut(1) ~= tab(end,3))
                   tab = [tab; [-1, [tab(end,3), cut(1)]]];
                   tab = [tab; [double(note), [cut(1), cut(2)]]];
               else
                   disp("here")
                   tab = [tab; [double(note), [cut(1), cut(2)]]];
               end
           end
       end
       
       
       function [times,signal] = playTab(obj, tab, Fs, amplitude)
           nIntervals = size(tab, 1);
           signal = [];
           deltaT = 1/Fs;
           for i = 1:nIntervals
               interval = tab(i,:);
               initialTime = interval(2);
               finalTime = interval(3);
               timesInterval = initialTime:deltaT:finalTime;
               note = interval(1);
               if(note == -1)
                  signal = [signal,timesInterval*0]; 
               else
                   frequency = obj.noteFreqs(uint8(note) + 1);
                   signal = [signal, amplitude*sin(2*pi*frequency*timesInterval)];
               end
           end
           times = (0:length(signal) - 1)*deltaT;
       end
        
        
    end
    
    
    
    
    
end