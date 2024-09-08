/************************************************************************
 * @description Implements a javascript-like Promise
 * @author thqby
 * @date 2024/09/04
 * @version 1.0.4
 * @requires AutoHotkey-v2.0.3+	The lower version ahk uses version 1.0.1.
 ***********************************************************************/

/**
 * Represents the completion of an asynchronous operation
 * @see {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise MDN doc}
 * @alias Promise<T=Any>
 */
class Promise {
	static Prototype.status := 'pending'
	/** @type {T} */
	static Prototype.value := ''
	static Prototype.reason := ''

	/**
	 * @param {(resolve [,reject])=>void} executor A callback used to initialize the promise. This callback is passed two arguments:
	 * a resolve callback used to resolve the promise with a value or the result of another promise,
	 * and a reject callback used to reject the promise with a provided reason or error.
	 * - resolve(data) => void
	 * - reject(err) => void
	 */
	__New(executor) {
		; this.DefineProp('__Delete', { call: this => OutputDebug('del: ' ObjPtr(this) '`n') })
		this.onResolvedCallbacks := []
		this.onRejectedCallbacks := []
		try
			(executor.MaxParams = 1) ? executor(resolve) : executor(resolve, reject)
		catch Any as e
			reject(e)
		resolve(value := '') {
			if value is Promise
				return value.then(resolve, reject)
			if (this.status != 'pending')
				return
			this.value := value
			this.status := 'fulfilled'
			handle(this, 'onRejectedCallbacks')
			handle(this, 'onResolvedCallbacks', value)
		}
		reject(reason?) {
			if (this.status != 'pending')
				return
			if !IsSet(reason)
				reason := Error(, -1)
			this.reason := reason
			this.status := 'rejected'
			handle(this, 'onResolvedCallbacks')
			if !handle(this, 'onRejectedCallbacks', reason)
				SetTimer(this.throw := () => (this.DeleteProp('throw'), (Promise.onRejected)(reason)), -1)
		}
		static handle(this, name, val?) {
			cbs := this.%name%
			this.%name% := { Push: (*) => 0 }
			if IsSet(val)
				for fn in cbs
					SetTimer(fn.Bind(val), -1)
			return cbs.Length
		}
	}
	/**
	 * Attaches callbacks for the resolution and/or rejection of the Promise.
	 * @param {(value)=>any} onfulfilled The callback to execute when the Promise is resolved.
	 * @param {(reason)=>any} onrejected The callback to execute when the Promise is rejected.
	 * @returns {Promise} A Promise for the completion of which ever callback is executed.
	 */
	then(onfulfilled, onrejected := Promise.onRejected) {
		if !HasMethod(onrejected, , 1)
			throw TypeError('invalid onRejected')
		if !HasMethod(onfulfilled, , 1)
			throw TypeError('invalid onFulfilled')
		promise2 := { base: Promise.Prototype }
		promise2.__New(executor)
		return promise2
		executor(resolve, reject) {
			switch this.status {
				case 'fulfilled':
					task(promise2, resolve, reject, onfulfilled, this.value)
				case 'rejected':
					if hasthrow := this.DeleteProp('throw')
						SetTimer(hasthrow, 0)
					task(promise2, resolve, reject, onrejected, this.reason)
				default:
					this.onResolvedCallbacks.Push(task.Bind(promise2, resolve, reject, onfulfilled))
					this.onRejectedCallbacks.Push(task.Bind(promise2, resolve, reject, onrejected))
			}
			static task(p2, resolve, reject, fn, val) {
				try
					resolvePromise(p2, fn(val), resolve, reject)
				catch Any as e
					reject(e)
			}
			static resolvePromise(p2, x, resolve, reject) {
				if !(x is Promise)
					return resolve(x)
				if p2 == x
					throw TypeError('Chaining cycle detected for promise #<Promise>')
				called := 0
				try {
					x.then(
						res => (!called && (called := 1, resolvePromise(p2, res, resolve, reject)), ''),
						err => (!called && (called := 1, reject(err)), '')
					)
				} catch Any as e
					(!called && (called := 1, reject(e)))
			}
		}
	}
	/**
	 * Attaches a callback for only the rejection of the Promise.
	 * @param {(reason)=>any} onrejected The callback to execute when the Promise is rejected.
	 * @returns {Promise} A Promise for the completion of the callback.
	 */
	catch(onrejected) => this.then(val => val, onrejected)
	/**
	 * Attaches a callback that is invoked when the Promise is settled (fulfilled or rejected).
	 * The resolved value cannot be modified from the callback.
	 * @param {()=>void} onfinally The callback to execute when the Promise is settled (fulfilled or rejected).
	 * @returns {Promise} A Promise for the completion of the callback.
	 */
	finally(onfinally) => this.then(
		val => (onfinally(), val),
		err => (onfinally(), (Promise.onRejected)(err))
	)
	/**
	 * Waits for a promise to be completed.
	 * @returns {T}
	 */
	await(timeout := -1) {
		end := A_TickCount + timeout
		while this.status == 'pending' && (timeout < 0 || A_TickCount < end)
			Sleep(1)
		if this.status == 'fulfilled'
			return this.value
		throw this.status == 'pending' ? TimeoutError() : this.reason
	}
	/**
	 * Waits for a promise to be completed.
	 * Wake up only when a system event or timeout occurs, which takes up less cpu time.
	 * @returns {T}
	 */
	await2(timeout := -1) {
		static hEvent := DllCall('CreateEvent', 'ptr', 0, 'int', 1, 'int', 0, 'ptr', 0, 'ptr')
		static __del := { Ptr: hEvent, __Delete: this => DllCall('CloseHandle', 'ptr', this) }
		t := A_TickCount, r := 258
		while this.status == 'pending' && timeout &&
			1 == r := DllCall('MsgWaitForMultipleObjects', 'uint', 1, 'ptr*', hEvent,
				'int', 0, 'uint', timeout, 'uint', 7423, 'uint')
			Sleep(-1), (timeout < 0) || timeout := Max(timeout - A_TickCount + t, 0)
		if this.status == 'fulfilled'
			return this.value
		throw this.status == 'pending' ? r == 0xffffffff ? OSError() : TimeoutError() : this.reason
	}
	static onRejected() {
		throw this
	}
	/**
	 * Creates a new resolved promise for the provided value.
	 * @param value The value the promise was resolved.
	 * @returns {Promise} A new resolved Promise.
	 */
	static resolve(value) => Promise((resolve, _) => resolve(value))
	/**
	 * Creates a new rejected promise for the provided reason.
	 * @param reason The reason the promise was rejected.
	 * @returns {Promise} A new rejected Promise.
	 */
	static reject(reason) => Promise((_, reject) => reject(reason))
	/**
	 * Creates a Promise that is resolved with an array of results when all of the provided Promises
	 * resolve, or rejected when any Promise is rejected.
	 * @param {Array<Promise>} values An array of Promises.
	 * @returns {Promise<Array>} A new Promise.
	 */
	static all(values) {
		return Promise(executor)
		executor(resolve, reject) {
			res := [], count := 0
			if !(res.Length := values.Length)
				return resolve(res)
			resolveRes := (index, data) => (res[index] := data, ++count == res.Length && resolve(res))
			for val in values
				if val is Promise
					val.then(resolveRes.Bind(A_Index), reject)
				else resolveRes(A_Index, val)
		}
	}
	/**
	 * Creates a Promise that is resolved with an array of results when all
	 * of the provided Promises resolve or reject.
	 * @param {Array<Promise>} values An array of Promises.
	 * @returns {Promise<Array<{status: String, value?: Any, reason?: Any}>>} A new Promise.
	 */
	static allSettled(values) {
		return Promise(executor)
		executor(resolve, reject) {
			res := [], count := 0
			if !(res.Length := values.Length)
				return resolve(res)
			resolveRes := (index, data) => (res[index] := { status: 'fulfilled', value: data }, ++count == res.Length && resolve(res))
			rejectRes := (index, data) => (res[index] := { status: 'rejected', reason: data }, ++count == res.Length && resolve(res))
			for val in values
				if val is Promise
					val.then(resolveRes.Bind(A_Index), rejectRes.Bind(A_Index))
				else resolveRes(A_Index, val)
		}
	}
	/**
	 * Creates a Promise that is resolved or rejected when any of the provided Promises are resolved
	 * or rejected.
	 * @param {Array<Promise>} values An array of Promises.
	 * @returns {Promise} A new Promise.
	 */
	static race(values) {
		return Promise(executor)
		executor(resolve, reject) {
			for val in values
				if val is Promise
					val.then(resolve, reject)
				else return resolve(val)
		}
	}
}
