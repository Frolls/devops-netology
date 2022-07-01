package main

import (
	"errors"
	"fmt"
)

func Min(vals []int) (int, error) {
	if len(vals) == 0 {
		return -1, errors.New("Achtung! Empty slice")
	}
	min := vals[0]
	for _, v := range vals {
		if v < min {
			min = v
		}
	}
	return min, nil
}

func main() {
	x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}

	fmt.Println(Min(x))
}
