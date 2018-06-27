# this file aims to find the N nearest neighboors of eavery location

import math
import operator
import getopt, sys
from collections import defaultdict
import numpy
import pp

server_num=24
ppservers=()
job_server=pp.Server(server_num, ppservers=ppservers)
print "Starting pp with", job_server.get_ncpus(), "workers"

def import_location_coordinates(location_file):
    inf=open(location_file, "r")
    locations=defaultdict(list)
    for line in inf:
        pid, lat, lng=line.split()
        locations[int(pid)]=[float(lat), float(lng)]
    print "completing loading the location coordinates, %s locations in the dataset" %len(locations.keys())
    return locations

def geo_dist_computing(coordinates1, coordinates2):
    delta_lat=((coordinates1[0]-coordinates2[0])/180)*math.pi
    delat_lng=((coordinates1[1]-coordinates2[1])/180)*math.pi
    lat1=(coordinates1[0]/180)*math.pi
    lat2=(coordinates2[0]/180)*math.pi
    #a=math.sin(delta_lat/2)*math.sin(delta_lat/2) + math.sin(delat_lng/2)*math.sin(delat_lng/2)*math.cos(lat1)*math.cos(lat2)
    a = (math.sin(delta_lat/2))**2 + ((math.sin(delat_lng/2))**)*math.cos(lat1)*math.cos(lat2)
    
    return 2*math.atan2(math.sqrt(a), math.sqrt(1-a))*6371

def individual_geo_NN(pid, locations, flag, K):
    geodist, geoNNs=([], [])
    for pid1 in locations.keys():
        dist=geo_dist_computing(locations[pid], locations[pid1])
        geodist.append((pid1, dist))
    sorted_dis=sorted(geodist, key=operator.itemgetter(1))
    if flag=="number":
        geoNNs=sorted_dis[1:(int(K)+1)]
    elif flag=="distance":
        for inx, val in sorted_dis:
            if val < K:
                geoNNs.append((inx, val))
            else:
                break
    return geoNNs

def geo_nearest_neighboors_new(locations, flag, K):
    geo_nns=defaultdict(list)
    pids=locations.keys()

    steps= len(pids)/server_num
    print "total steps: %s" %steps

    for i in xrange(steps):
        subpids=pids[i*server_num : (i+1)*server_num]
        jobs=[(pid,job_server.submit(individual_geo_NN, (pid, locations, flag, K,), (geo_dist_computing, ), ("math", "operator",))) for pid in subpids]
        for pid, job in jobs:
            geo_nns[pid]=job()
#            print uid, type(sim[uid]), len(sim[uid]
        if i>0 and i%10==0:
            print i
        else:
            print i,
    subpids=pids[steps*server_num : len(pids)]
    jobs=[(pid,job_server.submit(individual_geo_NN, (pid, locations, flag, K,), (geo_dist_computing, ), ("math", "operator",))) for pid in subpids]
    
    for pid, job in jobs:
        geo_nns[pid]=job()

    return geo_nns
def geo_nearest_neighboors(locations, flag, K):	
    pids=locations.keys()
    pids.sort()
    geo_dist=numpy.zeros((len(pids), len(pids)))
    # geo_dist=coo_matrix((len(pids), len(pids)))
    
    for i in xrange(len(pids)):
        for j in range(i+1, len(pids)):
            pid1, pid2=(pids[i], pids[j])
            # if pid1 < pid2:
            geo_dist[i][j]=geo_dist_computing(locations[pid1], locations[pid2])
            # elif pid1> pid2:
                # geo_dist[pid2][pid1]=geo_dist_computing(locations[pid1], locations[pid2])
    geo_nns=defaultdict(list)
    
    print "complete computing the geo distance between users"
    for i in xrange(len(pids)):
        temp=[]
        for j in xrange(len(pids)):
            pid1, pid2=(pids[i], pids[j])
            if pid1 < pid2:
                temp.append((pid2, geo_dist[i][j]))
            elif pid1 > pid2:
                temp.append((pid2, geo_dist[j][i]))

        sorted_dis=sorted(temp, key=operator.itemgetter(1))

        if flag=="number":
            geo_nns[pid1]=sorted_dis[0:int(K)]
        elif flag=="distance":
            for inx, val in sorted_dis:
                if val < K:
                    geo_nns[pid1].append((inx, val))
                else:
                    break
    return geo_nns

def import_historical_checkins(checkin_file):
    inf=open(checkin_file, "r")
    locations=defaultdict(list)
    for line in inf:
        data=line.split()
        locations[int(data[1])].append(int(data[0]))
    print "complete loading the historical checkins"
    return locations
 
def checkin_similarity(checkins1, checkins2):
    interset=set(checkins1).intersection(set(checkins2))
    unionset=set(checkins1).union(set(checkins2))
    if len(unionset)>0:
        sim=float(len(interset))/float(len(unionset))
    else:
        sim=0.0
    return sim

def checkin_nearest_neighbors(locations, K):
    sim=defaultdict(dict)
    pids=locations.keys()
    pid_num=len(pids)
    for i in xrange(pid_num):
        for j in range(i+1, pid_num):
            pid1, pid2=(pids[i], pids[j])
            similarity=checkin_similarity(locations[pid1], locations[pid2])
            if pid1 < pid2:
                sim[pid1][pid2]=similarity
            elif pid1 > pid2:
                sim[pid2][pid1]=similarity
    print "complete compute the checkin similarity between locations"
    pidNN=defaultdict(list)

    for pid1 in pids:
        temp=[]
        for pid2 in pids:
            if pid1 < pid2:
                temp.append((pid2, sim[pid1][pid2]))
            elif pid1>pid2:
                temp.append((pid2, sim[pid2][pid1]))
        sorted_dis=sorted(temp, key=operator.itemgetter(1))
        sorted_dis.reverse()

        pidNN[pid1]=sorted_dis[0:int(K)]
        print pidNN[pid1]
    return pidNN

def main(argv):
    try:
    	opts, args= getopt.getopt(argv, "dfit", ["dataset=", "folder=", "index=", "threshold=",])
    except getopt.error, msg:
        print msg
        sys.exit(2)
    for o, a in opts:
        if o in ("-d", "--dataset"):
            dataset=a
        if o in ("-f", "--folder"):
            folder=a
        if o in ("-i", "--index"):
        	index=a
        if o in ("-t", "--threshold"):
            th=float(a)
    pidCoords=import_location_coordinates(folder+dataset+"_POICoords.txt")
    # geo_NN=geo_nearest_neighboors(pidCoords, index, th)
    geo_NN=geo_nearest_neighboors_new(pidCoords, index, th)

    #pidUsers=import_historical_checkins(folder+dataset+"_training.txt")
    #pidNN=checkin_nearest_neighbors(pidUsers, th)

    #output the topk for each location
    outf1=open(folder+dataset+"_GeoNN.txt", "w")
    pids=geo_NN.keys()
    pids.sort()

    for pid in pids:
        outf1.write(str(pid))
        for inx, val in geo_NN[pid]:
            #outf1.write(str(pid) + " " + str(inx)+" "+str(val) + "\n")
            outf1.write(" " + str(inx))
        outf1.write("\n")
    outf1.close()

    #outf2=open(folder+dataset+"_NN.txt", "w")
    #pids=pidNN.keys()
    #pids.sort()

    #for pid in pids:
    #    #vals=[val for inx, val in pidNN[pid]]
    #    for inx, val in pidNN[pid]:
    #        outf2.write(str(pid) + " " + str(inx)+" "+str(val) +"\n")
    #outf2.close()

if __name__=="__main__":
	main(sys.argv[1:])
