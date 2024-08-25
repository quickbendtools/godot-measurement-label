@tool
extends HBoxContainer

class_name MeasurementLabel

enum Type {
	## An Integar value. X
	INT,
	
	## A decimal value. X.XX
	DECIMAL,
	
	## A value that represent an angle. X.X°
	DEGREE,
	
	## A value that represent an inch. # ##/##''
	INCH,
	
	## A Value that represents a Foot / Inch. #' # ##/##''
	FT_INCH,
	
	## A Value that value may need to be displayed by a fraction.
	## Such as cups. ::shrug::
	FRACTION
}

@export_category("Label")

## Indicates the value that the label should represent.
@export var value: float :
	set(v):
		value = v;
		setup_label();

## The Type of measurement.
@export var type: Type :
	set(t):
		type = t;
		setup_label();

## The text color of the label. By default this value is White.
@export var textColor: Color = Color.WHITE :
	set(color):
		textColor = color;
		setup_label();

## The font size of the label
@export var fontSize: int = 24 :
	set(s):
		fontSize = s;
		setup_label();

@export_category("Accents")

## The prefix of the measurement (Empty by default).
@export var prefix: String :
	set(string):
		prefix = string;
		setup_label();

## The suffix of the measurement (Empty by default).
@export var suffix: String :
	set(string):
		suffix = string;
		setup_label();

## The Accent Color of the label. This will be used for the prefix, suffix, and / or special characters.
@export var accentColor: Color = Color(Color.WHITE, 0) :
	set(color):
		accentColor = color;
		setup_label();

@export_category("Rounding")

## The amount to round to. This value by default is at 0.01, and is based on if you're using `Decimal`, or not.
##
## If you're not using decimal than ignore this value as it's not necessary.
@export var roundEvery: float = 0.01 :
	set(r):
		roundEvery = r;
		setup_label();

## The maximum length of the decimals.
@export var maxLength: int = 2 :
	set(length):
		maxLength = length;
		setup_label();

# Called when the node enters the scene tree for the first time.
func _ready():
	add_theme_constant_override("separation", 0)
	setup_label();



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup_label():
	for child in get_children():
		child.free();
	
	match type:
		Type.INT:
			build_int();
		Type.DECIMAL:
			build_decimal();
		Type.DEGREE:
			build_degree();
		Type.INCH:
			build_inch();
		Type.FT_INCH:
			build_ft_inch();
		Type.FRACTION:
			build_fraction();
		_:
			print("'tis not.")
	

#
#MARK: - Getters
#

func get_font_size() -> int:
	return fontSize * DisplayServer.screen_get_scale();

#
#MARK: - Builders
#

func build_int():
	if prefix != "":
		add_special_label(prefix);
	
	add_label(str(int(value)));
	
	if suffix != "":
		add_special_label(suffix);

func build_decimal():
	if prefix != "":
		add_special_label(prefix);
	
	add_label(str(rounding(value, roundEvery)).pad_decimals(maxLength));
	
	if suffix != "":
		add_special_label(suffix);

func build_degree():
	add_label(str(rounding(value, 0.1)).pad_decimals(1));
	add_special_label("°");

func build_inch():
	var inchValue = int(value);
	var fracValue = value - int(value);
	
	add_label(str(inchValue));
	
	add_fraction_label(fracValue);
	
	add_special_label("''");

func build_ft_inch():
	var ftValue   = int(int(value) / 12);
	var inchValue = int(value - (ftValue * 12));
	
	var fracValue = value - int(value);
	
	if ftValue != 0:
		add_label(str(ftValue));
		add_special_label("' ");

	add_label(str(inchValue));
	
	add_fraction_label(fracValue);
	
	add_special_label("''");

func build_fraction():
	var wholeValue = int(value);
	var fracValue  = value - wholeValue;
	
	add_special_label(prefix);
	
	add_label(str(wholeValue));
	
	if fracValue != 0:
		add_fraction_label(fracValue);
	
	add_special_label(suffix);

#
# MARK: - Add Child
#

func add_label(text: String, color: Color = textColor):
	var label = Label.new()
	
	label.add_theme_font_size_override("font_size", get_font_size());
	label.add_theme_color_override("font_color", color);
	label.text = text;
	
	add_child(label);

func add_fraction_label(value: float):
	if value == 0: pass;
	
	var fontSize         = get_font_size();
	
	var formatter        = FractionFormatter.new(value);
	var sizeFactor       = 0.5;
	var adjustFactor     = 0.6;
	var separationFactor = 0.2;
	
	var container = CenterContainer.new();
	
	if type == Type.FRACTION:
		formatter.set_max_denominator(1 / roundEvery);
	
	var numeratorContainer = MarginContainer.new();
	numeratorContainer.add_theme_constant_override("margin_left", fontSize * separationFactor);
	numeratorContainer.add_theme_constant_override("margin_right", fontSize * separationFactor);
	numeratorContainer.add_theme_constant_override("margin_bottom", fontSize * adjustFactor);
	
	var numeratorLabel = Label.new();
	numeratorLabel.add_theme_font_size_override("font_size", fontSize * sizeFactor);
	numeratorLabel.add_theme_color_override("font_color", textColor);
	numeratorLabel.text = formatter.numerator_to_string();
	
	var denominatorContainer = MarginContainer.new();
	denominatorContainer.add_theme_constant_override("margin_left", fontSize * separationFactor);
	denominatorContainer.add_theme_constant_override("margin_right", fontSize * separationFactor);
	denominatorContainer.add_theme_constant_override("margin_top", fontSize * adjustFactor);	
	
	var denominatorLabel = Label.new();
	denominatorLabel.add_theme_font_size_override("font_size", fontSize * sizeFactor);
	denominatorLabel.add_theme_color_override("font_color", textColor);
	denominatorLabel.text = formatter.denominator_to_string();
	
	var lineContainer = MarginContainer.new();
	lineContainer.add_theme_constant_override("margin_left", fontSize * separationFactor);
	lineContainer.add_theme_constant_override("margin_right", fontSize * separationFactor);
	
	var line = Line2D.new();
	line.add_point(Vector2(fontSize * -0.1, fontSize * 0.05));
	line.add_point(Vector2(fontSize *  0.5,  0));
	line.antialiased    = true;
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND;
	line.end_cap_mode   = Line2D.LINE_CAP_ROUND;
	line.width          = fontSize * 0.05
	line.default_color  = textColor;
	
	var blankContainer = MarginContainer.new();
	blankContainer.add_theme_constant_override("margin_left", fontSize * separationFactor);
	blankContainer.add_theme_constant_override("margin_right", fontSize * separationFactor);
	
	var blankLabel = Label.new();
	blankLabel.add_theme_font_size_override("font_size", fontSize * sizeFactor);
	blankLabel.add_theme_color_override("font_color", Color(Color.WHITE, 0));
	blankLabel.text = "16";
	
	numeratorContainer.add_child(numeratorLabel)
	container.add_child(numeratorContainer);
	
	denominatorContainer.add_child(denominatorLabel);
	container.add_child(denominatorContainer);
	
	lineContainer.add_child(line);
	container.add_child(lineContainer);
	
	blankContainer.add_child(blankLabel);
	container.add_child(blankContainer);
	
	add_child(container);

func add_special_label(text: String):
	var color = accentColor if accentColor.a != 0 else textColor;
	
	add_label(text, color)

func rounding(v: float, x: float):
	x = abs(x);
	
	return round(v * (1 / x)) / (1 / x);

