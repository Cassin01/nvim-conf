package main

import (
	"fmt"
	"sort"
)

func main() {
	var n int
	var k int
	fmt.Scan(&n)
	fmt.Scan(&k)

	rs := make([]int, n)
	for i := 0; i < n; i++ {
		fmt.Scan(&rs[i])
	}

	sort.Sort(sort.Reverse(sort.IntSlice(rs)))

	fmt.Printf("%v\n", ans)
}
