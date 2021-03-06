package;

///forced synchronisation for shared data.
import cpp.vm.Mutex;
class Mut<T> {
	var mut:Mutex;
	var value:T;

	public function new(value:T) {
		this.value = value;
		mut = new Mutex();
	}

	public inline function set(value:T) {
		mut.acquire();
		this.value = value;
		mut.release();
	}

	public inline function with<S>(action:T->S) {
		mut.acquire();
		var ret = action(value);
		mut.release();
		return ret;
	}
}
