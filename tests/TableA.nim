#[ TableA
  Automatically generated by the FlatBuffers compiler, do not modify.
  Or modify. I'm a message, not a cop.

  flatc version: 23.5.26

  Declared by  : 
  Rooting type : MyGame.Example.Monster ()
]#

import MyGame/OtherNameSpace/TableB as MyGame_OtherNameSpace_TableB
import flatbuffers
import std/options

type TableA* = object of FlatObj
func b*(self: TableA): Option[MyGame_OtherNameSpace_TableB.TableB] =
  let o = self.tab.Offset(4)
  if o != 0:
    return some(MyGame_OtherNameSpace_TableB.TableB(tab: Vtable(Bytes: self.tab.Bytes, Pos: self.tab.Pos + o)))
proc TableAstart*(builder: var Builder) =
  builder.StartObject(1)
proc TableAaddb*(builder: var Builder, b: uoffset) =
  builder.PrependStructSlot(0, b, default(uoffset))
proc TableAend*(builder: var Builder): uoffset =
  return builder.EndObject()
