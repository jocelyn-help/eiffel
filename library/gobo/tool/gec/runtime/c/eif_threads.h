/*
	description:

		"C functions used to implement Thread support"

	system: "Gobo Eiffel Compiler"
	copyright: "Copyright (c) 2007, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2008-05-12 11:29:00 +0200 (Mon, 12 May 2008) $"
	revision: "$Revision: 6409 $"
*/

#ifndef EIF_THREADS_H
#define EIF_THREADS_H

#ifdef __cplusplus
extern "C" {
#endif

#ifndef EIF_THREADS

/*
	Empty stubs for EiffelThread library so that it may be compiled against a non-multithreaded run-time.
*/
#define eif_thr_mutex_create() NULL
#define eif_thr_mutex_lock(a_mutex_pointer)
#define eif_thr_mutex_unlock(a_mutex_pointer)
#define eif_thr_mutex_trylock(a_mutex_pointer) EIF_FALSE
#define eif_thr_mutex_destroy(a_mutex_pointer)
#define eif_thr_cond_create() NULL
#define eif_thr_cond_broadcast(a_cond_ptr)
#define eif_thr_cond_wait(a_cond_ptr,a_mutex_ptr)
#define eif_thr_cond_destroy(a_mutex_ptr)
#define eif_thr_thread_id() NULL
#define eif_thr_last_thread() NULL
#define eif_thr_default_priority() 0
#define eif_thr_create_with_args(current_obj, init_func, priority, policy, detach)
#define eif_thr_sleep(nanoseconds)

#endif

#ifdef __cplusplus
}
#endif

#endif
