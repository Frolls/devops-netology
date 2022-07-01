package main

import "fmt"

const Scale = 0.3048

func metersToFoot(m float64) float64 {
	return m / Scale
}

func main() {
	fmt.Print("Введите длину в метрах: ")
	var input float64
	fmt.Scanf("%f", &input)
	fmt.Println(input, " м == ", metersToFoot(input), " ft.")
}
