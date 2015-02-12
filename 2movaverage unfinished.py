datafile=open ('C:/Users/Stefan Mallia/Bachelor of Commerce/Bachelor of Commerce Year 4/Semester 2/Dissertation/Matlab Code/Finished algorithms/Finished algorithms/Movingaverage/2 parameters/EURUSD_hour.csv', 'r')
data=[]
for row in datafile:
    data.append(row.strip().split(','))
