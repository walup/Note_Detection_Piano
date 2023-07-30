classdef FeatureTableNoteExtractor
   properties
       wSize; 
       overlap;
       windowType;
       waveletType;
       S;
   end
    
    
    
    
   %Quiero tener tres versiones de esto, la primera simplementa se va a basar en
   %una inmersión del espectrograma
   
   methods
       
       function obj = FeatureTableNoteExtractor(wSize, overlap, windowType, waveletType)
           %Tamaño ventana 
           obj.wSize = wSize;
           obj.overlap = overlap;
           obj.windowType = windowType;
           obj.waveletType = waveletType;
           
       end
       
       
       function featuresTable = extractFeatures(obj, signal, Fs, detail)
           deltaT = 1/Fs;
           tArray = (0:length(signal) - 1)*deltaT;
           sdftCalculator = SDFTCalculator();
           %Obtenemos la transformadad de tiempo corto (espectrograma)
           [~, freqs, sdft] = sdftCalculator.computeSDFT(signal, tArray, obj.windowType, obj.wSize, obj.overlap);
           halfIndex = floor(length(freqs)/2);
           freqs = freqs(1:halfIndex);
           %Obtenemos las descomposiciones Wavelet
           dwtCalculator = DiscreteWaveletTransform();
           [details, base] = dwtCalculator.computeDWTNoSampling(obj.waveletType, signal', detail);
           
           sdft = abs(sdft);
           cols = size(sdft,2);
           waveletFreqs = {};
           waveletSDFT = {};
           nFeatures = detail + 2;
           for j = 1:detail
              d = details{j}(1:length(tArray));
              [~,detFreq,sdftDet] = sdftCalculator.computeSDFT(d', tArray, obj.windowType, obj.wSize, obj.overlap);
              detFreq = detFreq(1:halfIndex);
              sdftDet = abs(sdftDet);
              waveletSDFT{j} = sdftDet;
              waveletFreqs{j} = detFreq;
           end
           
           [~,baseFreqs,baseSDFT] = sdftCalculator.computeSDFT(base(1:length(tArray))', tArray, obj.windowType, obj.wSize, obj.overlap);
           waveletFreqs{detail +1} = baseFreqs(1:halfIndex);
           waveletSDFT{detail + 1} = abs(baseSDFT);
           
           featuresTable = [];
           
           for i = 1:cols
               featuresVector = [];
               spectrum = sdft(:,i);
               spectrum = spectrum(1:halfIndex);
               if(sum(spectrum) ~= 0)
                    spectrum = spectrum/sum(spectrum);
                    avgFreq = sum(spectrum'.*freqs);
                    featuresVector = [featuresVector, avgFreq];
               end
               for j = 1:detail
                  sdftDet = waveletSDFT{j};
                  sdftDetFreqs = waveletFreqs{j};
                  specDet = sdftDet(:,i);
                  specDet = specDet(1:halfIndex);
                  if(sum(specDet) ~= 0)
                      specDet = specDet/sum(specDet);
                      featuresVector = [featuresVector, sum(specDet'.*sdftDetFreqs)];
                  end
                  %featuresVector = [featuresVector, mean(details{j})];
                  %featuresVector = [featuresVector, std(details{j})];
               end
               baseFreqs = waveletFreqs{detail+1};
               sdftBase = waveletSDFT{detail + 1};
               
               baseSpectrum = sdftBase(:,i);
               baseSpectrum = baseSpectrum(1:halfIndex);
               if(sum(baseSpectrum)~= 0)
                   baseSpectrum = baseSpectrum/sum(baseSpectrum);
                   featuresVector = [featuresVector, sum(baseFreqs.*baseSpectrum')];
               end
               %featuresVector = [featuresVector, mean(base)];
               %featuresVector = [featuresVector, std(base)];
               if(length(featuresVector) == nFeatures)
                   featuresTable = [featuresTable; featuresVector];
               end
           end
       end
       
       
   end
    
    
    
    
    
end