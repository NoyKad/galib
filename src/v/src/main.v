module main

import rand


fn init_individual(size int) ![]u8 {

	mut chromosome := []u8{len: size}

	for	i in 0 .. size {
		chromosome[i] = u8(rand.binomial(1, 0.5)!)
	}

	return chromosome

}

fn main() {

	a := init_individual(10)!
	println(a)

}
