# this file includes all the functions designed for the processing of gowalla dataset
import math
import sys
import getopt
from collections import defaultdict

# datafolder="../../../dataset/gowalla/"
scales=[1.0, 0.1, 0.01, 0.001, 0.0001, 0.00001, 0.000001] #grid scales

def location_coordinates(spot_file):
    PMaps=defaultdict(list)    # stores the geographical coordinates of locations
    fid=open(spot_file, 'r')
    for line in fid:
        data=line.split()
        (pid, lat, lng)=(int(data[0]), float(data[1]), float(data[2])) 
        PMaps[pid]=[lat, lng]
    fid.close()
    return PMaps

def load_historical_checkins(history_file):
    user_checkins=defaultdict(list)
    fid=open(history_file, 'r')
    for line in fid:
        data=line.split()
        (uid, pid, times)=(int(data[0]), int(data[1]), int(data[2]))
        for i in xrange(times):
            user_checkins[uid].append(pid)
    fid.close()
    return user_checkins

def get_user_home_address(dataset_name, datafolder):
    # get the location history of users
    user_history=load_historical_checkins(datafolder + dataset_name + '_training.txt') 
    location_coords=location_coordinates(datafolder + dataset_name + '_POICoords.txt')    
    # compute the home location of users and write to a new csv file
    outf=open(datafolder + dataset_name + '_UserCoords.txt', 'w')
    users=user_history.keys()
    users.sort()
    for user in users:
        locations=user_history[user]
#        print locations, locationcoord[1]
        coords=assign_home_grid(locations, location_coords)
        outf.write(str(user)+' '+str(coords[0])+' '+str(coords[1])+'\n')
        # locations.sort()
        # for pid in locations:
        #     outf.write(str(pid) +":"+str(location_coords[pid][0])+","+str(location_coords[pid][1])+" ")
        # outf.write("\n\n")    
    print "complete users' home location assignment"

# the spots is a list contains the longitude and latitude of a place
def assign_home_grid(spots, PMaps):
    coords, sub_spots=(defaultdict(list), [])
    for spot in spots:
        if spot in PMaps:
            coords['lat'].append(PMaps[spot][0])          
            coords['lng'].append(PMaps[spot][1])            
            sub_spots.append(spot)
    if len(sub_spots)>0:
        grid={"long_min": math.floor(min(coords['lng']))-1, "long_max": math.ceil(max(coords['lng'])) +1, 
                "lati_min": math.floor(min(coords['lat']))-1, "lati_max": math.ceil(max(coords['lat'])) + 1}
        for scale in scales:
            grid, sub_spots=get_sub_grid(sub_spots, PMaps, grid, scale)
        hometown=[(grid["lati_max"]+grid["lati_min"])/2, (grid["long_max"]+grid["long_min"])/2]          
    else:
        hometown=[0.0, 0.0]
    return hometown

def get_sub_grid(spots, PMaps, grid, scale):
    X_num=int(math.ceil((grid["long_max"]-grid["long_min"])/scale))
    Y_num=int(math.ceil((grid["lati_max"]-grid["lati_min"])/scale))
    dist=([0])*X_num*Y_num    
    for spot in spots:
        X_ind=math.floor((PMaps[spot][1]-grid["long_min"])/scale)
        Y_ind=math.floor((PMaps[spot][0]-grid["lati_min"])/scale)
        try:
            ind=int(Y_ind * X_num + X_ind)       
            dist[ind] +=  1
        except:
            dist_len=len(dist)
            print grid, scale
            print X_num, Y_num, X_ind, Y_ind, (Y_ind * X_num + X_ind), dist_len
#            dist[dist_len-1] = dist[dist_len-1] +1
    max_ind= dist.index(max(dist))
    Y_ind=max_ind / X_num
    X_ind=max_ind % X_num

    long_min=round((grid["long_min"] + X_ind * scale), 8)
    long_max=round((grid["long_min"] + (X_ind +1) * scale), 8)
    lati_min=round((grid["lati_min"] + Y_ind * scale), 8)
    lati_max=round((grid["lati_min"] + (Y_ind+1)* scale), 8)
    
    temp_spots=[]
    
    for spot in spots:
        if (long_min<=PMaps[spot][1]<long_max) and (lati_min<=PMaps[spot][0]<lati_max):
            temp_spots.append(spot)
    temp_grid={"long_min": long_min, "long_max": long_max, "lati_min": lati_min, "lati_max": lati_max}
    return temp_grid, temp_spots

def main(argv):
    try:
        opts, args= getopt.getopt(argv, "d:f:", ["dataset=", "folder=",])
    except getopt.error, msg:
        print msg
        sys.exit(2)
    for o, a in opts:
        if o in ('-d', '--dataset'):
            dataset=a
        if o in ('-f', '--folder'):
            datafolder=a
    get_user_home_address(dataset, datafolder)    

if __name__=="__main__":
    main(sys.argv[1:])
    #get_user_home_address('NewYorkSubCheckins_temporal_0.7', '../../datasets/GSSLFM/temporal_partition/')