// RUN: %swift -emit-silgen %s | FileCheck %s

protocol UID {
    func uid() -> Int
    var clsid: Int { get set }
    var iid: Int { get }
}

protocol ObjectUID : class, UID {}

class Base {}

// CHECK-LABEL: sil hidden @_TF25protocol_class_refinement12getObjectUIDUS_9ObjectUID__FQ_TSiSi_
// CHECK:       bb0([[X:%.*]] : $T):
// -- call x.uid()
// CHECK-NOT:     strong_retain [[X]]
// CHECK:         [[TMP:%.*]] = alloc_stack $T
// CHECK:         store [[X]] to [[TMP]]
// CHECK:         [[UID:%.*]] = witness_method $T, #UID.uid
// CHECK:         [[UID_VALUE:%.*]] = apply [[UID]]<T>([[TMP]]#1)
// CHECK-NOT:     strong_release [[X]]
// -- call x.clsid.setter (TODO: avoid r/r here)
// CHECK:         strong_retain [[X]]
// CHECK:         [[TMP:%.*]] = alloc_stack $T
// CHECK:         store [[X]] to [[TMP]]
// CHECK:         [[SET_CLSID:%.*]] = witness_method $T, #UID.clsid!setter
// CHECK:         apply [[SET_CLSID]]<T>([[UID_VALUE]], [[TMP]]#1)
// CHECK:         strong_release [[X]]
// -- call x.iid.getter
// CHECK-NOT:     strong_retain [[X]]
// CHECK:         [[TMP:%.*]] = alloc_stack $T
// CHECK:         store [[X]] to [[TMP]]
// CHECK:         [[GET_IID:%.*]] = witness_method $T, #UID.iid!getter
// CHECK:         apply [[GET_IID]]<T>([[TMP]]#1)
// CHECK-NOT:     strong_release [[X]]
// -- call x.clsid.getter (TODO: avoid r/r here)
// CHECK:         strong_retain [[X]]
// CHECK:         [[TMP:%.*]] = alloc_stack $T
// CHECK:         store [[X]] to [[TMP]]
// CHECK:         [[GET_CLSID:%.*]] = witness_method $T, #UID.clsid!getter
// CHECK:         apply [[GET_CLSID]]<T>([[TMP]]#1)
// CHECK:         strong_release [[X]]
// -- done
// CHECK:         strong_release [[X]]

func getObjectUID<T: ObjectUID>(x: T) -> (Int, Int) {
  x.clsid = x.uid()
  return (x.iid, x.clsid)
}

// CHECK-LABEL: sil hidden @_TF25protocol_class_refinement16getBaseObjectUIDUS_3UID__FQ_TSiSi_
// CHECK:       bb0([[X:%.*]] : $T):
// -- call x.uid()
// CHECK-NOT:     strong_retain [[X]]
// CHECK:         [[TMP:%.*]] = alloc_stack $T
// CHECK:         store [[X]] to [[TMP]]
// CHECK:         [[UID:%.*]] = witness_method $T, #UID.uid
// CHECK:         [[UID_VALUE:%.*]] = apply [[UID]]<T>([[TMP]]#1)
// CHECK-NOT:     strong_release [[X]]
// -- call x.clsid.setter (TODO: avoid r/r here)
// CHECK:         strong_retain [[X]]
// CHECK:         [[TMP:%.*]] = alloc_stack $T
// CHECK:         store [[X]] to [[TMP]]
// CHECK:         [[SET_CLSID:%.*]] = witness_method $T, #UID.clsid!setter
// CHECK:         apply [[SET_CLSID]]<T>([[UID_VALUE]], [[TMP]]#1)
// CHECK:         strong_release [[X]]
// -- call x.iid.getter
// CHECK-NOT:     strong_retain [[X]]
// CHECK:         [[TMP:%.*]] = alloc_stack $T
// CHECK:         store [[X]] to [[TMP]]
// CHECK:         [[GET_IID:%.*]] = witness_method $T, #UID.iid!getter
// CHECK:         apply [[GET_IID]]<T>([[TMP]]#1)
// CHECK-NOT:     strong_release [[X]]
// -- call x.clsid.getter (TODO: avoid r/r here)
// CHECK:         strong_retain [[X]]
// CHECK:         [[TMP:%.*]] = alloc_stack $T
// CHECK:         store [[X]] to [[TMP]]
// CHECK:         [[GET_CLSID:%.*]] = witness_method $T, #UID.clsid!getter
// CHECK:         apply [[GET_CLSID]]<T>([[TMP]]#1)
// CHECK:         strong_release [[X]]
// -- done
// CHECK:         strong_release [[X]]

func getBaseObjectUID<T: UID where T: Base>(x: T) -> (Int, Int) {
  x.clsid = x.uid()
  return (x.iid, x.clsid)
}
