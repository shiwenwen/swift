
// RUN: %target-swift-emit-silgen -enable-sil-ownership %s | %FileCheck %s

class A {}
class B {}
protocol P {}
protocol Q {}

// CHECK-LABEL: sil hidden @{{.*}}loadable
func loadable(readonly: A, writable: inout A,
              value: B,
              kp: KeyPath<A, B>,
              wkp: WritableKeyPath<A, B>,
              rkp: ReferenceWritableKeyPath<A, B>) {
  // CHECK: [[ROOT_COPY:%.*]] = copy_value %0
  // CHECK: [[KP_COPY:%.*]] = copy_value %3
  // CHECK: [[ROOT_TMP:%.*]] = alloc_stack $A
  // CHECK: store [[ROOT_COPY]] to [init] [[ROOT_TMP]]
  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}_projectKeyPathReadOnly
  // CHECK: [[RESULT_TMP:%.*]] = alloc_stack $B
  // CHECK: apply [[PROJECT]]<A, B>([[RESULT_TMP]], [[ROOT_TMP]], [[KP_COPY]])
  // CHECK: [[RESULT:%.*]] = load [take] [[RESULT_TMP]]
  // CHECK: destroy_value [[RESULT]]
  _ = readonly[keyPath: kp]

  // CHECK: [[ACCESS:%.*]] = begin_access [read] [unknown] %1
  // CHECK: [[ROOT_COPY:%.*]] = load [copy] [[ACCESS]]
  // CHECK: end_access [[ACCESS]]
  // CHECK: [[KP_COPY:%.*]] = copy_value %3
  // CHECK: [[ROOT_TMP:%.*]] = alloc_stack $A
  // CHECK: store [[ROOT_COPY]] to [init] [[ROOT_TMP]]
  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}_projectKeyPathReadOnly
  // CHECK: [[RESULT_TMP:%.*]] = alloc_stack $B
  // CHECK: apply [[PROJECT]]<A, B>([[RESULT_TMP]], [[ROOT_TMP]], [[KP_COPY]])
  // CHECK: [[RESULT:%.*]] = load [take] [[RESULT_TMP]]
  // CHECK: destroy_value [[RESULT]]
  _ = writable[keyPath: kp]

  // CHECK: [[ROOT_COPY:%.*]] = copy_value %0
  // CHECK: [[KP_COPY:%.*]] = copy_value %4
  // CHECK: [[KP_UPCAST:%.*]] = upcast [[KP_COPY]] : $WritableKeyPath<A, B> to $KeyPath<A, B>
  // CHECK: [[ROOT_TMP:%.*]] = alloc_stack $A
  // CHECK: store [[ROOT_COPY]] to [init] [[ROOT_TMP]]
  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}_projectKeyPathReadOnly
  // CHECK: [[RESULT_TMP:%.*]] = alloc_stack $B
  // CHECK: apply [[PROJECT]]<A, B>([[RESULT_TMP]], [[ROOT_TMP]], [[KP_UPCAST]])
  // CHECK: [[RESULT:%.*]] = load [take] [[RESULT_TMP]]
  // CHECK: destroy_value [[RESULT]]
  _ = readonly[keyPath: wkp]

  // CHECK: function_ref @{{.*}}_projectKeyPathReadOnly
  _ = writable[keyPath: wkp]

  // CHECK: function_ref @{{.*}}_projectKeyPathReadOnly
  _ = readonly[keyPath: rkp]
  // CHECK: function_ref @{{.*}}_projectKeyPathReadOnly
  _ = writable[keyPath: rkp]

  // CHECK: function_ref @{{.*}}_projectKeyPathWritable
  writable[keyPath: wkp] = value
  // CHECK: function_ref @{{.*}}_projectKeyPathReferenceWritable
  readonly[keyPath: rkp] = value
  // CHECK: function_ref @{{.*}}_projectKeyPathReferenceWritable
  writable[keyPath: rkp] = value
}

// CHECK-LABEL: sil hidden @{{.*}}addressOnly
func addressOnly(readonly: P, writable: inout P,
                 value: Q,
                 kp: KeyPath<P, Q>,
                 wkp: WritableKeyPath<P, Q>,
                 rkp: ReferenceWritableKeyPath<P, Q>) {
  // CHECK: function_ref @{{.*}}_projectKeyPathReadOnly
  _ = readonly[keyPath: kp]
  // CHECK: function_ref @{{.*}}_projectKeyPathReadOnly
  _ = writable[keyPath: kp]
  // CHECK: function_ref @{{.*}}_projectKeyPathReadOnly
  _ = readonly[keyPath: wkp]

  // CHECK: function_ref @{{.*}}_projectKeyPathReadOnly
  _ = writable[keyPath: wkp]

  // CHECK: function_ref @{{.*}}_projectKeyPathReadOnly
  _ = readonly[keyPath: rkp]
  // CHECK: function_ref @{{.*}}_projectKeyPathReadOnly
  _ = writable[keyPath: rkp]

  // CHECK: function_ref @{{.*}}_projectKeyPathWritable
  writable[keyPath: wkp] = value
  // CHECK: function_ref @{{.*}}_projectKeyPathReferenceWritable
  readonly[keyPath: rkp] = value
  // CHECK: function_ref @{{.*}}_projectKeyPathReferenceWritable
  writable[keyPath: rkp] = value
}

// CHECK-LABEL: sil hidden @{{.*}}reabstracted
func reabstracted(readonly: @escaping () -> (),
                  writable: inout () -> (),
                  value: @escaping (A) -> B,
                  kp: KeyPath<() -> (), (A) -> B>,
                  wkp: WritableKeyPath<() -> (), (A) -> B>,
                  rkp: ReferenceWritableKeyPath<() -> (), (A) -> B>) {
  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}_projectKeyPathReadOnly
  _ = readonly[keyPath: kp]
  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}_projectKeyPathReadOnly
  _ = writable[keyPath: kp]
  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}_projectKeyPathReadOnly
  _ = readonly[keyPath: wkp]

  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}_projectKeyPathReadOnly
  _ = writable[keyPath: wkp]

  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}_projectKeyPathReadOnly
  _ = readonly[keyPath: rkp]
  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}_projectKeyPathReadOnly
  _ = writable[keyPath: rkp]

  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}_projectKeyPathWritable
  writable[keyPath: wkp] = value
  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}_projectKeyPathReferenceWritable
  readonly[keyPath: rkp] = value
  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}_projectKeyPathReferenceWritable
  writable[keyPath: rkp] = value
}

// CHECK-LABEL: sil hidden @{{.*}}partial
func partial<A>(valueA: A,
                valueB: Int,
                pkpA: PartialKeyPath<A>,
                pkpB: PartialKeyPath<Int>,
                akp: AnyKeyPath) {
  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}projectKeyPathAny
  // CHECK: apply [[PROJECT]]<A>
  _ = valueA[keyPath: akp]
  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}projectKeyPathPartial
  // CHECK: apply [[PROJECT]]<A>
  _ = valueA[keyPath: pkpA]

  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}projectKeyPathAny
  // CHECK: apply [[PROJECT]]<Int>
  _ = valueB[keyPath: akp]
  // CHECK: [[PROJECT:%.*]] = function_ref @{{.*}}projectKeyPathPartial
  // CHECK: apply [[PROJECT]]<Int>
  _ = valueB[keyPath: pkpB]
}

extension Int {
  var b: Int { get { return 0 } set { } }
  var u: Int { get { return 0 } set { } }
  var tt: Int { get { return 0 } set { } }
}

// CHECK-LABEL: sil hidden @{{.*}}writebackNesting
func writebackNesting(x: inout Int,
                      y: WritableKeyPath<Int, Int>,
                      z: WritableKeyPath<Int, Int>,
                      w: Int) -> Int {
  // -- get 'b'
  // CHECK: function_ref @$sSi19keypath_applicationE1bSivg
  // -- apply keypath y
  // CHECK: [[PROJECT_FN:%.*]] = function_ref @{{.*}}_projectKeyPathWritable
  // CHECK: [[PROJECT_RET:%.*]] = apply [[PROJECT_FN]]
  // CHECK: ({{%.*}}, [[OWNER_Y:%.*]]) = destructure_tuple [[PROJECT_RET]]
  // -- get 'u'
  // CHECK: function_ref @$sSi19keypath_applicationE1uSivg
  // -- apply keypath z
  // CHECK: [[PROJECT_FN:%.*]] = function_ref @{{.*}}_projectKeyPathWritable
  // CHECK: [[PROJECT_RET:%.*]] = apply [[PROJECT_FN]]
  // CHECK: ({{%.*}}, [[OWNER_Z:%.*]]) = destructure_tuple [[PROJECT_RET]]

  // -- set 'tt'
  // CHECK: function_ref @$sSi19keypath_applicationE2ttSivs
  // -- destroy owner for keypath projection z
  // CHECK: destroy_value [[OWNER_Z]]
  // -- set 'u'
  // CHECK: function_ref @$sSi19keypath_applicationE1uSivs
  // -- destroy owner for keypath projection y
  // CHECK: destroy_value [[OWNER_Y]]
  // -- set 'b'
  // CHECK: function_ref @$sSi19keypath_applicationE1bSivs

  x.b[keyPath: y].u[keyPath: z].tt = w
}
