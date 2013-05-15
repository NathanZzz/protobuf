#!/usr/bin/env dart
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library generated_message_test;

import 'package:protobuf/protobuf.dart';
import 'package:unittest/unittest.dart';

import '../out/protos/google/protobuf/unittest.pb.dart';
import '../out/protos/google/protobuf/unittest_import.pb.dart';
import '../out/protos/google/protobuf/unittest_optimize_for.pb.dart';
import '../out/protos/multiple_files_test.pb.dart';
import '../out/protos/nested_extension.pb.dart';
import '../out/protos/non_nested_extension.pb.dart';

import 'test_util.dart';

void main() {
  final throwsInvalidProtocolBufferException =
      throwsA(new isInstanceOf<InvalidProtocolBufferException>());

  test('testProtosShareRepeatedArraysIfDidntChange', () {
    TestAllTypes value1 = new TestAllTypes()
        ..repeatedInt32.add(100)
        ..repeatedImportEnum.add(ImportEnum.IMPORT_BAR)
        ..repeatedForeignMessage.add(new ForeignMessage());

    TestAllTypes value2 = value1.clone();

    expect(value2.repeatedInt32, value1.repeatedInt32);
    expect(value2.repeatedImportEnum, value1.repeatedImportEnum);
    expect(value2.repeatedForeignMessage, value1.repeatedForeignMessage);
  });

  test('testSettersRejectNull', () {
    TestAllTypes message = new TestAllTypes();
    expect(() { message.optionalString = null; }, throwsArgumentError);
    expect(() { message.optionalBytes = null; }, throwsArgumentError);
    expect(() { message.optionalNestedMessage = null; }, throwsArgumentError);
    expect(() { message.optionalNestedMessage =null; }, throwsArgumentError);
    expect(() { message.optionalNestedEnum = null; }, throwsArgumentError);
    expect(() { message.repeatedString.add(null); }, throwsArgumentError);
    expect(() { message.repeatedBytes.add(null); }, throwsArgumentError);
    expect(() { message.repeatedNestedMessage.add(null); },
           throwsArgumentError);
    expect(() { message.repeatedNestedMessage.add(null); },
           throwsArgumentError);
    expect(() { message.repeatedNestedEnum.add(null); }, throwsArgumentError);
  });

  test('testRepeatedSetters', () {
    TestAllTypes message = getAllSet();
    modifyRepeatedFields(message);
    assertRepeatedFieldsModified(message);
  });

  test('testRepeatedSettersRejectNull', () {
    TestAllTypes message = new TestAllTypes();

    message.repeatedString.addAll(['one', 'two']);
    expect(() { message.repeatedString[1] = null; }, throwsArgumentError);

    message.repeatedBytes.addAll(['one'.codeUnits, 'two'.codeUnits]);
    expect(() { message.repeatedBytes[1] = null; }, throwsArgumentError);

    message.repeatedNestedMessage.addAll([
        new TestAllTypes_NestedMessage()..bb = 318,
        new TestAllTypes_NestedMessage()..bb = 456]);
    expect(() { message.repeatedNestedMessage[1] = null; },
           throwsArgumentError);

    message.repeatedNestedEnum.addAll(
        [TestAllTypes_NestedEnum.FOO, TestAllTypes_NestedEnum.BAR]);
    expect(() { message.repeatedNestedEnum[1] = null; },
           throwsArgumentError);
  });

  test('testRepeatedAppend', () {
    TestAllTypes message = new TestAllTypes()
      ..repeatedInt32.addAll([1, 2, 3, 4])
      ..repeatedForeignEnum.addAll([ForeignEnum.FOREIGN_BAZ])
      ..repeatedForeignMessage.addAll([new ForeignMessage()..c = 12]);

    expect(message.repeatedInt32, [1, 2, 3, 4]);
    expect(message.repeatedForeignEnum, [ForeignEnum.FOREIGN_BAZ]);
    expect(message.repeatedForeignMessage.length, 1);
    expect(message.repeatedForeignMessage[0].c, 12);
  });

  test('testRepeatedAppendRejectsNull', () {
    TestAllTypes message = new TestAllTypes();

    expect(() {
        message.repeatedForeignMessage.addAll([
            new ForeignMessage()..c = 12, null]); }, throwsArgumentError);

    expect(() {
        message.repeatedForeignEnum.addAll([ForeignEnum.FOREIGN_BAZ, null]);
        }, throwsArgumentError);

    expect(() { message.repeatedString.addAll(['one', null]); },
           throwsArgumentError);

    expect(() { message.repeatedBytes.addAll(['one'.codeUnits, null]); },
           throwsArgumentError);
  });

  test('testSettingForeignMessage', () {
    TestAllTypes message = new TestAllTypes()
      ..optionalForeignMessage = (new ForeignMessage()..c = 123);

    TestAllTypes expectedMessage = new TestAllTypes()
      ..optionalForeignMessage = (new ForeignMessage()..c = 123);

    expect(message, expectedMessage);
  });

  test('testSettingRepeatedForeignMessage', () {
    TestAllTypes message = new TestAllTypes()
      ..repeatedForeignMessage.add(new ForeignMessage()..c = 456);

    TestAllTypes expectedMessage = new TestAllTypes()
      ..repeatedForeignMessage.add(new ForeignMessage()..c = 456);

    expect(message, expectedMessage);
  });

  test('testDefaults', () {
    assertClear(new TestAllTypes());

    TestExtremeDefaultValues message =
        new TestExtremeDefaultValues();

    expect(message.utf8String, '\u1234');
    expect(message.infDouble, same(double.INFINITY));
    expect(message.negInfDouble, same(double.NEGATIVE_INFINITY));
    expect(message.nanDouble, same(double.NAN));
    expect(message.infFloat, same(double.INFINITY));
    expect(message.negInfFloat, same(double.NEGATIVE_INFINITY));
    expect(message.nanFloat, same(double.NAN));
    expect(message.cppTrigraph, '? ? ?? ?? ??? ??/ ??-');
  });

  test('testClear', () {
    TestAllTypes message = new TestAllTypes();

    assertClear(message);
    setAllFields(message);
    message.clear();
    assertClear(message);
  });

  // void testReflectionGetters() {} // UNSUPPORTED -- until reflection
  // void testReflectionSetters() {} // UNSUPPORTED -- until reflection
  // void testReflectionSettersRejectNull() {} // UNSUPPORTED - reflection
  // void testReflectionRepeatedSetters() {} // UNSUPPORTED -- reflection
  // void testReflectionRepeatedSettersRejectNull() {} // UNSUPPORTED
  // void testReflectionDefaults() {} // UNSUPPORTED -- until reflection

  test('testEnumInterface', () {
    expect(new TestAllTypes().defaultNestedEnum,
           new isInstanceOf<ProtobufEnum>());
  });

  test('testEnumMap', () {
    for (ForeignEnum value in ForeignEnum.values) {
      expect(ForeignEnum.valueOf(value.value), value);
    }
    expect(ForeignEnum.valueOf(12345), isNull);
  });

  test('testParsePackedToUnpacked', () {
    TestUnpackedTypes message =
        new TestUnpackedTypes.fromBuffer(getPackedSet().writeToBuffer());
    assertUnpackedFieldsSet(message);
  });

  test('testParseUnpackedToPacked', () {
    TestPackedTypes message =
        new TestPackedTypes.fromBuffer(getUnpackedSet().writeToBuffer());
    assertPackedFieldsSet(message);
  });

  // =================================================================
  // Extensions.
  test('testSetAllExtensions', () {
    TestAllExtensions message = new TestAllExtensions();
    setAllExtensions(message);
    assertAllExtensionsSet(message);
  });

  test('testExtensionRepeatedSetters', () {
    TestAllExtensions message = new TestAllExtensions();
    setAllExtensions(message);
    modifyRepeatedExtensions(message);
    assertRepeatedExtensionsModified(message);
  });

  test('testExtensionDefaults', () {
    assertExtensionsClear(new TestAllExtensions());
  });

  // void testExtensionReflectionGetters() {} // UNSUPPORTED -- reflection
  // void testExtensionReflectionSetters() {} // UNSUPPORTED -- reflection
  // void testExtensionReflectionSettersRejectNull() {} // UNSUPPORTED
  // void testExtensionReflectionRepeatedSetters() {} // UNSUPPORTED
  // void testExtensionReflectionRepeatedSettersRejectNull() // UNSUPPORTED
  // void testExtensionReflectionDefaults() // UNSUPPORTED

  test('testClearExtension', () {
    // clearExtension() is not actually used in test_util, so try it manually.
    TestAllExtensions message = new TestAllExtensions();
    message.setExtension(Unittest.optionalInt32Extension, 1);
    message.clearExtension(Unittest.optionalInt32Extension);
    expect(message.hasExtension(Unittest.optionalInt32Extension), isFalse);

    message = new TestAllExtensions();
    message.addExtension(Unittest.repeatedInt32Extension, 1);
    message.clearExtension(Unittest.repeatedInt32Extension);
    expect(message.getExtension(Unittest.repeatedInt32Extension).length, 0);
  });

  test('testExtensionCopy', () {
    assertAllExtensionsSet(getAllExtensionsSet().clone());
  });

  test('testExtensionMergeFrom', () {
    TestAllExtensions original = new TestAllExtensions();
    original.setExtension(Unittest.optionalInt32Extension, 1);
    TestAllExtensions clone = original.clone();
    expect(clone.hasExtension(Unittest.optionalInt32Extension), isTrue);
    expect(clone.getExtension(Unittest.optionalInt32Extension), 1);
  });

  test('testMultipleFilesOption', () { // UNSUPPORTED getFile
    // We mostly just want to check that things compile.
    MessageWithNoOuter message = new MessageWithNoOuter()
        ..nested = (new MessageWithNoOuter_NestedMessage()..i = 1)
        ..foreign.add(new TestAllTypes()..optionalInt32 = 1)
        ..nestedEnum = MessageWithNoOuter_NestedEnum.BAZ
        ..foreignEnum = EnumWithNoOuter.BAR;

    expect(new MessageWithNoOuter.fromBuffer(message.writeToBuffer()), message);

    // Not currently supported in Dart protobuf.
    // expect(MessageWithNoOuter.getDescriptor().getFile(),
    //        MultipleFilesTestProto.getDescriptor());

    int tagNumber = message.getTagNumber('foreignEnum');
    expect(tagNumber, isNotNull);
    expect(message.getField(tagNumber), EnumWithNoOuter.BAR);

    // Not currently supported in Dart protobuf.
    // expect(ServiceWithNoOuter.getDescriptor().getFile()
    //        MultipleFilesTestProto.getDescriptor());

    expect(new TestAllExtensions().hasExtension(
        Multiple_files_test.extensionWithOuter), isFalse);
  });

  test('testOptionalFieldWithRequiredSubfieldsOptimizedForSize', () {
    expect(new TestOptionalOptimizedForSize().isInitialized(), isTrue);

    expect((new TestOptionalOptimizedForSize()
        ..o = new TestRequiredOptimizedForSize()).isInitialized(),
        isFalse);

    expect((new TestOptionalOptimizedForSize()
        ..o = (new TestRequiredOptimizedForSize()..x = 5)).isInitialized(),
        isTrue);
  });

  test('testSetAllFieldsAndClone', () {
    TestAllTypes message = getAllSet();
    assertAllFieldsSet(message);
    assertAllFieldsSet(message.clone());
  });

  test('testReadWholeMessage', () {
    TestAllTypes message = getAllSet();
    List<int> rawBytes = message.writeToBuffer();
    assertAllFieldsSet(new TestAllTypes.fromBuffer(rawBytes));
  });

  test('testReadHugeBlob', () {
    // Allocate and initialize a 1MB blob.
    List<int> blob = new List<int>(1 << 20);
    for (int i = 0; i < blob.length; i++) {
      blob[i] = i % 256;
    }

    // Make a message containing it.
    TestAllTypes message = getAllSet();
    message.optionalBytes = blob;

    TestAllTypes message2 =
        new TestAllTypes.fromBuffer(message.writeToBuffer());
    expect(message2.optionalBytes, message.optionalBytes);
  });

  test('testRecursiveMessageDefaultInstance', () {
    TestRecursiveMessage message = new TestRecursiveMessage();
    expect(message.a, isNotNull);
    expect(message, message.a);
  });

  test('testMaliciousRecursion', () {
    _makeRecursiveMessage(int depth) {
      return depth == 0 ?
          (new TestRecursiveMessage()..i = 5) :
          (new TestRecursiveMessage()..a = _makeRecursiveMessage(depth - 1));
    }

    _assertMessageDepth(TestRecursiveMessage message, int depth) {
      if (depth == 0) {
        expect(message.hasA(), isFalse);
        expect(message.i, 5);
      } else {
        expect(message.hasA(), isTrue);
        _assertMessageDepth(message.a, depth - 1);
      }
    }

    List<int> data64 = _makeRecursiveMessage(64).writeToBuffer();
    List<int> data65 = _makeRecursiveMessage(65).writeToBuffer();

    _assertMessageDepth(new TestRecursiveMessage.fromBuffer(data64), 64);

    expect(() { new TestRecursiveMessage.fromBuffer(data65); },
           throwsInvalidProtocolBufferException);

    CodedBufferReader input = new CodedBufferReader(data64, recursionLimit: 8);
    expect(() {
        // Uncomfortable alternative to below...
        new TestRecursiveMessage().mergeFromCodedBufferReader(input);
      }, throwsInvalidProtocolBufferException);
  });

  test('testSizeLimit', () {
    CodedBufferReader input = new CodedBufferReader(
        getAllSet().writeToBuffer(), sizeLimit: 16);

    expect(() {
        // Uncomfortable alternative to below...
        new TestAllTypes().mergeFromCodedBufferReader(input);
      }, throwsInvalidProtocolBufferException);
  });
  test('testSerialize', () {
    TestAllTypes expected = getAllSet();
    List<int> out = expected.writeToBuffer();
    TestAllTypes actual = new TestAllTypes.fromBuffer(out);
    expect(actual, expected);
  });

  test('testEnumValues', () {
    expect(TestAllTypes_NestedEnum.values,
           [ TestAllTypes_NestedEnum.FOO,
             TestAllTypes_NestedEnum.BAR,
             TestAllTypes_NestedEnum.BAZ]);
    expect(TestAllTypes_NestedEnum.FOO.value, 1);
    expect(TestAllTypes_NestedEnum.BAR.value, 2);
    expect(TestAllTypes_NestedEnum.BAZ.value, 3);
  });

  test('testBadExtension', () {
    TestAllTypes message = new TestAllTypes();
    expect(() { message.setExtension(Unittest.optionalInt32Extension, 101); },
           throwsArgumentError);

    expect(() { message.getExtension(Unittest.optionalInt32Extension); },
           throwsArgumentError);
  });

  test('testNonNestedExtensionInitialization', () {
    expect(Non_nested_extension.nonNestedExtension.makeDefault(),
        new isInstanceOf<MyNonNestedExtension>());
    expect(Non_nested_extension.nonNestedExtension.name, 'nonNestedExtension');
  });

  test('testNestedExtensionInitialization', () {
    expect(MyNestedExtension.recursiveExtension
        .makeDefault() is MessageToBeExtended, isTrue);
    expect(MyNestedExtension.recursiveExtension.name, 'recursiveExtension');
  });

  test('testWriteWholeMessage', () {
    List<int> goldenMessage = const <int>[
      0x08, 0x65, 0x10, 0x66, 0x18, 0x67, 0x20, 0x68, 0x28, 0xd2, 0x01, 0x30,
      0xd4, 0x01, 0x3d, 0x6b, 0x00, 0x00, 0x00, 0x41, 0x6c, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x4d, 0x6d, 0x00, 0x00, 0x00, 0x51, 0x6e, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5d, 0x00, 0x00, 0xde, 0x42, 0x61,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5c, 0x40, 0x68, 0x01, 0x72, 0x03,
      0x31, 0x31, 0x35, 0x7a, 0x03, 0x31, 0x31, 0x36, 0x83, 0x01, 0x88, 0x01,
      0x75, 0x84, 0x01, 0x92, 0x01, 0x02, 0x08, 0x76, 0x9a, 0x01, 0x02, 0x08,
      0x77, 0xa2, 0x01, 0x02, 0x08, 0x78, 0xa8, 0x01, 0x03, 0xb0, 0x01, 0x06,
      0xb8, 0x01, 0x09, 0xc2, 0x01, 0x03, 0x31, 0x32, 0x34, 0xca, 0x01, 0x03,
      0x31, 0x32, 0x35, 0xf8, 0x01, 0xc9, 0x01, 0xf8, 0x01, 0xad, 0x02, 0x80,
      0x02, 0xca, 0x01, 0x80, 0x02, 0xae, 0x02, 0x88, 0x02, 0xcb, 0x01, 0x88,
      0x02, 0xaf, 0x02, 0x90, 0x02, 0xcc, 0x01, 0x90, 0x02, 0xb0, 0x02, 0x98,
      0x02, 0x9a, 0x03, 0x98, 0x02, 0xe2, 0x04, 0xa0, 0x02, 0x9c, 0x03, 0xa0,
      0x02, 0xe4, 0x04, 0xad, 0x02, 0xcf, 0x00, 0x00, 0x00, 0xad, 0x02, 0x33,
      0x01, 0x00, 0x00, 0xb1, 0x02, 0xd0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0xb1, 0x02, 0x34, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xbd,
      0x02, 0xd1, 0x00, 0x00, 0x00, 0xbd, 0x02, 0x35, 0x01, 0x00, 0x00, 0xc1,
      0x02, 0xd2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc1, 0x02, 0x36,
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xcd, 0x02, 0x00, 0x00, 0x53,
      0x43, 0xcd, 0x02, 0x00, 0x80, 0x9b, 0x43, 0xd1, 0x02, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x80, 0x6a, 0x40, 0xd1, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x80, 0x73, 0x40, 0xd8, 0x02, 0x01, 0xd8, 0x02, 0x00, 0xe2, 0x02, 0x03,
      0x32, 0x31, 0x35, 0xe2, 0x02, 0x03, 0x33, 0x31, 0x35, 0xea, 0x02, 0x03,
      0x32, 0x31, 0x36, 0xea, 0x02, 0x03, 0x33, 0x31, 0x36, 0xf3, 0x02, 0xf8,
      0x02, 0xd9, 0x01, 0xf4, 0x02, 0xf3, 0x02, 0xf8, 0x02, 0xbd, 0x02, 0xf4,
      0x02, 0x82, 0x03, 0x03, 0x08, 0xda, 0x01, 0x82, 0x03, 0x03, 0x08, 0xbe,
      0x02, 0x8a, 0x03, 0x03, 0x08, 0xdb, 0x01, 0x8a, 0x03, 0x03, 0x08, 0xbf,
      0x02, 0x92, 0x03, 0x03, 0x08, 0xdc, 0x01, 0x92, 0x03, 0x03, 0x08, 0xc0,
      0x02, 0x98, 0x03, 0x02, 0x98, 0x03, 0x03, 0xa0, 0x03, 0x05, 0xa0, 0x03,
      0x06, 0xa8, 0x03, 0x08, 0xa8, 0x03, 0x09, 0xb2, 0x03, 0x03, 0x32, 0x32,
      0x34, 0xb2, 0x03, 0x03, 0x33, 0x32, 0x34, 0xba, 0x03, 0x03, 0x32, 0x32,
      0x35, 0xba, 0x03, 0x03, 0x33, 0x32, 0x35, 0xe8, 0x03, 0x91, 0x03, 0xf0,
      0x03, 0x92, 0x03, 0xf8, 0x03, 0x93, 0x03, 0x80, 0x04, 0x94, 0x03, 0x88,
      0x04, 0xaa, 0x06, 0x90, 0x04, 0xac, 0x06, 0x9d, 0x04, 0x97, 0x01, 0x00,
      0x00, 0xa1, 0x04, 0x98, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xad,
      0x04, 0x99, 0x01, 0x00, 0x00, 0xb1, 0x04, 0x9a, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0xbd, 0x04, 0x00, 0x80, 0xcd, 0x43, 0xc1, 0x04, 0x00,
      0x00, 0x00, 0x00, 0x00, 0xc0, 0x79, 0x40, 0xc8, 0x04, 0x00, 0xd2, 0x04,
      0x03, 0x34, 0x31, 0x35, 0xda, 0x04, 0x03, 0x34, 0x31, 0x36, 0x88, 0x05,
      0x01, 0x90, 0x05, 0x04, 0x98, 0x05, 0x07, 0xa2, 0x05, 0x03, 0x34, 0x32,
      0x34, 0xaa, 0x05, 0x03, 0x34, 0x32, 0x35
    ];
    expect(getAllSet().writeToBuffer(), goldenMessage);
  });

  test('testWriteWholePackedFieldsMessage', () {
    List<int> goldenPackedMessage = const <int>[
      0xd2, 0x05, 0x04, 0xd9, 0x04, 0xbd, 0x05, 0xda, 0x05, 0x04, 0xda, 0x04,
      0xbe, 0x05, 0xe2, 0x05, 0x04, 0xdb, 0x04, 0xbf, 0x05, 0xea, 0x05, 0x04,
      0xdc, 0x04, 0xc0, 0x05, 0xf2, 0x05, 0x04, 0xba, 0x09, 0x82, 0x0b, 0xfa,
      0x05, 0x04, 0xbc, 0x09, 0x84, 0x0b, 0x82, 0x06, 0x08, 0x5f, 0x02, 0x00,
      0x00, 0xc3, 0x02, 0x00, 0x00, 0x8a, 0x06, 0x10, 0x60, 0x02, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0xc4, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x92, 0x06, 0x08, 0x61, 0x02, 0x00, 0x00, 0xc5, 0x02, 0x00, 0x00, 0x9a,
      0x06, 0x10, 0x62, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc6, 0x02,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa2, 0x06, 0x08, 0x00, 0xc0, 0x18,
      0x44, 0x00, 0xc0, 0x31, 0x44, 0xaa, 0x06, 0x10, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x20, 0x83, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x86, 0x40,
      0xb2, 0x06, 0x02, 0x01, 0x00, 0xba, 0x06, 0x02, 0x05, 0x06
    ];
    expect(getPackedSet().writeToBuffer(), goldenPackedMessage);
  });

  test('testWriteMessageWithNegativeEnumValue', () {
    SparseEnumMessage message = new SparseEnumMessage()
        ..sparseEnum = TestSparseEnum.SPARSE_E;
    expect(message.sparseEnum.value < 0, isTrue,
        reason: 'enum.value should be -53452');
    SparseEnumMessage message2 =
        new SparseEnumMessage.fromBuffer(message.writeToBuffer());
    expect(message2.sparseEnum, TestSparseEnum.SPARSE_E,
           reason: 'should resolve back to SPARSE_E');
  });
}
