#!/usr/bin/python

#command script import ~/git/lldb_scripts/frame_utils.py
#script reload(frame_utils)
#script help(lldb.SBFrame)

import lldb
import time
import os
import shlex
from optparse import OptionParser


def print_stack_frame(debugger, command, result, internal_dict):
  """This command takes the index of a frame on the current stack (-i, zero based) and a optiona prefix(-p) to print before the selected frames method.
Ex. psf -i 1 -p "init called by " """
  options = ParseCommands(command)

  thread = debugger.GetSelectedTarget().GetProcess().GetSelectedThread()
  if len(thread.frames)>=options.index:
          frame = thread.frames[options.index]
          print options.prefix + frame.name
  else :
          print options.prefix + "requested frame index outside of the current stack"

def ParseCommands(command):
        parser = OptionParser()
        parser.add_option("-i", "--index", action="store", type="int", dest="index", default=0 ,help="The index of the frame in the current stack to print details for [default]")
        parser.add_option("-p", "--prefix", action="store", type="string", dest="prefix",default="" ,help="A prefix to be printed before the frame's details [default]")
        (options, args) = parser.parse_args(shlex.split(command))
        return options

def __lldb_init_module(debugger, internal_dict):
  debugger.HandleCommand('command script add -f frame_utils.print_stack_frame print_stack_frame')
  debugger.HandleCommand('command script add -f frame_utils.print_stack_frame psf')
  print 'The "print_stack_frame" command has been installed and is ready of use.'
