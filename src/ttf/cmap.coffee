r = require 'restructure'

SubHeader = new r.Struct
  firstCode:      r.uint16
  entryCount:     r.uint16
  idDelta:        r.int16
  idRangeOffset:  r.uint16
  
CmapGroup = new r.Struct
  startCharCode:  r.uint32
  endCharCode:    r.uint32
  glyphID:        r.uint32
  
UnicodeValueRange = new r.Struct
  startUnicodeValue:  r.uint24
  additionalCount:    r.uint8
  
UVSMapping = new r.Struct
  unicodeValue: r.uint24
  glyphID:      r.uint16
  
DefaultUVS = new r.Array(UnicodeValueRange, r.uint32)
NonDefaultUVS = new r.Array(UVSMapping, r.uint32)
  
VarSelectorRecord = new r.Struct
  varSelector:    r.uint24
  defaultUVS:     new r.Pointer(r.uint32, DefaultUVS, type: 'parent')
  nonDefaultUVS:  new r.Pointer(r.uint32, NonDefaultUVS, type: 'parent')
  
CmapSubtable = new r.VersionedStruct r.uint16,
  0: # Byte encoding
    length:     r.uint16   # Total table length in bytes (set to 262 for format 0)
    language:   r.uint16   # Language code for this encoding subtable, or zero if language-independent
    codeMap:    new r.Array(r.uint8, 256)
    
  2: # High-byte mapping (CJK)
    length:           r.uint16
    language:         r.uint16
    subHeaderKeys:    new r.Array(r.uint16, 256)
    subHeaderCount:   -> Math.max.apply(Math, @subHeaderKeys)       
    subHeaders:       new r.Array(SubHeader, 'subHeaderCount')
    glyphIndexArray:  new r.Array(r.uint16, 'subHeaderCount')
  
  4: # Segment mapping to delta values
    length:           r.uint16              # Total table length in bytes
    language:         r.uint16              # Language code
    segCountX2:       r.uint16
    segCount:         -> @segCountX2 >> 1
    searchRange:      r.uint16
    entrySelector:    r.uint16
    rangeShift:       r.uint16
    endCode:          new r.Array(r.uint16, 'segCount')
    reservedPad:      new r.Reserved(r.uint16)       # This value should be zero
    startCode:        new r.Array(r.uint16, 'segCount')
    idDelta:          new r.Array(r.uint16, 'segCount')
    idRangeOffset:    new r.Array(r.uint16, 'segCount')
    glyphIndexArray:  new r.Array(r.uint16, -> (@length - @_currentOffset) / 2)
    
  6: # Trimmed table
    length:         r.uint16
    language:       r.uint16
    firstCode:      r.uint16
    entryCount:     r.uint16
    glyphIndices:   new r.Array(r.uint16, 'entryCount')
    
  8: # mixed 16-bit and 32-bit coverage
    reserved: new r.Reserved(r.uint16)
    length:   r.uint32
    language: r.uint16
    is32:     new r.Array(r.uint8, 8192)
    nGroups:  r.uint32
    groups:   new r.Array(CmapGroup, 'nGroups')
    
  10: # Trimmed Array
    reserved:       new r.Reserved(r.uint16)
    length:         r.uint32
    language:       r.uint32
    firstCode:      r.uint32
    entryCount:     r.uint32
    glyphIndices:   new r.Array(r.uint16, 'numChars')
    
  12: # Segmented coverage
    reserved: new r.Reserved(r.uint16)
    length:   r.uint32
    language: r.uint32
    nGroups:  r.uint32
    groups:   new r.Array(CmapGroup, 'nGroups')
    
  13: # Many-to-one range mappings (same as 12 except for group.startGlyphID)
    reserved: new r.Reserved(r.uint16)
    length:   r.uint32
    language: r.uint32
    nGroups:  r.uint32
    groups:   new r.Array(CmapGroup, 'nGroups')
    
  14: # Unicode Variation Sequences
    length:       r.uint32
    numRecords:   r.uint32
    varSelectors: new r.Array(VarSelectorRecord, 'numRecords')

CmapEntry = new r.Struct
  platformID:  r.uint16  # Platform identifier
  encodingID:  r.uint16  # Platform-specific encoding identifier
  table:       new r.Pointer(r.uint32, CmapSubtable, type: 'parent')
  
# character to glyph mapping
module.exports = new r.Struct
  version:      r.uint16
  numSubtables: r.uint16
  tables:       new r.Array(CmapEntry, 'numSubtables')