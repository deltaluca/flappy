# Inland, Sea, Coast, Bi-coast
# Write a function that pulls out long words from file and replaces with TLA


def getNames(filename):
  f = open(filename,'r')
  n = f.readlines()
  n = map(str.rstrip, n)
  n = map(lambda x: x.split(','), n)
  names = [(x[0],x[1]) for x in n if len(x)>1]
  return dict(names)

def flipDict(dictionary):
  return dict(zip(dictionary.values(),dictionary.keys()))

def my_import(filename):
  f = open(filename,'r')
  p = f.readlines()
  p = map(str.rstrip,p)
  p = map(lambda x: x.split(';'),p)
  p = map(lambda y: map(lambda x: x.split(','),y), p)
  return p

def write_provinces(provinces, outfilename, modify=(lambda x: x)): 
  outfile = open(outfilename,'w')
  for province in provinces:
    if len(province) == 1: #is a seperator
      outfile.write(province[0][0] + '\n')
      continue

    outfile.write(province[0][0] + ';')
    lands = ""
    for i in range(len(province[1])):
      if province[1][i] == '': continue
      lands += modify(province[1][i])
      if i < len(province[1])-1: lands += ','
    outfile.write(lands + ';')
    waters = ""
    for i in range(len(province[2])):
      if province[2][i] == '': continue
      waters += modify(province[2][i])
      if i < len(province[2])-1: waters += ','
    outfile.write(waters)
    outfile.write('\n')
  
  outfile.close()
