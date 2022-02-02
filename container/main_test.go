package main

import (
	"testing"
)

func TestCalc(t *testing.T) {
	inputs := []int64{5, 6, 7, 8}
	outputs := []int64{120, 720, 5040, 40320}
	for i := 0; i < len(inputs); i++ {
		r := calc(inputs[i])
		if r != outputs[i] {
			t.Errorf("Calc method failed! Given: %d, Expected: %d, Got: %d", inputs[i], outputs[i], r)
		}
	}
}
