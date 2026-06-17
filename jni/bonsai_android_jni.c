#include <jni.h>
#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/mlvalues.h>

static int ocaml_runtime_started = 0;

static void ensure_ocaml_runtime(void) {
  if (!ocaml_runtime_started) {
    char *argv[] = { "bonsai_android", NULL };
    caml_startup(argv);
    ocaml_runtime_started = 1;
  }
}

JNIEXPORT jstring JNICALL
Java_com_logseq_bonsaiandroid_BonsaiAndroidNative_renderNative(JNIEnv *env, jobject self) {
  (void)self;
  ensure_ocaml_runtime();
  const value *callback = caml_named_value("bonsai_android_render");
  if (callback == NULL) {
    return (*env)->NewStringUTF(env, "{\"type\":\"text\",\"text\":\"OCaml render callback missing\",\"modifiers\":[]}");
  }
  value result = caml_callback(*callback, Val_unit);
  return (*env)->NewStringUTF(env, String_val(result));
}

JNIEXPORT void JNICALL
Java_com_logseq_bonsaiandroid_BonsaiAndroidNative_dispatchClickNative(JNIEnv *env, jobject self, jint event_id) {
  (void)env;
  (void)self;
  ensure_ocaml_runtime();
  const value *callback = caml_named_value("bonsai_android_dispatch_click");
  if (callback != NULL) caml_callback(*callback, Val_int(event_id));
}

JNIEXPORT void JNICALL
Java_com_logseq_bonsaiandroid_BonsaiAndroidNative_dispatchChangeNative(
    JNIEnv *env,
    jobject self,
    jint event_id,
    jstring text) {
  (void)self;
  ensure_ocaml_runtime();
  const value *callback = caml_named_value("bonsai_android_dispatch_change");
  if (callback == NULL) return;

  const char *utf8 = (*env)->GetStringUTFChars(env, text, NULL);
  value args[2] = { Val_int(event_id), caml_copy_string(utf8) };
  caml_callbackN(*callback, 2, args);
  (*env)->ReleaseStringUTFChars(env, text, utf8);
}
