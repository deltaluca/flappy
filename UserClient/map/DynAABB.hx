package map;

//mostly copy-pasted from Nape (https://github.com/deltaluca/nape)
//to avoid having to include the whole project

//An AABB tree for use in mouse selection of provinces.

import map.AABB;
import nme.geom.Point;

class AABBNode<T> {
	public var aabb:AABB;

	//tree links
	public var parent:AABBNode<T>;
	public var child1:AABBNode<T>;
	public var child2:AABBNode<T>;
	
	//sub-tree height
	public var height:Int;

	public var data:T;

	public function new(data:T=null) {
		height = -1;
		aabb = new AABB();
		this.data = data;
	}

	public inline function isLeaf() return child1==null
}

class AABBTree<T> {
	public var root:AABBNode<T>;
	public function new() {}

	static var tmpaabb = new AABB();
	public function insertLeaf(leaf:AABBNode<T>) {
	   if(root==null) {
            root = leaf;
            root.parent = null;
        }else {
            var leafaabb = leaf.aabb;
            var node = root;
            while(!node.isLeaf()) {
                var child1 = node.child1;
                var child2 = node.child2;
                
                var area = node.aabb.perimeter();
                tmpaabb.set_combine(node.aabb,leafaabb);
                var carea = tmpaabb.perimeter();
                
                //cost of creating a new parent for this node and the new leaf
                var cost = 2*carea;
                //min. cost of pushing the leaf further down the tree
                var icost = 2*(carea - area);
                
                //cost of descending into child
				function cost_descend(child:AABBNode<T>) {
					tmpaabb.set_combine(leafaabb,child.aabb);
                    if(child.isLeaf()) return tmpaabb.perimeter() + icost;
                    else {
                        var oarea = child.aabb.perimeter();
                        var narea = tmpaabb.perimeter();
                        return (narea - oarea) + icost;
                    }
                }
                var cost1 = cost_descend(child1);
                var cost2 = cost_descend(child2);
                
                //descend according to min. cost
                if(cost < cost1 && cost < cost2) break;
                else node = cost1 < cost2 ? child1 : child2;
            }
            
            var sibling = node;
            
            //create a new parent
            var oparent = sibling.parent;
            var nparent = new AABBNode<T>();
            nparent.parent = oparent;
            nparent.aabb.set_combine(leafaabb,sibling.aabb);
            nparent.height = sibling.height + 1;
            
            if(oparent != null) {
                //sibling not the root
                if(oparent.child1 == sibling)
                     oparent.child1 = nparent;
                else oparent.child2 = nparent;
                
                nparent.child1 = sibling;
                nparent.child2 = leaf;
                sibling.parent = nparent;
                leaf.parent = nparent;
            }else {
                //sibling is the root.
                nparent.child1 = sibling;
                nparent.child2 = leaf;
                sibling.parent = nparent;
                leaf.parent = nparent;
                root = nparent;
            }
            
            //walk back up the tree fixing heights and aabbs
            node = leaf.parent;
            while(node != null) {
                node = balance(node);
                
                var child1 = node.child1;
                var child2 = node.child2;
                node.height = 1 + (child1.height > child2.height ? child1.height : child2.height);
                node.aabb.set_combine(child1.aabb,child2.aabb);
                
                node = node.parent;
            }
        }
	}	
	
	//don't need to remove leaves (except for cleaing) so no need to implement it
	//if needed can be mostly copy-pasted from nape as with insertion

	public function balance(a:AABBNode<T>) {
		if(a.isLeaf() || a.height < 2) return a;
        else {
            var b = a.child1;
            var c = a.child2;
            
            //rotate b or c up, with childN corresponding to child1/child2 for b/c
			function rotate_up(rot:AABBNode<T>, other:AABBNode<T>, childN:Int) {
                var f = rot.child1;
                var g = rot.child2;
                
                //swap a<->rot
                rot.child1 = a;
                rot.parent = a.parent;
                a.parent = rot;
                
                //a's old parent should point to rot
                if(rot.parent != null) {
                    if(rot.parent.child1 == a)
                         rot.parent.child1 = rot;
                    else rot.parent.child2 = rot;
                }else root = rot;
                
                //rotate
				function rotate(f:AABBNode<T>, g:AABBNode<T>) {
                    rot.child2 = f;
                    if(childN==1) a.child1 = g else a.child2 = g;
                    g.parent = a;
                    a.aabb.set_combine(other.aabb,g.aabb);
                    rot.aabb.set_combine(a.aabb,    f.aabb);
                    
                    a.height = 1 + (other.height > g.height ? other.height : g.height);
                    rot.height = 1 + (a.height > f.height ? a.height : f.height);
                }
                if(f.height > g.height)
                     rotate(f,g);
                else rotate(g,f);
                
                return rot;
            }
            
            var balance = c.height - b.height;
            return if(balance > 1) rotate_up(c,b,2);
            else if(balance <-1) rotate_up(b,c,1);
            else a;
        }
	}

	//addition for flappy:
	public function traverse<R>(xy:Point, success:T->R):R {
		//since AABB subtrees can overlap, we do still need recursion/stack.

		var stack =	[];
		if(root!=null && root.aabb.contains(xy)) stack.push(root);

		while(stack.length>0) {
			var cur = stack.pop();
			if(cur.isLeaf()) {
				var ret = success(cur.data);

				//since we've assumed map regions do not overlap
				//we can assume that success(x)!=null && success(y)!=null <=> x==y
				if(ret!=null) return ret;
			}else {
				if(cur.child1!=null && cur.child1.aabb.contains(xy)) stack.push(cur.child1);
				if(cur.child2!=null && cur.child2.aabb.contains(xy)) stack.push(cur.child2);
			}
		}
	
		return null;
	}
}
