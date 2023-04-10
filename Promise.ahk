/************************************************************************
 * @description Implements a javascript-like Promise
 * @author thqby
 * @date 2023/01/29
 * @version 1.0.1
 ***********************************************************************/

; Represents the completion of an asynchronous operation
class Promise {
	/**
	 * @param {(resolve,reject)=>void} executor A callback used to initialize the promise. This callback is passed two arguments:
	 * a resolve callback used to resolve the promise with a value or the result of another promise,
	 * and a reject callback used to reject the promise with a provided reason or error.
	 * - resolve(data) => void
	 * - reject(err) => void
	 * @returns {Promise} Creates a new Promise.
	 */
	__New(executor) {
		; this.DefineProp('__Delete', { call: this => OutputDebug('del: ' ObjPtr(this) '`n') })
		this.status := 'pending'
		this.value := ''
		this.reason := ''
		this.onResolvedCallbacks := []
		this.onRejectedCallbacks := []
		try
			executor(resolve, reason => reject(this, reason))
		catch Any as e
			reject(this, e)
		resolve(value) {
			if value is Promise
				return value.then(resolve, reason => reject(this, reason))
			if (this.status != 'pending')
				return
			this.value := value
			this.status := 'fulfilled'
			handle(this, 'onRejectedCallbacks')
			handle(this, 'onResolvedCallbacks', value)
		}
		static reject(this, reason) {
			if (this.status != 'pending')
				return
			this.reason := reason
			this.status := 'rejected'
			handle(this, 'onResolvedCallbacks')
			if !handle(this, 'onRejectedCallbacks', reason)
				SetTimer(this.throw := () => (this.DeleteProp('throw'), (Promise.onRejected)(reason)), -1)
		}
		static _(*) => ''
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
				if !HasMethod(x, 'then', 1)
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
	_catch(onrejected) => this.then(val => val, onrejected)
	/**
	 * Attaches a callback that is invoked when the Promise is settled (fulfilled or rejected).
	 * The resolved value cannot be modified from the callback.
	 * @param {()=>void} onfinally The callback to execute when the Promise is settled (fulfilled or rejected).
	 * @returns {Promise} A Promise for the completion of the callback.
	 */
	_finally(onfinally) => this.then(
		val => (onfinally(), val),
		err => (onfinally(), (Promise.onRejected)(err)),
	)
	/**
	 * Waits for a promise to be completed.
	 */
	await(timeout := 0) {
		end := A_TickCount + timeout
		while this.status == 'pending' && (!timeout || A_TickCount < end)
			Sleep(-1)
		if this.status == 'fulfilled'
			return this.value
		throw this.status == 'pending' ? TimeoutError() : this.reason
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
	 * @param values An array of Promises.
	 * @returns {Promise} A new Promise.
	 */
	static all(values) {
		return Promise(executor)
		executor(resolve, reject) {
			res := [], count := 0
			if !(res.Length := values.Length)
				return resolve(res)
			resolveRes := (index, data) => (res[index] := data, ++count == res.Length && resolve(res))
			for val in values
				if HasMethod(val, 'then', 1)
					val.then(resolveRes.Bind(A_Index), reject)
				else resolveRes(A_Index, val)
		}
	}
	/**
	 * Creates a Promise that is resolved with an array of results when all
	 * of the provided Promises resolve or reject.
	 * @param values An array of Promises.
	 * @returns A new Promise.
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
				if HasMethod(val, 'then', 1)
					val.then(resolveRes.Bind(A_Index), rejectRes.Bind(A_Index))
				else resolveRes(A_Index, val)
		}
	}
	/**
	 * Creates a Promise that is resolved or rejected when any of the provided Promises are resolved
	 * or rejected.
	 * @param values An array of Promises.
	 * @returns {Promise} A new Promise.
	 */
	static race(values) {
		return Promise(executor)
		executor(resolve, reject) {
			for val in values
				if HasMethod(val, 'then', 1)
					val.then(resolve, reject)
				else return resolve(val)
		}
	}
}
