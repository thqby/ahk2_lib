/************************************************************************
 * @description Implements a javascript-like Promise
 * @date 2023/01/29
 * @version 1.0.0
 ***********************************************************************/

class Promise {
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
	then(onFulfilled, onRejected := Promise.onRejected) {
		if !HasMethod(onRejected, , 1)
			throw TypeError('invalid onRejected')
		if !HasMethod(onFulfilled, , 1)
			throw TypeError('invalid onFulfilled')
		promise2 := { base: Promise.Prototype }
		promise2.__New(executor)
		return promise2
		executor(resolve, reject) {
			switch this.status {
				case 'fulfilled':
					SetTimer(task.Bind(promise2, resolve, reject, onFulfilled, this.value), -1)
				case 'rejected':
					if _throw := this.DeleteProp('throw')
						SetTimer(_throw, 0)
					SetTimer(task.Bind(promise2, resolve, reject, onRejected, this.reason), -1)
				default:
					this.onResolvedCallbacks.Push(task.Bind(promise2, resolve, reject, onFulfilled))
					this.onRejectedCallbacks.Push(task.Bind(promise2, resolve, reject, onRejected))
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
	_catch(onRejected) => this.then(val => val, onRejected)
	_finally(callback) => this.then(
		val => (callback(), val),
		err => (callback(), (Promise.onRejected)(err)),
	)
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
	static resolve(value) => Promise((resolve, _) => resolve(value))
	static reject(reason) => Promise((_, reject) => reject(reason))
	static all(promises) {
		return Promise(executor)
		executor(resolve, reject) {
			res := [], count := 0
			res.Length := promises.Length
			resolveRes := (index, data) => (res[index] := data, ++count == res.Length && resolve(res))
			for p in promises
				if HasMethod(p, 'then', 1)
					p.then(resolveRes.Bind(A_Index), reject)
				else resolveRes(A_Index, p)
		}
	}
	static race(promises) {
		return Promise(executor)
		executor(resolve, reject) {
			for p in promises
				if HasMethod(p, 'then', 1)
					p.then(resolve, reject)
				else return resolve(p)
		}
	}
}
