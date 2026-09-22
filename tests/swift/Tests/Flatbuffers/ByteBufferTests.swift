/*
 * Copyright 2024 Google Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import XCTest

@testable import FlatBuffers

final class ByteBufferTests: XCTestCase {
  func testCopyingMemory() {
    let count = 100
    let ptr = UnsafeMutableRawPointer.allocate(byteCount: count, alignment: 1)
    let byteBuffer = ByteBuffer(copyingMemoryBound: ptr, capacity: count)
    byteBuffer.withUnsafeBytes { memory in
      XCTAssertNotEqual(memory.baseAddress, ptr)
    }
  }

  func testSamePointer() {
    let count = 100
    let ptr = UnsafeMutableRawPointer.allocate(byteCount: count, alignment: 1)
    let byteBuffer = ByteBuffer(assumingMemoryBound: ptr, capacity: count)
    byteBuffer.withUnsafeBytes { memory in
      XCTAssertEqual(memory.baseAddress!, ptr)
    }
  }

  func testDuplicateOfBorrowedMemory() {
    let count = 16
    let ptr = UnsafeMutableRawPointer.allocate(byteCount: count, alignment: 8)
    defer { ptr.deallocate() }
    ptr.storeBytes(of: UInt32(0xCAFE_F00D), toByteOffset: 4, as: UInt32.self)
    let byteBuffer = ByteBuffer(assumingMemoryBound: ptr, capacity: count)
    let duplicate = byteBuffer.duplicate()
    duplicate.withUnsafeBytes { memory in
      XCTAssertEqual(memory.baseAddress!, UnsafeRawPointer(ptr))
      XCTAssertEqual(memory.count, count)
    }
    XCTAssertEqual(duplicate.read(def: UInt32.self, position: 4), 0xCAFE_F00D)
    XCTAssertEqual(duplicate.reader, byteBuffer.reader)
    XCTAssertEqual(byteBuffer.duplicate(removing: 4).reader, 4)
  }

  func testDuplicateOfOwnedMemoryOutlivesOriginal() {
    let count = 16
    let source = UnsafeMutableRawPointer.allocate(byteCount: count, alignment: 8)
    defer { source.deallocate() }
    source.storeBytes(of: UInt32(0xDEAD_BEEF), toByteOffset: 8, as: UInt32.self)
    let duplicate: ByteBuffer = {
      let owned = ByteBuffer(copyingMemoryBound: source, capacity: count)
      return owned.duplicate(removing: 4)
    }()
    source.storeBytes(of: UInt32(0), toByteOffset: 8, as: UInt32.self)
    XCTAssertEqual(duplicate.read(def: UInt32.self, position: 8), 0xDEAD_BEEF)
    XCTAssertEqual(duplicate.reader, 4)
    XCTAssertEqual(duplicate.capacity, count)
  }

  func testRebindOfBorrowedBufferAllocatesNothing() {
    let first = UnsafeMutableRawPointer.allocate(byteCount: 16, alignment: 8)
    let second = UnsafeMutableRawPointer.allocate(byteCount: 24, alignment: 8)
    defer {
      first.deallocate()
      second.deallocate()
    }
    first.storeBytes(of: UInt32(0xAAAA_0001), toByteOffset: 4, as: UInt32.self)
    second.storeBytes(of: UInt32(0xBBBB_0002), toByteOffset: 4, as: UInt32.self)
    var byteBuffer = ByteBuffer(assumingMemoryBound: first, capacity: 16)
    XCTAssertEqual(byteBuffer.read(def: UInt32.self, position: 4), 0xAAAA_0001)
    XCTAssertTrue(byteBuffer.rebind(assumingMemoryBound: second, capacity: 24))
    XCTAssertEqual(byteBuffer.read(def: UInt32.self, position: 4), 0xBBBB_0002)
    XCTAssertEqual(byteBuffer.capacity, 24)
    XCTAssertEqual(byteBuffer.size, 24)
    XCTAssertEqual(byteBuffer.reader, 0)
    byteBuffer.withUnsafeBytes { memory in
      XCTAssertEqual(memory.baseAddress!, UnsafeRawPointer(second))
      XCTAssertEqual(memory.count, 24)
    }
  }

  func testRebindLeavesTheOtherCopyIntact() {
    let first = UnsafeMutableRawPointer.allocate(byteCount: 16, alignment: 8)
    let second = UnsafeMutableRawPointer.allocate(byteCount: 8, alignment: 8)
    defer {
      first.deallocate()
      second.deallocate()
    }
    first.storeBytes(of: UInt32(0xAAAA_0001), toByteOffset: 4, as: UInt32.self)
    second.storeBytes(of: UInt32(0xBBBB_0002), toByteOffset: 4, as: UInt32.self)
    var byteBuffer = ByteBuffer(assumingMemoryBound: first, capacity: 16)
    let table = Table(bb: byteBuffer, position: 0)
    XCTAssertTrue(byteBuffer.rebind(assumingMemoryBound: second, capacity: 8))
    XCTAssertEqual(byteBuffer.read(def: UInt32.self, position: 4), 0xBBBB_0002)
    XCTAssertEqual(byteBuffer.capacity, 8)
    XCTAssertEqual(table.bb.read(def: UInt32.self, position: 4), 0xAAAA_0001)
    XCTAssertEqual(table.bb.capacity, 16)
    table.bb.withUnsafeBytes { memory in
      XCTAssertEqual(memory.baseAddress!, UnsafeRawPointer(first))
    }
  }

  func testRebindOfOwnedBufferBorrowsTheNewMemory() {
    let source = UnsafeMutableRawPointer.allocate(byteCount: 16, alignment: 8)
    let borrowed = UnsafeMutableRawPointer.allocate(byteCount: 16, alignment: 8)
    defer {
      source.deallocate()
      borrowed.deallocate()
    }
    source.storeBytes(of: UInt32(0xAAAA_0001), toByteOffset: 4, as: UInt32.self)
    borrowed.storeBytes(of: UInt32(0xBBBB_0002), toByteOffset: 4, as: UInt32.self)
    var byteBuffer = ByteBuffer(copyingMemoryBound: source, capacity: 16)
    XCTAssertFalse(byteBuffer.rebind(assumingMemoryBound: borrowed, capacity: 16))
    XCTAssertEqual(byteBuffer.read(def: UInt32.self, position: 4), 0xBBBB_0002)
    borrowed.storeBytes(of: UInt32(0xCCCC_0003), toByteOffset: 4, as: UInt32.self)
    XCTAssertEqual(byteBuffer.read(def: UInt32.self, position: 4), 0xCCCC_0003)
    XCTAssertTrue(byteBuffer.rebind(assumingMemoryBound: source, capacity: 16))
    XCTAssertEqual(byteBuffer.read(def: UInt32.self, position: 4), 0xAAAA_0001)
  }

  func testSameDataPtr() {
    let count = 100
    let ptr = Data(repeating: 0, count: count)
    let byteBuffer = ByteBuffer(data: ptr)
    byteBuffer.withUnsafeBytes { memory in
      ptr.withUnsafeBytes { ptr in
        XCTAssertEqual(memory.baseAddress!, ptr.baseAddress!)
      }
    }
  }

  func testSameArrayPtr() {
    let count = 100
    let ptr: [UInt8] = Array(repeating: 0, count: count)
    let byteBuffer = ByteBuffer(bytes: ptr)
    ptr.withUnsafeBytes { ptr in
      byteBuffer.withUnsafeBytes { memory in
        XCTAssertEqual(memory.baseAddress, ptr.baseAddress)
      }
    }
  }

  func testReadingDoubleBuffer() {
    let count = 8
    let array: [Double] = Array(repeating: 8.8, count: count)
    var oldBuffer = _InternalByteBuffer(initialSize: 16)
    oldBuffer.push(elements: array)
    let bytes: [Byte] = oldBuffer.withUnsafeBytes { bytes in
      Array(bytes)
    }
    let byteBuffer = ByteBuffer(bytes: bytes)
    byteBuffer.withUnsafePointerToSlice(index: 0, count: count) { ptr in
      XCTAssertEqual(ptr.count, count)
      bytes.withUnsafeBufferPointer {
        XCTAssertEqual(
          UnsafeRawPointer($0.baseAddress),
          UnsafeRawPointer(ptr.baseAddress))
      }
    }
  }

  func testReadingNativeStructs() {
    let array = [
      MyGame_Example_Vec3(
        x: 3.2,
        y: 3.2,
        z: 3.2,
        test1: 8,
        test2: .red,
        test3: MyGame_Example_Test(a: 8, b: 8)),
      MyGame_Example_Vec3(
        x: 3.2,
        y: 3.2,
        z: 3.2,
        test1: 8,
        test2: .green,
        test3: MyGame_Example_Test(a: 16, b: 16)),
      MyGame_Example_Vec3(
        x: 3.2,
        y: 3.2,
        z: 3.2,
        test1: 8,
        test2: .blue,
        test3: MyGame_Example_Test(a: 32, b: 32)),
    ]
    let count = array.count
    var oldBuffer = _InternalByteBuffer(initialSize: 16)
    oldBuffer.push(elements: array)
    let bytes: [Byte] = oldBuffer.withUnsafeBytes { bytes in
      Array(bytes)
    }
    let byteBuffer = ByteBuffer(bytes: bytes)
    byteBuffer
      .withUnsafePointerToSlice(index: 0, count: count) { bufferPointer in
        XCTAssertEqual(bufferPointer.count, count)
        bytes.withUnsafeBufferPointer { ptr in
          XCTAssertEqual(
            UnsafeRawPointer(ptr.baseAddress),
            UnsafeRawPointer(bufferPointer.baseAddress))
        }
      }
  }
}

private struct TestNativeStructs: NativeStruct {
  let x: Double
  let y: Double
  let z: Int
}

extension MyGame_Example_Color: CaseIterable {
  public static var allCases: [MyGame_Example_Color] = [.red, .blue, .green]
}
