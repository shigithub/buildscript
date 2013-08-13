from filecmp import dircmp
import os, sys, shutil, os.path

FILE_REMOVED = 'D'
FILE_ADDED = 'A'
FILE_MODIFIED = 'M';



def parseDiff(srcDir, dstDir) :

	print 'Checking for differences...'
	
	resList = []
	parseDiff_(dircmp(srcDir, dstDir), srcDir, dstDir, resList)
	
	print 'Differences parsed.'
	
	return resList

def createEntry(status, dir, file):
	if(dir == '.') :
		path = file
	else:
		path = dir + '\\' + file
	
	return (status, path)
		
				
			
	
def parseDiff_(dcmp, srcDir, dstDir, resList):

	for name in dcmp.right_only:
		resList.append(createEntry(FILE_ADDED, os.path.relpath(dcmp.right, dstDir), name))

	for name in dcmp.left_only:		
		resList.append(createEntry(FILE_REMOVED, os.path.relpath(dcmp.left, srcDir), name))
		
	for name in dcmp.diff_files:	
		resList.append(createEntry(FILE_MODIFIED, os.path.relpath(dcmp.right, dstDir), name))
		   
	for sub_dcmp in dcmp.subdirs.values():
		parseDiff_(sub_dcmp, srcDir, dstDir, resList)


def prepareDir(resDir):
	if not os.path.exists(resDir):
		os.makedirs(resDir)

		
def createDiff(resDir, srcDir, dstDir, log) :

	print 'Creating diff...'

	def copy(op, path) :
		fullPath = resDir +  '\\_files\\' + path
		baseDir = os.path.dirname(fullPath)
		if not os.path.exists(baseDir):
			os.makedirs(baseDir)	
			
		isFromDest = True if op in [FILE_ADDED, FILE_MODIFIED] else False
		resource = (dstDir if isFromDest else srcDir) + '\\' + path
		copyFunc = shutil.copy if not os.path.isdir(resource) else shutil.copytree
		copyFunc(resource, fullPath)
	
	for item in log:
		op = item[0]
		path = item[1]			
		copy(op, path)
	
	print 'Diff created.'

def createDiffLog(resDir, log):
	
	print 'Creating diff log...'
	
	f = open(resDir + '\\changes.log', 'w+')
	
	for item in log:
		op = item[0]
		path = item[1]
		writeLine = "{0}: {1}\r\n".format(op, path)
		f.write(writeLine)
		
	f.close()
	print 'Diff log created.'				

#--------------------- MAIN -----------------------		

srcDir = sys.argv[1]
dstDir = sys.argv[2]
resDir = sys.argv[3]
resList = parseDiff(srcDir, dstDir)
prepareDir(resDir)
createDiff(resDir, srcDir, dstDir, resList)
createDiffLog(resDir, resList)

