/************************************************************************
 * @author thqby
 * @date 2024/12/11
 * @version 1.0.1
 ***********************************************************************/

class DirectoryWatcher {
	/**
	 * Call the notification function when the specified directory changes.
	 * @param dirPath The directory to be monitored.
	 * @param {(this, notify: NOTIFY_INFORMATION) => 0} notifyCallback
	 * @param {Integer} notifyFilter The filter criteria that checks to determine if the operation has completed.
	 * This parameter can be one or more of the following values.
	 * |Meaning    | Flag|
	 * |-------    | ----|
	 * |FILE_NAME  |  0x1|
	 * |DIR_NAME   |  0x2|
	 * |ATTRIBUTES |  0x4|
	 * |SIZE       |  0x8|
	 * |LAST_WRITE | 0x10|
	 * |LAST_ACCESS| 0x20|
	 * |CREATION   | 0x40|
	 * |SECURITY   |0x100|
	 * @param {Integer} watchSubtree If it is TRUE, monitors the directory tree rooted at the specified directory.
	 * @typedef {Object} NOTIFY_INFORMATION
	 * @property {'ADDED'|'REMOVED'|'MODIFIED'|'RENAMED'} action The type of change that has occurred.
	 * @property {String} name The file/dir name relative to the directory.
	 * @property {String|unset} oldName The file/dir name relative to the directory before renaming.
	 */
	__New(dirPath, notifyCallback, notifyFilter := 0x17f, watchSubtree := false) {
		if -1 == this.Ptr := DllCall('CreateFile', 'str', this.dirPath := dirPath, 'uint', 1, 'uint', 7, 'int', 0, 'uint', 3, 'uint', 0x42000000, 'int', 0, 'ptr')
			Throw OSError()
		OVERLAPPED.EnableIoCompletionCallback(this), preName := '', preAction := 0, pFile := this.Ptr, start(this)
		start(this) {
			this.DefineProp('Stop', { call: stop }).DeleteProp('Start')
			buf := Buffer(0x4000), ol := OVERLAPPED(onRead), ol._root := ObjPtr(this), this._overlapped := ol
			if !DllCall('ReadDirectoryChangesW', 'ptr', this, 'ptr', buf, 'uint', buf.Size, 'uint', watchSubtree, 'uint', notifyFilter, 'ptr', 0, 'ptr', ol, 'ptr', 0)
				Throw OSError()
			onRead(ol, err, byte) {
				static ActionName := Array.Prototype.Get.Bind(['ADDED', 'REMOVED', 'MODIFIED', , 'RENAMED'])
				switch err {
					case 0:
					case 0xC0000120:	; STATUS_CANCELLED
						return
					case 0xC0000056:	; STATUS_DELETE_PENDING
						return SetTimer(notifyCallback.Bind(ObjFromPtrAddRef(ol._root), { action: ActionName(2), name: '' }), -1)
					default: Throw OSError(err)
				}
				addr := buf.Ptr, offset := 0, _this := ObjFromPtrAddRef(ol._root)
				loop {
					addr += offset, action := NumGet(addr + 4, 'uint'), name := StrGet(addr + 12, NumGet(addr + 8, 'uint') >> 1, 'utf-16')
					if action == 5 && preAction == 4
						SetTimer(notifyCallback.Bind(_this, { action: ActionName(action), name: name, oldName: preName }), -1)
					else if action == preAction && name == preName
						continue
					else if action !== 4
						SetTimer(notifyCallback.Bind(_this, { action: ActionName(action), name: name }), -1)
					preName := name, preAction := action
				} until !offset := NumGet(addr, 'uint')
				if !DllCall('ReadDirectoryChangesW', 'ptr', pFile, 'ptr', buf, 'uint', buf.Size, 'uint', watchSubtree, 'uint', notifyFilter, 'ptr', 0, 'ptr', ol, 'ptr', 0)
					Throw OSError()
			}
		}
		stop(this) => DllCall('CancelIoEx', 'ptr', this.DefineProp('Start', { call: start }), 'ptr', this._overlapped)
	}
	__Delete() {
		if this.Ptr == -1
			return
		this._overlapped.SafeDelete(this)
		DllCall('CloseHandle', 'ptr', this)
		this.Ptr := -1
	}
	Start() => 0
	Stop() => 0
	; @lint-disable class-non-dynamic-member-check
}
#Include <OVERLAPPED>