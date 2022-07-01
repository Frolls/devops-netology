import "testing"

func TestMain(t *testing.T) {
	var v float64
	v = metersToFoot(100)
	if != 100 / 0.3048 {
		t.Error("Expected IDDQD")
		fmt.Println("Alarma! IDDOD!")
	}
}