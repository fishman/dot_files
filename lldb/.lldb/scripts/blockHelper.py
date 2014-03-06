#!/usr/bin/env python

import lldb
import commands

def pbyref(debugger, command, result, internal_dict):
    cmd = "expr (void)printf(\"%s\",(const char*)_Block_byref_dump((char*)&" + \
    command + "- 2*sizeof(int) - 2*sizeof(void *)));"
    debugger.HandleCommand(cmd)

def pblock(debugger, command, result, internal_dict):
    cmd = "expr (void)printf(\"%s\",(const char*)_Block_dump(" + command + "));"
    debugger.HandleCommand(cmd)

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f blockHelper.pbyref pbyref')
    debugger.HandleCommand('command script add -f blockHelper.pblock pblock')
    print 'The "pbyref" command has been installed and is ready to use.'
    print 'The "pblock" command has been installed and is ready to use.'
