// <auto-generated>
//  automatically generated by the FlatBuffers compiler, do not modify
// </auto-generated>

namespace flatbuffers.goldens
{

using global::System;
using global::System.Collections.Generic;
using global::Google.FlatBuffers;

public struct Universe : IFlatbufferObject
{
  private Table __p;
  public ByteBuffer ByteBuffer { get { return __p.bb; } }
  public static void ValidateVersion() { FlatBufferConstants.FLATBUFFERS_23_5_26(); }
  public static Universe GetRootAsUniverse(ByteBuffer _bb) { return GetRootAsUniverse(_bb, new Universe()); }
  public static Universe GetRootAsUniverse(ByteBuffer _bb, Universe obj) { return (obj.__assign(_bb.GetInt(_bb.Position) + _bb.Position, _bb)); }
  public static bool VerifyUniverse(ByteBuffer _bb) {Google.FlatBuffers.Verifier verifier = new Google.FlatBuffers.Verifier(_bb); return verifier.VerifyBuffer("", false, UniverseVerify.Verify); }
  public void __init(int _i, ByteBuffer _bb) { __p = new Table(_i, _bb); }
  public Universe __assign(int _i, ByteBuffer _bb) { __init(_i, _bb); return this; }

  public double Age { get { int o = __p.__offset(4); return o != 0 ? __p.bb.GetDouble(o + __p.bb_pos) : (double)0.0; } }
  public flatbuffers.goldens.Galaxy? Galaxies(int j) { int o = __p.__offset(6); return o != 0 ? (flatbuffers.goldens.Galaxy?)(new flatbuffers.goldens.Galaxy()).__assign(__p.__indirect(__p.__vector(o) + j * 4), __p.bb) : null; }
  public int GalaxiesLength { get { int o = __p.__offset(6); return o != 0 ? __p.__vector_len(o) : 0; } }

  public static Offset<flatbuffers.goldens.Universe> CreateUniverse(FlatBufferBuilder builder,
      double age = 0.0,
      VectorOffset galaxiesOffset = default(VectorOffset)) {
    builder.StartTable(2);
    Universe.AddAge(builder, age);
    Universe.AddGalaxies(builder, galaxiesOffset);
    return Universe.EndUniverse(builder);
  }

  public static void StartUniverse(FlatBufferBuilder builder) { builder.StartTable(2); }
  public static void AddAge(FlatBufferBuilder builder, double age) { builder.AddDouble(0, age, 0.0); }
  public static void AddGalaxies(FlatBufferBuilder builder, VectorOffset galaxiesOffset) { builder.AddOffset(1, galaxiesOffset.Value, 0); }
  public static VectorOffset CreateGalaxiesVector(FlatBufferBuilder builder, Offset<flatbuffers.goldens.Galaxy>[] data) { builder.StartVector(4, data.Length, 4); for (int i = data.Length - 1; i >= 0; i--) builder.AddOffset(data[i].Value); return builder.EndVector(); }
  public static VectorOffset CreateGalaxiesVectorBlock(FlatBufferBuilder builder, Offset<flatbuffers.goldens.Galaxy>[] data) { builder.StartVector(4, data.Length, 4); builder.Add(data); return builder.EndVector(); }
  public static VectorOffset CreateGalaxiesVectorBlock(FlatBufferBuilder builder, ArraySegment<Offset<flatbuffers.goldens.Galaxy>> data) { builder.StartVector(4, data.Count, 4); builder.Add(data); return builder.EndVector(); }
  public static VectorOffset CreateGalaxiesVectorBlock(FlatBufferBuilder builder, IntPtr dataPtr, int sizeInBytes) { builder.StartVector(1, sizeInBytes, 1); builder.Add<Offset<flatbuffers.goldens.Galaxy>>(dataPtr, sizeInBytes); return builder.EndVector(); }
  public static void StartGalaxiesVector(FlatBufferBuilder builder, int numElems) { builder.StartVector(4, numElems, 4); }
  public static Offset<flatbuffers.goldens.Universe> EndUniverse(FlatBufferBuilder builder) {
    int o = builder.EndTable();
    return new Offset<flatbuffers.goldens.Universe>(o);
  }
  public static void FinishUniverseBuffer(FlatBufferBuilder builder, Offset<flatbuffers.goldens.Universe> offset) { builder.Finish(offset.Value); }
  public static void FinishSizePrefixedUniverseBuffer(FlatBufferBuilder builder, Offset<flatbuffers.goldens.Universe> offset) { builder.FinishSizePrefixed(offset.Value); }
}


static public class UniverseVerify
{
  static public bool Verify(Google.FlatBuffers.Verifier verifier, uint tablePos)
  {
    return verifier.VerifyTableStart(tablePos)
      && verifier.VerifyField(tablePos, 4 /*Age*/, 8 /*double*/, 8, false)
      && verifier.VerifyVectorOfTables(tablePos, 6 /*Galaxies*/, flatbuffers.goldens.GalaxyVerify.Verify, false)
      && verifier.VerifyTableEnd(tablePos);
  }
}

}
