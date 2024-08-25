class_name FractionFormatter

var value: float;

var numerator:      int = 0;
var denominator:    int = 0;
var maxDenominator: int = 16;

func _init(value: float):
	self.value = value;
	reduce();

func set_max_denominator(maxDenominator: int):
	self.maxDenominator = maxDenominator;
	reduce();

func reduce():
	var n: int;
	var d: int;
	
	var percision: int = self.maxDenominator;
	
	n = int(round(value * float(percision)));
	d = percision;
	
	var reducedNumerator:   int = n;
	var reducedDenominator: int = d;
	var temp:               int = 0;
	
	while reducedDenominator != 0:
		temp = reducedNumerator % reducedDenominator;
		reducedNumerator   = reducedDenominator;
		reducedDenominator = temp;
	
	n /= reducedNumerator;
	d /= reducedNumerator;
	
	if n == d:
		n = 0;
	
	self.numerator   = n;
	self.denominator = d;


# MARK: - Getters

func to_string():
	return(str(numerator) + "/" + str(denominator));

func numerator_to_string():
	return str(numerator);

func denominator_to_string():
	return str(denominator);
