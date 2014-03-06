import lldb
import commands

def unsignedshortptr_SummaryProvider(valobj, dict):
  e = lldb.SBError()
  s = u'"'
  if valobj.GetValue() != 0:
    i = 0
    newchar = -1
    while newchar != 0:
          # read next wchar character out of memory
      data_val = valobj.GetPointeeData(i, 1)
      size = data_val.GetByteSize()
      if size == 1:
        newchar = data_val.GetUnsignedInt8(e, 0)    # utf-8
      elif size == 2:
        newchar = data_val.GetUnsignedInt16(e, 0)   # utf-16
      elif size == 4:
        newchar = data_val.GetUnsignedInt32(e, 0)   # utf-32
      else:
        return "<errorsize: %i>" % size
      if e.fail:
        return '<errorfail>'
      i = i + 1
      # add the character to our string 's'
      if newchar != 0:
        s = s + unichr(newchar)
  s = s + u'"'
  return s.encode('utf-8')

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand("type summary add -F unsignedshortptrsummary.unsignedshortptr_SummaryProvider \"unsigned short *\"")
    print "unsignedshortptrsummary installed."
