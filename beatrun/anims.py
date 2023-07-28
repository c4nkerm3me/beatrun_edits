import os
import sys
import shutil

files_new = [ file for file in os.listdir("_new") ]
files_old = [ file for file in os.listdir("_old") ]
i = input("Type \"y\" for new animations or \"n\" for old animations to be installed: ")

if i == "y":
	for file in files_new:
		shutil.copy2(file, "gamemodes/beatrun/content/models")
else:
	for file in files_old:
		shutil.copy2(file, "gamemodes/beatrun/content/models")

print("i hate python")
sys.exit(0)