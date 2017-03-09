%to do
% - exclude extreme distance values
% - possible exclude distances by direction of displacement (as direction
%   should be kinda uniform)


mov = VideoReader('W22_1.avi');
frames = size(mov,2);
mycounter = 1;  

figures = [];
startf = 1;
endf = 1000;
myCircles = zeros(20,(endf-startf));
tic
for frame = startf:endf
    thisF = read(mov,frame);
    imwrite(thisF, sprintf('PNGS/Frame%4d.png',frame),'png');
%    figures(frame-startf+1) = figure;
    bw = imread(sprintf('PNGS/Frame%4d.png',frame));
%    imshow(bw)
    
    [centers,radii] = imfindcircles(bw,[15,20],'ObjectPolarity','dark','Sensitivity',0.97);
    myCircles(1:size(centers,1),mycounter:mycounter+1) = centers;
    myCircles(1:size(radii,1),mycounter+2) = radii;
    mycounter = mycounter + 3;
%    i = viscircles(centers,radii);
    if mod(frame,10) == 0
        disp(frame)
    end
end

disp(toc)

%Exclude overlapping circles
for x = 3:3:size(myCircles,2)
    for y = 1:size(myCircles,1)
       value = [myCircles(y,x-2),myCircles(y,x-1),myCircles(y,x)];
       
        for i = 1:size(myCircles,1)
            value2 = [myCircles(i,x-2),myCircles(i,x-1),myCircles(i,x)];
            if (~(isequal(value2,value)) && ~(isequal(value2,[0,0,0])))
                dist = sqrt((value(1)-value2(1))^2 + (value(2)-value2(2))^2);
                radiiSum = value(3) + value2(3);
                if (dist<radiiSum)
                    midpoint = [ (value(1)+value2(1))/2 , (value(2)+value2(2))/2, radiiSum/2];
                    myCircles(y,x-2:x) = [0,0,0];
                    myCircles(i,x-2:x) = midpoint;
                    
                end
            end
        end

    end 
end

dist = zeros(size(myCircles,1),size(myCircles,2)/3);
angles = zeros(size(myCircles,1),size(myCircles,2)/3);
normalize = zeros(size(myCircles,1),size(myCircles,2)/3);
indicies = zeros(size(myCircles,1),size(myCircles,2)/3);
for x = 4:3:size(myCircles,2)
    for y = 1:size(myCircles,1)
        value = [myCircles(y,x),myCircles(y,x+1)];
        if(value ~= [0,0])
            [index,thisDist,angle] = findClosest(value,myCircles(1:size(myCircles,1),x-3:x-2));
            dist(y,(x-1)/3) = thisDist;
            if(~isnan(angle))
                angles(y,(x-1)/3) = angle;
            else
                angles(y,(x-1)/3) = 0;
            end
            if (index~=-1)
                closest = myCircles(index,x-3:x-2);
                midpoint = [(closest(1)+value(1))/2,(closest(2)+value(2))/2];
                normalize(y,(x-1)/3) = sqrt(midpoint(1)^2+midpoint(2)^2);
                indicies(y,(x-1)/3) = index;
            else
                disp(x)
                disp(y)
                disp(thisDist)
                disp(angle)
                disp(index)
                
            end
            if thisDist == 0
                disp(x)
                disp(y)
                disp(thisDist)
                disp(angle)
                disp(index)
            end
            
        end
    end
end

distPruned = dist;
%remove outliers
%1. based on # (DONE)
%2. based on angle and dist and radii (med+xsd)

for c = 4:3:size(myCircles,2)
    index2 = size(myCircles,1);
    for x = size(myCircles,1):-1:1
        if myCircles(x,c) ~= 0
            index2 = x;
            break;
        end
    end
    
    index1 = size(myCircles,1);
    for x = size(myCircles,1):-1:1
        if myCircles(x,c-3) ~= 0
            index1 = x;
            break;
        end
    end
    
    if index2>index1    
        for each = 1:(index2-index1)
            [maxv, maxi] = max(distPruned(1:size(distPruned,1),(c-1)/3));
            distPruned(maxi,(c-1)/3) = 0;
        end
    end
    
end

finalValues = zeros(size(myCircles,1),size(myCircles,2)/3);
finalValuesMean = zeros(1,size(myCircles,2)/3);
for c = 1:size(distPruned,2)
    counter = 0;
    for r = 1:size(distPruned,1)
        if distPruned(r,c) ~= 0 || normalize(r,c)~=0
            finalValues(r,c) = distPruned(r,c)/normalize(r,c);
            counter = counter + 1;
        end
    end
    
    finalValuesMean(c) = sum(finalValues(1:size(distPruned,1),c))/counter;
    
end

%attempt to calculate speed
speed = zeros(size(finalValuesMean,2)/5);
for each = 5:5:size(finalValuesMean,2)
    speed(each/5) = mean(finalValuesMean(each-4:each));
end

%print our results
figure
plot(finalValuesMean)
figure
plot(speed)
