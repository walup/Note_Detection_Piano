function cutArray = cutWithTime(tArray, xArray, initialTime, finalTime)
n = length(tArray);
epsilon = 0.001;
initialIndex = -1;
finalIndex = -1;
for i=1:n
    tValue = tArray(i);
    if(tValue > initialTime - epsilon && tValue < initialTime + epsilon)
       initialIndex = i;
    end
    
    if(tValue >finalTime - epsilon && tValue < finalTime + epsilon)
        finalIndex = i;
        break;
    end
end

cutArray = xArray(initialIndex:finalIndex);
end