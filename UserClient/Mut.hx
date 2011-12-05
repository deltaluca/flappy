package;

import cpp.vm.Mutex;
import cpp.vm.Thread;

class Mut<T> {
	var mut:Mutex;
	var value:T;

	public function new(value:T) {
		this.value = value;
		this.mut = new Mutex();
	}

	public inline function with<S>(action:T->S) {
		mut.acquire();
		var ret = action(value);
		mut.release();
		return ret;
	}
	public inline function without(action:T->Void)  {
		mut.acquire();
		action(value);
		mut.release();
	}
}
