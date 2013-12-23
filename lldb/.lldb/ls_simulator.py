#!/usr/bin/python

import lldb
import commands
import os

def ls_simulator_cmd(debugger, command, result, dict):
    app_dir = commands.getoutput('find "%s/Library/Application Support/iPhone Simulator" -type d -name *.app -print0 | xargs -0 ls -td | head -1' % os.environ.get('HOME'))
    shell_cmd = '/bin/ls -alF "%s/%s"' % (app_dir, command)
    shell_result = commands.getoutput(shell_cmd)
    result.PutCString(shell_result)

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand("command script add -f ls_simulator.ls_simulator_cmd lssim")
    print "lssim installed."
