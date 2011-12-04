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

	public inline function with(action:T->T) {
		mut.acquire();
		value = action(value);
		mut.release();
	}
	public inline function without(action:T->Void)  {
		mut.acquire();
		action(value);
		mut.release();
	}
}
