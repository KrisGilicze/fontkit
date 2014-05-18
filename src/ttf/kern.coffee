r = require 'restructure'

KernPair = new r.Struct
  left:   r.uint16
  right:  r.uint16
  value:  r.int16
  
KernSubtable = new r.VersionedStruct 'format', 
  0:
    nPairs:         r.uint16
    searchRange:    r.uint16
    entrySelector:  r.uint16
    rangeShift:     r.uint16
    pairs:          new r.Array(KernPair, 'nPairs')
    
  # TODO: other formats

KernTable = new r.VersionedStruct 'version',
  0: # Microsoft uses this format
    subVersion: r.uint16  # Microsoft has an extra sub-table version number
    length:     r.uint16  # Length of the subtable, in bytes
    format:     r.uint8   # Format of subtable
    coverage:   new r.Bitfield r.uint8, [
      'horizontal'    # 1 if table has horizontal data, 0 if vertical
      'minimum'       # If set to 1, the table has minimum values. If set to 0, the table has kerning values.
      'crossStream'   # If set to 1, kerning is perpendicular to the flow of the text
      'override'      # If set to 1 the value in this table replaces the accumulated value
    ]
    subtable:   KernSubtable
  1: # Apple uses this format
    length:     r.uint32
    coverage:   new r.Bitfield r.uint8, [
      null, null, null, null, null,
      'variation'     # Set if table has variation kerning values
      'crossStream'   # Set if table has cross-stream kerning values
      'vertical'      # Set if table has vertical kerning values
    ]
    format:     r.uint8
    tupleIndex: r.uint16
    subtable:   KernSubtable

# The kern table has been largely superseded by the GPOS table
module.exports = new r.VersionedStruct r.uint16,
  0: # Microsoft Version
    nTables:    r.uint16
    tables:     new r.Array(KernTable, 'nTables')
    
  1: # Apple Version
    reserved:   new r.Reserved(r.uint16) # the other half of the version number
    nTables:    r.uint32
    tables:     new r.Array(KernTable, 'nTables')