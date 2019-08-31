#!/usr/bin/env python3

import argparse
import os
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--iconsdir", action="store", required=True)
args = vars(parser.parse_args())

icons_dir = args["iconsdir"]

if not os.environ.get('DESTDIR'):
    print('Compiling icon cache ...')
    subprocess.run(['gtk-update-icon-cache', icons_dir])

