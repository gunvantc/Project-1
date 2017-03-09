function [closest,minDist,minAngle] = findClosest(values,lists)
closest = -1;
minDist = 99999.0;
minAngle = 0;
for i = 1:size(lists,1)
    listVal = lists(i,1:2);
    if listVal ~= [0,0]
        dist = sqrt((values(1)-listVal(1))^2 + (values(2)-listVal(2))^2);
        if dist<minDist
            minDist = dist;
            closest = i;
            minAngle = atan((values(2)-listVal(2))/(values(1)-listVal(1)));
        end
    end
    
end
