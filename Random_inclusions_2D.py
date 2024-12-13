from part import *
from material import *
from section import *
from assembly import *
from step import *
from interaction import *
from load import *
from mesh import *
from optimization import *
from job import *
from sketch import *
from visualization import *
from connectorBehavior import *
import random
from array import *
import math
import numpy as np
import os        
import shutil    

dis=np.zeros(1000)

targetporosity=0.09
targetporesize=1.4
totalPorearea = 61.5
numberOfPores = 10
Max_iterations=11   

for q in range (1,Max_iterations):
    
    mdb.Model(modelType=STANDARD_EXPLICIT, name='Model-%d' %(q))
    

    mdb.models['Model-%d' %(q)].ConstrainedSketch(name='__profile__', sheetSize=20.0)
    mdb.models['Model-%d' %(q)].sketches['__profile__'].rectangle(point1=(0, 0), 
        point2=(20, 20))
    mdb.models['Model-%d' %(q)].Part(dimensionality=TWO_D_PLANAR, name='Part-1', type=
        DEFORMABLE_BODY)
    mdb.models['Model-%d' %(q)].parts['Part-1'].BaseShell(sketch=
        mdb.models['Model-%d' %(q)].sketches['__profile__'])
    del mdb.models['Model-%d' %(q)].sketches['__profile__']
    mdb.models['Model-%d' %(q)].ConstrainedSketch(gridSpacing=1.8, name='__profile__', 
        sheetSize=20, transform=
        mdb.models['Model-%d' %(q)].parts['Part-1'].MakeSketchTransform(
        sketchPlane=mdb.models['Model-%d' %(q)].parts['Part-1'].faces[0], 
        sketchPlaneSide=SIDE1, sketchOrientation=RIGHT, origin=(0.0, 0.0, 0.0)))
    mdb.models['Model-%d' %(q)].parts['Part-1'].projectReferencesOntoSketch(filter=
        COPLANAR_EDGES, sketch=mdb.models['Model-%d' %(q)].sketches['__profile__'])

    num_incl = 0
    x_coordinate = []
    y_coordinate = []
    rad = [] 
    nx = 20
    ny = 20
    domain = np.zeros((nx, ny))

    while np.sum(domain) / domain.size < targetporosity:
        currentAveragePoreSize = 0 
        if numberOfPores > 0: 
            currentAveragePoreSize = (1/pi) * (totalPorearea / numberOfPores)**(1/2)
        
        growthSize = max(1, int(targetporesize - currentAveragePoreSize + 1)) 

        seedX= int(random.uniform(1, 21)) 
        seedY= int(random.uniform(1, 21)) 

        if domain[seedX - 1, seedY - 1] == 0:
            newPoreVolume = 0
            for x in range(max(1, seedX - growthSize), min(nx, seedX + growthSize) + 1):
                for y in range(max(1, seedY - growthSize), min(ny, seedY + growthSize) + 1):
                    if math.sqrt((x - seedX) ** 2 + (y - seedY) ** 2) <= growthSize:
                        if domain[x-1, y-1] == 0:  # Only if it's solid (indexing adjusted for Python's 0-based index)
                           domain[x-1, y-1] = 1
                           radius = int(random.uniform(1,6))
                           newPoreVolume += (pi) * (radius)**(2)
                           x_coordinate.append(seedX)
                           y_coordinate.append(seedY)
                           rad.append(radius)
            if newPoreVolume > 0:
                totalPorearea += newPoreVolume
                numberOfPores += 1

    for i in range(numberOfPores):    
        mdb.models['Model-%d' %(q)].sketches['__profile__'].CircleByCenterPerimeter(center=(
            x_coordinate[i], y_coordinate[i]), point1=((x_coordinate[i]-rad[i]), y_coordinate[i]))

        mdb.models['Model-%d' %(q)].parts['Part-1'].PartitionFaceBySketch(faces=
            mdb.models['Model-%d' %(q)].parts['Part-1'].faces.findAt(((9.9, 
            9.9, 0.0), (0.0, 0.0, 1.0)), ), sketch=mdb.models['Model-%d' %(q)].sketches['__profile__'])


